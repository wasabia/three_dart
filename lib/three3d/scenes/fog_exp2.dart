
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/scenes/fog.dart';

class FogExp2 extends FogBase {
  @override
  bool isFogExp2 = true;
  late num density;

  FogExp2(color, density) {
    name = '';

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
    return FogExp2(color, density);
  }

  @override
  toJSON(/* meta */) {
    return {
      "type": 'FogExp2',
      "color": color.getHex(),
      "density": density
    };
  }
}
