part of three_extra;

/// Bezier Curves formulas obtained from
/// http://en.wikipedia.org/wiki/Bézier_curve

CatmullRom(t, p0, p1, p2, p3) {
  var v0 = (p2 - p0) * 0.5;
  var v1 = (p3 - p1) * 0.5;
  var t2 = t * t;
  var t3 = t * t2;
  return (2 * p1 - 2 * p2 + v0 + v1) * t3 +
      (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 +
      v0 * t +
      p1;
}

//

QuadraticBezierP0(t, p) {
  var k = 1 - t;
  return k * k * p;
}

QuadraticBezierP1(t, p) {
  return 2 * (1 - t) * t * p;
}

QuadraticBezierP2(t, p) {
  return t * t * p;
}

QuadraticBezier(t, p0, p1, p2) {
  return QuadraticBezierP0(t, p0) +
      QuadraticBezierP1(t, p1) +
      QuadraticBezierP2(t, p2);
}

//

CubicBezierP0(t, p) {
  var k = 1 - t;
  return k * k * k * p;
}

CubicBezierP1(t, p) {
  var k = 1 - t;
  return 3 * k * k * t * p;
}

CubicBezierP2(t, p) {
  return 3 * (1 - t) * t * t * p;
}

CubicBezierP3(t, p) {
  return t * t * t * p;
}

CubicBezier(t, p0, p1, p2, p3) {
  return CubicBezierP0(t, p0) +
      CubicBezierP1(t, p1) +
      CubicBezierP2(t, p2) +
      CubicBezierP3(t, p3);
}
