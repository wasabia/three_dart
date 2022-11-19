import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three3d/math/uuid.dart';

var _seed = 1234567;

class MathUtils {
  static num deg2rad = Math.pi / 180.0;
  static num rad2deg = 180.0 / Math.pi;

  static String generateUUID() {
    var uuid = Uuid().v4();
    // .toLowerCase() here flattens concatenated strings to save heap memory space.
    return uuid.toLowerCase();
  }

  static T clamp<T extends num>(T value, T min, T max) {
    return Math.max(min, Math.min(max, value));
  }

  // compute euclidian modulo of m % n
  // https://en.wikipedia.org/wiki/Modulo_operation

  static num euclideanModulo<T extends num>(T n, T m) {
    return ((n % m) + m) % m;
  }

  // Linear mapping from range <a1, a2> to range <b1, b2>

  static num mapLinear<T extends num>(T x, T a1, T a2, T b1, T b2) {
    return b1 + (x - a1) * (b2 - b1) / (a2 - a1);
  }

  // https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/inverse-lerp-a-super-useful-yet-often-overlooked-function-r5230/
  static num inverseLerp<T extends num>(T x, T y, T value) {
    if (x != y) {
      return (value - x) / (y - x);
    } else {
      return 0;
    }
  }

  // https://en.wikipedia.org/wiki/Linear_interpolation

  static num lerp<T extends num>(T x, T y, T t) {
    return (1 - t) * x + t * y;
  }

  // https://www.desmos.com/calculator/vcsjnyz7x4

  static num pingPong<T extends num>(T x, {int length = 1}) {
    return length - Math.abs(x % (length * 2) - length);
  }

  static num damp(num x, num y, num lambda, num dt) {
    return MathUtils.lerp(x, y, 1 - Math.exp(-lambda * dt));
  }

  // http://en.wikipedia.org/wiki/Smoothstep

  static num smoothstep(num x, num min, num max) {
    if (x <= min) return 0;
    if (x >= max) return 1;

    x = (x - min) / (max - min);

    return x * x * (3 - 2 * x);
  }

  static num smootherstep(num x, num min, num max) {
    if (x <= min) return 0;
    if (x >= max) return 1;

    x = (x - min) / (max - min);

    return x * x * x * (x * (x * 6 - 15) + 10);
  }

  // Random integer from <low, high> interval

  static int randInt(int low, int high) {
    return low + Math.floor(Math.random() * (high - low + 1));
  }

  // Random float from <low, high> interval

  static double randFloat(double low, double high) {
    return low + Math.random() * (high - low);
  }

  // Random float from <-range/2, range/2> interval

  static double randFloatSpread(double range) {
    return range * (0.5 - Math.random());
  }

  // Deterministic pseudo-random float in the interval [ 0, 1 ]

  static double seededRandom([int? s]) {
    if (s != null) _seed = s % 2147483647;

    // Park-Miller algorithm

    _seed = _seed * 16807 % 2147483647;

    return (_seed - 1) / 2147483646;
  }

  static num degToRad(num degrees) {
    return degrees * MathUtils.deg2rad;
  }

  static num radToDeg(num radians) {
    return radians * MathUtils.rad2deg;
  }

  static bool isPowerOfTwo(int value) {
    return (value & (value - 1)) == 0 && value != 0;
  }

  static num ceilPowerOfTwo<T extends num>(T value) {
    return Math.pow(2, Math.ceil(Math.log(value) / Math.ln2).toDouble());
  }

  static num floorPowerOfTwo<T extends num>(T value) {
    return Math.pow(2, Math.floor(Math.log(value) / Math.ln2).toDouble());
  }

  static void setQuaternionFromProperEuler(q, num a, num b, num c, String order) {
    // Intrinsic Proper Euler Angles - see https://en.wikipedia.org/wiki/Euler_angles

    // rotations are applied to the axes in the order specified by 'order'
    // rotation by angle 'a' is applied first, then by angle 'b', then by angle 'c'
    // angles are in radians

    var cos = Math.cos;
    var sin = Math.sin;

    var c2 = cos(b / 2);
    var s2 = sin(b / 2);

    var c13 = cos((a + c) / 2);
    var s13 = sin((a + c) / 2);

    var c1_3 = cos((a - c) / 2);
    var s1_3 = sin((a - c) / 2);

    var c3_1 = cos((c - a) / 2);
    var s3_1 = sin((c - a) / 2);

    switch (order) {
      case 'XYX':
        q.set(c2 * s13, s2 * c1_3, s2 * s1_3, c2 * c13);
        break;

      case 'YZY':
        q.set(s2 * s1_3, c2 * s13, s2 * c1_3, c2 * c13);
        break;

      case 'ZXZ':
        q.set(s2 * c1_3, s2 * s1_3, c2 * s13, c2 * c13);
        break;

      case 'XZX':
        q.set(c2 * s13, s2 * s3_1, s2 * c3_1, c2 * c13);
        break;

      case 'YXY':
        q.set(s2 * c3_1, c2 * s13, s2 * s3_1, c2 * c13);
        break;

      case 'ZYZ':
        q.set(s2 * s3_1, s2 * c3_1, c2 * s13, c2 * c13);
        break;

      default:
        print('three.MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: $order');
    }
  }

  static denormalize(num value, array) {
    switch (array) {
      case Float32Array:
        return value;

      case Uint16Array:
        return value / 65535.0;

      case Uint8Array:
        return value / 255.0;

      case Int16Array:
        return Math.max(value / 32767.0, -1.0);

      case Int8Array:
        return Math.max(value / 127.0, -1.0);

      default:
        throw ('Invalid component type.');
    }
  }

  static normalize(value, array) {
    switch (array) {
      case Float32Array:
        return value;

      case Uint16Array:
        return Math.round(value * 65535.0);

      case Uint8Array:
        return Math.round(value * 255.0);

      case Int16Array:
        return Math.round(value * 32767.0);

      case Int8Array:
        return Math.round(value * 127.0);

      default:
        throw ('Invalid component type.');
    }
  }
}
