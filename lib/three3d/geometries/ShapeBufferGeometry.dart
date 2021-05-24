
part of three_geometries;

class ShapeBufferGeometry extends BufferGeometry {

  String type = 'ShapeBufferGeometry';

	ShapeBufferGeometry( List<Shape> shapes, {num curveSegments = 12 } ) : super() {

    this.curveSegments = curveSegments;
    this.shapes = shapes;

    init();
	}

  ShapeBufferGeometry.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    curveSegments = json["curveSegments"];
    
    var _shapes;

    if(json["shapes"] != null) {
      List<Shape> rootShapes = rootJSON["shapes"];

      String shapeUuid = json["shapes"];
      _shapes = rootShapes.firstWhere((element) => element.uuid == shapeUuid);
    }

    shapes = _shapes;

    init();
  }

  init() {

		this.parameters["shapes"] = shapes;
    this.parameters["curveSegments"] = curveSegments;

		// buffers

		this.indices = [];
		this.vertices = [];
		this.normals = [];
		this.uvs = [];

		// helper variables

		var groupStart = 0;
		var groupCount = 0;

		// allow single and array values for "shapes" parameter


    Function addShape = ( shape ) {

			var indexOffset = vertices.length / 3;
			var points = shape.extractPoints( curveSegments );

			var shapeVertices = points["shape"];
			var shapeHoles = points["holes"];

			// check direction of vertices

			if ( ShapeUtils.isClockWise( shapeVertices ) == false ) {

				shapeVertices = shapeVertices.reversed.toList();

			}

			for ( var i = 0, l = shapeHoles.length; i < l; i ++ ) {

				var shapeHole = shapeHoles[ i ];

				if ( ShapeUtils.isClockWise( shapeHole ) == true ) {

					shapeHoles[ i ] = shapeHole.reversed.toList();

				}

			}

			var faces = ShapeUtils.triangulateShape( shapeVertices, shapeHoles );

			// join vertices of inner and outer paths to a single array

			for ( var i = 0, l = shapeHoles.length; i < l; i ++ ) {

				var shapeHole = shapeHoles[ i ];
				shapeVertices.addAll( shapeHole );

			}

			// vertices, normals, uvs

			for ( var i = 0, l = shapeVertices.length; i < l; i ++ ) {

				var vertex = shapeVertices[ i ];

				vertices.addAll( [vertex.x, vertex.y, 0] );
				normals.addAll( [0, 0, 1] );
				uvs.addAll( [vertex.x, vertex.y] ); // world uvs

			}

			// incides

			for ( var i = 0, l = faces.length; i < l; i ++ ) {

				var face = faces[ i ];

				var a = face[ 0 ] + indexOffset;
				var b = face[ 1 ] + indexOffset;
				var c = face[ 2 ] + indexOffset;

				indices.addAll( [a, b, c] );
				groupCount += 3;

			}

		};


    for ( var i = 0; i < shapes.length; i ++ ) {
      addShape( shapes[ i ] );
      this.addGroup( groupStart, groupCount, materialIndex: i ); // enables MultiMaterial support
      groupStart += groupCount;
      groupCount = 0;
    }

    // if(shapes.runtimeType == List) {
    //   for ( var i = 0; i < shapes.length; i ++ ) {

    //     addShape( shapes[ i ] );

    //     this.addGroup( groupStart, groupCount, materialIndex: i ); // enables MultiMaterial support

    //     groupStart += groupCount;
    //     groupCount = 0;

    //   }
    // } else {
      // addShape( shapes );
    // }

		

		// build geometry

   

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );


		// helper functions

		
  }

  // addShape( List<num> vertices, List<num> normals, List<num> uvs, shape, groupCount ) {

  //   var indexOffset = vertices.length / 3;
  //   var points = shape.extractPoints( curveSegments );

  //   var shapeVertices = points["shape"];
  //   var shapeHoles = points["holes"];

  //   // check direction of vertices

  //   if ( ShapeUtils.isClockWise( shapeVertices ) == false ) {

  //     shapeVertices = shapeVertices.reversed.toList();

  //   }

  //   for ( var i = 0, l = shapeHoles.length; i < l; i ++ ) {

  //     var shapeHole = shapeHoles[ i ];

  //     if ( ShapeUtils.isClockWise( shapeHole ) == true ) {

  //       shapeHoles[ i ] = shapeHole.reversed.toList();

  //     }

  //   }

  //   var faces = ShapeUtils.triangulateShape( shapeVertices, shapeHoles );

  //   // join vertices of inner and outer paths to a single array

  //   for ( var i = 0, l = shapeHoles.length; i < l; i ++ ) {

  //     var shapeHole = shapeHoles[ i ];
  //     shapeVertices = shapeVertices.concat( shapeHole );

  //   }

  //   // vertices, normals, uvs

  //   for ( var i = 0, l = shapeVertices.length; i < l; i ++ ) {

  //     var vertex = shapeVertices[ i ];

  //     vertices..addAll([vertex.x, vertex.y, 0]);
  //     normals..addAll([0, 0, 1]);
  //     uvs..addAll([vertex.x, vertex.y]); // world uvs

  //   }

  //   // incides

  //   for ( var i = 0, l = faces.length; i < l; i ++ ) {

  //     var face = faces[ i ];

  //     var a = face[ 0 ] + indexOffset;
  //     var b = face[ 1 ] + indexOffset;
  //     var c = face[ 2 ] + indexOffset;

  //     indices.addAll( [a, b, c] );
  //     groupCount += 3;

  //   }

  // }

	toJSON({Object3dMeta? meta}) {

		var data = super.toJSON(meta: meta );

		var shapes = this.parameters["shapes"];

		return toJSON2( shapes, data );

	}


  toJSON2( shapes, data ) {

    if(shapes != null) {
      data["shapes"] = [];

      for ( var i = 0, l = shapes.length; i < l; i ++ ) {

        var shape = shapes[ i ];

        data["shapes"].add( shape.uuid );

      }

    }
    
    return data;

  }


}
