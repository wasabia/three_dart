part of jsm_deprecated;

var _v0 = new Vector3.init();
var _v1 = new Vector3.init();
var _normal = new Vector3.init();
var _triangle = new Triangle(null, null, null);

class EdgesGeometry extends Geometry {

  String type = 'EdgesGeometry';

	EdgesGeometry( geometry, thresholdAngle ) : super() {

		this.parameters = {
			"thresholdAngle": thresholdAngle
		};

		thresholdAngle = ( thresholdAngle != null ) ? thresholdAngle : 1;

		if ( geometry.isGeometry ) {

			geometry = new BufferGeometry().fromGeometry( geometry );

		}

		var precisionPoints = 4;
		var precision = Math.pow( 10, precisionPoints );
		var thresholdDot = Math.cos( MathUtils.DEG2RAD * thresholdAngle );

		var indexAttr = geometry.getIndex();
		var positionAttr = geometry.getAttribute( 'position' );
		var indexCount = indexAttr != null ? indexAttr.count : positionAttr.count;

		var indexArr = [ 0, 0, 0 ];
		var vertKeys = [ 'a', 'b', 'c' ];
		var hashes = List<String>.filled(3, "");

		var edgeData = {};
		List<double> vertices = [];
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
			hashes[ 0 ] = "${ Math.round( a.x * precision ) },${ Math.round( a.y * precision ) },${ Math.round( a.z * precision ) }";
			hashes[ 1 ] = "${ Math.round( b.x * precision ) },${ Math.round( b.y * precision ) },${ Math.round( b.z * precision ) }";
			hashes[ 2 ] = "${ Math.round( c.x * precision ) },${ Math.round( c.y * precision ) },${ Math.round( c.z * precision ) }";

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
				var v0 = _triangle.getValue( vertKeys[ j ] );
				var v1 = _triangle.getValue( vertKeys[ jNext ] );

				var hash = "${ vecHash0 }_${ vecHash1 }";
				var reverseHash = "${ vecHash1 }_${ vecHash0 }";
     
				if ( edgeData.keys.toList().indexOf(reverseHash) >= 0 && [ reverseHash ] != null ) {

					// if we found a sibling edge add it into the vertex array if
					// it meets the angle threshold and delete the edge from the map.
					if ( _normal.dot( edgeData[ reverseHash ]["normal"] ) <= thresholdDot ) {

						vertices.addAll( [v0.x, v0.y, v0.z] );
						vertices.addAll( [v1.x, v1.y, v1.z] );

					}

					edgeData[ reverseHash ] = null;

				} else if ( ! ( edgeData.keys.toList().indexOf(hash) >= 0) ) {

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

        var edv = edgeData[ key ];
        var index0 = edv["index0"];
        var index1 = edv["index1"];

				_v0.fromBufferAttribute( positionAttr, index0 );
				_v1.fromBufferAttribute( positionAttr, index1 );

				vertices.addAll( [_v0.x.toDouble(), _v0.y.toDouble(), _v0.z.toDouble()] );
				vertices.addAll( [_v1.x.toDouble(), _v1.y.toDouble(), _v1.z.toDouble()] );

			}

		}

		this.setAttribute( 'position', Float32BufferAttribute( Float32Array.from(vertices), 3, false ) );

	}

}
