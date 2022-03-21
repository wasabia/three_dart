part of three_core;

class Raycaster {
  late Ray ray;
  late num near;
  late num far;
  late Camera camera;
  late Layers layers;
  late Map<String, dynamic> params;

  Raycaster([Vector3? origin, Vector3? direction, num? near, num? far]) {
    ray = Ray(origin, direction);
    // direction is assumed to be normalized (for accurate distance calculations)

    this.near = near ?? 0;
    this.far = far ?? double.infinity;
    layers = Layers();

    params = {
      "Mesh": {},
      "Line": {"threshold": 1},
      "LOD": {},
      "Points": {"threshold": 1},
      "Sprite": {}
    };
  }

  int ascSort(Intersection a, Intersection b) {
    return a.distance - b.distance >= 0 ? 1 : -1;
  }

  void intersectObject4(Object3D object, Raycaster raycaster,
      List<Intersection> intersects, bool recursive) {
    if (object.layers.test(raycaster.layers)) {
      object.raycast(raycaster, intersects);
    }

    if (recursive == true) {
      var children = object.children;

      for (var i = 0, l = children.length; i < l; i++) {
        intersectObject4(children[i], raycaster, intersects, true);
      }
    }
  }

  void set(Vector3 origin, Vector3 direction) {
    // direction is assumed to be normalized (for accurate distance calculations)

    ray.set(origin, direction);
  }

  void setFromCamera(Vector2 coords, Camera camera) {
    if (camera is PerspectiveCamera) {
      ray.origin.setFromMatrixPosition(camera.matrixWorld);
      ray
          .direction
          .set(coords.x, coords.y, 0.5)
          .unproject(camera)
          .sub(ray.origin)
          .normalize();
      this.camera = camera;
    } else if (camera is OrthographicCamera) {
      ray
          .origin
          .set(coords.x, coords.y,
              (camera.near + camera.far) / (camera.near - camera.far))
          .unproject(camera); // set origin in plane of camera
      ray.direction.set(0, 0, -1).transformDirection(camera.matrixWorld);
      this.camera = camera;
    } else {
      print('THREE.Raycaster: Unsupported camera type: ' + camera.type);
    }
  }

  List<Intersection> intersectObject(Object3D object, bool recursive,
      [List<Intersection>? intersects]) {
    List<Intersection> _intersects = intersects ?? [];

    intersectObject4(object, this, _intersects, recursive);

    _intersects.sort(ascSort);

    return _intersects;
  }

  List<Intersection> intersectObjects(List<Object3D> objects, bool recursive,
      [List<Intersection>? intersects]) {
    intersects = intersects ?? List<Intersection>.from([]);

    for (var i = 0, l = objects.length; i < l; i++) {
      intersectObject4(objects[i], this, intersects, recursive);
    }

    intersects.sort(ascSort);

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
    if (json["instanceId"] != null) {
      instanceId = json["instanceId"];
    }

    if (json["distance"] != null) {
      distance = json["distance"];
    }

    if (json["distanceToRay"] != null) {
      distanceToRay = json["distanceToRay"];
    }

    if (json["point"] != null) {
      point = json["point"];
    }

    if (json["index"] != null) {
      index = json["index"];
    }

    if (json["face"] != null) {
      face = json["face"];
    }

    if (json["faceIndex"] != null) {
      faceIndex = json["faceIndex"];
    }

    if (json["object"] != null) {
      object = json["object"];
    }

    if (json["uv"] != null) {
      uv = json["uv"];
    }

    if (json["uv2"] != null) {
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

  Face(this.a, this.b, this.c, this.normal, this.materialIndex);

  factory Face.fromJSON(Map<String, dynamic> json) {
    return Face(
      json["a"],
      json["b"],
      json["c"],
      json["normal"],
      json["materialIndex"],
    );
  }
}
