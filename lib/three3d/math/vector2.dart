

import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three3d/math/matrix3.dart';

class Vector2 {
  String type = "Vector2";
  double x = 0;
  double y = 0;

  Vector2([double? x, double? y]) {
    this.x = x ?? 0;
    this.y = y ?? 0;
  }

  Vector2.fromJSON(List<double>? json) {
    if (json != null) {
      x = json[0];
      y = json[1];
    }
  }

  double get width => x;
  set width(double value) => x = value;

  double get height => y;
  set height(double value) => y = value;

  Vector2 set(double x, double y) {
    this.x = x;
    this.y = y;

    return this;
  }

  Vector2 setScalar(double scalar) {
    x = scalar;
    y = scalar;

    return this;
  }

  Vector2 setX(double x) {
    this.x = x;

    return this;
  }

  Vector2 setY(double y) {
    this.y = y;

    return this;
  }

  Vector2 setComponent(int index, double value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      default:
        throw "index is out of range: $index";
    }

    return this;
  }

  num getComponent(int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        throw "index is out of range: $index";
    }
  }

  Vector2 clone() {
    return Vector2(x, y);
  }

  Vector2 copy(Vector2 v) {
    x = v.x;
    y = v.y;

    return this;
  }

  Vector2 add(Vector2 v, {Vector2? w}) {
    if (w != null) {
      print('three.Vector2: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(v, w);
    }

    x += v.x;
    y += v.y;

    return this;
  }

  Vector2 addScalar(num s) {
    x += s;
    y += s;

    return this;
  }

  Vector2 addVectors(Vector2 a, Vector2 b) {
    x = a.x + b.x;
    y = a.y + b.y;

    return this;
  }

  Vector2 addScaledVector(Vector2 v, double s) {
    x += v.x * s;
    y += v.y * s;

    return this;
  }

  Vector2 sub(Vector2 v, {Vector2? w}) {
    if (w != null) {
      print('three.Vector2: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w);
    }

    x -= v.x;
    y -= v.y;

    return this;
  }

  Vector2 subScalar(num s) {
    x -= s;
    y -= s;

    return this;
  }

  Vector2 subVectors(Vector2 a, Vector2 b) {
    x = a.x - b.x;
    y = a.y - b.y;

    return this;
  }

  Vector2 multiply(Vector2 v) {
    x *= v.x;
    y *= v.y;

    return this;
  }

  Vector2 multiplyScalar(num scalar) {
    x *= scalar;
    y *= scalar;

    return this;
  }

  Vector2 divide(Vector2 v) {
    x /= v.x;
    y /= v.y;

    return this;
  }

  Vector2 divideScalar(double scalar) {
    return multiplyScalar(1 / scalar);
  }

  Vector2 applyMatrix3(Matrix3 m) {
    var x = this.x;
    var y = this.y;
    var e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6];
    this.y = e[1] * x + e[4] * y + e[7];

    return this;
  }

  Vector2 min(Vector2 v) {
    x = Math.min(x, v.x).toDouble();
    y = Math.min(y, v.y).toDouble();

    return this;
  }

  Vector2 max(Vector2 v) {
    x = Math.max(x, v.x);
    y = Math.max(y, v.y);

    return this;
  }

  Vector2 clamp(Vector2 min, Vector2 max) {
    // assumes min < max, componentwise

    x = Math.max(min.x, Math.min(max.x, x));
    y = Math.max(min.y, Math.min(max.y, y));

    return this;
  }

  Vector2 clampScalar(double minVal, double maxVal) {
    x = Math.max(minVal, Math.min(maxVal, x));
    y = Math.max(minVal, Math.min(maxVal, y));

    return this;
  }

  Vector2 clampLength(double min, double max) {
    var length = this.length();

    return divideScalar(length).multiplyScalar(Math.max(min, Math.min(max, length)));
  }

  Vector2 floor() {
    x = Math.floor(x).toDouble();
    y = Math.floor(y).toDouble();

    return this;
  }

  Vector2 ceil() {
    x = Math.ceil(x).toDouble();
    y = Math.ceil(y).toDouble();

    return this;
  }

  Vector2 round() {
    x = Math.round(x).toDouble();
    y = Math.round(y).toDouble();

    return this;
  }

  Vector2 roundToZero() {
    x = (x < 0) ? Math.ceil(x).toDouble() : Math.floor(x).toDouble();
    y = (y < 0) ? Math.ceil(y).toDouble() : Math.floor(y).toDouble();

    return this;
  }

  Vector2 negate() {
    x = -x;
    y = -y;

    return this;
  }

  num dot(Vector2 v) {
    return x * v.x + y * v.y;
  }

  num cross(Vector2 v) {
    return x * v.y - y * v.x;
  }

  num lengthSq() {
    return x * x + y * y;
  }

  double length() {
    return Math.sqrt(x * x + y * y);
  }

  num manhattanLength() {
    return (Math.abs(x) + Math.abs(y)).toDouble();
  }

  Vector2 normalize() {
    return divideScalar(length());
  }

  double angle() {
    // computes the angle in radians with respect to the positive x-axis

    var angle = Math.atan2(-y, -x) + Math.PI;

    return angle;
  }

  double distanceTo(Vector2 v) {
    return Math.sqrt(distanceToSquared(v));
  }

  num distanceToSquared(Vector2 v) {
    var dx = x - v.x, dy = y - v.y;
    return dx * dx + dy * dy;
  }

  num manhattanDistanceTo(Vector2 v) {
    return (Math.abs(x - v.x) + Math.abs(y - v.y)).toDouble();
  }

  Vector2 setLength(double length) {
    return normalize().multiplyScalar(length);
  }

  Vector2 lerp(Vector2 v, double alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;

    return this;
  }

  Vector2 lerpVectors(Vector2 v1, Vector2 v2, double alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;

    return this;
  }

  bool equals(Vector2 v) {
    return ((v.x == x) && (v.y == y));
  }

  Vector2 fromArray(array, [int offset = 0]) {
    x = array[offset];
    y = array[offset + 1];

    return this;
  }

  List<num> toArray([List<double>? array, int offset = 0]) {
    array ??= List<double>.filled(2, 0.0);

    array[offset] = x;
    array[offset + 1] = y;
    return array;
  }

  List<num> toJSON() {
    return [x, y];
  }

  Vector2 fromBufferAttribute(attribute, index) {
    x = attribute.getX(index);
    y = attribute.getY(index);

    return this;
  }

  Vector2 rotateAround(Vector2 center, double angle) {
    var c = Math.cos(angle), s = Math.sin(angle);

    var x = this.x - center.x;
    var y = this.y - center.y;

    this.x = x * c - y * s + center.x;
    this.y = x * s + y * c + center.y;

    return this;
  }

  Vector2 random() {
    x = Math.random();
    y = Math.random();

    return this;
  }

  Vector2.fromJson(Map<String, double> json) {
    x = json['x']!;
    y = json['y']!;
  }

  Map<String, double> toJson() {
    return {'x': x, 'y': y};
  }
}
