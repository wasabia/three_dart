part of three_materials;

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
