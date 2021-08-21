part of three_geometries;

class SphereGeometry extends BufferGeometry {

  String type = "SphereGeometry";

	SphereGeometry( {radius = 1, num widthSegments = 8, num heightSegments = 6, phiStart = 0, phiLength = Math.PI * 2, thetaStart = 0, thetaLength = Math.PI} ): super() {

		this.parameters = {
			"radius": radius,
			"widthSegments": widthSegments,
			"heightSegments": heightSegments,
			"phiStart": phiStart,
			"phiLength": phiLength,
			"thetaStart": thetaStart,
			"thetaLength": thetaLength
		};

		widthSegments = Math.max( 3, Math.floor( widthSegments ) );
		heightSegments = Math.max( 2, Math.floor( heightSegments ) );

		var thetaEnd = Math.min( thetaStart + thetaLength, Math.PI );

		var index = 0;
		var grid = [];

		var vertex = Vector3.init();
		var normal = Vector3.init();

		// buffers

		List<num> indices = [];
		List<num> vertices = [];
		List<num> normals = [];
		List<num> uvs = [];

		// generate vertices, normals and uvs

		for ( var iy = 0; iy <= heightSegments; iy ++ ) {

			var verticesRow = [];

			var v = iy / heightSegments;

			// special case for the poles

			num uOffset = 0;

			if ( iy == 0 && thetaStart == 0 ) {

				uOffset = 0.5 / widthSegments;

			} else if ( iy == heightSegments && thetaEnd == Math.PI ) {

				uOffset = - 0.5 / widthSegments;

			}

			for ( var ix = 0; ix <= widthSegments; ix ++ ) {

				var u = ix / widthSegments;

				// vertex

				vertex.x = - radius * Math.cos( phiStart + u * phiLength ) * Math.sin( thetaStart + v * thetaLength );
				vertex.y = radius * Math.cos( thetaStart + v * thetaLength );
				vertex.z = radius * Math.sin( phiStart + u * phiLength ) * Math.sin( thetaStart + v * thetaLength );

				vertices.addAll( [vertex.x, vertex.y, vertex.z] );

				// normal

				normal.copy( vertex ).normalize();
				normals.addAll( [normal.x, normal.y, normal.z] );

				// uv

				uvs.addAll( [u + uOffset, 1 - v] );

				verticesRow.add( index ++ );

			}

			grid.add( verticesRow );

		}


		// indices

		for ( var iy = 0; iy < heightSegments; iy ++ ) {

			for ( var ix = 0; ix < widthSegments; ix ++ ) {

				var a = grid[ iy ][ ix + 1 ];
				var b = grid[ iy ][ ix ];
				var c = grid[ iy + 1 ][ ix ];
				var d = grid[ iy + 1 ][ ix + 1 ];

				if ( iy != 0 || thetaStart > 0 ) indices.addAll( [a, b, d] );
				if ( iy != heightSegments - 1 || thetaEnd < Math.PI ) indices.addAll( [b, c, d] );

			}

		}

		// build geometry

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );

	}

}