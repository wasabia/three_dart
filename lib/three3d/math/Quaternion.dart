part of three_math;

class Quaternion {
  String type = "Quaternion";
  num _x = 0.0;
  num _y = 0.0;
  num _z = 0.0;
  num _w = 0.0;

  Function onChangeCallback = () {};

  Quaternion([num x = 0.0, num y = 0.0, num z = 0.0, num w = 1.0])
      : _x = x,
        _y = y,
        _z = z,
        _w = w;

  Quaternion.fromJSON(List<num>? json) {
    if (json != null) {
      _x = json[0];
      _y = json[1];
      _z = json[2];
      _w = json[3];
    }
  }

  List<num> toJSON() {
    return [_x, _y, _z, _w];
  }

  static Quaternion static_slerp(
      Quaternion qa, Quaternion qb, Quaternion qm, num t) {
    print(
        'THREE.Quaternion: Static .slerp() has been deprecated. Use is now qm.slerpQuaternions( qa, qb, t ) instead.');
    return qm.slerpQuaternions(qa, qb, t);
  }

  static void slerpFlat(
      dst, num dstOffset, src0, num srcOffset0, src1, num srcOffset1, num t) {
    // fuzz-free, array-based Quaternion SLERP operation

    double x0 = src0[srcOffset0 + 0].toDouble(),
        y0 = src0[srcOffset0 + 1].toDouble(),
        z0 = src0[srcOffset0 + 2].toDouble(),
        w0 = src0[srcOffset0 + 3].toDouble();

    double x1 = src1[srcOffset1 + 0].toDouble(),
        y1 = src1[srcOffset1 + 1].toDouble(),
        z1 = src1[srcOffset1 + 2].toDouble(),
        w1 = src1[srcOffset1 + 3].toDouble();

    if (t == 0) {
      dst[dstOffset] = x0;
      dst[dstOffset + 1] = y0;
      dst[dstOffset + 2] = z0;
      dst[dstOffset + 3] = w0;
      return;
    }

    if (t == 1) {
      dst[dstOffset] = x1;
      dst[dstOffset + 1] = y1;
      dst[dstOffset + 2] = z1;
      dst[dstOffset + 3] = w1;
      return;
    }

    if (w0 != w1 || x0 != x1 || y0 != y1 || z0 != z1) {
      var s = 1 - t;
      double cos = x0 * x1 + y0 * y1 + z0 * z1 + w0 * w1;
      var dir = (cos >= 0 ? 1 : -1), sqrSin = 1 - cos * cos;

      // Skip the Slerp for tiny steps to avoid numeric problems:
      if (sqrSin > Math.EPSILON) {
        var sin = Math.sqrt(sqrSin), len = Math.atan2(sin, cos * dir);

        s = Math.sin(s * len) / sin;
        t = Math.sin(t * len) / sin;
      }

      var tDir = t * dir;

      x0 = x0 * s + x1 * tDir;
      y0 = y0 * s + y1 * tDir;
      z0 = z0 * s + z1 * tDir;
      w0 = w0 * s + w1 * tDir;

      // Normalize in case we just did a lerp:
      if (s == 1 - t) {
        var f = 1 / Math.sqrt(x0 * x0 + y0 * y0 + z0 * z0 + w0 * w0);

        x0 *= f;
        y0 *= f;
        z0 *= f;
        w0 *= f;
      }
    }

    dst[dstOffset] = x0;
    dst[dstOffset + 1] = y0;
    dst[dstOffset + 2] = z0;
    dst[dstOffset + 3] = w0;
  }

  static multiplyQuaternionsFlat(
      dst, num dstOffset, src0, num srcOffset0, src1, num srcOffset1) {
    var x0 = src0[srcOffset0];
    var y0 = src0[srcOffset0 + 1];
    var z0 = src0[srcOffset0 + 2];
    var w0 = src0[srcOffset0 + 3];

    var x1 = src1[srcOffset1];
    var y1 = src1[srcOffset1 + 1];
    var z1 = src1[srcOffset1 + 2];
    var w1 = src1[srcOffset1 + 3];

    dst[dstOffset] = x0 * w1 + w0 * x1 + y0 * z1 - z0 * y1;
    dst[dstOffset + 1] = y0 * w1 + w0 * y1 + z0 * x1 - x0 * z1;
    dst[dstOffset + 2] = z0 * w1 + w0 * z1 + x0 * y1 - y0 * x1;
    dst[dstOffset + 3] = w0 * w1 - x0 * x1 - y0 * y1 - z0 * z1;

    return dst;
  }

