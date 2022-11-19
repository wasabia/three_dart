
/// Bezier Curves formulas obtained from
/// http://en.wikipedia.org/wiki/Bézier_curve

num catmullRom(t, p0, p1, p2, p3) {
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

double quadraticBezierP0(double t, double p) {
  var k = 1 - t;
  return k * k * p;
}

quadraticBezierP1(t, p) {
  return 2 * (1 - t) * t * p;
}

quadraticBezierP2(t, p) {
  return t * t * p;
}

quadraticBezier(t, p0, p1, p2) {
  return quadraticBezierP0(t, p0) +
      quadraticBezierP1(t, p1) +
      quadraticBezierP2(t, p2);
}

//

cubicBezierP0(t, p) {
  var k = 1 - t;
  return k * k * k * p;
}

cubicBezierP1(t, p) {
  var k = 1 - t;
  return 3 * k * k * t * p;
}

cubicBezierP2(t, p) {
  return 3 * (1 - t) * t * t * p;
}

cubicBezierP3(t, p) {
  return t * t * t * p;
}

cubicBezier(t, p0, p1, p2, p3) {
  return cubicBezierP0(t, p0) +
      cubicBezierP1(t, p1) +
      cubicBezierP2(t, p2) +
      cubicBezierP3(t, p3);
}
