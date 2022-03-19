part of three_math;

class Triangle {
  static final _v0 = /*@__PURE__*/ Vector3.init();
  static final _v1 = /*@__PURE__*/ Vector3.init();
  static final _v2 = /*@__PURE__*/ Vector3.init();
  static final _v3 = /*@__PURE__*/ Vector3.init();

  static final _vab = /*@__PURE__*/ Vector3.init();
  static final _vac = /*@__PURE__*/ Vector3.init();
  static final _vbc = /*@__PURE__*/ Vector3.init();
  static final _vap = /*@__PURE__*/ Vector3.init();
  static final _vbp = /*@__PURE__*/ Vector3.init();
  static final _vcp = /*@__PURE__*/ Vector3.init();

  String type = "Triangle";

  late Vector3 a;
  late Vector3 b;
  late Vector3 c;

  Triangle([Vector3? a, Vector3? b, Vector3? c]) {
    this.a = (a != null) ? a : Vector3.init();
    this.b = (b != null) ? b : Vector3.init();
    this.c = (c != null) ? c : Vector3.init();
  }

  Triangle.init({Vector3? a, Vector3? b, Vector3? c}) {
    this.a = (a != null) ? a : Vector3.init();
    this.b = (b != null) ? b : Vector3.init();
    this.c = (c != null) ? c : Vector3.init();
  }

  Vector3 operator [](Object? key) {
    return getValue(key);
  }

  Vector3 getValue(Object? key) {
    if (key == "a") {
      return a;
    } else if (key == "b") {
      return b;
    } else if (key == "c") {
      return c;
    } else {
      throw ("Triangle getValue key: $key not support .....");
    }
  }

  static Vector3 static_getNormal(
      Vector3 a, Vector3 b, Vector3 c, Vector3 target) {
    target.subVectors(c, b);
    _v0.subVectors(a, b);
    target.cross(_v0);

    var targetLengthSq = target.lengthSq();
    if (targetLengthSq > 0) {
      // print(" targer: ${target.toJSON()} getNormal scale: ${1 / Math.sqrt( targetLengthSq )} ");

      return target.multiplyScalar(1 / Math.sqrt(targetLengthSq));
    }

    return target.set(0, 0, 0);
  }

  // static/instance method to calculate barycentric coordinates
  // based on: http://www.blackpawn.com/texts/pointinpoly/default.html
  static Vector3 static_getBarycoord(
      point, Vector3 a, Vector3 b, Vector3 c, Vector3 target) {
    _v0.subVectors(c, a);
    _v1.subVectors(b, a);
    _v2.subVectors(point, a);

    var dot00 = _v0.dot(_v0);
    var dot01 = _v0.dot(_v1);
    var dot02 = _v0.dot(_v2);
    var dot11 = _v1.dot(_v1);
    var dot12 = _v1.dot(_v2);

    var denom = (dot00 * dot11 - dot01 * dot01);

    // collinear or singular triangle
    if (denom == 0) {
      // arbitrary location outside of triangle?
      // not sure if this is the best idea, maybe should be returning null
      return target.set(-2, -1, -1);
    }

    var invDenom = 1 / denom;
    var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    var v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // barycentric coordinates must always sum to 1
    return target.set(1 - u - v, v, u);
  }

  static bool static_containsPoint(point, Vector3 a, Vector3 b, Vector3 c) {
    static_getBarycoord(point, a, b, c, _v3);

    return (_v3.x >= 0) && (_v3.y >= 0) && ((_v3.x + _v3.y) <= 1);
  }

  static static_getUV(
      point, Vector3 p1, Vector3 p2, Vector3 p3, uv1, uv2, uv3, target) {
    static_getBarycoord(point, p1, p2, p3, _v3);

    target.set(0, 0);
    target.addScaledVector(uv1, _v3.x);
    target.addScaledVector(uv2, _v3.y);
    target.addScaledVector(uv3, _v3.z);

    return target;
  }

  static bool static_isFrontFacing(
      Vector3 a, Vector3 b, Vector3 c, Vector3 direction) {
    _v0.subVectors(c, b);
    _v1.subVectors(a, b);

    // strictly front facing
    return (_v0.cross(_v1).dot(direction) < 0) ? true : false;
  }

  Triangle set(Vector3 a, Vector3 b, Vector3 c) {
    this.a.copy(a);
    this.b.copy(b);
    this.c.copy(c);

    return this;
  }

