part of three_geometries;


class EdgesGeometry extends BufferGeometry {

  var _v0 = new Vector3.init();
  var _v1 = new Vector3.init();
  var _normal = new Vector3.init();
  var _triangle = new Triangle.init();

  String type = "EdgesGeometry";

	EdgesGeometry( BufferGeometry geometry, thresholdAngle ) : super() {

		this.parameters = {
			"thresholdAngle": thresholdAngle
		};

		thresholdAngle = ( thresholdAngle != null ) ? thresholdAngle : 1;

		var precisionPoints = 4;
		var precision = Math.pow( 10, precisionPoints );
		var thresholdDot = Math.cos( MathUtils.DEG2RAD * thresholdAngle );

		var indexAttr = geometry.getIndex();
		var positionAttr = geometry.getAttribute( 'position' );
		var indexCount = indexAttr != null ? indexAttr.count : positionAttr.count;

		var indexArr = [ 0, 0, 0 ];
		var vertKeys = [ 'a', 'b', 'c' ];
		var hashes = Map();

		var edgeData = {};
		var vertices = [];
		for ( var i = 0; i < indexCount; i += 3 ) {

			if ( indexAttr != null ) {

				indexArr[ 0 ] = indexAttr.getX( i );
				indexArr[ 1 ] = indexAttr.getX( i + 1 );
				indexArr[ 2 ] = indexAttr.getX( i + 2 );

			} else {

				indexArr[ 0 ] = i;
				indexArr[ 1 ] = i + 1;
				indexArr[ 2 ] = i + 2;

			}

      var a = _triangle.a;
      var b = _triangle.b;
      var c = _triangle.c;

			a.fromBufferAttribute( positionAttr, indexArr[ 0 ] );
			b.fromBufferAttribute( positionAttr, indexArr[ 1 ] );
			c.fromBufferAttribute( positionAttr, indexArr[ 2 ] );
			_triangle.getNormal( _normal );

			// create hashes for the edge from the vertices
      hashes[ 0 ] = "${ a.x },${ a.y },${ a.z }";
			hashes[ 1 ] = "${ b.x },${ b.y },${ b.z }";
			hashes[ 2 ] = "${ c.x },${ c.y },${ c.z }";
      
			// skip degenerate triangles
			if ( hashes[ 0 ] == hashes[ 1 ] || hashes[ 1 ] == hashes[ 2 ] || hashes[ 2 ] == hashes[ 0 ] ) {

				continue;

			}

			// iterate over every edge
			for ( var j = 0; j < 3; j ++ ) {

				// get the first and next vertex making up the edge
				var jNext = ( j + 1 ) % 3;
				var vecHash0 = hashes[ j ];
				var vecHash1 = hashes[ jNext ];
				var v0 = _triangle[ vertKeys[ j ] ];
				var v1 = _triangle[ vertKeys[ jNext ] ];

				var hash = "${ vecHash0 }_${ vecHash1 }";
				var reverseHash = "${ vecHash1 }_${ vecHash0 }";

				if ( edgeData.containsKey(reverseHash) && edgeData[ reverseHash ] != null ) {

					// if we found a sibling edge add it into the vertex array if
					// it meets the angle threshold and delete the edge from the map.
					if ( _normal.dot( edgeData[ reverseHash ]["normal"] ) <= thresholdDot ) {

						vertices.addAll( [v0.x, v0.y, v0.z] );
						vertices.addAll( [v1.x, v1.y, v1.z] );

					}

					edgeData[ reverseHash ] = null;

				} else if ( ! ( edgeData.containsKey(hash) ) ) {

					// if we've already got an edge here then skip adding a new one
					edgeData[ hash ] = {

						"index0": indexArr[ j ],
						"index1": indexArr[ jNext ],
						"normal": _normal.clone(),

					};

				}

			}

		}

		// iterate over all remaining, unmatched edges and add them to the vertex array
		for ( var key in edgeData.keys ) {

			if ( edgeData[ key ] != null ) {
        var _ed = edgeData[ key ];
        var index0 = _ed["index0"];
        var index1 = _ed["index1"];
				_v0.fromBufferAttribute( positionAttr, index0 );
				_v1.fromBufferAttribute( positionAttr, index1 );

				vertices.addAll( [_v0.x, _v0.y, _v0.z] );
				vertices.addAll( [_v1.x, _v1.y, _v1.z] );

			}

		}

		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );

	}

}
