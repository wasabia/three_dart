
import 'package:three_dart/three3d/dart_helpers.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/math/color.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/math/matrix4.dart';
import 'package:three_dart/three3d/math/vector2.dart';
import 'package:three_dart/three3d/math/vector3.dart';
import 'package:three_dart/three3d/renderers/shaders/index.dart';
import 'package:three_dart/three3d/renderers/webgl/web_gl_capabilities.dart';
import 'package:three_dart/three3d/renderers/webgl/web_gl_extensions.dart';

class UniformsCache {
  UniformsCache();

  Map<int, Map<String, dynamic>> lights = {};

  Map<String, dynamic> get(light) {
    if (lights[light.id] != null) {
      return lights[light.id]!;
    }

    Map<String, dynamic>? uniforms;

    switch (light.type) {
      case 'DirectionalLight':
        uniforms = {"direction": Vector3.init(), "color": Color(0, 0, 0)};
        break;

      case 'SpotLight':
        uniforms = {
          "position": Vector3.init(),
          "direction": Vector3.init(),
          "color": Color(0, 0, 0),
          "distance": 0,
          "coneCos": 0,
          "penumbraCos": 0,
          "decay": 0
        };
        break;

      case 'PointLight':
        uniforms = {"position": Vector3.init(), "color": Color(1, 1, 1), "distance": 0, "decay": 0};
        break;

      case 'HemisphereLight':
        uniforms = {"direction": Vector3.init(), "skyColor": Color(0, 0, 0), "groundColor": Color(0, 0, 0)};
        break;

      case 'RectAreaLight':
        uniforms = {
          "color": Color(0, 0, 0),
          "position": Vector3.init(),
          "halfWidth": Vector3.init(),
          "halfHeight": Vector3.init()
        };
        break;
    }

    lights[light.id] = uniforms!;

    return uniforms;
  }
}

class ShadowUniformsCache {
  Map<int, Map<String, dynamic>> lights = {};

  get(light) {
    if (lights[light.id] != null) {
      return lights[light.id];
    }

    Map<String, dynamic> uniforms = {};

    switch (light.type) {
      case 'DirectionalLight':
        uniforms = {"shadowBias": 0, "shadowNormalBias": 0, "shadowRadius": 1, "shadowMapSize": Vector2(null, null)};
        break;

      case 'SpotLight':
        uniforms = {"shadowBias": 0, "shadowNormalBias": 0, "shadowRadius": 1, "shadowMapSize": Vector2(null, null)};
        break;

      case 'PointLight':
        uniforms = {
          "shadowBias": 0,
          "shadowNormalBias": 0,
          "shadowRadius": 1,
          "shadowMapSize": Vector2(null, null),
          "shadowCameraNear": 1,
          "shadowCameraFar": 1000
        };
        break;

      // TODO (abelnation): set RectAreaLight shadow uniforms

    }

    lights[light.id] = uniforms;

    return uniforms;
  }
}

var nextVersion = 0;

shadowCastingLightsFirst(Light lightA, Light lightB) {
  return (lightB.castShadow ? 1 : 0) - (lightA.castShadow ? 1 : 0);
}

class WebGLLights {
  late LightState state;
  late UniformsCache cache;
  late ShadowUniformsCache shadowCache;
  late Vector3 vector3;
  late Matrix4 matrix4;
  late Matrix4 matrix42;
  WebGLExtensions extensions;
  WebGLCapabilities capabilities;

  WebGLLights(this.extensions, this.capabilities) {
    cache = UniformsCache();
    shadowCache = ShadowUniformsCache();

    state = LightState({
      "version": 0,
      "hash": {
        "directionalLength": -1,
        "pointLength": -1,
        "spotLength": -1,
        "rectAreaLength": -1,
        "hemiLength": -1,
        "numDirectionalShadows": -1,
        "numPointShadows": -1,
        "numSpotShadows": -1
      },
      "ambient": List<double>.from([0.0, 0.0, 0.0]),
      "probe": [],
      "directional": [],
      "directionalShadow": [],
      "directionalShadowMap": [],
      "directionalShadowMatrix": [],
      "spot": [],
      "spotShadow": [],
      "spotShadowMap": [],
      "spotShadowMatrix": [],
      "rectArea": [],
      "rectAreaLTC1": null,
      "rectAreaLTC2": null,
      "point": [],
      "pointShadow": [],
      "pointShadowMap": [],
      "pointShadowMatrix": [],
      "hemi": []
    });

    for (int i = 0; i < 9; i++) {
      state.probe.add(Vector3.init());
    }

    vector3 = Vector3.init();
    matrix4 = Matrix4();
    matrix42 = Matrix4();
  }

