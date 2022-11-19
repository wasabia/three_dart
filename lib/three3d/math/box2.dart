import 'package:three_dart/three3d/math/index.dart';

var _vector = Vector2(null, null);

class Box2 {
  static double infinity = Math.infinity;

  bool isBox2 = true;
  late Vector2 min;
  late Vector2 max;

  Box2(Vector2? min, Vector2? max) {
    this.min = (min != null) ? min : Vector2(infinity, infinity);
    this.max = (max != null) ? max : Vector2(-infinity, -infinity);
  }

  Box2 set(Vector2 min, Vector2 max) {
    this.min.copy(min);
    this.max.copy(max);

    return this;
  }

  Box2 setFromPoints(List<Vector2> points) {
    makeEmpty();

    for (var i = 0, il = points.length; i < il; i++) {
      expandByPoint(points[i]);
    }

    return this;
  }

  Box2 setFromCenterAndSize(Vector2 center, Vector2 size) {
    var halfSize = _vector.copy(size).multiplyScalar(0.5);
    min.copy(center).sub(halfSize);
    max.copy(center).add(halfSize);

    return this;
  }

  Box2 clone() {
    return Box2(null, null).copy(this);
  }

  Box2 copy(Box2 box) {
    min.copy(box.min);
    max.copy(box.max);

    return this;
  }

  Box2 makeEmpty() {
    min.x = min.y = infinity;
    max.x = max.y = -infinity;

    return this;
  }

  bool isEmpty() {
    // this is a more robust check for empty than ( volume <= 0 ) because volume can get positive with two negative axes

    return (max.x < min.x) || (max.y < min.y);
  }

  Vector2 getCenter(Vector2 target) {
    return isEmpty() ? target.set(0, 0) : target.addVectors(min, max).multiplyScalar(0.5);
  }

  Vector2 getSize(Vector2 target) {
    return isEmpty() ? target.set(0, 0) : target.subVectors(max, min);
  }

  Box2 expandByPoint(Vector2 point) {
    min.min(point);
    max.max(point);

    return this;
  }

  Box2 expandByVector(Vector2 vector) {
    min.sub(vector);
    max.add(vector);

    return this;
  }

  Box2 expandByScalar(double scalar) {
    min.addScalar(-scalar);
    max.addScalar(scalar);

    return this;
  }

  bool containsPoint(Vector2 point) {
    return point.x < min.x || point.x > max.x || point.y < min.y || point.y > max.y ? false : true;
  }

  bool containsBox(Box2 box) {
    return min.x <= box.min.x && box.max.x <= max.x && min.y <= box.min.y && box.max.y <= max.y;
  }

  Vector2 getParameter(Vector2 point, Vector2 target) {
    // This can potentially have a divide by zero if the box
    // has a size dimension of 0.

    return target.set((point.x - min.x) / (max.x - min.x), (point.y - min.y) / (max.y - min.y));
  }

  bool intersectsBox(Box2 box) {
    // using 4 splitting planes to rule out intersections

    return box.max.x < min.x || box.min.x > max.x || box.max.y < min.y || box.min.y > max.y ? false : true;
  }

  Vector2 clampPoint(Vector2 point, Vector2 target) {
    return target.copy(point).clamp(min, max);
  }

  num distanceToPoint(Vector2 point) {
    var clampedPoint = _vector.copy(point).clamp(min, max);
    return clampedPoint.sub(point).length();
  }

  Box2 intersect(Box2 box) {
    min.max(box.min);
    max.min(box.max);

    return this;
  }

  Box2 union(Box2 box) {
    min.min(box.min);
    max.max(box.max);

    return this;
  }

  Box2 translate(Vector2 offset) {
    min.add(offset);
    max.add(offset);

    return this;
  }

  bool equals(Box2 box) {
    return box.min.equals(min) && box.max.equals(max);
  }
}
