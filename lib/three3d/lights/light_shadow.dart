
import 'package:flutter/foundation.dart';
import 'package:three_dart/three3d/cameras/camera.dart';
import 'package:three_dart/three3d/lights/light.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/renderers/web_gl_render_target.dart';

class LightShadow {
  Camera? camera;

  num bias = 0;
  num normalBias = 0;
  num radius = 1;
  num blurSamples = 8;

  Vector2 mapSize = Vector2(512, 512);

  RenderTarget? map;
  RenderTarget? mapPass;
  Matrix4 matrix = Matrix4();

  bool autoUpdate = true;
  bool needsUpdate = false;

  final Frustum _frustum = Frustum(null, null, null, null, null, null);

  @protected
  late Vector2 frameExtents;

  @protected
  late num viewportCount;

  @protected
  late List<Vector4> viewports;

  final Matrix4 _projScreenMatrix = Matrix4();
  final Vector3 _lightPositionWorld = Vector3.init();
  final Vector3 _lookTarget = Vector3.init();

  late num focus;

  LightShadow(this.camera) {
    frameExtents = Vector2(1, 1);
    viewportCount = 1;
    viewports = [Vector4(0, 0, 1, 1)];
  }

  LightShadow.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON);

  num getViewportCount() {
    return viewportCount;
  }

  Frustum getFrustum() {
    return _frustum;
  }

  void updateMatrices(Light light, {int viewportIndex = 0}) {
    var shadowCamera = camera;
    var shadowMatrix = matrix;

    var lightPositionWorld = _lightPositionWorld;

    lightPositionWorld.setFromMatrixPosition(light.matrixWorld);
    shadowCamera!.position.copy(lightPositionWorld);

    _lookTarget.setFromMatrixPosition(light.target!.matrixWorld);
    shadowCamera.lookAt(_lookTarget);
    shadowCamera.updateMatrixWorld(false);

    _projScreenMatrix.multiplyMatrices(shadowCamera.projectionMatrix, shadowCamera.matrixWorldInverse);
    _frustum.setFromProjectionMatrix(_projScreenMatrix);

    shadowMatrix.set(0.5, 0.0, 0.0, 0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0, 1.0);

    shadowMatrix.multiply(shadowCamera.projectionMatrix);
    shadowMatrix.multiply(shadowCamera.matrixWorldInverse);
  }

  Vector4 getViewport(int viewportIndex) {
    return viewports[viewportIndex];
  }

  Vector2 getFrameExtents() {
    return frameExtents;
  }

  LightShadow copy(LightShadow source) {
    camera = source.camera?.clone();

    bias = source.bias;
    radius = source.radius;

    mapSize.copy(source.mapSize);

    return this;
  }

  LightShadow clone() {
    return LightShadow(null).copy(this);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> object = {};

    if (bias != 0) object["bias"] = bias;
    if (normalBias != 0) object["normalBias"] = normalBias;
    if (radius != 1) object["radius"] = radius;
    if (mapSize.x != 512 || mapSize.y != 512) {
      object["mapSize"] = mapSize.toArray();
    }

    object["camera"] = camera!.toJSON()["object"];

    return object;
  }

  void dispose() {
    if (map != null) {
      map!.dispose();
    }

    if (mapPass != null) {
      mapPass!.dispose();
    }
  }
}
