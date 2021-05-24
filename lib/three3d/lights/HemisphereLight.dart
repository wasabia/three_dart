part of three_lights;

class HemisphereLight extends Light {

  HemisphereLight( Color skyColor, Color groundColor, double intensity ) : super(skyColor, intensity) {

    this.type = 'HemisphereLight';

    this.position.copy( Object3D.DefaultUp );

    this.isHemisphereLight = true;
    this.updateMatrix();

    this.groundColor = new Color( groundColor.r, groundColor.g, groundColor.b );
  }


  copy ( Object3D source, bool recursive ) {

		super.copy( source, recursive );

    HemisphereLight source1 = source as HemisphereLight;


		this.groundColor!.copy( source1.groundColor );

		return this;

	}


}
