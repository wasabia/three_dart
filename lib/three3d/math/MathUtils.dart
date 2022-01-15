part of three_math;

var _seed = 1234567;

class MathUtils {
  static num DEG2RAD = Math.PI / 180.0;
  static num RAD2DEG = 180.0 / Math.PI;

  static String generateUUID() {
    var uuid = Uuid.generate();
    // .toUpperCase() here flattens concatenated strings to save heap memory space.
    return uuid.toUpperCase();
  }

  static clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
  }

  // compute euclidian modulo of m % n
  // https://en.wikipedia.org/wiki/Modulo_operation

  static euclideanModulo(n, m) {
    return ((n % m) + m) % m;
  }

  // Linear mapping from range <a1, a2> to range <b1, b2>

  static mapLinear(x, a1, a2, b1, b2) {
    return b1 + (x - a1) * (b2 - b1) / (a2 - a1);
  }

  // https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/inverse-lerp-a-super-useful-yet-often-overlooked-function-r5230/
  static inverseLerp(x, y, value) {
    if (x != y) {
      return (value - x) / (y - x);
    } else {
      return 0;
    }
  }

  // https://en.wikipedia.org/wiki/Linear_interpolation

  static lerp(x, y, t) {
    return (1 - t) * x + t * y;
  }

  // https://www.desmos.com/calculator/vcsjnyz7x4

  static pingPong(x, {length = 1}) {
    return length - Math.abs(x % (length * 2) - length);
  }

  static damp(num x, num y, num lambda, num dt) {
    return MathUtils.lerp(x, y, 1 - Math.exp(-lambda * dt));
  }

  // http://en.wikipedia.org/wiki/Smoothstep

  static smoothstep(x, min, max) {
    if (x <= min) return 0;
    if (x >= max) return 1;

    x = (x - min) / (max - min);

    return x * x * (3 - 2 * x);
  }

  static smootherstep(x, min, max) {
    if (x <= min) return 0;
    if (x >= max) return 1;

    x = (x - min) / (max - min);

    return x * x * x * (x * (x * 6 - 15) + 10);
  }

  // Random integer from <low, high> interval

  static randInt(low, high) {
    return low + Math.floor(Math.random() * (high - low + 1));
  }

  // Random float from <low, high> interval

  static randFloat(low, high) {
    return low + Math.random() * (high - low);
  }

  // Random float from <-range/2, range/2> interval

  static randFloatSpread(range) {
    return range * (0.5 - Math.random());
  }

  // Deterministic pseudo-random float in the interval [ 0, 1 ]

  static seededRandom(s) {
    if (s != null) _seed = s % 2147483647;

    // Park-Miller algorithm

    _seed = _seed * 16807 % 2147483647;

    return (_seed - 1) / 2147483646;
  }

  static degToRad(degrees) {
    return degrees * MathUtils.DEG2RAD;
  }

  static radToDeg(radians) {
    return radians * MathUtils.RAD2DEG;
  }

  static isPowerOfTwo(value) {
    return (value & (value - 1)) == 0 && value != 0;
  }

  static ceilPowerOfTwo(value) {
    return Math.pow(2, Math.ceil(Math.log(value) / Math.LN2).toDouble());
  }

  static floorPowerOfTwo(value) {
    return Math.pow(2, Math.floor(Math.log(value) / Math.LN2).toDouble());
  }

  static setQuaternionFromProperEuler(q, a, b, c, order) {
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
        print(
            'THREE.MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: ' +
                order);
    }
  }
}
