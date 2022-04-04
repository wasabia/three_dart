part of three_materials;

class SpriteMaterial extends Material {
  SpriteMaterial([parameters]) : super() {
    type = 'SpriteMaterial';
    transparent = true;
    color = Color(1, 1, 1);
    setValues(parameters);
  }

  SpriteMaterial.fromJSON(
      Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON);

  @override
  SpriteMaterial copy(Material source) {
    super.copy(source);
    color.copy(source.color);
    map = source.map;
    alphaMap = source.alphaMap;
    rotation = source.rotation;
    sizeAttenuation = source.sizeAttenuation;
    return this;
  }
}
