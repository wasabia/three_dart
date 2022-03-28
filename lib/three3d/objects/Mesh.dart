part of three_objects;

var _meshinverseMatrix = Matrix4();
var _meshray = Ray(null, null);
var _meshsphere = Sphere(null, null);

var _vA = Vector3.init();
var _vB = Vector3.init();
var _vC = Vector3.init();

var _tempA = Vector3.init();
var _tempB = Vector3.init();
var _tempC = Vector3.init();

var _morphA = Vector3.init();
var _morphB = Vector3.init();
var _morphC = Vector3.init();

var _uvA = Vector2(null, null);
var _uvB = Vector2(null, null);
var _uvC = Vector2(null, null);

var _intersectionPoint = Vector3.init();
var _intersectionPointWorld = Vector3.init();

class Mesh extends Object3D {
  Mesh(BufferGeometry? geometry, material) : super() {
    this.geometry = geometry ?? BufferGeometry();
    this.material = material;
    type = "Mesh";
    updateMorphTargets();
  }

  Mesh.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    type = "Mesh";
  }

  @override
  Mesh clone([bool? recursive = true]) {
    return Mesh(geometry!, material).copy(this, recursive);
  }

  @override
  Mesh copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);
    if (source is Mesh) {
      if (source.morphTargetInfluences != null) {
        morphTargetInfluences = source.morphTargetInfluences!.sublist(0);
      }
      if (source.morphTargetDictionary != null) {
        morphTargetDictionary =
            json.decode(json.encode(source.morphTargetDictionary));
      }
      material = source.material;
      geometry = source.geometry;
    }
    return this;
  }

  void updateMorphTargets() {
    var geometry = this.geometry;

    if (geometry is BufferGeometry) {
      var morphAttributes = geometry.morphAttributes;
      var keys = morphAttributes.keys.toList();

      if (keys.isNotEmpty) {
        List<BufferAttribute>? morphAttribute = morphAttributes[keys[0]];

        if (morphAttribute != null) {
          morphTargetInfluences = [];
          morphTargetDictionary = {};

          for (var m = 0, ml = morphAttribute.length; m < ml; m++) {
            String name = morphAttribute[m].name ?? m.toString();

            morphTargetInfluences!.add(0.0);
            morphTargetDictionary![name] = m;
          }
        }
      }
    }
    // else {
    //   var morphTargets = geometry?.morphTargets;

    //   if (morphTargets != null && morphTargets.length > 0) {
    //     print(
    //         'THREE.Mesh.updateMorphTargets() no longer supports THREE.Geometry. Use THREE.BufferGeometry instead.');
    //   }
    // }
  }

  @override
  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    // print(" raycast: ${this.name} ${this} ");

    var geometry = this.geometry!;
    var material = this.material;
    var matrixWorld = this.matrixWorld;

    if (material == null) return;

    // Checking boundingSphere distance to ray

    if (geometry.boundingSphere == null) geometry.computeBoundingSphere();

    _meshsphere.copy(geometry.boundingSphere!);
    _meshsphere.applyMatrix4(matrixWorld);

    if (raycaster.ray.intersectsSphere(_meshsphere) == false) return;

    _meshinverseMatrix.copy(matrixWorld).invert();
    _meshray.copy(raycaster.ray).applyMatrix4(_meshinverseMatrix);

    // Check boundingBox before continuing

    if (geometry.boundingBox != null) {
      if (_meshray.intersectsBox(geometry.boundingBox!) == false) return;
    }

    Intersection? intersection;
    var index = geometry.index;
    var position = geometry.attributes["position"];
    var morphPosition = geometry.morphAttributes["position"];
    var morphTargetsRelative = geometry.morphTargetsRelative;
    var uv = geometry.attributes["uv"];
    var uv2 = geometry.attributes["uv2"];
    var groups = geometry.groups;
    var drawRange = geometry.drawRange;

    if (index != null) {
      // indexed buffer geometry

      if (material is List) {
        for (var i = 0, il = groups.length; i < il; i++) {
          var group = groups[i];
          var groupMaterial = material[group["materialIndex"]];

          var start = Math.max<int>(group["start"], drawRange["start"]!);
          var end = Math.min<int>((group["start"] + group["count"]),
              (drawRange["start"]! + drawRange["count"]!));

          for (var j = start, jl = end; j < jl; j += 3) {
            int a = index.getX(j)!.toInt();
            int b = index.getX(j + 1)!.toInt();
            int c = index.getX(j + 2)!.toInt();

            intersection = checkBufferGeometryIntersection(
                this,
                groupMaterial,
                raycaster,
                _meshray,
                position,
                morphPosition,
                morphTargetsRelative,
                uv,
                uv2,
                a,
                b,
                c);

            if (intersection != null) {
              intersection.faceIndex = Math.floor(j / 3);
              // triangle number in indexed buffer semantics
              intersection.face?.materialIndex = group["materialIndex"];
              intersects.add(intersection);
            }
          }
        }
      } else {
        var start = Math.max(0, drawRange["start"]!);
        var end =
            Math.min(index.count, (drawRange["start"]! + drawRange["count"]!));

        for (var i = start, il = end; i < il; i += 3) {
          int a = index.getX(i)!.toInt();
          int b = index.getX(i + 1)!.toInt();
          int c = index.getX(i + 2)!.toInt();

          intersection = checkBufferGeometryIntersection(
              this,
              material,
              raycaster,
              _meshray,
              position,
              morphPosition,
              morphTargetsRelative,
              uv,
              uv2,
              a,
              b,
              c);

          if (intersection != null) {
            intersection.faceIndex = Math.floor(i / 3);
            // triangle number in indexed buffer semantics
            intersects.add(intersection);
          }
        }
      }
    } else if (position != null) {
      // non-indexed buffer geometry

      if (material is List) {
        for (var i = 0, il = groups.length; i < il; i++) {
          var group = groups[i];
          var groupMaterial = material[group["materialIndex"]];

          var start = Math.max<int>(group["start"], drawRange["start"]!);
          var end = Math.min<int>((group["start"] + group["count"]),
              (drawRange["start"]! + drawRange["count"]!));

          for (var j = start, jl = end; j < jl; j += 3) {
            var a = j;
            var b = j + 1;
            var c = j + 2;

            intersection = checkBufferGeometryIntersection(
                this,
                groupMaterial,
                raycaster,
                _meshray,
                position,
                morphPosition,
                morphTargetsRelative,
                uv,
                uv2,
                a,
                b,
                c);

            if (intersection != null) {
              intersection.faceIndex = Math.floor(j / 3);
              // triangle number in non-indexed buffer semantics
              intersection.face?.materialIndex = group["materialIndex"];
              intersects.add(intersection);
            }
          }
        }
      } else {
        var start = Math.max(0, drawRange["start"]!);
        var end = Math.min<int>(
            position.count, (drawRange["start"]! + drawRange["count"]!));

        for (var i = start, il = end; i < il; i += 3) {
          var a = i;
          var b = i + 1;
          var c = i + 2;

          intersection = checkBufferGeometryIntersection(
              this,
              material,
              raycaster,
              _meshray,
              position,
              morphPosition,
              morphTargetsRelative,
              uv,
              uv2,
              a,
              b,
              c);

          if (intersection != null) {
            intersection.faceIndex = Math.floor(
                i / 3); // triangle number in non-indexed buffer semantics
            intersects.add(intersection);
          }
        }
      }
    }
  }
}

