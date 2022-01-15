part of three_materials;

/**
 * parameters = {
 *  opacity: <float>,
 *
 *  bumpMap: new THREE.Texture( <Image> ),
 *  bumpScale: <float>,
 *
 *  normalMap: new THREE.Texture( <Image> ),
 *  normalMapType: THREE.TangentSpaceNormalMap,
 *  normalScale: <Vector2>,
 *
 *  displacementMap: new THREE.Texture( <Image> ),
 *  displacementScale: <float>,
 *  displacementBias: <float>,
 *
 *  wireframe: <boolean>,
 *  wireframeLinewidth: <float>
 *
 * }
 */

class MeshNormalMaterial extends Material {
  bool isMeshNormalMaterial = true;

  String type = "MeshNormalMaterial";
  num? bumpScale = 1;
  Texture? bumpMap;

  Texture? normalMap;
  int? normalMapType = TangentSpaceNormalMap;

  Vector2? normalScale = Vector2(1, 1);

  Texture? displacementMap;
  num? displacementScale = 1;
  num? displacementBias = 0;

  bool wireframe = false;
  num? wireframeLinewidth = 1;

  bool fog = false;

  MeshNormalMaterial([Map<String, dynamic>? parameters]) : super() {
    this.setValues(parameters);
  }
}
