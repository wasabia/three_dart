part of three_lights;

class DirectionalLight extends Light {
  @override
  String type = "DirectionalLight";
  bool isDirectionalLight = true;

  DirectionalLight(color, [intensity]) : super(color, intensity) {
    position.copy(Object3D.DefaultUp);
    updateMatrix();

    target = Object3D();

    shadow = DirectionalLightShadow();
  }

  @override
  copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);

    DirectionalLight source1 = source as DirectionalLight;

    target = source1.target!.clone(false);

    shadow = source1.shadow!.clone();

    return this;
  }

  @override
  dispose() {
    shadow!.dispose();
  }
}
