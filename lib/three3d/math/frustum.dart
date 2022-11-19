import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/box3.dart';
import 'package:three_dart/three3d/math/matrix4.dart';
import 'package:three_dart/three3d/math/plane.dart';
import 'package:three_dart/three3d/math/sphere.dart';
import 'package:three_dart/three3d/math/vector3.dart';

var _sphere = Sphere(null, null);
var _vectorFrustum = Vector3.init();

class Frustum {
  late List<Plane> planes;

  Frustum([Plane? p0, Plane? p1, Plane? p2, Plane? p3, Plane? p4, Plane? p5]) {
    planes = [
      (p0 != null) ? p0 : Plane(null, null),
      (p1 != null) ? p1 : Plane(null, null),
      (p2 != null) ? p2 : Plane(null, null),
      (p3 != null) ? p3 : Plane(null, null),
      (p4 != null) ? p4 : Plane(null, null),
      (p5 != null) ? p5 : Plane(null, null)
    ];
  }

  List<List<num>> toJSON() {
    return planes.map((e) => e.toJSON()).toList();
  }

  Frustum set(Plane p0, Plane p1, Plane p2, Plane p3, Plane p4, Plane p5) {
    var planes = this.planes;

    planes[0].copy(p0);
    planes[1].copy(p1);
    planes[2].copy(p2);
    planes[3].copy(p3);
    planes[4].copy(p4);
    planes[5].copy(p5);

    return this;
  }

  Frustum clone() {
    return Frustum(null, null, null, null, null, null).copy(this);
  }

  Frustum copy(Frustum frustum) {
    var planes = this.planes;

    for (var i = 0; i < 6; i++) {
      planes[i].copy(frustum.planes[i]);
    }

    return this;
  }

  Frustum setFromProjectionMatrix(Matrix4 m) {
    var planes = this.planes;
    var me = m.elements;
    var me0 = me[0], me1 = me[1], me2 = me[2], me3 = me[3];
    var me4 = me[4], me5 = me[5], me6 = me[6], me7 = me[7];
    var me8 = me[8], me9 = me[9], me10 = me[10], me11 = me[11];
    var me12 = me[12], me13 = me[13], me14 = me[14], me15 = me[15];

    planes[0].setComponents(me3 - me0, me7 - me4, me11 - me8, me15 - me12).normalize();
    planes[1].setComponents(me3 + me0, me7 + me4, me11 + me8, me15 + me12).normalize();
    planes[2].setComponents(me3 + me1, me7 + me5, me11 + me9, me15 + me13).normalize();
    planes[3].setComponents(me3 - me1, me7 - me5, me11 - me9, me15 - me13).normalize();
    planes[4].setComponents(me3 - me2, me7 - me6, me11 - me10, me15 - me14).normalize();
    planes[5].setComponents(me3 + me2, me7 + me6, me11 + me10, me15 + me14).normalize();

    return this;
  }

  bool intersectsObject(Object3D object) {
    final geometry = object.geometry;
    if (geometry == null) return false;

    if (geometry.boundingSphere == null) geometry.computeBoundingSphere();

    _sphere.copy(geometry.boundingSphere!);

    _sphere.applyMatrix4(object.matrixWorld);

    return intersectsSphere(_sphere);
  }

  bool intersectsSprite(Object3D sprite) {
    _sphere.center.set(0, 0, 0);
    _sphere.radius = 0.7071067811865476;
    _sphere.applyMatrix4(sprite.matrixWorld);

    return intersectsSphere(_sphere);
  }

  bool intersectsSphere(Sphere sphere) {
    var planes = this.planes;
    var center = sphere.center;
    var negRadius = -sphere.radius;

    for (var i = 0; i < 6; i++) {
      var distance = planes[i].distanceToPoint(center);

      // print("i: ${i} distance: ${distance} negRadius: ${negRadius} ${distance < negRadius} ");

      if (distance < negRadius) {
        return false;
      }
    }

    return true;
  }

  bool intersectsBox(Box3 box) {
    var planes = this.planes;

    for (var i = 0; i < 6; i++) {
      var plane = planes[i];

      // corner at max distance

      _vectorFrustum.x = plane.normal.x > 0 ? box.max.x : box.min.x;
      _vectorFrustum.y = plane.normal.y > 0 ? box.max.y : box.min.y;
      _vectorFrustum.z = plane.normal.z > 0 ? box.max.z : box.min.z;

      if (plane.distanceToPoint(_vectorFrustum) < 0) {
        return false;
      }
    }

    return true;
  }

  bool containsPoint(Vector3 point) {
    var planes = this.planes;

    for (var i = 0; i < 6; i++) {
      if (planes[i].distanceToPoint(point) < 0) {
        return false;
      }
    }

    return true;
  }
}
