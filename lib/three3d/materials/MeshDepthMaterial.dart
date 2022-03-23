part of three_materials;

/*
 * parameters = {
 *
 *  opacity: <float>,
 *
 *  map: new THREE.Texture( <Image> ),
 *
 *  alphaMap: new THREE.Texture( <Image> ),
 *
 *  displacementMap: new THREE.Texture( <Image> ),
 *  displacementScale: <float>,
 *  displacementBias: <float>,
 *
 *  wireframe: <boolean>,
 *  wireframeLinewidth: <float>
 * }
 */

class MeshDepthMaterial extends Material {
  MeshDepthMaterial([Map<String, dynamic>? parameters]) : super() {
    type = "MeshDepthMaterial";
    depthPacking = BasicDepthPacking;
    displacementScale = 1.0;
    displacementBias = 0;
    wireframe = false;
    wireframeLinewidth = 1;
    fog = false;

    displacementMap = null;

    setValues(parameters);
  }

  @override
  MeshDepthMaterial copy(Material source) {
    super.copy(source);

    depthPacking = source.depthPacking;

    map = source.map;

    alphaMap = source.alphaMap;

    displacementMap = source.displacementMap;
    displacementScale = source.displacementScale;
    displacementBias = source.displacementBias;

    wireframe = source.wireframe;
    wireframeLinewidth = source.wireframeLinewidth;

    return this;
  }

  @override
  MeshDepthMaterial clone() {
    return MeshDepthMaterial().copy(this);
  }
}
