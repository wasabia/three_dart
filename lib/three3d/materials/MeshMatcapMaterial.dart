part of three_materials;

/**
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
  bool isMeshMatcapMaterial = true;

  MeshMatcapMaterial([parameters]) : super() {
    this.defines = {'MATCAP': ''};

    this.type = 'MeshMatcapMaterial';

    this.color = Color.fromHex(0xffffff); // diffuse

    this.matcap = null;

    this.map = null;

    this.bumpMap = null;
    this.bumpScale = 1;

    this.normalMap = null;
    this.normalMapType = TangentSpaceNormalMap;
    this.normalScale = new Vector2(1, 1);

    this.displacementMap = null;
    this.displacementScale = 1;
    this.displacementBias = 0;

    this.alphaMap = null;

    this.flatShading = false;

    this.setValues(parameters);
  }

  copy(source) {
    super.copy(source);

    this.defines = {'MATCAP': ''};

    this.color!.copy(source.color);

    this.matcap = source.matcap;

    this.map = source.map;

    this.bumpMap = source.bumpMap;
    this.bumpScale = source.bumpScale;

    this.normalMap = source.normalMap;
    this.normalMapType = source.normalMapType;
    this.normalScale!.copy(source.normalScale);

    this.displacementMap = source.displacementMap;
    this.displacementScale = source.displacementScale;
    this.displacementBias = source.displacementBias;

    this.alphaMap = source.alphaMap;

    this.flatShading = source.flatShading;

    return this;
  }
}
