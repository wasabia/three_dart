part of three_materials;

class LineBasicMaterial extends Material {
  LineBasicMaterial([Map<String, dynamic>? parameters]) : super() {
    type = 'LineBasicMaterial';

    color = Color(1, 1, 1);
    linewidth = 1;
    linecap = 'round'; // 'butt', 'round' and 'square'.
    linejoin = 'round'; // 'round', 'bevel' and 'miter'.

    fog = true;

    setValues(parameters);
  }

  @override
  LineBasicMaterial copy(Material source) {
    super.copy(source);

    color.copy(source.color);

    linewidth = source.linewidth;
    linecap = source.linecap;
    linejoin = source.linejoin;

    fog = source.fog;

    return this;
  }

  @override
  LineBasicMaterial clone() {
    return LineBasicMaterial({}).copy(this);
  }
}