  void setup(List<Light> lights, [bool? physicallyCorrectLights]) {
    num r = 0.0;
    num g = 0.0;
    num b = 0.0;

    for (var i = 0; i < 9; i++) {
      state.probe[i].set(0, 0, 0);
    }

    var directionalLength = 0;
    var pointLength = 0;
    var spotLength = 0;
    var rectAreaLength = 0;
    var hemiLength = 0;

    var numDirectionalShadows = 0;
    var numPointShadows = 0;
    var numSpotShadows = 0;

    lights.sort((a, b) => shadowCastingLightsFirst(a, b));

    // artist-friendly light intensity scaling factor
    num scaleFactor = (physicallyCorrectLights != true) ? Math.PI : 1.0;

    for (var i = 0, l = lights.length; i < l; i++) {
      var light = lights[i];

      var color = light.color!;
      var intensity = light.intensity;
      var distance = light.distance;

      var shadowMap = (light.shadow != null && light.shadow!.map != null) ? light.shadow!.map!.texture : null;

      if (light.type == "AmbientLight") {
        r += color.r * intensity * scaleFactor;
        g += color.g * intensity * scaleFactor;
        b += color.b * intensity * scaleFactor;
      } else if (light.type == "LightProbe") {
        for (var j = 0; j < 9; j++) {
          state.probe[j].addScaledVector(light.sh!.coefficients[j], intensity);
        }
      } else if (light.type == "DirectionalLight") {
        var uniforms = cache.get(light);

        uniforms["color"].copy(light.color).multiplyScalar(light.intensity * scaleFactor);

        if (light.castShadow) {
          var shadow = light.shadow!;

          var shadowUniforms = shadowCache.get(light);

          shadowUniforms["shadowBias"] = shadow.bias;
          shadowUniforms["shadowNormalBias"] = shadow.normalBias;
          shadowUniforms["shadowRadius"] = shadow.radius;
          shadowUniforms["shadowMapSize"] = shadow.mapSize;

          // state.directionalShadow[ directionalLength ] = shadowUniforms;
          listSetter(state.directionalShadow, directionalLength, shadowUniforms);

          // state["directionalShadowMap"][ directionalLength ] = shadowMap;
          listSetter(state.directionalShadowMap, directionalLength, shadowMap);

          // state["directionalShadowMatrix"][ directionalLength ] = light.shadow!.matrix;
          listSetter(state.directionalShadowMatrix, directionalLength, light.shadow!.matrix);

          numDirectionalShadows++;
        }

        // state.directional[ directionalLength ] = uniforms;
        listSetter(state.directional, directionalLength, uniforms);

        directionalLength++;
      } else if (light.type == "SpotLight") {
        var uniforms = cache.get(light);

        uniforms["position"].setFromMatrixPosition(light.matrixWorld);
        uniforms["color"].copy(color).multiplyScalar(intensity * scaleFactor);

        uniforms["distance"] = distance;

        uniforms["coneCos"] = Math.cos(light.angle!);
        uniforms["penumbraCos"] = Math.cos(light.angle! * (1 - light.penumbra!));
        uniforms["decay"] = light.decay;

        if (light.castShadow) {
          var shadow = light.shadow!;

          var shadowUniforms = shadowCache.get(light);

          shadowUniforms["shadowBias"] = shadow.bias;
          shadowUniforms["shadowNormalBias"] = shadow.normalBias;
          shadowUniforms["shadowRadius"] = shadow.radius;
          shadowUniforms["shadowMapSize"] = shadow.mapSize;

          // state.spotShadow[ spotLength ] = shadowUniforms;
          listSetter(state.spotShadow, spotLength, shadowUniforms);

          // state.spotShadowMap[ spotLength ] = shadowMap;
          // print("1 spotShadowMap: ${state.spotShadowMap} ${spotLength} ${shadowMap} ");
          listSetter(state.spotShadowMap, spotLength, shadowMap);

          // state.spotShadowMatrix[ spotLength ] = light.shadow!.matrix;
          listSetter(state.spotShadowMatrix, spotLength, light.shadow!.matrix);

          numSpotShadows++;
        }

        // state.spot[ spotLength ] = uniforms;
        listSetter(state.spot, spotLength, uniforms);

        spotLength++;
      } else if (light.type == "RectAreaLight") {
        var uniforms = cache.get(light);

        // (a) intensity is the total visible light emitted
        //uniforms.color.copy( color ).multiplyScalar( intensity / ( light.width * light.height * Math.PI ) );

        // (b) intensity is the brightness of the light
        uniforms["color"].copy(color).multiplyScalar(intensity);

        uniforms["halfWidth"].set(light.width! * 0.5, 0.0, 0.0);
        uniforms["halfHeight"].set(0.0, light.height! * 0.5, 0.0);

        // state.rectArea[ rectAreaLength ] = uniforms;
        listSetter(state.rectArea, rectAreaLength, uniforms);

        rectAreaLength++;
      } else if (light.type == "PointLight") {
        var uniforms = cache.get(light);

        uniforms["color"].copy(light.color).multiplyScalar(light.intensity * scaleFactor);

        // TODO distance 默认0 ？？
        uniforms["distance"] = light.distance ?? 0;
        uniforms["decay"] = light.decay;

        if (light.castShadow) {
          var shadow = light.shadow!;

          var shadowUniforms = shadowCache.get(light);

          shadowUniforms["shadowBias"] = shadow.bias;
          shadowUniforms["shadowNormalBias"] = shadow.normalBias;
          shadowUniforms["shadowRadius"] = shadow.radius;
          shadowUniforms["shadowMapSize"] = shadow.mapSize;
          shadowUniforms["shadowCameraNear"] = shadow.camera!.near;
          shadowUniforms["shadowCameraFar"] = shadow.camera!.far;

          // state.pointShadow[ pointLength ] = shadowUniforms;
          listSetter(state.pointShadow, pointLength, shadowUniforms);

          // state.pointShadowMap[ pointLength ] = shadowMap;
          listSetter(state.pointShadowMap, pointLength, shadowMap);

          // state.pointShadowMatrix[ pointLength ] = light.shadow!.matrix;
          listSetter(state.pointShadowMatrix, pointLength, light.shadow!.matrix);

          numPointShadows++;
        }

        // state.point[ pointLength ] = uniforms;
        listSetter(state.point, pointLength, uniforms);

        pointLength++;
      } else if (light.type == "HemisphereLight") {
        var uniforms = cache.get(light);

        uniforms["skyColor"].copy(light.color).multiplyScalar(intensity * scaleFactor);
        uniforms["groundColor"].copy(light.groundColor).multiplyScalar(intensity * scaleFactor);

        // state.hemi[ hemiLength ] = uniforms;
        listSetter(state.hemi, hemiLength, uniforms);

        hemiLength++;
      } else {
        throw (" WebGLLigts type: ${light.type} is not support ..... ");
      }
    }

    if (rectAreaLength > 0) {
      if (capabilities.isWebGL2) {
        // WebGL 2

        state.rectAreaLTC1 = UniformsLib["LTC_FLOAT_1"];
        state.rectAreaLTC2 = UniformsLib["LTC_FLOAT_2"];
      } else {
        // WebGL 1

        if (extensions.has('OES_texture_float_linear') == true) {
          state.rectAreaLTC1 = UniformsLib["LTC_FLOAT_1"];
          state.rectAreaLTC2 = UniformsLib["LTC_FLOAT_2"];
        } else if (extensions.has('OES_texture_half_float_linear') == true) {
          state.rectAreaLTC1 = UniformsLib["LTC_HALF_1"];
          state.rectAreaLTC2 = UniformsLib["LTC_HALF_2"];
        } else {
          print('three.WebGLRenderer: Unable to use RectAreaLight. Missing WebGL extensions.');
        }
      }
    }

    state.ambient[0] = r.toDouble();
    state.ambient[1] = g.toDouble();
    state.ambient[2] = b.toDouble();

    var hash = state.hash;

    if (hash["directionalLength"] != directionalLength ||
        hash["pointLength"] != pointLength ||
        hash["spotLength"] != spotLength ||
        hash["rectAreaLength"] != rectAreaLength ||
        hash["hemiLength"] != hemiLength ||
        hash["numDirectionalShadows"] != numDirectionalShadows ||
        hash["numPointShadows"] != numPointShadows ||
        hash["numSpotShadows"] != numSpotShadows) {
      state.directional.length = directionalLength;
      state.spot.length = spotLength;
      state.rectArea.length = rectAreaLength;
      state.point.length = pointLength;
      state.hemi.length = hemiLength;

      state.directionalShadow.length = numDirectionalShadows;
      state.directionalShadowMap.length = numDirectionalShadows;
      state.pointShadow.length = numPointShadows;
      state.pointShadowMap.length = numPointShadows;
      state.spotShadow.length = numSpotShadows;
      state.spotShadowMap.length = numSpotShadows;
      state.directionalShadowMatrix.length = numDirectionalShadows;
      state.pointShadowMatrix.length = numPointShadows;
      state.spotShadowMatrix.length = numSpotShadows;

      hash["directionalLength"] = directionalLength;
      hash["pointLength"] = pointLength;
      hash["spotLength"] = spotLength;
      hash["rectAreaLength"] = rectAreaLength;
      hash["hemiLength"] = hemiLength;

      hash["numDirectionalShadows"] = numDirectionalShadows;
      hash["numPointShadows"] = numPointShadows;
      hash["numSpotShadows"] = numSpotShadows;

      state.version = nextVersion++;
    }
  }

