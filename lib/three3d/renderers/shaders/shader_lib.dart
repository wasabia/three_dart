import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/shaders/shader_chunk.dart';
import 'package:three_dart/three3d/renderers/shaders/uniforms_lib.dart';
import 'package:three_dart/three3d/renderers/shaders/uniforms_utils.dart';

Map<String, dynamic> shaderLibStandard = {
  "uniforms": mergeUniforms([
    uniformsLib["common"],
    uniformsLib["envmap"],
    uniformsLib["aomap"],
    uniformsLib["lightmap"],
    uniformsLib["emissivemap"],
    uniformsLib["bumpmap"],
    uniformsLib["normalmap"],
    uniformsLib["displacementmap"],
    uniformsLib["roughnessmap"],
    uniformsLib["metalnessmap"],
    uniformsLib["fog"],
    uniformsLib["lights"],
    {
      "emissive": {"value": Color(0, 0, 0)},
      "roughness": {"value": 1.0},
      "metalness": {"value": 0.0},
      "envMapIntensity": {"value": 1} // temporary
    }
  ]),
  "vertexShader": shaderChunk["meshphysical_vert"],
  "fragmentShader": shaderChunk["meshphysical_frag"]
};

Map<String, dynamic> shaderLib = {
  "basic": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["specularmap"],
      uniformsLib["envmap"],
      uniformsLib["aomap"],
      uniformsLib["lightmap"],
      uniformsLib["fog"]
    ]),
    "vertexShader": shaderChunk["meshbasic_vert"],
    "fragmentShader": shaderChunk["meshbasic_frag"]
  },
  "lambert": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["specularmap"],
      uniformsLib["envmap"],
      uniformsLib["aomap"],
      uniformsLib["lightmap"],
      uniformsLib["emissivemap"],
      uniformsLib["fog"],
      uniformsLib["lights"],
      {
        "emissive": {"value": Color.fromHex(0x000000)}
      }
    ]),
    "vertexShader": shaderChunk["meshlambert_vert"],
    "fragmentShader": shaderChunk["meshlambert_frag"]
  },
  "phong": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["specularmap"],
      uniformsLib["envmap"],
      uniformsLib["aomap"],
      uniformsLib["lightmap"],
      uniformsLib["emissivemap"],
      uniformsLib["bumpmap"],
      uniformsLib["normalmap"],
      uniformsLib["displacementmap"],
      uniformsLib["fog"],
      uniformsLib["lights"],
      {
        "emissive": {"value": Color.fromHex(0x000000)},
        "specular": {"value": Color.fromHex(0x111111)},
        "shininess": {"value": 30}
      }
    ]),
    "vertexShader": shaderChunk["meshphong_vert"],
    "fragmentShader": shaderChunk["meshphong_frag"]
  },
  "standard": shaderLibStandard,
  "toon": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["aomap"],
      uniformsLib["lightmap"],
      uniformsLib["emissivemap"],
      uniformsLib["bumpmap"],
      uniformsLib["normalmap"],
      uniformsLib["displacementmap"],
      uniformsLib["gradientmap"],
      uniformsLib["fog"],
      uniformsLib["lights"],
      {
        "emissive": {"value": Color.fromHex(0x000000)}
      }
    ]),
    "vertexShader": shaderChunk["meshtoon_vert"],
    "fragmentShader": shaderChunk["meshtoon_frag"]
  },
  "matcap": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["bumpmap"],
      uniformsLib["normalmap"],
      uniformsLib["displacementmap"],
      uniformsLib["fog"],
      {
        "matcap": {"value": null}
      }
    ]),
    "vertexShader": shaderChunk["meshmatcap_vert"],
    "fragmentShader": shaderChunk["meshmatcap_frag"]
  },
  "points": {
    "uniforms": mergeUniforms([uniformsLib["points"], uniformsLib["fog"]]),
    "vertexShader": shaderChunk["points_vert"],
    "fragmentShader": shaderChunk["points_frag"]
  },
  "dashed": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["fog"],
      {
        "scale": {"value": 1},
        "dashSize": {"value": 1},
        "totalSize": {"value": 2}
      }
    ]),
    "vertexShader": shaderChunk["linedashed_vert"],
    "fragmentShader": shaderChunk["linedashed_frag"]
  },
  "depth": {
    "uniforms": mergeUniforms([uniformsLib["common"], uniformsLib["displacementmap"]]),
    "vertexShader": shaderChunk["depth_vert"],
    "fragmentShader": shaderChunk["depth_frag"]
  },
  "normal": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["bumpmap"],
      uniformsLib["normalmap"],
      uniformsLib["displacementmap"],
      {
        "opacity": {"value": 1.0}
      }
    ]),
    "vertexShader": shaderChunk["meshnormal_vert"],
    "fragmentShader": shaderChunk["meshnormal_frag"]
  },
  "sprite": {
    "uniforms": mergeUniforms([uniformsLib["sprite"], uniformsLib["fog"]]),
    "vertexShader": shaderChunk["sprite_vert"],
    "fragmentShader": shaderChunk["sprite_frag"]
  },
  "background": {
    "uniforms": {
      "uvTransform": {"value": Matrix3()},
      "t2D": {"value": null},
    },
    "vertexShader": shaderChunk["background_vert"],
    "fragmentShader": shaderChunk["background_frag"]
  },
  /* -------------------------------------------------------------------------
	//	Cube map shader
	 ------------------------------------------------------------------------- */

  "cube": {
    "uniforms": mergeUniforms([
      uniformsLib["envmap"],
      {
        "opacity": {"value": 1.0}
      }
    ]),
    "vertexShader": shaderChunk["cube_vert"],
    "fragmentShader": shaderChunk["cube_frag"]
  },
  "equirect": {
    "uniforms": {
      "tEquirect": {"value": null},
    },
    "vertexShader": shaderChunk["equirect_vert"],
    "fragmentShader": shaderChunk["equirect_frag"]
  },
  "distanceRGBA": {
    "uniforms": mergeUniforms([
      uniformsLib["common"],
      uniformsLib["displacementmap"],
      {
        "referencePosition": {"value": Vector3.init()},
        "nearDistance": {"value": 1},
        "farDistance": {"value": 1000}
      }
    ]),
    "vertexShader": shaderChunk["distanceRGBA_vert"],
    "fragmentShader": shaderChunk["distanceRGBA_frag"]
  },
  "shadow": {
    "uniforms": mergeUniforms([
      uniformsLib["lights"],
      uniformsLib["fog"],
      {
        "color": {"value": Color.fromHex(0x000000)},
        "opacity": {"value": 1.0}
      },
    ]),
    "vertexShader": shaderChunk["shadow_vert"],
    "fragmentShader": shaderChunk["shadow_frag"]
  },
  "physical": {
    "uniforms": mergeUniforms([
      shaderLibStandard["uniforms"],
      {
        "clearcoat": {"value": 0},
        "clearcoatMap": {"value": null},
        "clearcoatRoughness": {"value": 0},
        "clearcoatRoughnessMap": {"value": null},
        "clearcoatNormalScale": {"value": Vector2(1, 1)},
        "clearcoatNormalMap": {"value": null},
        "sheenColor": {"value": Color.fromHex(0x000000)},
        "sheenColorMap": {},
        "sheenRoughness": {"value": 1.0},
        "sheenRoughnessMap": {},
        "transmission": {"value": 0},
        "transmissionMap": {"value": null},
        "transmissionSamplerSize": {"value": Vector2(null, null)},
        "transmissionSamplerMap": {"value": null},
        "thickness": {"value": 0},
        "thicknessMap": {"value": null},
        "attenuationDistance": {"value": 0},
        "attenuationColor": {"value": Color.fromHex(0x000000)},
        "specularIntensity": {"value": 1.0},
        "specularIntensityMap": {"value": null},
        "specularColor": {"value": Color(1, 1, 1)},
        "specularColorMap": {"value": null}
      }
    ]),
    "vertexShader": shaderChunk["meshphysical_vert"],
    "fragmentShader": shaderChunk["meshphysical_frag"]
  }
};
