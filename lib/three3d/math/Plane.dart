part of three_math;

var _vector1 = /*@__PURE__*/ Vector3.init();
var _vector2 = /*@__PURE__*/ Vector3.init();
var _normalMatrix = /*@__PURE__*/ Matrix3();

class Plane {
  String type = "Plane";

  late Vector3 normal;
  num constant = 0;

  Plane([Vector3? normal, num? constant]) {
    // normal is assumed to be normalized

    this.normal = (normal != null) ? normal : Vector3(1, 0, 0);
    this.constant = (constant != null) ? constant : 0;
  }

  List<num> toJSON() {
    List<num> _data = normal.toJSON();
    _data.add(constant);

    return _data;
  }

  Plane set(normal, num constant) {
    this.normal.copy(normal);
    this.constant = constant;

    return this;
  }

  Plane setComponents(num x, num y, num z, num w) {
    normal.set(x, y, z);
    constant = w;

    return this;
  }

  Plane setFromNormalAndCoplanarPoint(normal, point) {
    this.normal.copy(normal);
    constant = -point.dot(this.normal);

    return this;
  }

  Plane setFromCoplanarPoints(a, b, c) {
    var normal =
        _vector1.subVectors(c, b).cross(_vector2.subVectors(a, b)).normalize();

    // Q: should an error be thrown if normal is zero (e.g. degenerate plane)?

    setFromNormalAndCoplanarPoint(normal, a);

    return this;
  }

  Plane clone() {
    return Plane(null, null).copy(this);
  }

  Plane copy(Plane plane) {
    normal.copy(plane.normal);
    constant = plane.constant;

    return this;
  }

  Plane normalize() {
    // Note: will lead to a divide by zero if the plane is invalid.

    var inverseNormalLength = 1.0 / normal.length();
    normal.multiplyScalar(inverseNormalLength);
    constant *= inverseNormalLength;

    return this;
  }

  Plane negate() {
    constant *= -1;
    normal.negate();

    return this;
  }

  num distanceToPoint(Vector3 point) {
    return normal.dot(point) + constant;
  }

  num distanceToSphere(sphere) {
    return distanceToPoint(sphere.center) - sphere.radius;
  }

  Vector3 projectPoint(point, Vector3 target) {
    return target
        .copy(normal)
        .multiplyScalar(-distanceToPoint(point))
        .add(point);
  }

  Vector3? intersectLine(line, Vector3 target) {
    var direction = line.delta(_vector1);

    var denominator = normal.dot(direction);

    if (denominator == 0) {
      // line is coplanar, return origin
      if (distanceToPoint(line.start) == 0) {
        return target.copy(line.start);
      }

      // Unsure if this is the correct method to handle this case.
      return null;
    }

    var t = -(line.start.dot(normal) + constant) / denominator;

    if (t < 0 || t > 1) {
      return null;
    }

    return target.copy(direction).multiplyScalar(t).add(line.start);
  }

  bool intersectsLine(line) {
    // Note: this tests if a line intersects the plane, not whether it (or its end-points) are coplanar with it.

    var startSign = distanceToPoint(line.start);
    var endSign = distanceToPoint(line.end);

    return (startSign < 0 && endSign > 0) || (endSign < 0 && startSign > 0);
  }

  intersectsBox(box) {
    return box.intersectsPlane(this);
  }

  intersectsSphere(sphere) {
    return sphere.intersectsPlane(this);
  }

  Vector3 coplanarPoint(Vector3 target) {
    return target.copy(normal).multiplyScalar(-constant);
  }

  Plane applyMatrix4(Matrix4 matrix, optionalNormalMatrix) {
    var normalMatrix =
        optionalNormalMatrix ?? _normalMatrix.getNormalMatrix(matrix);

    var referencePoint = coplanarPoint(_vector1).applyMatrix4(matrix);

    var normal = this.normal.applyMatrix3(normalMatrix).normalize();

    constant = -referencePoint.dot(normal);

    return this;
  }

  Plane translate(offset) {
    constant -= offset.dot(normal);

    return this;
  }

  bool equals(Plane plane) {
    return plane.normal.equals(normal) && (plane.constant == constant);
  }
}
