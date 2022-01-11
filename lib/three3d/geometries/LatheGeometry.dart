
part of three_geometries;

class LatheGeometry extends BufferGeometry {


  String type = 'LatheGeometry';

	LatheGeometry( points, {segments = 12, phiStart = 0, phiLength = Math.PI * 2} ) : super() {

		this.parameters = {
			"points": points,
			"segments": segments,
			"phiStart": phiStart,
			"phiLength": phiLength
		};

		segments = Math.floor( segments );

		// clamp phiLength so it's in range of [ 0, 2PI ]

		phiLength = MathUtils.clamp( phiLength, 0, Math.PI * 2 );

		// buffers

		var indices = [];
		var vertices = [];
		var uvs = [];

		// helper variables

		var inverseSegments = 1.0 / segments;
		var vertex = new Vector3.init();
		var uv = new Vector2(null, null);

		// generate vertices and uvs

		for ( var i = 0; i <= segments; i ++ ) {

			var phi = phiStart + i * inverseSegments * phiLength;

			var sin = Math.sin( phi );
			var cos = Math.cos( phi );

			for ( var j = 0; j <= ( points.length - 1 ); j ++ ) {

				// vertex

				vertex.x = points[ j ].x * sin;
				vertex.y = points[ j ].y;
				vertex.z = points[ j ].x * cos;

				vertices.addAll( [vertex.x, vertex.y, vertex.z] );

				// uv

				uv.x = i / segments;
				uv.y = j / ( points.length - 1 );

				uvs.addAll( [uv.x, uv.y] );


			}

		}

		// indices

		for ( var i = 0; i < segments; i ++ ) {

			for ( var j = 0; j < ( points.length - 1 ); j ++ ) {

				var base = j + i * points.length;

				var a = base;
				var b = base + points.length;
				var c = base + points.length + 1;
				var d = base + 1;

				// faces

				indices.addAll( [a, b, d] );
				indices.addAll( [b, c, d] );

			}

		}

		// build geometry

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );

		// generate normals

		this.computeVertexNormals();

		// if the geometry is closed, we need to average the normals along the seam.
		// because the corresponding vertices are identical (but still have different UVs).

		if ( phiLength == Math.PI * 2 ) {

			var normals = this.attributes["normal"].array;
			var n1 = new Vector3.init();
			var n2 = new Vector3.init();
			var n = new Vector3.init();

			// this is the buffer offset for the last line of vertices

			var base = segments * points.length * 3;

			for ( var i = 0, j = 0; i < points.length; i ++, j += 3 ) {

				// select the normal of the vertex in the first line

				n1.x = normals[ j + 0 ];
				n1.y = normals[ j + 1 ];
				n1.z = normals[ j + 2 ];

				// select the normal of the vertex in the last line

				n2.x = normals[ base + j + 0 ];
				n2.y = normals[ base + j + 1 ];
				n2.z = normals[ base + j + 2 ];

				// average normals

				n.addVectors( n1, n2 ).normalize();

				// assign the new values to both normals

				normals[ j + 0 ] = normals[ base + j + 0 ] = n.x;
				normals[ j + 1 ] = normals[ base + j + 1 ] = n.y;
				normals[ j + 2 ] = normals[ base + j + 2 ] = n.z;

			}

		}

	}

}
