part of three_lights;

class PointLightShadow extends LightShadow {
  late List<Vector3> _cubeDirections;
  late List<Vector3> _cubeUps;

  PointLightShadow() : super(PerspectiveCamera(90, 1, 0.5, 500)) {
    isPointLightShadow = true;
    _frameExtents = Vector2(4, 2);

    _viewportCount = 6;

    _viewports = [
      // These viewports map a cube-map onto a 2D texture with the
      // following orientation:
      //
      //  xzXZ
      //   y Y
      //
      // X - Positive x direction
      // x - Negative x direction
      // Y - Positive y direction
      // y - Negative y direction
      // Z - Positive z direction
      // z - Negative z direction

      // positive X
      Vector4(2, 1, 1, 1),
      // negative X
      Vector4(0, 1, 1, 1),
      // positive Z
      Vector4(3, 1, 1, 1),
      // negative Z
      Vector4(1, 1, 1, 1),
      // positive Y
      Vector4(3, 0, 1, 1),
      // negative Y
      Vector4(1, 0, 1, 1)
    ];

    _cubeDirections = [
      Vector3(1, 0, 0),
      Vector3(-1, 0, 0),
      Vector3(0, 0, 1),
      Vector3(0, 0, -1),
      Vector3(0, 1, 0),
      Vector3(0, -1, 0)
    ];

    _cubeUps = [
      Vector3(0, 1, 0),
      Vector3(0, 1, 0),
      Vector3(0, 1, 0),
      Vector3(0, 1, 0),
      Vector3(0, 0, 1),
      Vector3(0, 0, -1)
    ];
  }

  PointLightShadow.fromJSON(
      Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    camera = Object3D.castJSON(json["camera"], rootJSON) as Camera;
  }

  @override
  updateMatrices(light, {viewportIndex = 0}) {
    var camera = this.camera;
    var shadowMatrix = matrix;

    var far = light.distance ?? camera!.far;

    if (far != camera!.far) {
      camera.far = far;
      camera.updateProjectionMatrix();
    }

    _lightPositionWorld.setFromMatrixPosition(light.matrixWorld);
    camera.position.copy(_lightPositionWorld);

    _lookTarget.copy(camera.position);
    _lookTarget.add(_cubeDirections[viewportIndex]);
    camera.up.copy(_cubeUps[viewportIndex]);
    camera.lookAt(_lookTarget);
    camera.updateMatrixWorld(false);

    shadowMatrix.makeTranslation(
        -_lightPositionWorld.x, -_lightPositionWorld.y, -_lightPositionWorld.z);

    _projScreenMatrix.multiplyMatrices(
        camera.projectionMatrix, camera.matrixWorldInverse);
    _frustum.setFromProjectionMatrix(_projScreenMatrix);
  }
}
