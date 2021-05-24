part of three_materials;


/**
 * parameters = {
 *  color: <hex>,
 *  map: new THREE.Texture( <Image> ),
 *  alphaMap: new THREE.Texture( <Image> ),
 *  rotation: <float>,
 *  sizeAttenuation: <bool>
 * }
 */

class SpriteMaterial extends Material {

  bool isSpriteMaterial = true;


  bool transparent = true;

  SpriteMaterial( parameters ) : super() {
    
    this.type = 'SpriteMaterial';

    this.color = new Color( 255,255,255 );


    this.setValues( parameters );
  }

  SpriteMaterial.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
   
  }


  copy ( source ) {

    super.copy( source );

    this.color?.copy( source.color );

    this.map = source.map;

    this.alphaMap = source.alphaMap;

    this.rotation = source.rotation;

    this.sizeAttenuation = source.sizeAttenuation;

    return this;

  }



}