  num get x => _x;
  set x(num value) {
    _x = value;
    onChangeCallback();
  }

  num get y => _y;
  set y(num value) {
    _y = value;
    onChangeCallback();
  }

  num get z => _z;
  set z(num value) {
    _z = value;
    onChangeCallback();
  }

  num get w => _w;
  set w(num value) {
    _w = value;
    onChangeCallback();
  }

  Quaternion set(num x, num y, num z, num w) {
    _x = x;
    _y = y;
    _z = z;
    _w = w;

    onChangeCallback();

    return this;
  }

  Quaternion clone() {
    return Quaternion(_x, _y, _z, _w);
  }

  Quaternion copy(Quaternion quaternion) {
    _x = quaternion.x;
    _y = quaternion.y;
    _z = quaternion.z;
    _w = quaternion.w;

    onChangeCallback();

    return this;
  }

  Quaternion setFromEuler(Euler euler, [bool update = false]) {
    var x = euler.x;
    var y = euler.y;
    var z = euler.z;
    var order = euler.order;

    // http://www.mathworks.com/matlabcentral/fileexchange/
    // 	20696-function-to-convert-between-dcm-euler-angles-quaternions-and-euler-vectors/
    //	content/SpinCalc.m

    var cos = Math.cos;
    var sin = Math.sin;

    var c1 = cos(x / 2);
    var c2 = cos(y / 2);
    var c3 = cos(z / 2);

    var s1 = sin(x / 2);
    var s2 = sin(y / 2);
    var s3 = sin(z / 2);

    switch (order) {
      case 'XYZ':
        _x = s1 * c2 * c3 + c1 * s2 * s3;
        _y = c1 * s2 * c3 - s1 * c2 * s3;
        _z = c1 * c2 * s3 + s1 * s2 * c3;
        _w = c1 * c2 * c3 - s1 * s2 * s3;

        break;

      case 'YXZ':
        _x = s1 * c2 * c3 + c1 * s2 * s3;
        _y = c1 * s2 * c3 - s1 * c2 * s3;
        _z = c1 * c2 * s3 - s1 * s2 * c3;
        _w = c1 * c2 * c3 + s1 * s2 * s3;
        break;

      case 'ZXY':
        _x = s1 * c2 * c3 - c1 * s2 * s3;
        _y = c1 * s2 * c3 + s1 * c2 * s3;
        _z = c1 * c2 * s3 + s1 * s2 * c3;
        _w = c1 * c2 * c3 - s1 * s2 * s3;
        break;

      case 'ZYX':
        _x = s1 * c2 * c3 - c1 * s2 * s3;
        _y = c1 * s2 * c3 + s1 * c2 * s3;
        _z = c1 * c2 * s3 - s1 * s2 * c3;
        _w = c1 * c2 * c3 + s1 * s2 * s3;
        break;

      case 'YZX':
        _x = s1 * c2 * c3 + c1 * s2 * s3;
        _y = c1 * s2 * c3 + s1 * c2 * s3;
        _z = c1 * c2 * s3 - s1 * s2 * c3;
        _w = c1 * c2 * c3 - s1 * s2 * s3;
        break;

      case 'XZY':
        _x = s1 * c2 * c3 - c1 * s2 * s3;
        _y = c1 * s2 * c3 - s1 * c2 * s3;
        _z = c1 * c2 * s3 + s1 * s2 * c3;
        _w = c1 * c2 * c3 + s1 * s2 * s3;
        break;

      default:
        print(
            'THREE.Quaternion: .setFromEuler() encountered an unknown order: ' +
                order);
    }

    if (update) {
      onChangeCallback();
    }
    return this;
  }

