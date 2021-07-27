part of jsm_lines;


// import { LineSegments2 } from '../lines/LineSegments2.js';
// import { LineGeometry } from '../lines/LineGeometry.js';
// import { LineMaterial } from '../lines/LineMaterial.js';

class Line2 extends LineSegments2 {

  String type = 'Line2';
  bool isLine2 = true;

  Line2( geometry, material ) : super(geometry, material) {

  }

	// if ( geometry === undefined ) geometry = new LineGeometry();
	// if ( material === undefined ) material = new LineMaterial( { color: Math.random() * 0xffffff } );

	

}
