part of three_geometries;

/**
 * Parametric Surfaces Geometry
 * based on the brilliant article by @prideout https://prideout.net/blog/old/blog/index.html@p=44.html
 */


class ParametricGeometry extends BufferGeometry {

  String type = "ParametricGeometry";

	ParametricGeometry( func, slices, stacks ) : super() {

		this.parameters = {
			"func": func,
			"slices": slices,
			"stacks": stacks
		};

		// buffers

		List<num> indices = [];
		List<num> vertices = [];
		List<num> normals = [];
		List<num> uvs = [];

		var EPS = 0.00001;

		var normal = new Vector3();

		var p0 = new Vector3(), p1 = new Vector3();
		var pu = new Vector3(), pv = new Vector3();

		if ( func.length < 3 ) {

			print( 'THREE.ParametricGeometry: Function must now modify a Vector3 as third parameter.' );

		}

		// generate vertices, normals and uvs

		var sliceCount = slices + 1;

		for ( var i = 0; i <= stacks; i ++ ) {

			var v = i / stacks;

			for ( var j = 0; j <= slices; j ++ ) {

				var u = j / slices;

				// vertex

				func( u, v, p0 );
				vertices.addAll( [p0.x, p0.y, p0.z] );

				// normal

				// approximate tangent vectors via finite differences

				if ( u - EPS >= 0 ) {

					func( u - EPS, v, p1 );
					pu.subVectors( p0, p1 );

				} else {

					func( u + EPS, v, p1 );
					pu.subVectors( p1, p0 );

				}

				if ( v - EPS >= 0 ) {

					func( u, v - EPS, p1 );
					pv.subVectors( p0, p1 );

				} else {

					func( u, v + EPS, p1 );
					pv.subVectors( p1, p0 );

				}

				// cross product of tangent vectors returns surface normal

				normal.crossVectors( pu, pv ).normalize();
				normals.addAll( [normal.x, normal.y, normal.z] );

				// uv

				uvs.addAll( [u, v] );

			}

		}

		// generate indices

		for ( var i = 0; i < stacks; i ++ ) {

			for ( var j = 0; j < slices; j ++ ) {

				var a = i * sliceCount + j;
				var b = i * sliceCount + j + 1;
				var c = ( i + 1 ) * sliceCount + j + 1;
				var d = ( i + 1 ) * sliceCount + j;

				// faces one and two

				indices.addAll( [a, b, d] );
				indices.addAll( [b, c, d] );

			}

		}

		// build geometry

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3 ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3 ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2 ) );

	}

}

