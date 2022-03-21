part of three_lights;

class SpotLightShadow extends LightShadow {
  @override
  bool isSpotLightShadow = true;

  SpotLightShadow() : super(PerspectiveCamera(50, 1, 0.5, 500)) {
    focus = 1;
  }

  @override
  updateMatrices(light, {int viewportIndex = 0}) {
    PerspectiveCamera camera = this.camera as PerspectiveCamera;

    var fov = MathUtils.RAD2DEG * 2 * light.angle * focus;
    var aspect = mapSize.width / mapSize.height;
    var far = light.distance ?? camera.far;

    if (fov != camera.fov || aspect != camera.aspect || far != camera.far) {
      camera.fov = fov;
      camera.aspect = aspect;
      camera.far = far;
      camera.updateProjectionMatrix();
    }

    super.updateMatrices(light, viewportIndex: viewportIndex);
  }

  @override
  copy(source) {
    super.copy(source);

    focus = source.focus;

    return this;
  }
}
