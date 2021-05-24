
part of three_geometries;

class PlaneBufferGeometry extends BufferGeometry {

	PlaneBufferGeometry( {num width = 1, num height = 1, double widthSegments = 1, double heightSegments = 1} ) : super() {

		this.type = 'PlaneBufferGeometry';

		this.parameters = {
			"width": width,
			"height": height,
			"widthSegments": widthSegments,
			"heightSegments": heightSegments
		};

		num width_half = width / 2.0;
		num height_half = height / 2.0;

		num gridX = Math.floor( widthSegments );
		num gridY = Math.floor( heightSegments );

		num gridX1 = gridX + 1;
		num gridY1 = gridY + 1;

		num segment_width = width / gridX;
		num segment_height = height / gridY;

		//

		List<num> indices = [];
		List<num> vertices = [];
		List<num> normals = [];
		List<num> uvs = [];

		for ( var iy = 0; iy < gridY1; iy ++ ) {

			var y = iy * segment_height - height_half;

			for ( var ix = 0; ix < gridX1; ix ++ ) {

				var x = ix * segment_width - width_half;

				vertices.addAll( [x, - y, 0] );

				normals.addAll( [0, 0, 1] );

				uvs.add( ix / gridX );
				uvs.add( 1 - ( iy / gridY ) );

			}

		}

		for ( var iy = 0; iy < gridY; iy ++ ) {

			for ( var ix = 0; ix < gridX; ix ++ ) {

				var a = ix + gridX1 * iy;
				var b = ix + gridX1 * ( iy + 1 );
				var c = ( ix + 1 ) + gridX1 * ( iy + 1 );
				var d = ( ix + 1 ) + gridX1 * iy;

				indices.addAll( [a, b, d] );
				indices.addAll( [b, c, d] );

			}

		}

		this.setIndex( indices );
		this.setAttribute( 'position', new Float32BufferAttribute( vertices, 3, false ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( normals, 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( uvs, 2, false ) );

	}

}
