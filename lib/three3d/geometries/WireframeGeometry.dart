// import { BufferGeometry } from '../core/BufferGeometry.js';
// import { Float32BufferAttribute } from '../core/BufferAttribute.js';
// import { Vector3 } from '../math/Vector3.js';

part of three_geometries;


class WireframeGeometry extends BufferGeometry {

  String type = 'WireframeGeometry';

	WireframeGeometry( geometry ) : super() {


		// buffer

		var vertices = [];

		// helper variables

		var edge = [ 0, 0 ], edges = {};
		var keys = [ 'a', 'b', 'c' ];

		// different logic for Geometry and BufferGeometry

		if ( geometry && geometry.isGeometry ) {

			// create a data structure that contains all edges without duplicates

			var faces = geometry.faces;

			for ( var i = 0, l = faces.length; i < l; i ++ ) {

				var face = faces[ i ];

				for ( var j = 0; j < 3; j ++ ) {

					var edge1 = face[ keys[ j ] ];
					var edge2 = face[ keys[ ( j + 1 ) % 3 ] ];
					edge[ 0 ] = Math.min( edge1, edge2 ); // sorting prevents duplicates
					edge[ 1 ] = Math.max( edge1, edge2 );

					var key = '${edge[ 0 ]},${edge[ 1 ]}';

					if ( edges[ key ] == null ) {

						edges[ key ] = { "index1": edge[ 0 ], "index2": edge[ 1 ] };

					}

				}

			}

			// generate vertices

			for ( var key in edges.keys ) {

				var e = edges[ key ];

				var vertex = geometry.vertices[ e.index1 ];
				vertices.addAll( [vertex.x, vertex.y, vertex.z] );

				vertex = geometry.vertices[ e.index2 ];
				vertices.addAll( [vertex.x, vertex.y, vertex.z] );

			}

		} else if ( geometry && geometry.isBufferGeometry ) {

			var vertex = new Vector3.init();

			if ( geometry.index != null ) {

				// indexed BufferGeometry

				var position = geometry.attributes.position;
				var indices = geometry.index;
				var groups = geometry.groups;

				if ( groups.length == 0 ) {

					groups = [ { "start": 0, "count": indices.count, "materialIndex": 0 } ];

				}

				// create a data structure that contains all eges without duplicates

				for ( var o = 0, ol = groups.length; o < ol; ++ o ) {

					var group = groups[ o ];

					var start = group.start;
					var count = group.count;

					for ( var i = start, l = ( start + count ); i < l; i += 3 ) {

						for ( var j = 0; j < 3; j ++ ) {

							var edge1 = indices.getX( i + j );
							var edge2 = indices.getX( i + ( j + 1 ) % 3 );
							edge[ 0 ] = Math.min( edge1, edge2 ); // sorting prevents duplicates
							edge[ 1 ] = Math.max( edge1, edge2 );

							var key = '${edge[ 0 ]},${edge[ 1 ]}';

							if ( edges[ key ] == null ) {

								edges[ key ] = { "index1": edge[ 0 ], "index2": edge[ 1 ] };

							}

						}

					}

				}

				// generate vertices

				for ( var key in edges.keys ) {

					var e = edges[ key ];

					vertex.fromBufferAttribute( position, e.index1 );
					vertices.addAll( [vertex.x, vertex.y, vertex.z] );

					vertex.fromBufferAttribute( position, e.index2 );
					vertices.addAll( [vertex.x, vertex.y, vertex.z] );

				}

			} else {

				// non-indexed BufferGeometry

				var position = geometry.attributes.position;

				for ( var i = 0, l = ( position.count / 3 ); i < l; i ++ ) {

					for ( var j = 0; j < 3; j ++ ) {

						// three edges per triangle, an edge is represented as (index1, index2)
						// e.g. the first triangle has the following edges: (0,1),(1,2),(2,0)

						var index1 = 3 * i + j;
						vertex.fromBufferAttribute( position, index1 );
						vertices.addAll( [vertex.x, vertex.y, vertex.z] );

						var index2 = 3 * i + ( ( j + 1 ) % 3 );
						vertex.fromBufferAttribute( position, index2 );
						vertices.addAll( [vertex.x, vertex.y, vertex.z] );

					}

				}

			}

		}

		// build geometry

		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );

	}

}