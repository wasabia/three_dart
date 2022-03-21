part of three_materials;

/*
 * parameters = {
 *  color: <hex>,
 *  map: new THREE.Texture( <Image> ),
 *  alphaMap: new THREE.Texture( <Image> ),
 *  rotation: <float>,
 *  sizeAttenuation: <bool>
 * }
 */

class SpriteMaterial extends Material {
  SpriteMaterial([parameters]) : super() {
    type = 'SpriteMaterial';
    isSpriteMaterial = true;
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
    color?.copy(source.color!);
    map = source.map;
    alphaMap = source.alphaMap;
    rotation = source.rotation;
    sizeAttenuation = source.sizeAttenuation;
    return this;
  }
}
