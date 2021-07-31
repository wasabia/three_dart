part of jsm_lines;


// import {
// 	Box3,
// 	Float32BufferAttribute,
// 	InstancedBufferGeometry,
// 	InstancedInterleavedBuffer,
// 	InterleavedBufferAttribute,
// 	Sphere,
// 	Vector3,
// 	WireframeGeometry
// } from '../../../build/three.module.js';


class LineSegmentsGeometry extends InstancedBufferGeometry {

  String type = "LineSegmentsGeometry";
  bool isLineSegmentsGeometry = true;

  LineSegmentsGeometry() : super() {

    List<double> positions = [ - 1, 2, 0, 1, 2, 0, - 1, 1, 0, 1, 1, 0, - 1, 0, 0, 1, 0, 0, - 1, - 1, 0, 1, - 1, 0 ];
    List<double> uvs = [ - 1, 2, 1, 2, - 1, 1, 1, 1, - 1, - 1, 1, - 1, - 1, - 2, 1, - 2 ];
    List<int> index = [ 0, 2, 1, 2, 3, 1, 2, 4, 3, 4, 5, 3, 4, 6, 5, 6, 7, 5 ];

    this.setIndex( index );
    this.setAttribute( 'position', new Float32BufferAttribute( Float32Array.from(positions), 3, false ) );
    this.setAttribute( 'uv', new Float32BufferAttribute( Float32Array.from(uvs), 2, false ) );
  }

  applyMatrix4( matrix ) {

		var start = this.attributes["instanceStart"];
		var end = this.attributes["instanceEnd"];

		if ( start != null ) {

			start.applyMatrix4( matrix );

			end.applyMatrix4( matrix );

			start.needsUpdate = true;

		}

		if ( this.boundingBox != null ) {

			this.computeBoundingBox();

		}

		if ( this.boundingSphere != null ) {

			this.computeBoundingSphere();

		}

		return this;

	}

	setPositions( array ) {

		var lineSegments;

		if ( array is Float32Array ) {

			lineSegments = array;

		} else if ( array is List ) {

			lineSegments = Float32Array.from( array );

		}

		var instanceBuffer = new InstancedInterleavedBuffer( lineSegments, 6, 1 ); // xyz, xyz

		this.setAttribute( 'instanceStart', new InterleavedBufferAttribute( instanceBuffer, 3, 0, false ) ); // xyz
		this.setAttribute( 'instanceEnd', new InterleavedBufferAttribute( instanceBuffer, 3, 3, false ) ); // xyz

		//

		this.computeBoundingBox();
		this.computeBoundingSphere();

		return this;

	}

	setColors( array ) {

		var colors;

		if ( array is Float32Array ) {

			colors = array;

		} else if ( array is List ) {

			colors = Float32Array.from( array );

		}

		var instanceColorBuffer = new InstancedInterleavedBuffer( colors, 6, 1 ); // rgb, rgb

		this.setAttribute( 'instanceColorStart', new InterleavedBufferAttribute( instanceColorBuffer, 3, 0, false ) ); // rgb
		this.setAttribute( 'instanceColorEnd', new InterleavedBufferAttribute( instanceColorBuffer, 3, 3, false ) ); // rgb

		return this;

	}

	fromWireframeGeometry( geometry ) {

		this.setPositions( geometry.attributes.position.array );

		return this;

	}

	fromEdgesGeometry( geometry ) {

		this.setPositions( geometry.attributes.position.array );

		return this;

	}

	fromMesh( mesh ) {

		this.fromWireframeGeometry( new WireframeGeometry( mesh.geometry ) );

		// set colors, maybe

		return this;

	}

	fromLineSegments( lineSegments ) {

		var geometry = lineSegments.geometry;

		if ( geometry.isGeometry ) {

			this.setPositions( geometry.vertices );

		} else if ( geometry.isBufferGeometry ) {

			this.setPositions( geometry.attributes.position.array ); // assumes non-indexed

		}

		// set colors, maybe

		return this;

	}

	computeBoundingBox () {

		var box = new Box3(null, null);

    if ( this.boundingBox == null ) {

      this.boundingBox = new Box3(null, null);

    }

    var start = this.attributes["instanceStart"];
    var end = this.attributes["instanceEnd"];

    if ( start != null && end != null ) {

      this.boundingBox!.setFromBufferAttribute( start );

      box.setFromBufferAttribute( end );

      this.boundingBox!.union( box );

    }


	}

	computeBoundingSphere() {

		var vector = new Vector3.init();

    if ( this.boundingSphere == null ) {

      this.boundingSphere = new Sphere(null, null);

    }

    if ( this.boundingBox == null ) {

      this.computeBoundingBox();

    }

    var start = this.attributes["instanceStart"];
    var end = this.attributes["instanceEnd"];

    if ( start != null && end != null ) {

      var center = this.boundingSphere!.center;

      this.boundingBox!.getCenter( center );

      num maxRadiusSq = 0;

      for ( var i = 0, il = start.count; i < il; i ++ ) {

        vector.fromBufferAttribute( start, i );
        maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( vector ) );

        vector.fromBufferAttribute( end, i );
        maxRadiusSq = Math.max( maxRadiusSq, center.distanceToSquared( vector ) );

      }

      this.boundingSphere!.radius = Math.sqrt( maxRadiusSq );

      if ( this.boundingSphere!.radius == null ) {

        print( 'THREE.LineSegmentsGeometry.computeBoundingSphere(): Computed radius is NaN. The instanced position data is likely to have NaN values. ${this}' );

      }

    }

	}

	// toJSON({}) {

	// 	// todo
  //   print(" toJSON TODO ...........");

	// }

	applyMatrix( matrix ) {

		print( 'THREE.LineSegmentsGeometry: applyMatrix() has been renamed to applyMatrix4().' );

		return this.applyMatrix4( matrix );

	}


}

