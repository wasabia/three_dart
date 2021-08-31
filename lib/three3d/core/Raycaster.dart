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
    this.far = far ?? double.infinity;
    this.layers = new Layers();

    this.params = {
      "Mesh": {},
      "Line": { "threshold": 1 },
      "LOD": {},
      "Points": { "threshold": 1 },
      "Sprite": {}
    };
  }


  int ascSort( a, b ) {

    return a.distance - b.distance >= 0 ? 1 : -1;

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

		if ( camera != null && camera.isPerspectiveCamera ) {

			this.ray.origin.setFromMatrixPosition( camera.matrixWorld );
			this.ray.direction.set( coords.x, coords.y, 0.5 ).unproject( camera ).sub( this.ray.origin ).normalize();
			this.camera = camera;

		} else if ( camera != null && camera.isOrthographicCamera ) {

			this.ray.origin.set( coords.x, coords.y, ( camera.near + camera.far ) / ( camera.near - camera.far ) ).unproject( camera ); // set origin in plane of camera
			this.ray.direction.set( 0, 0, - 1 ).transformDirection( camera.matrixWorld );
			this.camera = camera;

		} else {

			print( 'THREE.Raycaster: Unsupported camera type: ' + camera.type );

		}

	}

	intersectObject( object, recursive, intersects ) {

		intersectObject4( object, this, intersects ?? [], recursive );

		intersects.sort( ascSort );

		return intersects;

	}

	intersectObjects( objects, recursive, {List<Intersection>? intersects} ) {

    intersects = intersects ?? List<Intersection>.from([]);
    

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
  Face? face;
  late num faceIndex;
  late Object3D object;
  late Vector2 uv;
  Vector2? uv2;
  

  Intersection(Map<String, dynamic> json) {
    if(json["instanceId"] != null) {
      instanceId = json["instanceId"];
    }
    
    if(json["distance"] != null) {
      distance = json["distance"];
    }
    
    if(json["distanceToRay"] != null) {
      distanceToRay = json["distanceToRay"];
    }

    if(json["point"] != null) {
      point = json["point"];
    }

    if(json["index"] != null) {
      index = json["index"];
    }

    if(json["face"] != null) {
      face = json["face"];
    }

    if(json["faceIndex"] != null) {
      faceIndex = json["faceIndex"];
    }

    if(json["object"] != null) {
      object = json["object"];
    }

    if(json["uv"] != null) {
      uv = json["uv"];
    }

    if(json["uv2"] != null) {
      uv2 = json["uv2"];
    }
  }

  
}

class Face {
  late num a;
  late num b;
  late num c;
  late Vector3 normal;
  late num materialIndex;
  
  Face(this.a, this.b, this.c, this.normal, this.materialIndex) {}

  factory Face.fromJSON(json) {
    return Face(json["a"], json["b"], json["c"], json["normal"], json["materialIndex"]);
  }
}