Intersection? checkIntersection(
    Object3D object,
    Material material,
    Raycaster raycaster,
    Ray ray,
    Vector3 pA,
    Vector3 pB,
    Vector3 pC,
    Vector3 point) {
  Vector3? intersect;

  if (material.side == BackSide) {
    intersect = ray.intersectTriangle(pC, pB, pA, true, point);
  } else {
    intersect =
        ray.intersectTriangle(pA, pB, pC, material.side != DoubleSide, point);
  }

  if (intersect == null) return null;

  _intersectionPointWorld.copy(point);
  _intersectionPointWorld.applyMatrix4(object.matrixWorld);

  var distance = raycaster.ray.origin.distanceTo(_intersectionPointWorld);

  if (distance < raycaster.near || distance > raycaster.far) return null;

  return Intersection({
    "distance": distance,
    "point": _intersectionPointWorld.clone(),
    "object": object
  });
}

Intersection? checkBufferGeometryIntersection(
    Object3D object,
    Material material,
    Raycaster raycaster,
    Ray ray,
    BufferAttribute position,
    morphPosition,
    morphTargetsRelative,
    uv,
    uv2,
    int a,
    int b,
    int c) {
  _vA.fromBufferAttribute(position, a);
  _vB.fromBufferAttribute(position, b);
  _vC.fromBufferAttribute(position, c);

  var morphInfluences = object.morphTargetInfluences;

  if (morphPosition != null && morphInfluences != null) {
    _morphA.set(0, 0, 0);
    _morphB.set(0, 0, 0);
    _morphC.set(0, 0, 0);

    for (var i = 0, il = morphPosition.length; i < il; i++) {
      var influence = morphInfluences[i];
      var morphAttribute = morphPosition[i];

      if (influence == 0) continue;

      _tempA.fromBufferAttribute(morphAttribute, a);
      _tempB.fromBufferAttribute(morphAttribute, b);
      _tempC.fromBufferAttribute(morphAttribute, c);

      if (morphTargetsRelative) {
        _morphA.addScaledVector(_tempA, influence);
        _morphB.addScaledVector(_tempB, influence);
        _morphC.addScaledVector(_tempC, influence);
      } else {
        _morphA.addScaledVector(_tempA.sub(_vA), influence);
        _morphB.addScaledVector(_tempB.sub(_vB), influence);
        _morphC.addScaledVector(_tempC.sub(_vC), influence);
      }
    }

    _vA.add(_morphA);
    _vB.add(_morphB);
    _vC.add(_morphC);
  }

  if (object is SkinnedMesh) {
    object.boneTransform(a, _vA);
    object.boneTransform(b, _vB);
    object.boneTransform(c, _vC);
  }

  var intersection = checkIntersection(
      object, material, raycaster, ray, _vA, _vB, _vC, _intersectionPoint);

  if (intersection != null) {
    if (uv != null) {
      _uvA.fromBufferAttribute(uv, a);
      _uvB.fromBufferAttribute(uv, b);
      _uvC.fromBufferAttribute(uv, c);

      intersection.uv = Triangle.static_getUV(_intersectionPoint, _vA, _vB, _vC,
          _uvA, _uvB, _uvC, Vector2(null, null));
    }

    if (uv2 != null) {
      _uvA.fromBufferAttribute(uv2, a);
      _uvB.fromBufferAttribute(uv2, b);
      _uvC.fromBufferAttribute(uv2, c);

      intersection.uv2 = Triangle.static_getUV(_intersectionPoint, _vA, _vB,
          _vC, _uvA, _uvB, _uvC, Vector2(null, null));
    }

    var face = Face.fromJSON(
        {"a": a, "b": b, "c": c, "normal": Vector3.init(), "materialIndex": 0});

    Triangle.static_getNormal(_vA, _vB, _vC, face.normal);

    intersection.face = face;
  }

  return intersection;
}
