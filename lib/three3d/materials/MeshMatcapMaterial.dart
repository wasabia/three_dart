part of three_materials;

/*
 * parameters = {
 *  color: <hex>,
 *  opacity: <float>,
 *
 *  matcap: new THREE.Texture( <Image> ),
 *
 *  map: new THREE.Texture( <Image> ),
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
 *  alphaMap: new THREE.Texture( <Image> ),
 *
 *  flatShading: <bool>
 * }
 */

class MeshMatcapMaterial extends Material {
  MeshMatcapMaterial([Map<String, dynamic>? parameters]) : super() {
    isMeshMatcapMaterial = true;
    defines = {'MATCAP': ''};

    type = 'MeshMatcapMaterial';

    color = Color.fromHex(0xffffff); // diffuse

    matcap = null;

    map = null;

    bumpMap = null;
    bumpScale = 1;

    normalMap = null;
    normalMapType = TangentSpaceNormalMap;
    normalScale = Vector2(1, 1);

    displacementMap = null;
    displacementScale = 1;
    displacementBias = 0;

    alphaMap = null;

    flatShading = false;

    setValues(parameters);
  }

  @override
  MeshMatcapMaterial copy(Material source) {
    super.copy(source);

    defines = {'MATCAP': ''};

    color!.copy(source.color!);

    matcap = source.matcap;

    map = source.map;

    bumpMap = source.bumpMap;
    bumpScale = source.bumpScale;

    normalMap = source.normalMap;
    normalMapType = source.normalMapType;
    normalScale!.copy(source.normalScale!);

    displacementMap = source.displacementMap;
    displacementScale = source.displacementScale;
    displacementBias = source.displacementBias;

    alphaMap = source.alphaMap;

    flatShading = source.flatShading;

    return this;
  }
}
