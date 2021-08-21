
part of three_geometries;

class TorusKnotGeometry extends BufferGeometry {

  String type = "TorusKnotGeometry";

	TorusKnotGeometry( {radius = 1, tube = 0.4, tubularSegments = 64, radialSegments = 8, p = 2, q = 3} ) : super() {

		this.parameters = {
			"radius": radius,
			"tube": tube,
			"tubularSegments": tubularSegments,
			"radialSegments": radialSegments,
			"p": p,
			"q": q
		};

		tubularSegments = Math.floor( tubularSegments );
		radialSegments = Math.floor( radialSegments );

		// buffers

		List<num> indices = [];
		List<num> vertices = [];
		List<num> normals = [];
		List<num> uvs = [];

		// helper variables

		var vertex = new Vector3.init();
		var normal = new Vector3.init();

		var P1 = new Vector3.init();
		var P2 = new Vector3.init();

		var B = new Vector3.init();
		var T = new Vector3.init();
		var N = new Vector3.init();

    Function calculatePositionOnCurve = ( u, p, q, radius, position ) {

			var cu = Math.cos( u );
			var su = Math.sin( u );
			var quOverP = q / p * u;
			var cs = Math.cos( quOverP );

			position.x = radius * ( 2 + cs ) * 0.5 * cu;
			position.y = radius * ( 2 + cs ) * su * 0.5;
			position.z = radius * Math.sin( quOverP ) * 0.5;

		};

		// generate vertices, normals and uvs

		for ( var i = 0; i <= tubularSegments; ++ i ) {

			// the radian "u" is used to calculate the position on the torus curve of the current tubular segement

			var u = i / tubularSegments * p * Math.PI * 2;

			// now we calculate two points. P1 is our current position on the curve, P2 is a little farther ahead.
			// these points are used to create a special "coordinate space", which is necessary to calculate the correct vertex positions

			calculatePositionOnCurve( u, p, q, radius, P1 );
			calculatePositionOnCurve( u + 0.01, p, q, radius, P2 );

			// calculate orthonormal basis

			T.subVectors( P2, P1 );
			N.addVectors( P2, P1 );
			B.crossVectors( T, N );
			N.crossVectors( B, T );

			// normalize B, N. T can be ignored, we don't use it

			B.normalize();
			N.normalize();

			for ( var j = 0; j <= radialSegments; ++ j ) {

				// now calculate the vertices. they are nothing more than an extrusion of the torus curve.
				// because we extrude a shape in the xy-plane, there is no need to calculate a z-value.

				var v = j / radialSegments * Math.PI * 2;
				var cx = - tube * Math.cos( v );
				var cy = tube * Math.sin( v );

				// now calculate the final vertex position.
				// first we orient the extrusion with our basis vectos, then we add it to the current position on the curve

				vertex.x = P1.x + ( cx * N.x + cy * B.x );
				vertex.y = P1.y + ( cx * N.y + cy * B.y );
				vertex.z = P1.z + ( cx * N.z + cy * B.z );

				vertices.addAll([ vertex.x, vertex.y, vertex.z ]);

				// normal (P1 is always the center/origin of the extrusion, thus we can use it to calculate the normal)

				normal.subVectors( vertex, P1 ).normalize();

				normals.addAll( [normal.x, normal.y, normal.z] );

				// uv

				uvs.add( i / tubularSegments );
				uvs.add( j / radialSegments );

			}

		}

		// generate indices

		for ( var j = 1; j <= tubularSegments; j ++ ) {

			for ( var i = 1; i <= radialSegments; i ++ ) {

				// indices

				var a = ( radialSegments + 1 ) * ( j - 1 ) + ( i - 1 );
				var b = ( radialSegments + 1 ) * j + ( i - 1 );
				var c = ( radialSegments + 1 ) * j + i;
				var d = ( radialSegments + 1 ) * ( j - 1 ) + i;

				// faces

				indices.addAll( [a, b, d] );
				indices.addAll( [b, c, d] );

			}

		}

		// build geometry

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );

		// this function calculates the current position on the torus curve

		

	}

}
