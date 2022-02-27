part of three_math;

class Euler {
  static const String DefaultOrder = 'XYZ';
  static const List<String> RotationOrders = [
    'XYZ',
    'YZX',
    'ZXY',
    'XZY',
    'YXZ',
    'ZYX'
  ];

  String type = "Euler";

  late num _x;
  late num _y;
  late num _z;
  late String _order;

  Function onChangeCallback = () {};

  Euler(num x, num y, num z, {String? order = null}) {
    this._x = x;
    this._y = y;
    this._z = z;
    this._order = order ?? DefaultOrder;
  }

  Euler.init(
      {num x = 0, num y = 0, num z = 0, String order = Euler.DefaultOrder}) {
    this._x = x;
    this._y = y;
    this._z = z;
    this._order = order;
  }

  get x {
    return this._x;
  }

  set x(value) {
    this._x = value;
    this.onChangeCallback();
  }

  get y {
    return this._y;
  }

  set y(value) {
    this._y = value;
    this.onChangeCallback();
  }

  get z {
    return this._z;
  }

  set z(value) {
    this._z = value;
    this.onChangeCallback();
  }

  get order {
    return this._order;
  }

  set order(value) {
    this._order = value;
    this.onChangeCallback();
  }

  set(x, y, z, {String? order}) {
    this._x = x;
    this._y = y;
    this._z = z;
    this._order = order ?? this._order;

    this.onChangeCallback();

    return this;
  }

  clone() {
    return new Euler(this._x, this._y, this._z, order: this._order);
  }

  copy(euler) {
    this._x = euler._x;
    this._y = euler._y;
    this._z = euler._z;
    this._order = euler._order;

    this.onChangeCallback();

    return this;
  }

  setFromRotationMatrix(m, order, update) {
    var clamp = MathUtils.clamp;

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    var te = m.elements;
    var m11 = te[0], m12 = te[4], m13 = te[8];
    var m21 = te[1], m22 = te[5], m23 = te[9];
    var m31 = te[2], m32 = te[6], m33 = te[10];

    order = order ?? this._order;

    switch (order) {
      case 'XYZ':
        this._y = Math.asin(clamp(m13, -1, 1));

        if (Math.abs(m13) < 0.9999999) {
          this._x = Math.atan2(-m23, m33);
          this._z = Math.atan2(-m12, m11);
        } else {
          this._x = Math.atan2(m32, m22);
          this._z = 0;
        }

        break;

      case 'YXZ':
        this._x = Math.asin(-clamp(m23, -1, 1));

        if (Math.abs(m23) < 0.9999999) {
          this._y = Math.atan2(m13, m33);
          this._z = Math.atan2(m21, m22);
        } else {
          this._y = Math.atan2(-m31, m11);
          this._z = 0;
        }

        break;

      case 'ZXY':
        this._x = Math.asin(clamp(m32, -1, 1));

        if (Math.abs(m32) < 0.9999999) {
          this._y = Math.atan2(-m31, m33);
          this._z = Math.atan2(-m12, m22);
        } else {
          this._y = 0;
          this._z = Math.atan2(m21, m11);
        }

        break;

      case 'ZYX':
        this._y = Math.asin(-clamp(m31, -1, 1));

        if (Math.abs(m31) < 0.9999999) {
          this._x = Math.atan2(m32, m33);
          this._z = Math.atan2(m21, m11);
        } else {
          this._x = 0;
          this._z = Math.atan2(-m12, m22);
        }

        break;

      case 'YZX':
        this._z = Math.asin(clamp(m21, -1, 1));

        if (Math.abs(m21) < 0.9999999) {
          this._x = Math.atan2(-m23, m22);
          this._y = Math.atan2(-m31, m11);
        } else {
          this._x = 0;
          this._y = Math.atan2(m13, m33);
        }

        break;

      case 'XZY':
        this._z = Math.asin(-clamp(m12, -1, 1));

        if (Math.abs(m12) < 0.9999999) {
          this._x = Math.atan2(m32, m22);
          this._y = Math.atan2(m13, m11);
        } else {
          this._x = Math.atan2(-m23, m33);
          this._y = 0;
        }

        break;

      default:
        print(
            'THREE.Euler: .setFromRotationMatrix() encountered an unknown order: ' +
                order);
    }

    this._order = order;

    if (update != false) this.onChangeCallback();

    return this;
  }

  setFromQuaternion(Quaternion q, String? order, bool update) {
    _matrix.makeRotationFromQuaternion(q);

    return this.setFromRotationMatrix(_matrix, order, update);
  }

  setFromVector3(v, order) {
    return this.set(v.x, v.y, v.z, order: order ?? this._order);
  }

  reorder(newOrder) {
    // WARNING: this discards revolution information -bhouston

    _quaternion.setFromEuler(this, false);

    return this.setFromQuaternion(_quaternion, newOrder, false);
  }

  equals(euler) {
    return (euler._x == this._x) &&
        (euler._y == this._y) &&
        (euler._z == this._z) &&
        (euler._order == this._order);
  }

  fromArray(List<double> array) {
    this._x = array[0];
    this._y = array[1];
    this._z = array[2];
    if (array[3] != null) this._order = RotationOrders[array[3].toInt()];

    this.onChangeCallback();

    return this;
  }

  List<num> toJSON() {
    int orderNo = RotationOrders.indexOf(this._order);
    return [this._x, this._y, this._z, orderNo];
  }

  toArray(List<num> array, {int offset = 0}) {
    array[offset] = this._x;
    array[offset + 1] = this._y;
    array[offset + 2] = this._z;
    array[offset + 3] = RotationOrders.indexOf(this._order);

    return array;
  }

  toVector3(optionalResult) {
    print(" THREE.Euler: .toVector3() has been removed. Use Vector3.setFromEuler() instead ");
    if (optionalResult) {
      return optionalResult.set(this._x, this._y, this._z);
    } else {
      return new Vector3(this._x, this._y, this._z);
    }
  }

  onChange(Function callback) {
    this.onChangeCallback = callback;
  }
}

var _matrix = new Matrix4();
var _quaternion = new Quaternion();
