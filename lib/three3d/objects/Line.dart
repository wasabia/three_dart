part of three_objects;

var _start = Vector3.init();
var _end = Vector3.init();
var _inverseMatrix = Matrix4();
var _ray = Ray(null, null);
var _sphere = Sphere(null, null);

class Line extends Object3D {
  Line(BufferGeometry? geometry, Material? material) : super() {
    this.geometry = geometry ?? BufferGeometry();
    this.material = material ?? LineBasicMaterial(<String, dynamic>{});
    type = "Line";
    isLine = true;
    updateMorphTargets();
  }

  Line.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON) {
    type = "Line";
    isLine = true;
  }

  @override
  Line copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    material = source.material;
    geometry = source.geometry;

    return this;
  }

  @override
  Line clone([bool? recursive = true]) {
    return Line(geometry!, material!).copy(this, recursive);
  }

  Line computeLineDistances() {
    var geometry = this.geometry!;

    if (geometry.isBufferGeometry) {
      // we assume non-indexed geometry

      if (geometry.index == null) {
        var positionAttribute = geometry.attributes["position"];

        // List<num> lineDistances = [ 0.0 ];
        var lineDistances = Float32List(positionAttribute.count + 1);

        lineDistances[0] = 0.0;

        for (var i = 1, l = positionAttribute.count; i < l; i++) {
          _start.fromBufferAttribute(positionAttribute, i - 1);
          _end.fromBufferAttribute(positionAttribute, i);

          lineDistances[i] = lineDistances[i - 1];
          lineDistances[i] += _start.distanceTo(_end);
        }

        geometry.setAttribute('lineDistance',
            Float32BufferAttribute(lineDistances, 1, false));
      } else {
        print(
            'THREE.Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.');
      }
    } else if (geometry.isGeometry) {
      throw ('THREE.Line.computeLineDistances() no longer supports THREE.Geometry. Use THREE.BufferGeometry instead.');
    }

    return this;
  }

  @override
  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    var geometry = this.geometry!;
    var matrixWorld = this.matrixWorld;
    var threshold = raycaster.params["Line"]["threshold"];
    var drawRange = geometry.drawRange;

    // Checking boundingSphere distance to ray

    if (geometry.boundingSphere == null) geometry.computeBoundingSphere();

    _sphere.copy(geometry.boundingSphere!);
    _sphere.applyMatrix4(matrixWorld);
    _sphere.radius += threshold;

    if (raycaster.ray.intersectsSphere(_sphere) == false) return;

    //

    _inverseMatrix.copy(matrixWorld).invert();
    _ray.copy(raycaster.ray).applyMatrix4(_inverseMatrix);

    var localThreshold =
        threshold / ((scale.x + scale.y + scale.z) / 3);
    var localThresholdSq = localThreshold * localThreshold;

    var vStart = Vector3.init();
    var vEnd = Vector3.init();
    var interSegment = Vector3.init();
    var interRay = Vector3.init();
    var step = type == "LineSegments" ? 2 : 1;

    var index = geometry.index;
    var attributes = geometry.attributes;
    var positionAttribute = attributes["position"];

    if (index != null) {
      var start = Math.max(0, drawRange["start"]!);
      var end =
          Math.min(index.count, (drawRange["start"]! + drawRange["count"]!));

      for (var i = start, l = end - 1; i < l; i += step) {
        var a = index.getX(i)!;
        var b = index.getX(i + 1)!;

        vStart.fromBufferAttribute(positionAttribute, a.toInt());
        vEnd.fromBufferAttribute(positionAttribute, b.toInt());

        var distSq =
            _ray.distanceSqToSegment(vStart, vEnd, interRay, interSegment);

        if (distSq > localThresholdSq) continue;

        interRay.applyMatrix4(this
            .matrixWorld); //Move back to world space for distance calculation

        var distance = raycaster.ray.origin.distanceTo(interRay);

        if (distance < raycaster.near || distance > raycaster.far) continue;

        intersects.add(Intersection({
          "distance": distance,
          // What do we want? intersection point on the ray or on the segment??
          // point: raycaster.ray.at( distance ),
          "point": interSegment.clone().applyMatrix4(this.matrixWorld),
          "index": i,
          "face": null,
          "faceIndex": null,
          "object": this
        }));
      }
    } else {
      var start = Math.max(0, drawRange["start"]!);
      var end = Math.min(
          positionAttribute.count, (drawRange["start"]! + drawRange["count"]!));

      for (var i = start, l = end - 1; i < l; i += step) {
        vStart.fromBufferAttribute(positionAttribute, i);
        vEnd.fromBufferAttribute(positionAttribute, i + 1);

        var distSq =
            _ray.distanceSqToSegment(vStart, vEnd, interRay, interSegment);

        if (distSq > localThresholdSq) continue;

        interRay.applyMatrix4(this
            .matrixWorld); //Move back to world space for distance calculation

        var distance = raycaster.ray.origin.distanceTo(interRay);

        if (distance < raycaster.near || distance > raycaster.far) continue;

        intersects.add(Intersection({
          "distance": distance,
          // What do we want? intersection point on the ray or on the segment??
          // point: raycaster.ray.at( distance ),
          "point": interSegment.clone().applyMatrix4(this.matrixWorld),
          "index": i,
          "face": null,
          "faceIndex": null,
          "object": this
        }));
      }
    }
  }

  void updateMorphTargets() {
    var geometry = this.geometry!;

    if (geometry.isBufferGeometry) {
      var morphAttributes = geometry.morphAttributes;
      var keys = morphAttributes.keys.toList();

      if (keys.isNotEmpty) {
        var morphAttribute = morphAttributes[keys[0]];

        if (morphAttribute != null) {
          morphTargetInfluences = [];
          morphTargetDictionary = {};

          for (int m = 0, ml = morphAttribute.length; m < ml; m++) {
            var name = morphAttribute[m].name ?? m.toString();

            morphTargetInfluences!.add(0);
            morphTargetDictionary![name] = m;
          }
        }
      }
    } else {
      var morphTargets = geometry.morphTargets;

      if (morphTargets != null && morphTargets.length > 0) {
        print(
            'THREE.Line.updateMorphTargets() does not support THREE.Geometry. Use THREE.BufferGeometry instead.');
      }
    }
  }
}
