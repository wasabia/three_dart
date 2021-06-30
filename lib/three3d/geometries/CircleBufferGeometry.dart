part of three_geometries;

class CircleBufferGeometry extends BufferGeometry {

	CircleBufferGeometry( {radius = 1, segments = 8, thetaStart = 0, thetaLength = Math.PI * 2} ) : super() {

		this.type = 'CircleBufferGeometry';

		this.parameters = {
			"radius": radius,
			"segments": segments,
			"thetaStart": thetaStart,
			"thetaLength": thetaLength
		};

		segments = Math.max( 3, segments );

		// buffers

		List<num> indices = [];
		List<num> vertices = [];
		List<num> normals = [];
		List<num> uvs = [];

		// helper variables

		var vertex = new Vector3.init();
		var uv = new Vector2(null, null);

		// center point

		vertices.addAll( [0, 0, 0] );
		normals.addAll( [0, 0, 1] );
		uvs.addAll( [0.5, 0.5] );

		for ( var s = 0, i = 3; s <= segments; s ++, i += 3 ) {

			var segment = thetaStart + s / segments * thetaLength;

			// vertex

			vertex.x = radius * Math.cos( segment );
			vertex.y = radius * Math.sin( segment );

			vertices.addAll( [vertex.x, vertex.y, vertex.z] );

			// normal

			normals.addAll( [0, 0, 1] );

			// uvs

			uv.x = ( vertices[ i ] / radius + 1 ) / 2;
			uv.y = ( vertices[ i + 1 ] / radius + 1 ) / 2;

			uvs.addAll( [uv.x, uv.y] );

		}

		// indices

		for ( var i = 1; i <= segments; i ++ ) {

			indices.addAll( [i, i + 1, 0] );

		}

		// build geometry

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );

	}

}

