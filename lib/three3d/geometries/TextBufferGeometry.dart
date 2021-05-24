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


class TextBufferGeometry extends ExtrudeBufferGeometry {

  String type = "TextBufferGeometry";

  TextBufferGeometry.create(List<Shape> shapes, Map<String, dynamic> options) : super(shapes, options);

	factory TextBufferGeometry(String text, Map<String, dynamic> parameters) {

		Font font = parameters["font"];

		if ( ! ( font != null && font.isFont ) ) {
			throw( 'THREE.TextGeometry: font parameter is not an instance of THREE.Font.' );
		}

		var shapes = font.generateShapes( text, size: parameters["size"] );

		// translate parameters to ExtrudeGeometry API

		parameters["depth"] = parameters["height"] != null ? parameters["height"] : 50;

		// defaults

		if ( parameters["bevelThickness"] == null ) parameters["bevelThickness"] = 10;
		if ( parameters["bevelSize"] == null ) parameters["bevelSize"] = 8;
		if ( parameters["bevelEnabled"] == null ) parameters["bevelEnabled"] = false;

		TextBufferGeometry _textBufferGeometry = TextBufferGeometry.create(shapes, parameters);

		return _textBufferGeometry;
	}

}
