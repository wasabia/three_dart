part of three_core;

class Raycaster {

  late Ray ray;
  late num near;
  late num far;
  late Camera camera;
  late Layers layers;
  late Map<String, dynamic> params;


  Raycaster( origin, direction, near, far ) {
    this.ray = Ray( origin, direction );
    // direction is assumed to be normalized (for accurate distance calculations)

    this.near = near ?? 0;
    this.far = far ?? 999999999999;
    this.layers = new Layers();

    this.params = {
      "Mesh": {},
      "Line": { "threshold": 1 },
      "LOD": {},
      "Points": { "threshold": 1 },
      "Sprite": {}
    };
  }


  ascSort( a, b ) {

    return a.distance - b.distance;

  }

  intersectObject4( object, raycaster, intersects, recursive ) {

    if ( object.layers.test( raycaster.layers ) ) {

      object.raycast( raycaster, intersects );

    }

    if ( recursive == true ) {

      var children = object.children;

      for ( var i = 0, l = children.length; i < l; i ++ ) {

        intersectObject4( children[ i ], raycaster, intersects, true );

      }

    }

  }


  set( origin, direction ) {

		// direction is assumed to be normalized (for accurate distance calculations)

		this.ray.set( origin, direction );

	}

	setFromCamera ( coords, camera ) {

		if ( camera && camera.isPerspectiveCamera ) {

			this.ray.origin.setFromMatrixPosition( camera.matrixWorld );
			this.ray.direction.set( coords.x, coords.y, 0.5 ).unproject( camera ).sub( this.ray.origin ).normalize();
			this.camera = camera;

		} else if ( camera && camera.isOrthographicCamera ) {

			this.ray.origin.set( coords.x, coords.y, ( camera.near + camera.far ) / ( camera.near - camera.far ) ).unproject( camera ); // set origin in plane of camera
			this.ray.direction.set( 0, 0, - 1 ).transformDirection( camera.matrixWorld );
			this.camera = camera;

		} else {

			print( 'THREE.Raycaster: Unsupported camera type: ' + camera.type );

		}

	}

	intersectObject( object, recursive, optionalTarget ) {

		var intersects = optionalTarget ?? [];

		intersectObject4( object, this, intersects, recursive );

		intersects.sort( ascSort );

		return intersects;

	}

	intersectObjects( objects, recursive, optionalTarget ) {

		var intersects = optionalTarget ?? [];

		if ( !(objects is List) ) {

			print( 'THREE.Raycaster.intersectObjects: objects is not an Array.' );
			return intersects;

		}

		for ( var i = 0, l = objects.length; i < l; i ++ ) {

			intersectObject4( objects[ i ], this, intersects, recursive );

		}

		intersects.sort( ascSort );

		return intersects;

	}

}



class Intersection {

  late num instanceId;
  late num distance;
  late num distanceToRay;
  late Vector3 point;
  late num index;
  late Face3 face;
  late num faceIndex;
  late Object3D object;
  late Vector2 uv;
  

  Intersection(Map<String, dynamic> json) {
    instanceId = json["instanceId"];
    distance = json["distance"];
    distanceToRay = json["distanceToRay"];
    point = json["point"];
    index = json["index"];
    face = json["face"];
    faceIndex = json["faceIndex"];
    object = json["object"];
    uv = json["uv"];
  }

  
}