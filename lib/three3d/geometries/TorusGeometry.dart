
part of three_geometries;

class TorusGeometry extends BufferGeometry {


  String type = "TorusGeometry";

	TorusGeometry( [ radius = 1, tube = 0.4, radialSegments = 8, tubularSegments = 6, arc = Math.PI * 2 ]) : super() {

		this.parameters = {
			"radius": radius,
			"tube": tube,
			"radialSegments": radialSegments,
			"tubularSegments": tubularSegments,
			"arc": arc
		};

		radialSegments = Math.floor( radialSegments );
		tubularSegments = Math.floor( tubularSegments );

		// buffers

		List<num> indices = [];
		List<num> vertices = [];
		List<num> normals = [];
		List<num> uvs = [];

		// helper variables

		var center = new Vector3();
		var vertex = new Vector3();
		var normal = new Vector3();

		// generate vertices, normals and uvs

		for ( var j = 0; j <= radialSegments; j ++ ) {

			for ( var i = 0; i <= tubularSegments; i ++ ) {

				var u = i / tubularSegments * arc;
				var v = j / radialSegments * Math.PI * 2;

				// vertex

				vertex.x = ( radius + tube * Math.cos( v ) ) * Math.cos( u );
				vertex.y = ( radius + tube * Math.cos( v ) ) * Math.sin( u );
				vertex.z = tube * Math.sin( v );

				vertices.addAll( [vertex.x, vertex.y, vertex.z] );

				// normal

				center.x = radius * Math.cos( u );
				center.y = radius * Math.sin( u );
				normal.subVectors( vertex, center ).normalize();

				normals.addAll( [normal.x, normal.y, normal.z] );

				// uv

				uvs.add( i / tubularSegments );
				uvs.add( j / radialSegments );

			}

		}

		// generate indices

		for ( var j = 1; j <= radialSegments; j ++ ) {

			for ( var i = 1; i <= tubularSegments; i ++ ) {

				// indices

				var a = ( tubularSegments + 1 ) * j + i - 1;
				var b = ( tubularSegments + 1 ) * ( j - 1 ) + i - 1;
				var c = ( tubularSegments + 1 ) * ( j - 1 ) + i;
				var d = ( tubularSegments + 1 ) * j + i;

				// faces

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

	static fromJSON( data ) {

		return new TorusGeometry( data.radius, data.tube, data.radialSegments, data.tubularSegments, data.arc );

	}

}
