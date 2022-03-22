part of three_lights;

class SpotLight extends Light {
  SpotLight(color, [intensity, num? distance, angle, penumbra, decay])
      : super(color, intensity) {
    type = "SpotLight";
    isSpotLight = true;
    position.copy(Object3D.DefaultUp);
    updateMatrix();

    target = Object3D();

    // remove default 0  for js 0 is false  but for dart 0 is not.
    // SpotLightShadow.updateMatrices  far value
    this.distance = distance;
    this.angle = angle ?? Math.PI / 3;
    this.penumbra = penumbra ?? 0;
    this.decay = decay ?? 1; // for physically correct lights, should be 2.

    shadow = SpotLightShadow();
  }

  double get power {
    return intensity * Math.PI;
  }

  set power(double value) {
    intensity = value / Math.PI;
  }

  @override
  SpotLight copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    SpotLight source1 = source as SpotLight;

    distance = source1.distance;
    angle = source1.angle;
    penumbra = source1.penumbra;
    decay = source1.decay;

    target = source1.target!.clone();

    shadow = source1.shadow!.clone();

    return this;
  }

  @override
  void dispose() {
    shadow!.dispose();
  }
}
