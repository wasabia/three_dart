part of three_materials;

/**
 * parameters = {
 *  color: <hex>,
 *  opacity: <float>,
 *  map: new THREE.Texture( <Image> ),
 *  alphaMap: new THREE.Texture( <Image> ),
 *
 *  size: <float>,
 *  sizeAttenuation: <bool>
 *
 * }
 */

class PointsMaterial extends Material {

  num? size = 1;

  String type = "PointsMaterial";
  bool isPointsMaterial = true;
  
  bool sizeAttenuation = true;

  Color? color = new Color( 1,1,1 );

  PointsMaterial( parameters ) {
    this.setValues( parameters );
  }




  copy( source ) {

    super.copy( source );

    this.color?.copy( source.color );

    this.map = source.map;

    this.alphaMap = source.alphaMap;

    this.size = source.size;
    this.sizeAttenuation = source.sizeAttenuation;

    return this;

  }

}


