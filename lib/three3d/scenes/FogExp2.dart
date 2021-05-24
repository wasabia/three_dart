part of three_scenes;


class FogExp2 {

  bool isFogExp2 = true;
  String name = "";
  late Color color;
  late num density;

	FogExp2( color, density ) {

		this.name = '';

		this.color = Color.fromHex( color );
		this.density = ( density != null ) ? density : 0.00025;

	}

	clone() {

		return new FogExp2( this.color, this.density );

	}

	toJSON( /* meta */ ) {

		return {
			"type": 'FogExp2',
			"color": this.color.getHex(),
			"density": this.density
		};

	}

}
