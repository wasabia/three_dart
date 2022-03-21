part of three_materials;

/*
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
  MeshNormalMaterial([Map<String, dynamic>? parameters]) : super() {
    isMeshNormalMaterial = true;
    type = "MeshNormalMaterial";
    bumpScale = 1;
    normalMapType = TangentSpaceNormalMap;
    normalScale = Vector2(1, 1);
    displacementScale = 1;
    displacementBias = 0;
    wireframe = false;
    wireframeLinewidth = 1;
    fog = false;
    
    setValues(parameters);
  }
}
