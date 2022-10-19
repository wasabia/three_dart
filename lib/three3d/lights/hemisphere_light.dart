import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/lights/light.dart';
import 'package:three_dart/three3d/math/color.dart';

class HemisphereLight extends Light {
  HemisphereLight(skyColor, groundColor, [double intensity = 1.0]) : super(skyColor, intensity) {
    type = 'HemisphereLight';

    position.copy(Object3D.defaultUp);

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
