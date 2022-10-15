import 'package:three_dart/three3d/materials/line_basic_material.dart';
import 'package:three_dart/three3d/materials/material.dart';

class LineDashedMaterial extends LineBasicMaterial {
  LineDashedMaterial([Map<String, dynamic>? parameters]) : super() {
    type = 'LineDashedMaterial';

    scale = 1;
    dashSize = 3;
    gapSize = 1;

    setValues(parameters);
  }

  @override
  LineDashedMaterial copy(Material source) {
    super.copy(source);

    scale = source.scale;
    dashSize = source.dashSize;
    gapSize = source.gapSize;

    return this;
  }
}
