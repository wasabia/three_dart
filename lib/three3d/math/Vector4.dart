part of three_math;

class Vector4 {
  String type = "Vector4";
  late num x;
  late num y;
  late num z;
  late num w;

  Vector4([num? x, num? y, num? z, num? w]) {
    this.x = x ?? 0;
    this.y = y ?? 0;
    this.z = z ?? 0;
    this.w = w ?? 0;
  }

  Vector4.init({this.x = 0, this.y = 0, this.z = 0, this.w = 1});

  Vector4.fromJSON(List<num>? json) {
    if (json != null) {
      x = json[0];
      y = json[1];
      z = json[2];
      w = json[3];
    }
  }

  List<num> toJSON() {
    return [x, y, z, w];
  }

  get width => z;
  set width(value) => z = value;

  get height => w;
  set height(value) => w = value;

  Vector4 set(num x, num y, num z, num w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;

    return this;
  }

  Vector4 setScalar(num scalar) {
    x = scalar;
    y = scalar;
    z = scalar;
    w = scalar;

    return this;
  }

  Vector4 setX(num x) {
    this.x = x;

    return this;
  }

  Vector4 setY(num y) {
    this.y = y;

    return this;
  }

  Vector4 setZ(num z) {
    this.z = z;

    return this;
  }

  Vector4 setW(num w) {
    this.w = w;

    return this;
  }

  Vector4 setComponent(int index, num value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      case 2:
        z = value;
        break;
      case 3:
        w = value;
        break;
      default:
        throw ('index is out of range: $index');
    }

