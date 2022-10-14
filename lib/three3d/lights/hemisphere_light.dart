part of three_lights;

class HemisphereLight extends Light {
  HemisphereLight(skyColor, groundColor, [double intensity = 1.0])
      : super(skyColor, intensity) {
    type = 'HemisphereLight';

    position.copy(Object3D.DefaultUp);

    isHemisphereLight = true;
    updateMatrix();

    if (groundColor is Color) {
      this.groundColor = groundColor;
    } else if (groundColor is int) {
      this.groundColor = Color.fromHex(groundColor);
    } else {
      throw ("HemisphereLight init groundColor type is not support $groundColor ");
    }
  }

  @override
  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    HemisphereLight source1 = source as HemisphereLight;

    groundColor!.copy(source1.groundColor!);

    return this;
  }
}
