part of three_lights;

class SpotLight extends Light {
  String type = "SpotLight";
  bool isSpotLight = true;

  SpotLight(color, [intensity, num? distance, angle, penumbra, decay])
      : super(color, intensity) {
    this.position.copy(Object3D.DefaultUp);
    this.updateMatrix();

    this.target = new Object3D();

    // remove default 0  for js 0 is false  but for dart 0 is not.
    // SpotLightShadow.updateMatrices  far value
    this.distance = distance;
    this.angle = angle ?? Math.PI / 3;
    this.penumbra = penumbra ?? 0;
    this.decay = decay ?? 1; // for physically correct lights, should be 2.

    this.shadow = new SpotLightShadow();
  }

  get power {
    return this.intensity * Math.PI;
  }

  set power(value) {
    this.intensity = value / Math.PI;
  }

  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    SpotLight source1 = source as SpotLight;

    this.distance = source1.distance;
    this.angle = source1.angle;
    this.penumbra = source1.penumbra;
    this.decay = source1.decay;

    this.target = source1.target!.clone();

    this.shadow = source1.shadow!.clone();

    return this;
  }

  dispose() {
    this.shadow!.dispose();
  }
}