  Triangle setFromPointsAndIndices(points, int i0, int i1, int i2) {
    a.copy(points[i0]);
    b.copy(points[i1]);
    c.copy(points[i2]);

    return this;
  }

  Triangle clone() {
    return Triangle.init().copy(this);
  }

  Triangle copy(Triangle triangle) {
    a.copy(triangle.a);
    b.copy(triangle.b);
    c.copy(triangle.c);

    return this;
  }

  double getArea() {
    _v0.subVectors(c, b);
    _v1.subVectors(a, b);

    return _v0.cross(_v1).length() * 0.5;
  }

  Vector3 getMidpoint(Vector3 target) {
    return target.addVectors(a, b).add(c).multiplyScalar(1 / 3);
  }

  Vector3 getNormal(Vector3 target) {
    return Triangle.static_getNormal(a, b, c, target);
  }

  Plane getPlane(Plane target) {
    return target.setFromCoplanarPoints(a, b, c);
  }

  Vector3 getBarycoord(point, Vector3 target) {
    return Triangle.static_getBarycoord(point, a, b, c, target);
  }

  dynamic getUV(point, uv1, uv2, uv3, target) {
    return Triangle.static_getUV(point, a, b, c, uv1, uv2, uv3, target);
  }

  bool containsPoint(point) {
    return Triangle.static_containsPoint(point, a, b, c);
  }

  bool isFrontFacing(Vector3 direction) {
    return Triangle.static_isFrontFacing(a, b, c, direction);
  }

  intersectsBox(Box3 box) {
    return box.intersectsTriangle(this);
  }

  Vector3 closestPointToPoint(Vector3 p, Vector3 target) {
    var a = this.a, b = this.b, c = this.c;
    var v, w;

    // algorithm thanks to Real-Time Collision Detection by Christer Ericson,
    // published by Morgan Kaufmann Publishers, (c) 2005 Elsevier Inc.,
    // under the accompanying license; see chapter 5.1.5 for detailed explanation.
    // basically, we're distinguishing which of the voronoi regions of the triangle
    // the point lies in with the minimum amount of redundant computation.

    _vab.subVectors(b, a);
    _vac.subVectors(c, a);
    _vap.subVectors(p, a);
    var d1 = _vab.dot(_vap);
    var d2 = _vac.dot(_vap);
    if (d1 <= 0 && d2 <= 0) {
      // vertex region of A; barycentric coords (1, 0, 0)
      return target.copy(a);
    }

    _vbp.subVectors(p, b);
    var d3 = _vab.dot(_vbp);
    var d4 = _vac.dot(_vbp);
    if (d3 >= 0 && d4 <= d3) {
      // vertex region of B; barycentric coords (0, 1, 0)
      return target.copy(b);
    }

    var vc = d1 * d4 - d3 * d2;
    if (vc <= 0 && d1 >= 0 && d3 <= 0) {
      v = d1 / (d1 - d3);
      // edge region of AB; barycentric coords (1-v, v, 0)
      return target.copy(a).addScaledVector(_vab, v);
    }

    _vcp.subVectors(p, c);
    var d5 = _vab.dot(_vcp);
    var d6 = _vac.dot(_vcp);
    if (d6 >= 0 && d5 <= d6) {
      // vertex region of C; barycentric coords (0, 0, 1)
      return target.copy(c);
    }

    var vb = d5 * d2 - d1 * d6;
    if (vb <= 0 && d2 >= 0 && d6 <= 0) {
      w = d2 / (d2 - d6);
      // edge region of AC; barycentric coords (1-w, 0, w)
      return target.copy(a).addScaledVector(_vac, w);
    }

    var va = d3 * d6 - d5 * d4;
    if (va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0) {
      _vbc.subVectors(c, b);
      w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
      // edge region of BC; barycentric coords (0, 1-w, w)
      return target.copy(b).addScaledVector(_vbc, w); // edge region of BC

    }

    // face region
    var denom = 1 / (va + vb + vc);
    // u = va * denom
    v = vb * denom;
    w = vc * denom;

    return target.copy(a).addScaledVector(_vab, v).addScaledVector(_vac, w);
  }

  bool equals(Triangle triangle) {
    return triangle.a.equals(a) && triangle.b.equals(b) && triangle.c.equals(c);
  }
}
