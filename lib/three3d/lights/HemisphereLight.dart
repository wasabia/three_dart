part of three_lights;

class HemisphereLight extends Light {
  HemisphereLight(skyColor, groundColor, [double intensity = 1.0])
      : super(skyColor, intensity) {
    this.type = 'HemisphereLight';

    this.position.copy(Object3D.DefaultUp);

    this.isHemisphereLight = true;
    this.updateMatrix();

    if (groundColor is Color) {
      this.groundColor = groundColor;
    } else if (groundColor is int) {
      this.groundColor = Color.fromHex(groundColor);
    } else {
      throw ("HemisphereLight init groundColor type is not support ${groundColor} ");
    }
  }

  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    HemisphereLight source1 = source as HemisphereLight;

    this.groundColor!.copy(source1.groundColor!);

    return this;
  }
}
