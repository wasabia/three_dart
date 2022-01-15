part of three_math;

var _vector1 = /*@__PURE__*/ new Vector3.init();
var _vector2 = /*@__PURE__*/ new Vector3.init();
var _normalMatrix = /*@__PURE__*/ new Matrix3();

class Plane {
  String type = "Plane";

  late Vector3 normal;
  num constant = 0;

  Plane(normal, constant) {
    // normal is assumed to be normalized

    this.normal = (normal != null) ? normal : new Vector3(1, 0, 0);
    this.constant = (constant != null) ? constant : 0;
  }

  List<num> toJSON() {
    List<num> _data = this.normal.toJSON();
    _data.add(constant);

    return _data;
  }

  set(normal, constant) {
    this.normal.copy(normal);
    this.constant = constant;

    return this;
  }

  setComponents(x, y, z, w) {
    this.normal.set(x, y, z);
    this.constant = w;

    return this;
  }

  setFromNormalAndCoplanarPoint(normal, point) {
    this.normal.copy(normal);
    this.constant = -point.dot(this.normal);

    return this;
  }

  setFromCoplanarPoints(a, b, c) {
    var normal =
        _vector1.subVectors(c, b).cross(_vector2.subVectors(a, b)).normalize();

    // Q: should an error be thrown if normal is zero (e.g. degenerate plane)?

    this.setFromNormalAndCoplanarPoint(normal, a);

    return this;
  }

  clone() {
    return new Plane(null, null).copy(this);
  }

  copy(plane) {
    this.normal.copy(plane.normal);
    this.constant = plane.constant;

    return this;
  }

  normalize() {
    // Note: will lead to a divide by zero if the plane is invalid.

    var inverseNormalLength = 1.0 / this.normal.length();
    this.normal.multiplyScalar(inverseNormalLength);
    this.constant *= inverseNormalLength;

    return this;
  }

  negate() {
    this.constant *= -1;
    this.normal.negate();

    return this;
  }

  distanceToPoint(point) {
    return this.normal.dot(point) + this.constant;
  }

  distanceToSphere(sphere) {
    return this.distanceToPoint(sphere.center) - sphere.radius;
  }

  projectPoint(point, Vector3 target) {
    return target
        .copy(this.normal)
        .multiplyScalar(-this.distanceToPoint(point))
        .add(point);
  }

  intersectLine(line, Vector3 target) {
    var direction = line.delta(_vector1);

    var denominator = this.normal.dot(direction);

    if (denominator == 0) {
      // line is coplanar, return origin
      if (this.distanceToPoint(line.start) == 0) {
        return target.copy(line.start);
      }

      // Unsure if this is the correct method to handle this case.
      return null;
    }

    var t = -(line.start.dot(this.normal) + this.constant) / denominator;

    if (t < 0 || t > 1) {
      return null;
    }

    return target.copy(direction).multiplyScalar(t).add(line.start);
  }

  intersectsLine(line) {
    // Note: this tests if a line intersects the plane, not whether it (or its end-points) are coplanar with it.

    var startSign = this.distanceToPoint(line.start);
    var endSign = this.distanceToPoint(line.end);

    return (startSign < 0 && endSign > 0) || (endSign < 0 && startSign > 0);
  }

  intersectsBox(box) {
    return box.intersectsPlane(this);
  }

  intersectsSphere(sphere) {
    return sphere.intersectsPlane(this);
  }

  coplanarPoint(Vector3 target) {
    return target.copy(this.normal).multiplyScalar(-this.constant);
  }

  applyMatrix4(matrix, optionalNormalMatrix) {
    var normalMatrix =
        optionalNormalMatrix ?? _normalMatrix.getNormalMatrix(matrix);

    var referencePoint = this.coplanarPoint(_vector1).applyMatrix4(matrix);

    var normal = this.normal.applyMatrix3(normalMatrix).normalize();

    this.constant = -referencePoint.dot(normal);

    return this;
  }

  translate(offset) {
    this.constant -= offset.dot(this.normal);

    return this;
  }

  equals(plane) {
    return plane.normal.equals(this.normal) &&
        (plane.constant == this.constant);
  }
}
