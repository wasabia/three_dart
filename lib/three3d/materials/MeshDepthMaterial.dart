part of three_materials;

/**
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

  bool isMeshDepthMaterial = true;
  String type = "MeshDepthMaterial";
  int? depthPacking = BasicDepthPacking;
  bool skinning = false;
  bool morphTargets = false;

  num? displacementScale = 1.0;
  num? displacementBias = 0;
  bool wireframe = false;
  num? wireframeLinewidth = 1;
  bool fog = false;


  MeshDepthMaterial( Map<String, dynamic> parameters ) : super() {

    this.displacementMap = null;

    this.setValues( parameters );
  }



  copy ( source ) {

    super.copy( source );

    this.depthPacking = source.depthPacking;

    this.skinning = source.skinning;
    this.morphTargets = source.morphTargets;

    this.map = source.map;

    this.alphaMap = source.alphaMap;

    this.displacementMap = source.displacementMap;
    this.displacementScale = source.displacementScale;
    this.displacementBias = source.displacementBias;

    this.wireframe = source.wireframe;
    this.wireframeLinewidth = source.wireframeLinewidth;

    return this;

  }

}

