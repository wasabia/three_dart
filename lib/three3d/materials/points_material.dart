import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/materials/material.dart';
import 'package:three_dart/three3d/math/index.dart';

class PointsMaterial extends Material {
  PointsMaterial([Map<String, dynamic>? parameters]) {
    type = "PointsMaterial";
    sizeAttenuation = true;
    color = Color(1, 1, 1);
    size = 1;

    fog = true;

    setValues(parameters);
  }

  @override
  PointsMaterial copy(Material source) {
    super.copy(source);
    color.copy(source.color);

    map = source.map;
    alphaMap = source.alphaMap;
    size = source.size;
    sizeAttenuation = source.sizeAttenuation;

    fog = source.fog;

    return this;
  }
}
