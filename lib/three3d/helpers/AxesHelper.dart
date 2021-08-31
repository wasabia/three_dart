part of three_helpers;


class AxesHelper extends LineSegments {

  String type = "AxesHelper";
  
  AxesHelper.create({num size = 1, geometry, material}) : super(geometry, material) {

  }

  factory AxesHelper({num size = 1}) {
    var vertices = [
			0, 0, 0,	size, 0, 0,
			0, 0, 0,	0, size, 0,
			0, 0, 0,	0, 0, size
		];

		var colors = [
			1, 0, 0,	1, 0.6, 0,
			0, 1, 0,	0.6, 1, 0,
			0, 0, 1,	0, 0.6, 1
		];

		var geometry = new BufferGeometry();
		geometry.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		geometry.setAttribute( 'color', new Float32BufferAttribute( colors, 3, false ) );

		var material = new LineBasicMaterial( { "vertexColors": true, "toneMapped": false } );

		return AxesHelper.create( size: size, geometry: geometry, material: material );
  }


  setColors( Color xAxisColor, Color yAxisColor, Color zAxisColor ) {

		var color = new Color(1, 1, 1);
		var array = this.geometry!.attributes["color"].array;

		color.copy( xAxisColor );
		color.toArray( array, offset: 0 );
		color.toArray( array, offset: 3 );

		color.copy( yAxisColor );
		color.toArray( array, offset: 6 );
		color.toArray( array, offset: 9 );

		color.copy( zAxisColor );
		color.toArray( array, offset: 12 );
		color.toArray( array, offset: 15 );

		this.geometry!.attributes["color"].needsUpdate = true;

		return this;

	}

  dispose() {

		this.geometry!.dispose();
		this.material.dispose();

	}

}