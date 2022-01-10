part of three_lights;

class HemisphereLightProbe extends LightProbe {


	HemisphereLightProbe( Color skyColor, Color groundColor, num intensity ) : super(null, intensity) {

    var color1 = new Color(0,0,0).setRGB( skyColor.r, skyColor.g, skyColor.b );
    var color2 = new Color(0,0,0).setRGB( groundColor.r, groundColor.g, groundColor.b );

    var sky = new Vector3( color1.r, color1.g, color1.b );
    var ground = new Vector3( color2.r, color2.g, color2.b );

    // without extra factor of PI in the shader, should = 1 / Math.sqrt( Math.PI );
    var c0 = Math.sqrt( Math.PI );
    var c1 = c0 * Math.sqrt( 0.75 );

    this.sh!.coefficients[ 0 ].copy( sky ).add( ground ).multiplyScalar( c0 );
    this.sh!.coefficients[ 1 ].copy( sky ).sub( ground ).multiplyScalar( c1 );

    this.isHemisphereLightProbe = false;
	}

	toJSON ( {Object3dMeta? meta} ) {

		var data = super.toJSON( meta: meta );
		return data;

	}


}
