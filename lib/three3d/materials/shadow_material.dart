import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/materials/material.dart';
import 'package:three_dart/three3d/math/index.dart';

class ShadowMaterial extends Material {
  ShadowMaterial([parameters]) : super() {
    type = 'ShadowMaterial';
    color = Color.fromHex(0x000000);
    transparent = true;
    fog = true;
    setValues(parameters);
  }

  @override
  ShadowMaterial copy(Material source) {
    super.copy(source);

    color.copy(source.color);
    fog = source.fog;
    return this;
  }

  @override
  ShadowMaterial clone() {
    return ShadowMaterial().copy(this);
  }
}
