part of three_math;


class Math {

  static double Infinity = double.maxFinite;
  static const double PI = math.pi;
  static double LN2 = math.ln2;
  static const double EPSILON = 4.94065645841247E-324;
  static double LOG2E = math.log2e;
  static double MAX_VALUE = double.maxFinite;
  static double LN10 = math.ln10;

  static min(num x, num y) {
    return math.min(x, y);
  }

  static min3(num x, num y, num z) {
    return min(min(x, y), z);
  }

  static max(num x, num y) {
    return math.max(x, y);
  }

  static max3(num x, num y, num z) {
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

  static abs(num x) {
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

  static double randomFromA2B(a, b) {
    var result = random() * (b - a) + a;
    return result;
  }

  static num pow( num x, num y ) {
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
    return log(x) / LN2;
  }


}