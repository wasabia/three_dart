
part of three_geometries;

class PlaneGeometry extends BufferGeometry {

  factory PlaneGeometry.fromJson(Map<String, dynamic> options) {
    return PlaneGeometry(
      width: options["width"],
      height: options["height"],
      widthSegments: options["widthSegments"],
      heightSegments: options["heightSegments"]
    );
  }

	PlaneGeometry( {num width = 1, num height = 1, num widthSegments = 1, num heightSegments = 1} ) : super() {

		this.type = 'PlaneGeometry';

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
		List<double> vertices = [];
		List<double> normals = [];
		List<double> uvs = [];

		for ( var iy = 0; iy < gridY1; iy ++ ) {

			var y = iy * segment_height - height_half;

			for ( var ix = 0; ix < gridX1; ix ++ ) {

				var x = ix * segment_width - width_half;

				vertices.addAll( [x.toDouble(), - y.toDouble(), 0.0] );

				normals.addAll( [0.0, 0.0, 1.0] );

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
		this.setAttribute( 'position', new Float32BufferAttribute( Float32Array.from(vertices), 3, false ) );
		this.setAttribute( 'normal', new Float32BufferAttribute( Float32Array.from(normals), 3, false ) );
		this.setAttribute( 'uv', new Float32BufferAttribute( Float32Array.from(uvs), 2, false ) );

	}

}
