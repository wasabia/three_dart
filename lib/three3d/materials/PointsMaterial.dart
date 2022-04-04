part of three_materials;

class PointsMaterial extends Material {
  PointsMaterial([Map<String, dynamic>? parameters]) {
    type = "PointsMaterial";
    sizeAttenuation = true;
    color = Color(1, 1, 1);
    size = 1;

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
    return this;
  }
}
