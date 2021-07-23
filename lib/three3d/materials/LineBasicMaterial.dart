part of three_materials;

/**
 * parameters = {
 *  color: <hex>,
 *  opacity: <float>,
 *
 *  linewidth: <float>,
 *  linecap: "round",
 *  linejoin: "round"
 * }
 */

class LineBasicMaterial extends Material {

  bool isLineBasicMaterial = true;
  String type = 'LineBasicMaterial';

  LineBasicMaterial( Map<String, dynamic> parameters ) : super() {
    
    this.color = new Color( 1,1,1 );
    this.linewidth = 1;
    this.linecap = 'round'; // 'butt', 'round' and 'square'.
    this.linejoin = 'round'; // 'round', 'bevel' and 'miter'.

    this.morphTargets = false;

    this.setValues( parameters );
  }

  copy ( source ) {

    super.copy( source );

    this.color?.copy( source.color );

    this.linewidth = source.linewidth;
    this.linecap = source.linecap;
    this.linejoin = source.linejoin;

    this.morphTargets = source.morphTargets;

    return this;

  }

}
