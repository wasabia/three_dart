
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/math/index.dart';

var _pointsinverseMatrix = Matrix4();
var _pointsray = Ray(null, null);
var _pointssphere = Sphere(null, null);
var _position = Vector3.init();

class Points extends Object3D {
  Points(BufferGeometry geometry, material) {
    type = 'Points';

    this.geometry = geometry;
    this.material = material;

    updateMorphTargets();
  }

  Points.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    type = 'Points';
  }

  @override
  Points copy(Object3D source, [bool? recursive]) {
    super.copy(source);
    if (source is Points) {
      material = source.material;
      geometry = source.geometry;
    }
    return this;
  }

  @override
  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    var geometry = this.geometry!;
    var matrixWorld = this.matrixWorld;
    var threshold = raycaster.params["Points"].threshold;
    var drawRange = geometry.drawRange;

    // Checking boundingSphere distance to ray

    if (geometry.boundingSphere == null) geometry.computeBoundingSphere();

    _pointssphere.copy(geometry.boundingSphere!);
    _pointssphere.applyMatrix4(matrixWorld);
    _pointssphere.radius += threshold;

    if (raycaster.ray.intersectsSphere(_pointssphere) == false) return;

    //

    _pointsinverseMatrix.copy(matrixWorld).invert();
    _pointsray.copy(raycaster.ray).applyMatrix4(_pointsinverseMatrix);

    var localThreshold = threshold / ((scale.x + scale.y + scale.z) / 3);
    var localThresholdSq = localThreshold * localThreshold;

    var index = geometry.index;
    var attributes = geometry.attributes;
    var positionAttribute = attributes["position"];

    if (index != null) {
      var start = Math.max(0, drawRange["start"]!);
      var end = Math.min(index.count, (drawRange["start"]! + drawRange["count"]!));

      for (var i = start, il = end; i < il; i++) {
        var a = index.getX(i)!;

        _position.fromBufferAttribute(positionAttribute, a.toInt());

        testPoint(_position, a, localThresholdSq, matrixWorld, raycaster, intersects, this);
      }
    } else {
      var start = Math.max(0, drawRange["start"]!);
      var end = Math.min<int>(positionAttribute.count, (drawRange["start"]! + drawRange["count"]!));

      for (var i = start, l = end; i < l; i++) {
        _position.fromBufferAttribute(positionAttribute, i);

        testPoint(_position, i, localThresholdSq, matrixWorld, raycaster, intersects, this);
      }
    }
  }

  void updateMorphTargets() {
    var geometry = this.geometry;

    if (geometry is BufferGeometry) {
      var morphAttributes = geometry.morphAttributes;
      var keys = morphAttributes.keys.toList();

      if (keys.isNotEmpty) {
        var morphAttribute = morphAttributes[keys[0]];

        if (morphAttribute != null) {
          morphTargetInfluences = [];
          morphTargetDictionary = {};

          for (var m = 0, ml = morphAttribute.length; m < ml; m++) {
            var name = morphAttribute[m].name ?? m.toString();

            morphTargetInfluences!.add(0);
            morphTargetDictionary![name] = m;
          }
        }
      }
    }
    // else {
    //   var morphTargets = geometry.morphTargets;

    //   if (morphTargets != null && morphTargets.length > 0) {
    //     print(
    //         'three.Points.updateMorphTargets() does not support three.Geometry. Use three.BufferGeometry instead.');
    //   }
    // }
  }
}

void testPoint(Vector3 point, num index, num localThresholdSq, Matrix4 matrixWorld, Raycaster raycaster,
    List<Intersection> intersects, Object3D object) {
  var rayPointDistanceSq = _pointsray.distanceSqToPoint(point);

  if (rayPointDistanceSq < localThresholdSq) {
    var intersectPoint = Vector3.init();

    _pointsray.closestPointToPoint(point, intersectPoint);
    intersectPoint.applyMatrix4(matrixWorld);

    var distance = raycaster.ray.origin.distanceTo(intersectPoint);

    if (distance < raycaster.near || distance > raycaster.far) return;

    intersects.add(Intersection({
      "distance": distance,
      "distanceToRay": Math.sqrt(rayPointDistanceSq),
      "point": intersectPoint,
      "index": index,
      "face": null,
      "object": object
    }));
  }
}
