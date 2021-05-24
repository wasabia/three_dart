part of three_helpers;


class AxesHelper extends LineSegments {

  String type = "AxesHelper";

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

  AxesHelper.create({num size = 1, geometry, material}) : super(geometry, material) {

  }

}