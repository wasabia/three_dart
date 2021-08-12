part of three_loaders;


class SVGLoader extends Loader {

  // Default dots per inch
  num defaultDPI = 90;

  // Accepted units: 'mm', 'cm', 'in', 'pt', 'pc', 'px'
	String defaultUnit = 'px';

	SVGLoader(manager) : super(manager) {}

  loadAsync( url, onProgress ) async {
    var completer = Completer();

    load(
      url,
      (result) {
        completer.complete(result);
      }, 
      onProgress, 
      () {

      }
    );

    return completer.future;
  }


  load( url, onLoad, onProgress, onError ) {

		var scope = this;

		var loader = new FileLoader( scope.manager );
		loader.setPath( scope.path );
		loader.setRequestHeader( scope.requestHeader );
		loader.setWithCredentials( scope.withCredentials );
		loader.load( url, ( text ) {

			// try {
        if(onLoad != null) {
          onLoad( scope.parse( text ) );
        }
				

			// } catch ( e ) {

			// 	if ( onError != null ) {

			// 		onError( e );

			// 	} else {
      //     print("SVGLoader load error.... ");
			// 		print( e );

			// 	}

			// 	scope.manager.itemError( url );

			// }

		}, onProgress, onError );

	}

  // Function parse =========== start
	parse( text, {String? path, Function? onLoad, Function? onError} ) {
    var _parse = SVGLoaderParser(text, defaultUnit: this.defaultUnit, defaultDPI: this.defaultDPI);
    return _parse.parse(text);
	}
  // Function parse ================ end

  
  static Map<String, dynamic> getStrokeStyle( width, color, lineJoin, lineCap, miterLimit ) {

    // Param width: Stroke width
    // Param color: As returned by THREE.Color.getStyle()
    // Param lineJoin: One of "round", "bevel", "miter" or "miter-limit"
    // Param lineCap: One of "round", "square" or "butt"
    // Param miterLimit: Maximum join length, in multiples of the "width" parameter (join is truncated if it exceeds that distance)
    // Returns style object

    width = width != null ? width : 1;
    color = color != null ? color : '#000';
    lineJoin = lineJoin != null ? lineJoin : 'miter';
    lineCap = lineCap != null ? lineCap : 'butt';
    miterLimit = miterLimit != null ? miterLimit : 4;

    return {
      "strokeColor": color,
      "strokeWidth": width,
      "strokeLineJoin": lineJoin,
      "strokeLineCap": lineCap,
      "strokeMiterLimit": miterLimit
    };

  }



  static pointsToStroke( points, style, arcDivisions, minDistance ) {

    // Generates a stroke with some witdh around the given path.
    // The path can be open or closed (last point equals to first point)
    // Param points: Array of Vector2D (the path). Minimum 2 points.
    // Param style: Object with SVG properties as returned by SVGLoader.getStrokeStyle(), or SVGLoader.parse() in the path.userData.style object
    // Params arcDivisions: Arc divisions for round joins and endcaps. (Optional)
    // Param minDistance: Points closer to this distance will be merged. (Optional)
    // Returns BufferGeometry with stroke triangles (In plane z = 0). UV coordinates are generated ('u' along path. 'v' across it, from left to right)

    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    if ( SVGLoader.pointsToStrokeWithBuffers( points, style, arcDivisions, minDistance, vertices, normals, uvs, 0 ) == 0 ) {
      return null;
    }

    var geometry = new BufferGeometry();
    geometry.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
    geometry.setAttribute( 'normal', new Float32BufferAttribute( normals, 3, false ) );
    geometry.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );

    return geometry;

  }



  static pointsToStrokeWithBuffers(points, style, arcDivisions, minDistance, vertices, normals, uvs, vertexOffset) {
    var svgLPTS = SVGLoaderPointsToStroke(points, style, arcDivisions, minDistance, vertices, normals, uvs, vertexOffset);
    return svgLPTS.convert();
  }

}




