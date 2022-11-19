import 'dart:math' as math;

class Math {
  static double infinity = double.maxFinite;
  static const double pi = math.pi;
  static double ln2 = math.ln2;
  static const double epsilon = 4.94065645841247E-324;
  static double log2e = math.log2e;
  static double maxValue = double.maxFinite;
  static double ln10 = math.ln10;
  static double sqrt1_2 = math.sqrt1_2;

  // TODO
  static int maxSafeInteger = 9007199254740991;

  static T min<T extends num>(T x, T y) {
    return math.min(x, y);
  }

  static num min3(num x, num y, num z) {
    return min(min(x, y), z);
  }

  static T max<T extends num>(T x, T y) {
    return math.max(x, y);
  }

  static num max3(num x, num y, num z) {
    return max(max(x, y), z);
  }

  static int floor(num x) {
    return x.floor();
  }

  static int ceil(num x) {
    return x.ceil();
  }

  static int round(num x) {
    return x.round();
  }

  static double sqrt(num x) {
    return math.sqrt(x);
  }

  static num abs(num x) {
    return x.abs();
  }

  static double atan2(num x, num y) {
    return math.atan2(x, y);
  }

  static double cos(num x) {
    return math.cos(x);
  }

  static double sin(num x) {
    return math.sin(x);
  }

  static double acos(num x) {
    return math.acos(x);
  }

  static double asin(num x) {
    return math.asin(x);
  }

  static double random() {
    return math.Random().nextDouble();
  }

  static double randomFromA2B(num a, num b) {
    var result = random() * (b - a) + a;
    return result;
  }

  static num pow(num x, num y) {
    return math.pow(x, y);
  }

  static num log(num x) {
    return math.log(x);
  }

  static double tan(num x) {
    return math.tan(x);
  }

  static double atan(double x) {
    return math.atan(x);
  }

  static double sign(double x) {
    return x.sign;
  }

  static double exp(num x) {
    return math.exp(x);
  }

  static double log2(num x) {
    return log(x) / ln2;
  }

  // Random float from <low, high> interval
  static double randFloat(num low, num high) {
    return low + Math.random() * (high - low);
  }

  // Random float from <-range/2, range/2> interval
  static double randFloatSpread(num range) {
    return range * (0.5 - Math.random());
  }
}

bool isFinite(num v) {
  return v != Math.infinity || v != -Math.infinity;
}
