part of three_scenes;

class FogExp2 extends FogBase {
  bool isFogExp2 = true;
  late num density;

  FogExp2(color, density) {
    this.name = '';

    if (color is int) {
      this.color = Color(0, 0, 0).setHex(color);
    } else if (color is Color) {
      this.color = color;
    } else {
      throw (" Fog color type: ${color.runtimeType} is not support ... ");
    }

    this.density = (density != null) ? density : 0.00025;
  }

  clone() {
    return new FogExp2(this.color, this.density);
  }

  toJSON(/* meta */) {
    return {
      "type": 'FogExp2',
      "color": this.color.getHex(),
      "density": this.density
    };
  }
}