  Quaternion setFromAxisAngle(Vector3 axis, num angle) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToQuaternion/index.htm

    // assumes axis is normalized

    var halfAngle = angle / 2, s = Math.sin(halfAngle);

    _x = axis.x * s;
    _y = axis.y * s;
    _z = axis.z * s;
    _w = Math.cos(halfAngle);

    onChangeCallback();

    return this;
  }

  Quaternion setFromRotationMatrix(m) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

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
    double trace = m11 + m22 + m33;

    if (trace > 0) {
      var s = 0.5 / Math.sqrt(trace + 1.0);

      _w = 0.25 / s;
      _x = (m32 - m23) * s;
      _y = (m13 - m31) * s;
      _z = (m21 - m12) * s;
    } else if (m11 > m22 && m11 > m33) {
      var s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);

      _w = (m32 - m23) / s;
      _x = 0.25 * s;
      _y = (m12 + m21) / s;
      _z = (m13 + m31) / s;
    } else if (m22 > m33) {
      var s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);

      _w = (m13 - m31) / s;
      _x = (m12 + m21) / s;
      _y = 0.25 * s;
      _z = (m23 + m32) / s;
    } else {
      var s = 2.0 * Math.sqrt(1.0 + m33 - m11 - m22);

      _w = (m21 - m12) / s;
      _x = (m13 + m31) / s;
      _y = (m23 + m32) / s;
      _z = 0.25 * s;
    }

    onChangeCallback();

    return this;
  }

  Quaternion setFromUnitVectors(Vector3 vFrom, Vector3 vTo) {
    // assumes direction vectors vFrom and vTo are normalized

    var r = vFrom.dot(vTo) + 1;

    if (r < Math.EPSILON) {
      r = 0;

      if (Math.abs(vFrom.x) > Math.abs(vFrom.z)) {
        _x = -vFrom.y;
        _y = vFrom.x;
        _z = 0;
        _w = r;
      } else {
        _x = 0;
        _y = -vFrom.z;
        _z = vFrom.y;
        _w = r;
      }
    } else {
      // crossVectors( vFrom, vTo ); // inlined to avoid cyclic dependency on Vector3

      _x = vFrom.y * vTo.z - vFrom.z * vTo.y;
      _y = vFrom.z * vTo.x - vFrom.x * vTo.z;
      _z = vFrom.x * vTo.y - vFrom.y * vTo.x;
      _w = r;
    }

    return normalize();
  }

  double angleTo(Quaternion q) {
    return 2 * Math.acos(Math.abs(MathUtils.clamp(dot(q), -1, 1)));
  }

  Quaternion rotateTowards(Quaternion q, double step) {
    var angle = angleTo(q);

    if (angle == 0) return this;

    var t = Math.min(1, step / angle);

    slerp(q, t);

    return this;
  }

  Quaternion identity() {
    return set(0, 0, 0, 1);
  }

  Quaternion invert() {
    // quaternion is assumed to have unit length

    return conjugate();
  }

  Quaternion conjugate() {
    _x *= -1;
    _y *= -1;
    _z *= -1;

    onChangeCallback();

    return this;
  }

  num dot(Quaternion v) {
    return _x * v._x + _y * v._y + _z * v._z + _w * v._w;
  }

  num lengthSq() {
    return _x * _x + _y * _y + _z * _z + _w * _w;
  }

  double length() {
    return Math.sqrt(_x * _x + _y * _y + _z * _z + _w * _w);
  }

  Quaternion normalize() {
    var l = length();

    if (l == 0) {
      _x = 0;
      _y = 0;
      _z = 0;
      _w = 1;
    } else {
      l = 1 / l;

      _x = _x * l;
      _y = _y * l;
      _z = _z * l;
      _w = _w * l;
    }

    onChangeCallback();

    return this;
  }

  Quaternion multiply(Quaternion q, {Quaternion? p}) {
    if (p != null) {
      print(
          'THREE.Quaternion: .multiply() now only accepts one argument. Use .multiplyQuaternions( a, b ) instead.');
      return multiplyQuaternions(q, p);
    }

    return multiplyQuaternions(this, q);
  }

  Quaternion premultiply(Quaternion q) {
    return multiplyQuaternions(q, this);
  }

  Quaternion multiplyQuaternions(Quaternion a, Quaternion b) {
    // from http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/code/index.htm

    var qax = a._x, qay = a._y, qaz = a._z, qaw = a._w;
    var qbx = b._x, qby = b._y, qbz = b._z, qbw = b._w;

    _x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
    _y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
    _z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
    _w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;

    onChangeCallback();

    return this;
  }

  Quaternion slerp(Quaternion qb, num t) {
    if (t == 0) return this;
    if (t == 1) return copy(qb);

    var x = _x, y = _y, z = _z, w = _w;

    // http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/

    var cosHalfTheta = w * qb._w + x * qb._x + y * qb._y + z * qb._z;

    if (cosHalfTheta < 0) {
      _w = -qb._w;
      _x = -qb._x;
      _y = -qb._y;
      _z = -qb._z;

      cosHalfTheta = -cosHalfTheta;
    } else {
      copy(qb);
    }

    if (cosHalfTheta >= 1.0) {
      _w = w;
      _x = x;
      _y = y;
      _z = z;

      return this;
    }

    var sqrSinHalfTheta = 1.0 - cosHalfTheta * cosHalfTheta;

    if (sqrSinHalfTheta <= Math.EPSILON) {
      var s = 1 - t;
      _w = s * w + t * _w;
      _x = s * x + t * _x;
      _y = s * y + t * _y;
      _z = s * z + t * _z;

      normalize();
      onChangeCallback();

      return this;
    }

    var sinHalfTheta = Math.sqrt(sqrSinHalfTheta);
    var halfTheta = Math.atan2(sinHalfTheta, cosHalfTheta);
    var ratioA = Math.sin((1 - t) * halfTheta) / sinHalfTheta,
        ratioB = Math.sin(t * halfTheta) / sinHalfTheta;

    _w = (w * ratioA + _w * ratioB);
    _x = (x * ratioA + _x * ratioB);
    _y = (y * ratioA + _y * ratioB);
    _z = (z * ratioA + _z * ratioB);

    onChangeCallback();

    return this;
  }

  Quaternion slerpQuaternions(Quaternion qa, Quaternion qb, num t) {
    return copy(qa).slerp(qb, t);
  }

  Quaternion random() {
    // Derived from http://planning.cs.uiuc.edu/node198.html
    // Note, this source uses w, x, y, z ordering,
    // so we swap the order below.

    var u1 = Math.random();
    var sqrt1u1 = Math.sqrt(1 - u1);
    var sqrtu1 = Math.sqrt(u1);

    var u2 = 2 * Math.PI * Math.random();

    var u3 = 2 * Math.PI * Math.random();

    return set(
      sqrt1u1 * Math.cos(u2),
      sqrtu1 * Math.sin(u3),
      sqrtu1 * Math.cos(u3),
      sqrt1u1 * Math.sin(u2),
    );
  }

  bool equals(Quaternion quaternion) {
    return (quaternion._x == _x) &&
        (quaternion._y == _y) &&
        (quaternion._z == _z) &&
        (quaternion._w == _w);
  }

  Quaternion fromArray(List<num> array, [int offset = 0]) {
    _x = array[offset];
    _y = array[offset + 1];
    _z = array[offset + 2];
    _w = array[offset + 3];

    onChangeCallback();

    return this;
  }

  List<num> toArray(List<num> array, [int offset = 0]) {
    array[offset] = _x;
    array[offset + 1] = _y;
    array[offset + 2] = _z;
    array[offset + 3] = _w;

    return array;
  }

  Quaternion fromBufferAttribute(BufferAttribute attribute, int index) {
    _x = attribute.getX(index)!;
    _y = attribute.getY(index)!;
    _z = attribute.getZ(index)!;
    _w = attribute.getW(index)!;

    return this;
  }

  void onChange(Function callback) {
    onChangeCallback = callback;
  }
}