    return this;
  }

  num getComponent(int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      case 3:
        return w;
      default:
        throw ('index is out of range: $index');
    }
  }

  Vector4 clone() {
    return Vector4(x, y, z, w);
  }

  Vector4 copy(Vector4 v) {
    x = v.x;
    y = v.y;
    z = v.z;
    w = v.w;

    return this;
  }

  Vector4 add(Vector4 v, Vector4? w) {
    if (w != null) {
      print(
          'THREE.Vector4: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(v, w);
    }

    x += v.x;
    y += v.y;
    z += v.z;
    this.w += v.w;

    return this;
  }

  Vector4 addScalar(num s) {
    x += s;
    y += s;
    z += s;
    w += s;

    return this;
  }

  Vector4 addVectors(Vector4 a, Vector4 b) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;
    w = a.w + b.w;

    return this;
  }

  Vector4 addScaledVector(Vector4 v, num s) {
    x += v.x * s;
    y += v.y * s;
    z += v.z * s;
    w += v.w * s;

    return this;
  }

  Vector4 sub(Vector4 v, Vector4? w) {
    if (w != null) {
      print(
          'THREE.Vector4: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w);
    }

    x -= v.x;
    y -= v.y;
    z -= v.z;
    this.w -= v.w;

    return this;
  }

  Vector4 subScalar(num s) {
    x -= s;
    y -= s;
    z -= s;
    w -= s;

    return this;
  }

  Vector4 subVectors(Vector4 a, Vector4 b) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    w = a.w - b.w;

    return this;
  }

  // multiply( v, w ) {

  Vector4 multiply(Vector4 v) {
    // if ( w != null ) {
    // 	print( 'THREE.Vector4: .multiply() now only accepts one argument. Use .multiplyVectors( a, b ) instead.' );
    // 	return this.multiplyVectors( v, w );
    // }

    x *= v.x;
    y *= v.y;
    z *= v.z;
    w *= v.w;

    return this;
  }

  // multiplyVectors(v, w) {

  // }

  Vector4 multiplyScalar(num scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
    w *= scalar;

    return this;
  }

  Vector4 applyMatrix4(Matrix4 m) {
    var x = this.x, y = this.y, z = this.z, w = this.w;
    var e = m.elements;

    this.x = e[0] * x + e[4] * y + e[8] * z + e[12] * w;
    this.y = e[1] * x + e[5] * y + e[9] * z + e[13] * w;
    this.z = e[2] * x + e[6] * y + e[10] * z + e[14] * w;
    this.w = e[3] * x + e[7] * y + e[11] * z + e[15] * w;

    return this;
  }

  Vector4 divideScalar(num scalar) {
    return multiplyScalar(1 / scalar);
  }

  Vector4 setAxisAngleFromQuaternion(Quaternion q) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/index.htm

    // q is assumed to be normalized

    w = 2 * Math.acos(q.w);

    var s = Math.sqrt(1 - q.w * q.w);

    if (s < 0.0001) {
      x = 1;
      y = 0;
      z = 0;
    } else {
      x = q.x / s;
      y = q.y / s;
      z = q.z / s;
    }

    return this;
  }

  Vector4 setAxisAngleFromRotationMatrix(Matrix3 m) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToAngle/index.htm

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    double angle, x, y, z; // variables for result
    double epsilon = 0.01, // margin to allow for rounding errors
        epsilon2 = 0.1; // margin to distinguish between 0 and 180 degrees

    final te = m.elements;
    double m11 = te[0];
    double m12 = te[4];
    double m13 = te[8];
    double m21 = te[1];
    double m22 = te[5];
    double m23 = te[9];
    double m31 = te[2];
    double m32 = te[6];
    double m33 = te[10];

    if ((Math.abs(m12 - m21) < epsilon) &&
        (Math.abs(m13 - m31) < epsilon) &&
        (Math.abs(m23 - m32) < epsilon)) {
      // singularity found
      // first check for identity matrix which must have +1 for all terms
      // in leading diagonal and zero in other terms

      if ((Math.abs(m12 + m21) < epsilon2) &&
          (Math.abs(m13 + m31) < epsilon2) &&
          (Math.abs(m23 + m32) < epsilon2) &&
          (Math.abs(m11 + m22 + m33 - 3) < epsilon2)) {
        // this singularity is identity matrix so angle = 0

        set(1, 0, 0, 0);

        return this; // zero angle, arbitrary axis

      }

      // otherwise this singularity is angle = 180

      angle = Math.PI;

      var xx = (m11 + 1) / 2;
      var yy = (m22 + 1) / 2;
      var zz = (m33 + 1) / 2;
      var xy = (m12 + m21) / 4;
      var xz = (m13 + m31) / 4;
      var yz = (m23 + m32) / 4;

      if ((xx > yy) && (xx > zz)) {
        // m11 is the largest diagonal term

        if (xx < epsilon) {
          x = 0;
          y = 0.707106781;
          z = 0.707106781;
        } else {
          x = Math.sqrt(xx);
          y = xy / x;
          z = xz / x;
        }
      } else if (yy > zz) {
        // m22 is the largest diagonal term

        if (yy < epsilon) {
          x = 0.707106781;
          y = 0;
          z = 0.707106781;
        } else {
          y = Math.sqrt(yy);
          x = xy / y;
          z = yz / y;
        }
      } else {
        // m33 is the largest diagonal term so base result on this

        if (zz < epsilon) {
          x = 0.707106781;
          y = 0.707106781;
          z = 0;
        } else {
          z = Math.sqrt(zz);
          x = xz / z;
          y = yz / z;
        }
      }

      set(x, y, z, angle);

      return this; // return 180 deg rotation

    }

    // as we have reached here there are no singularities so we can handle normally

    var s = Math.sqrt((m32 - m23) * (m32 - m23) +
        (m13 - m31) * (m13 - m31) +
        (m21 - m12) * (m21 - m12)); // used to normalize

    if (Math.abs(s) < 0.001) s = 1;

    // prevent divide by zero, should not happen if matrix is orthogonal and should be
    // caught by singularity test above, but I've left it in just in case

    this.x = (m32 - m23) / s;
    this.y = (m13 - m31) / s;
    this.z = (m21 - m12) / s;
    w = Math.acos((m11 + m22 + m33 - 1) / 2);

    return this;
  }

  Vector4 min(Vector4 v) {
    x = Math.min(x, v.x);
    y = Math.min(y, v.y);
    z = Math.min(z, v.z);
    w = Math.min(w, v.w);

    return this;
  }

  Vector4 max(Vector4 v) {
    x = Math.max(x, v.x);
    y = Math.max(y, v.y);
    z = Math.max(z, v.z);
    w = Math.max(w, v.w);

    return this;
  }

  Vector4 clamp(Vector4 min, Vector4 max) {
    // assumes min < max, componentwise

    x = Math.max(min.x, Math.min(max.x, x));
    y = Math.max(min.y, Math.min(max.y, y));
    z = Math.max(min.z, Math.min(max.z, z));
    w = Math.max(min.w, Math.min(max.w, w));

    return this;
  }

  Vector4 clampScalar(num minVal, num maxVal) {
    x = Math.max(minVal, Math.min(maxVal, x));
    y = Math.max(minVal, Math.min(maxVal, y));
    z = Math.max(minVal, Math.min(maxVal, z));
    w = Math.max(minVal, Math.min(maxVal, w));

    return this;
  }

  Vector4 clampLength(num min, num max) {
    var length = this.length();

    return divideScalar(length)
        .multiplyScalar(Math.max(min, Math.min(max, length)));
  }

  Vector4 floor() {
    x = Math.floor(x);
    y = Math.floor(y);
    z = Math.floor(z);
    w = Math.floor(w);

    return this;
  }

  Vector4 ceil() {
    x = Math.ceil(x);
    y = Math.ceil(y);
    z = Math.ceil(z);
    w = Math.ceil(w);

    return this;
  }

  Vector4 round() {
    x = Math.round(x);
    y = Math.round(y);
    z = Math.round(z);
    w = Math.round(w);

    return this;
  }

  Vector4 roundToZero() {
    x = (x < 0) ? Math.ceil(x) : Math.floor(x);
    y = (y < 0) ? Math.ceil(y) : Math.floor(y);
    z = (z < 0) ? Math.ceil(z) : Math.floor(z);
    w = (w < 0) ? Math.ceil(w) : Math.floor(w);

    return this;
  }

  Vector4 negate() {
    x = -x;
    y = -y;
    z = -z;
    w = -w;

    return this;
  }

  num dot(Vector4 v) {
    return x * v.x + y * v.y + z * v.z + w * v.w;
  }

  num lengthSq() {
    return x * x + y * y + z * z + w * w;
  }

  double length() {
    return Math.sqrt(x * x + y * y + z * z + w * w);
  }

  num manhattanLength() {
    return Math.abs(x) + Math.abs(y) + Math.abs(z) + Math.abs(w);
  }

  Vector4 normalize() {
    return divideScalar(length());
  }

  Vector4 setLength(num length) {
    return normalize().multiplyScalar(length);
  }

  Vector4 lerp(Vector4 v, num alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;
    w += (v.w - w) * alpha;

    return this;
  }

  Vector4 lerpVectors(Vector4 v1, Vector4 v2, num alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;
    z = v1.z + (v2.z - v1.z) * alpha;
    w = v1.w + (v2.w - v1.w) * alpha;

    return this;
  }

  bool equals(Vector4 v) {
    return ((v.x == x) && (v.y == y) && (v.z == z) && (v.w == w));
  }

  Vector4 fromArray(List<num> array, {int offset = 0}) {
    x = array[offset];
    y = array[offset + 1];
    z = array[offset + 2];
    w = array[offset + 3];

    return this;
  }

  List<num> toArray(List<num> array, {int offset = 0}) {
    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;
    array[offset + 3] = w;

    return array;
  }

  Vector4 fromBufferAttribute(BufferAttribute attribute, int index) {
    x = attribute.getX(index)!;
    y = attribute.getY(index)!;
    z = attribute.getZ(index)!;
    w = attribute.getW(index) ?? 0;

    return this;
  }

  Vector4 random() {
    x = Math.random();
    y = Math.random();
    z = Math.random();
    w = Math.random();

    return this;
  }

  Vector4.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
    z = json['z'];
    w = json['w'];
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'z': z, 'w': w};
  }
}
