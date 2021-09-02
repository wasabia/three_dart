part of three_materials;


/**
 * parameters = {
 *  clearcoat: <float>,
 *  clearcoatMap: new THREE.Texture( <Image> ),
 *  clearcoatRoughness: <float>,
 *  clearcoatRoughnessMap: new THREE.Texture( <Image> ),
 *  clearcoatNormalScale: <Vector2>,
 *  clearcoatNormalMap: new THREE.Texture( <Image> ),
 *
 *  ior: <float>,
 *  reflectivity: <float>,
 *
 *  sheen: <Color>,
 *
 *  transmission: <float>,
 *  transmissionMap: new THREE.Texture( <Image> ),
 *
 *  thickness: <float>,
 *  thicknessMap: new THREE.Texture( <Image> ),
 *  attenuationTint: <Color>
 *  attenuationDistance: <float>,
 * 
 *  specularIntensity: <float>,
 *  specularIntensityhMap: new THREE.Texture( <Image> ),
 *  specularTint: <Color>,
 *  specularTintMap: new THREE.Texture( <Image> )
 * }
 */

class MeshPhysicalMaterial extends MeshStandardMaterial {

  bool isMeshPhysicalMaterial = true;
  num clearcoat = 0.0;
  Texture? clearcoatMap;
  num clearcoatRoughness = 0.0;
  String type = 'MeshPhysicalMaterial';
  Texture? clearcoatRoughnessMap;
  Vector2? clearcoatNormalScale = Vector2( 1, 1 );
  Texture? clearcoatNormalMap;

  // null will disable sheen bsdf
  Color? sheen;

  num thickness = 0.01;
  
  Color attenuationTint = new Color( 1, 1, 1 );
  num attenuationDistance = 0.0;
  

  num specularIntensity = 1.0;
  Texture? specularIntensityMap = null;
  Color specularTint = new Color( 1, 1, 1 );
  Texture? specularTintMap = null;
  num? ior = 1.5;


  MeshPhysicalMaterial( parameters ) : super(parameters) {
    this.defines = {
      'STANDARD': '',
      'PHYSICAL': ''
    };
  
    this.setValues( parameters );
  }


  num get reflectivity => ( MathUtils.clamp( 2.5 * ( this.ior! - 1 ) / ( this.ior! + 1 ), 0, 1 ) );
  set reflectivity(num value) {
    this.ior = ( 1 + 0.4 * value ) / ( 1 - 0.4 * value );
  }


  copy( source ) {

    super.copy( source );

    this.defines = {

      'STANDARD': '',
      'PHYSICAL': ''

    };

    this.clearcoat = source.clearcoat;
    this.clearcoatMap = source.clearcoatMap;
    this.clearcoatRoughness = source.clearcoatRoughness;
    this.clearcoatRoughnessMap = source.clearcoatRoughnessMap;
    this.clearcoatNormalMap = source.clearcoatNormalMap;
    this.clearcoatNormalScale!.copy( source.clearcoatNormalScale );

    this.ior = source.ior;

    if ( source.sheen ) {

      this.sheen = ( this.sheen ?? new Color(1,1,1) ).copy( source.sheen );

    } else {

      this.sheen = null;

    }

    this.transmission = source.transmission;
    this.transmissionMap = source.transmissionMap;

    this.thickness = source.thickness;
		this.thicknessMap = source.thicknessMap;

    this.attenuationTint.copy( source.attenuationTint );
		this.attenuationDistance = source.attenuationDistance;
		

    this.specularIntensity = source.specularIntensity;
		this.specularIntensityMap = source.specularIntensityMap;
		this.specularTint.copy( source.specularTint );
		this.specularTintMap = source.specularTintMap;

    return this;

  }


}
