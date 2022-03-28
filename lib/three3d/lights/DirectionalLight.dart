part of three_lights;

class DirectionalLight extends Light {
  bool isDirectionalLight = true;

  DirectionalLight(color, [intensity]) : super(color, intensity) {
    type = "DirectionalLight";
    position.copy(Object3D.DefaultUp);
    updateMatrix();
    target = Object3D();
    shadow = DirectionalLightShadow();
  }

  @override
  DirectionalLight copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);

    if (source is DirectionalLight) {
      target = source.target!.clone(false);
      shadow = source.shadow!.clone();
    }
    return this;
  }

  @override
  void dispose() {
    shadow!.dispose();
  }
}
