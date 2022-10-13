part of three_scenes;

class FogBase {
  String name = "";
  late Color color;

  bool isFog = false;
  bool isFogExp2 = false;

  toJSON() {
    throw(" need implement .... ");
  }

}

class Fog extends FogBase {

  @override
  bool isFog = true;

  late num near;
  late num far;

  Fog(color, num? near, num? far) {
    name = '';

    if (color is int) {
      this.color = Color(0, 0, 0).setHex(color);
    } else if (color is Color) {
      this.color = color;
    } else {
      throw (" Fog color type: ${color.runtimeType} is not support ... ");
    }

    this.near = near ?? 1;
    this.far = far ?? 1000;
  }

  clone() {
    return Fog(color, near, far);
  }

  @override
  toJSON(/* meta */) {
    return {
      "type": 'Fog',
      "color": color.getHex(),
      "near": near,
      "far": far
    };
  }
}
