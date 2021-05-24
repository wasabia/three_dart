part of three_geometries;

/**
 * Text = 3D Text
 *
 * parameters = {
 *  font: <THREE.Font>, // font
 *
 *  size: <float>, // size of the text
 *  height: <float>, // thickness to extrude text
 *  curveSegments: <int>, // number of points on the curves
 *
 *  bevelEnabled: <bool>, // turn on bevel
 *  bevelThickness: <float>, // how deep into text bevel goes
 *  bevelSize: <float>, // how far from text outline (including bevelOffset) is bevel
 *  bevelOffset: <float> // how far from text outline does bevel start
 * }
 */


class TextGeometry extends Geometry {

  String type = 'TextGeometry';

	TextGeometry( text, parameters ) : super() {

		this.parameters = {
			"text": text,
			"parameters": parameters
		};

		this.fromBufferGeometry( TextBufferGeometry.create( text, parameters ) );
		this.mergeVertices();

	}

}
