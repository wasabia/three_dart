import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three3d/math/math_utils.dart';
import 'package:three_dart/three3d/math/matrix4.dart';
import 'package:three_dart/three3d/math/quaternion.dart';
import 'package:three_dart/three3d/math/vector3.dart';

class Euler {
  static const String defaultOrder = 'XYZ';
  static const List<String> rotationOrders = ['XYZ', 'YZX', 'ZXY', 'XZY', 'YXZ', 'ZYX'];

  String type = "Euler";

  late double _x;
  late double _y;
  late double _z;
  late String _order;

  Function onChangeCallback = () {};

  Euler([double? x, double? y, double? z, String? order]) {
    _x = x ?? 0;
    _y = y ?? 0;
    _z = z ?? 0;
    _order = order ?? defaultOrder;
  }

  double get x => _x;
  set x(double value) {
    _x = value;
    onChangeCallback();
  }

  double get y => _y;
  set y(double value) {
    _y = value;
    onChangeCallback();
  }

  double get z => _z;
  set z(double value) {
    _z = value;
    onChangeCallback();
  }

  String get order => _order;
  set order(String value) {
    _order = value;
    onChangeCallback();
  }

  Euler set(double x, double y, double z, [String? order]) {
    _x = x;
    _y = y;
    _z = z;
    _order = order ?? _order;

    onChangeCallback();

    return this;
  }

  Euler clone() {
    return Euler(_x, _y, _z, _order);
  }

  Euler copy(Euler euler) {
    _x = euler._x;
    _y = euler._y;
    _z = euler._z;
    _order = euler._order;

    onChangeCallback();

    return this;
  }

  Euler setFromRotationMatrix(m, [String? order, bool? update]) {
    //var clamp = MathUtils.clamp;

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    final te = m.elements;
    double m11 = te[0], m12 = te[4], m13 = te[8];
    double m21 = te[1], m22 = te[5], m23 = te[9];
    double m31 = te[2], m32 = te[6], m33 = te[10];

    order = order ?? _order;

    switch (order) {
      case 'XYZ':
        _y = Math.asin(MathUtils.clamp(m13, -1, 1));

        if (Math.abs(m13) < 0.9999999) {
          _x = Math.atan2(-m23, m33);
          _z = Math.atan2(-m12, m11);
        } else {
          _x = Math.atan2(m32, m22);
          _z = 0;
        }

        break;

      case 'YXZ':
        _x = Math.asin(-MathUtils.clamp(m23, -1, 1));

        if (Math.abs(m23) < 0.9999999) {
          _y = Math.atan2(m13, m33);
          _z = Math.atan2(m21, m22);
        } else {
          _y = Math.atan2(-m31, m11);
          _z = 0;
        }

        break;

      case 'ZXY':
        _x = Math.asin(MathUtils.clamp(m32, -1, 1));

        if (Math.abs(m32) < 0.9999999) {
          _y = Math.atan2(-m31, m33);
          _z = Math.atan2(-m12, m22);
        } else {
          _y = 0;
          _z = Math.atan2(m21, m11);
        }

        break;

      case 'ZYX':
        _y = Math.asin(-MathUtils.clamp(m31, -1, 1));

        if (Math.abs(m31) < 0.9999999) {
          _x = Math.atan2(m32, m33);
          _z = Math.atan2(m21, m11);
        } else {
          _x = 0;
          _z = Math.atan2(-m12, m22);
        }

        break;

      case 'YZX':
        _z = Math.asin(MathUtils.clamp(m21, -1, 1));

        if (Math.abs(m21) < 0.9999999) {
          _x = Math.atan2(-m23, m22);
          _y = Math.atan2(-m31, m11);
        } else {
          _x = 0;
          _y = Math.atan2(m13, m33);
        }

        break;

      case 'XZY':
        _z = Math.asin(-MathUtils.clamp(m12, -1, 1));

        if (Math.abs(m12) < 0.9999999) {
          _x = Math.atan2(m32, m22);
          _y = Math.atan2(m13, m11);
        } else {
          _x = Math.atan2(-m23, m33);
          _y = 0;
        }

        break;

      default:
        print('three.Euler: .setFromRotationMatrix() encountered an unknown order: $order');
    }

    _order = order;

    if (update != false) onChangeCallback();

    return this;
  }

  Euler setFromQuaternion(Quaternion q, [String? order, bool update = false]) {
    _matrix.makeRotationFromQuaternion(q);

    return setFromRotationMatrix(_matrix, order, update);
  }

  Euler setFromVector3(Vector3 v, [String? order]) {
    return set(v.x, v.y, v.z, order ?? _order);
  }

  Euler reorder(String newOrder) {
    // WARNING: this discards revolution information -bhouston

    _quaternion.setFromEuler(this, false);

    return setFromQuaternion(_quaternion, newOrder, false);
  }

  bool equals(Euler euler) {
    return (euler._x == _x) && (euler._y == _y) && (euler._z == _z) && (euler._order == _order);
  }

  Euler fromArray(List<double> array) {
    _x = array[0];
    _y = array[1];
    _z = array[2];
    if (array.length > 3) _order = rotationOrders[array[3].toInt()];

    onChangeCallback();

    return this;
  }

  List<num> toJSON() {
    int orderNo = rotationOrders.indexOf(_order);
    return [_x, _y, _z, orderNo];
  }

  List<num> toArray([List<num>? array, int offset = 0]) {
    array ??= List<num>.filled(offset + 4, 0);

    array[offset] = _x;
    array[offset + 1] = _y;
    array[offset + 2] = _z;
    array[offset + 3] = rotationOrders.indexOf(_order);

    return array;
  }

  Vector3 toVector3([Vector3? optionalResult]) {
    print(" three.Euler: .toVector3() has been removed. Use Vector3.setFromEuler() instead ");
    if (optionalResult != null) {
      return optionalResult.set(_x, _y, _z);
    } else {
      return Vector3(_x, _y, _z);
    }
  }

  void onChange(Function callback) {
    onChangeCallback = callback;
  }
}

var _matrix = Matrix4();
var _quaternion = Quaternion();
