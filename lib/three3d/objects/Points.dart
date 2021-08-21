part of three_objects;

var _pointsinverseMatrix = new Matrix4();
var _pointsray = new Ray(null, null);
var _pointssphere = new Sphere(null, null);
var _position = new Vector3.init();

class Points extends Object3D {

  Points( BufferGeometry geometry, Material material) {
    this.type = 'Points';
    this.isPoints = true;

    this.geometry = geometry;
    this.material = material;

    this.updateMorphTargets();
  }

  Points.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
   
  }

  copy (Object3D source, bool recursive ) {

    super.copy(source, false);

    Points source1 = source as Points;


		this.material = source1.material;
		this.geometry = source1.geometry;

		return this;

	}

	raycast( raycaster, intersects ) {

		var geometry = this.geometry;
		var matrixWorld = this.matrixWorld;
		var threshold = raycaster.params["Points"].threshold;
    var drawRange = geometry.drawRange;

		// Checking boundingSphere distance to ray

		if ( geometry.boundingSphere == null ) geometry.computeBoundingSphere();

		_pointssphere.copy( geometry.boundingSphere );
		_pointssphere.applyMatrix4( matrixWorld );
		_pointssphere.radius += threshold;

		if ( raycaster.ray.intersectsSphere( _pointssphere ) == false ) return;

		//

		_pointsinverseMatrix.copy( matrixWorld ).invert();
		_pointsray.copy( raycaster.ray ).applyMatrix4( _pointsinverseMatrix );

		var localThreshold = threshold / ( ( this.scale.x + this.scale.y + this.scale.z ) / 3 );
		var localThresholdSq = localThreshold * localThreshold;


    var index = geometry.index;
    var attributes = geometry.attributes;
    var positionAttribute = attributes["position"];

    if ( index != null ) {

      var start = Math.max( 0, drawRange["start"]! );
      var end = Math.min( index.count, ( drawRange["start"]! + drawRange["count"]! ) );

      for ( var i = start, il = end; i < il; i ++ ) {

        var a = index.getX( i );

        _position.fromBufferAttribute( positionAttribute, a.toInt() );

        testPoint( _position, a, localThresholdSq, matrixWorld, raycaster, intersects, this );

      }

    } else {

      var start = Math.max( 0, drawRange["start"]! );
      var end = Math.min( positionAttribute.count, ( drawRange["start"]! + drawRange["count"]! ) );

      for ( var i = start, l = end; i < l; i ++ ) {

        _position.fromBufferAttribute( positionAttribute, i );

        testPoint( _position, i, localThresholdSq, matrixWorld, raycaster, intersects, this );

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

					for ( var m = 0, ml = morphAttribute.length; m < ml; m ++ ) {

						var name = morphAttribute[ m ].name;

						this.morphTargetInfluences!.add( 0 );
						this.morphTargetDictionary![ name ] = m;

					}

				}

			}

		} else {

			var morphTargets = geometry.morphTargets;

			if ( morphTargets != null && morphTargets.length > 0 ) {

				print( 'THREE.Points.updateMorphTargets() does not support THREE.Geometry. Use THREE.BufferGeometry instead.' );

			}

		}

	}

	

}


testPoint( point, index, localThresholdSq, matrixWorld, raycaster, intersects, object ) {

	var rayPointDistanceSq = _pointsray.distanceSqToPoint( point );

	if ( rayPointDistanceSq < localThresholdSq ) {

		var intersectPoint = new Vector3.init();

		_pointsray.closestPointToPoint( point, intersectPoint );
		intersectPoint.applyMatrix4( matrixWorld );

		var distance = raycaster.ray.origin.distanceTo( intersectPoint );

		if ( distance < raycaster.near || distance > raycaster.far ) return;

		intersects.add( {

			"distance": distance,
			"distanceToRay": Math.sqrt( rayPointDistanceSq ),
			"point": intersectPoint,
			"index": index,
			"face": null,
			"object": object

		} );

	}

}