  setupView(List<Light> lights, camera) {
    var directionalLength = 0;
    var pointLength = 0;
    var spotLength = 0;
    var rectAreaLength = 0;
    var hemiLength = 0;

    var viewMatrix = camera.matrixWorldInverse;

    for (var i = 0, l = lights.length; i < l; i++) {
      var light = lights[i];

      if (light.type == "DirectionalLight") {
        var uniforms = state.directional[directionalLength];

        uniforms["direction"].setFromMatrixPosition(light.matrixWorld);
        vector3.setFromMatrixPosition(light.target!.matrixWorld);
        uniforms["direction"].sub(vector3);
        uniforms["direction"].transformDirection(viewMatrix);

        directionalLength++;
      } else if (light.type == "SpotLight") {
        var uniforms = state.spot[spotLength];

        uniforms["position"].setFromMatrixPosition(light.matrixWorld);
        uniforms["position"].applyMatrix4(viewMatrix);

        uniforms["direction"].setFromMatrixPosition(light.matrixWorld);
        vector3.setFromMatrixPosition(light.target!.matrixWorld);
        uniforms["direction"].sub(vector3);
        uniforms["direction"].transformDirection(viewMatrix);

        spotLength++;
      } else if (light.type == "RectAreaLight") {
        var uniforms = state.rectArea[rectAreaLength];

        uniforms["position"].setFromMatrixPosition(light.matrixWorld);
        uniforms["position"].applyMatrix4(viewMatrix);

        // extract local rotation of light to derive width/height half vectors
        matrix42.identity();
        matrix4.copy(light.matrixWorld);
        matrix4.premultiply(viewMatrix);
        matrix42.extractRotation(matrix4);

        uniforms["halfWidth"].set(light.width! * 0.5, 0.0, 0.0);
        uniforms["halfHeight"].set(0.0, light.height! * 0.5, 0.0);

        uniforms["halfWidth"].applyMatrix4(matrix42);
        uniforms["halfHeight"].applyMatrix4(matrix42);

        rectAreaLength++;
      } else if (light.type == "PointLight") {
        var uniforms = state.point[pointLength];

        uniforms["position"].setFromMatrixPosition(light.matrixWorld);
        uniforms["position"].applyMatrix4(viewMatrix);

        pointLength++;
      } else if (light.type == "HemisphereLight") {
        var uniforms = state.hemi[hemiLength];

        uniforms["direction"].setFromMatrixPosition(light.matrixWorld);
        uniforms["direction"].transformDirection(viewMatrix);

        hemiLength++;
      }
    }
  }
}

