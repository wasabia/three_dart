part of three_objects;

var _start = new Vector3.init();
var _end = new Vector3.init();
var _inverseMatrix = new Matrix4();
var _ray = new Ray(null, null);
var _sphere = new Sphere(null, null);

class Line extends Object3D {

  String type = "Line";
  bool isLine = true;

  Line( BufferGeometry? geometry, Material? material ) : super() {
    this.geometry = geometry ?? BufferGeometry();
    this.material = material ?? LineBasicMaterial(Map<String, dynamic>());

    this.updateMorphTargets();
  }

  Line.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
   
  }



  copy ( Object3D source, bool recursive ) {

		super.copy( source, false );

		this.material = source.material;
		this.geometry = source.geometry;

		return this;

	}

	computeLineDistances () {

		var geometry = this.geometry;

		if ( geometry.isBufferGeometry ) {

			// we assume non-indexed geometry

			if ( geometry.index == null ) {

				var positionAttribute = geometry.attributes["position"];

				// List<num> lineDistances = [ 0.0 ];
        var lineDistances = new Float32Array( positionAttribute.count + 1 );

        lineDistances[0] = 0.0;

				for ( var i = 1, l = positionAttribute.count; i < l; i ++ ) {

					_start.fromBufferAttribute( positionAttribute, i - 1 );
					_end.fromBufferAttribute( positionAttribute, i );

					lineDistances[ i ] = lineDistances[ i - 1 ];
					lineDistances[ i ] += _start.distanceTo( _end );

				}

				geometry.setAttribute( 'lineDistance', new Float32BufferAttribute( lineDistances, 1, false ) );

			} else {

				print( 'THREE.Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.' );

			}

		} else if ( geometry.isGeometry ) {

			var vertices = geometry.vertices;
			var lineDistances = geometry.lineDistances;

			lineDistances[ 0 ] = 0;

			for ( var i = 1, l = vertices.length; i < l; i ++ ) {

				lineDistances[ i ] = lineDistances[ i - 1 ];
				// lineDistances[ i ] += vertices[ i - 1 ].distanceTo( vertices[ i ] );
        print("Line.computeLineDistances() todo ");
			}

		}

		return this;

	}

	raycast ( Raycaster raycaster, List<Intersection> intersects ) {

		var geometry = this.geometry;
		var matrixWorld = this.matrixWorld;
		var threshold = raycaster.params["Line"]["threshold"];

		// Checking boundingSphere distance to ray

		if ( geometry.boundingSphere == null ) geometry.computeBoundingSphere();

		_sphere.copy( geometry.boundingSphere );
		_sphere.applyMatrix4( matrixWorld );
		_sphere.radius += threshold;

		if ( raycaster.ray.intersectsSphere( _sphere ) == false ) return;

		//

		_inverseMatrix.copy( matrixWorld ).invert();
		_ray.copy( raycaster.ray ).applyMatrix4( _inverseMatrix );

		var localThreshold = threshold / ( ( this.scale.x + this.scale.y + this.scale.z ) / 3 );
		var localThresholdSq = localThreshold * localThreshold;

		var vStart = new Vector3.init();
		var vEnd = new Vector3.init();
		var interSegment = new Vector3.init();
		var interRay = new Vector3.init();
		var step = this.type == "LineSegments" ? 2 : 1;

		if ( geometry.isBufferGeometry ) {

			var index = geometry.index;
			var attributes = geometry.attributes;
			var positionAttribute = attributes["position"];

			if ( index != null ) {

				var indices = index.array;

				for ( var i = 0, l = indices.length - 1; i < l; i += step ) {

					var a = indices[ i ];
					var b = indices[ i + 1 ];

					vStart.fromBufferAttribute( positionAttribute, a.toInt() );
					vEnd.fromBufferAttribute( positionAttribute, b.toInt() );

					var distSq = _ray.distanceSqToSegment( vStart, vEnd, interRay, interSegment );

					if ( distSq > localThresholdSq ) continue;

					interRay.applyMatrix4( this.matrixWorld ); //Move back to world space for distance calculation

					var distance = raycaster.ray.origin.distanceTo( interRay );

					if ( distance < raycaster.near || distance > raycaster.far ) continue;

					intersects.add( Intersection({

						"distance": distance,
						// What do we want? intersection point on the ray or on the segment??
						// point: raycaster.ray.at( distance ),
						"point": interSegment.clone().applyMatrix4( this.matrixWorld ),
						"index": i,
						"face": null,
						"faceIndex": null,
						"object": this

					}) );

				}

			} else {

				for ( var i = 0, l = positionAttribute.count - 1; i < l; i += step ) {

					vStart.fromBufferAttribute( positionAttribute, i );
					vEnd.fromBufferAttribute( positionAttribute, i + 1 );

					var distSq = _ray.distanceSqToSegment( vStart, vEnd, interRay, interSegment );

					if ( distSq > localThresholdSq ) continue;

					interRay.applyMatrix4( this.matrixWorld ); //Move back to world space for distance calculation

					var distance = raycaster.ray.origin.distanceTo( interRay );

					if ( distance < raycaster.near || distance > raycaster.far ) continue;

					intersects.add(Intersection({

						"distance": distance,
						// What do we want? intersection point on the ray or on the segment??
						// point: raycaster.ray.at( distance ),
						"point": interSegment.clone().applyMatrix4( this.matrixWorld ),
						"index": i,
						"face": null,
						"faceIndex": null,
						"object": this

					}) );

				}

			}

		} else if ( geometry.isGeometry ) {

			var vertices = geometry.vertices;
			var nbVertices = vertices.length;

			for ( var i = 0; i < nbVertices - 1; i += step ) {

				var distSq = _ray.distanceSqToSegment( vertices[ i ], vertices[ i + 1 ], interRay, interSegment );

				if ( distSq > localThresholdSq ) continue;

				interRay.applyMatrix4( this.matrixWorld ); //Move back to world space for distance calculation

				var distance = raycaster.ray.origin.distanceTo( interRay );

				if ( distance < raycaster.near || distance > raycaster.far ) continue;

				intersects.add( Intersection({

					"distance": distance,
					// What do we want? intersection point on the ray or on the segment??
					// point: raycaster.ray.at( distance ),
					"point": interSegment.clone().applyMatrix4( this.matrixWorld ),
					"index": i,
					"face": null,
					"faceIndex": null,
					"object": this

				}) );

			}

		}

	}

	updateMorphTargets () {

		var geometry = this.geometry;

		if ( geometry.isBufferGeometry ) {

			var morphAttributes = geometry.morphAttributes;
			var keys = morphAttributes.keys.toList();

			if ( keys.length > 0 ) {

				var morphAttribute = morphAttributes[ keys[ 0 ] ];

				if ( morphAttribute != null ) {

					this.morphTargetInfluences = [];
					this.morphTargetDictionary = {};

					for ( int m = 0, ml = morphAttribute.length; m < ml; m ++ ) {

						var name = morphAttribute[ m ].name;

						this.morphTargetInfluences.add( 0 );
						this.morphTargetDictionary[ name ] = m;

					}

				}

			}

		} else {

			var morphTargets = geometry.morphTargets;

			if ( morphTargets != null && morphTargets.length > 0 ) {

				print( 'THREE.Line.updateMorphTargets() does not support THREE.Geometry. Use THREE.BufferGeometry instead.' );

			}

		}

	}

}