class LightState {
  late num version;
  late Map<String, num> hash;
  late List<double> ambient;
  late List<Vector3> probe;
  late List directional;
  late List directionalShadow;
  late List directionalShadowMap;
  late List directionalShadowMatrix;
  late List spot;
  late List spotShadow;
  late List spotShadowMap;
  late List spotShadowMatrix;
  late List rectArea;
  late List point;
  late List pointShadow;
  late List pointShadowMap;
  late List pointShadowMatrix;
  late List hemi;
  dynamic rectAreaLTC1;
  dynamic rectAreaLTC2;

  LightState(Map<String, dynamic> json) {
    version = json["version"];
    hash = json["hash"];
    ambient = List<double>.from(json["ambient"]);
    probe = List<Vector3>.from(json["probe"]);
    directional = json["directional"];
    directionalShadow = json["directionalShadow"];
    directionalShadowMap = json["directionalShadowMap"];
    directionalShadowMatrix = json["directionalShadowMatrix"];
    spot = json["spot"];
    spotShadow = json["spotShadow"];
    spotShadowMap = json["spotShadowMap"];
    spotShadowMatrix = json["spotShadowMatrix"];
    rectArea = json["rectArea"];
    point = json["point"];
    pointShadow = json["pointShadow"];
    pointShadowMap = json["pointShadowMap"];
    pointShadowMatrix = json["pointShadowMatrix"];
    hemi = json["hemi"];
  }
}
