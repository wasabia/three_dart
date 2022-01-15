part of three_extra;

/**************************************************************
 *	Curved Path - a curve path is simply a array of connected
 *  curves, but retains the api of a curve
 **************************************************************/

class CurvePath extends Curve {
  String type = 'CurvePath';

  CurvePath() : super() {
    this.curves = [];
    this.autoClose = false; // Automatically closes the path
  }

  CurvePath.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    this.autoClose = json["autoClose"];
    this.curves = [];

    for (var i = 0, l = json["curves"].length; i < l; i++) {
      var curve = json["curves"][i];
      this.curves.add(Curve.castJSON(curve));
    }
  }

  add(Curve curve) {
    this.curves.add(curve);
  }

  closePath() {
    // Add a line curve if start and end of lines are not connected
    var startPoint = this.curves[0].getPoint(0, null);
    var endPoint = this.curves[this.curves.length - 1].getPoint(1, null);

    if (!startPoint.equals(endPoint)) {
      this.curves.add(LineCurve(endPoint, startPoint));
    }
  }

  // To get accurate point with reference to
  // entire path distance at time t,
  // following has to be done:

  // 1. Length of each sub path have to be known
  // 2. Locate and identify type of curve
  // 3. Get t for the curve
  // 4. Return curve.getPointAt(t')

  getPoint(t, optionalTarget) {
    var d = t * this.getLength();
    var curveLengths = this.getCurveLengths();
    var i = 0;

    // To think about boundaries points.

    while (i < curveLengths.length) {
      if (curveLengths[i] >= d) {
        var diff = curveLengths[i] - d;
        var curve = this.curves[i];

        var segmentLength = curve.getLength();
        var u = segmentLength == 0 ? 0 : 1 - diff / segmentLength;

        return curve.getPointAt(u, null);
      }

      i++;
    }

    return null;

    // loop where sum != 0, sum > d , sum+1 <d
  }

  // We cannot use the default THREE.Curve getPoint() with getLength() because in
  // THREE.Curve, getLength() depends on getPoint() but in THREE.CurvePath
  // getPoint() depends on getLength

  getLength() {
    var lens = this.getCurveLengths();
    return lens[lens.length - 1];
  }

  // cacheLengths must be recalculated.
  updateArcLengths() {
    this.needsUpdate = true;
    this.cacheLengths = null;
    this.getCurveLengths();
  }

  // Compute lengths and cache them
  // We cannot overwrite getLengths() because UtoT mapping uses it.

  List<num> getCurveLengths() {
    // We use cache values if curves and cache array are same length

    if (this.cacheLengths != null &&
        this.cacheLengths!.length == this.curves.length) {
      return this.cacheLengths!;
    }

    // Get length of sub-curve
    // Push sums into cached array

    List<num> lengths = [];
    num sums = 0.0;

    for (var i = 0, l = this.curves.length; i < l; i++) {
      sums += this.curves[i].getLength();
      lengths.add(sums);
    }

    this.cacheLengths = lengths;

    return lengths;
  }

  getSpacedPoints([num divisions = 40, num offset = 0.0]) {
    var points = [];

    for (var i = 0; i <= divisions; i++) {
      var _offset = offset + i / divisions;
      if (_offset > 1.0) {
        _offset = _offset - 1.0;
      }

      points.add(this.getPoint(_offset, null));
    }

    if (this.autoClose) {
      points.add(points[0]);
    }

    return points;
  }

  List getPoints({num divisions = 12}) {
    var points = [];
    var last;

    for (var i = 0, curves = this.curves; i < curves.length; i++) {
      var curve = curves[i];
      var resolution = (curve != null && curve.isEllipseCurve)
          ? divisions * 2
          : (curve != null && (curve.isLineCurve || curve.isLineCurve3))
              ? 1
              : (curve != null && curve.isSplineCurve)
                  ? divisions * curve.points.length
                  : divisions;

      var pts = curve.getPoints(divisions: resolution);

      for (var j = 0; j < pts.length; j++) {
        var point = pts[j];

        if (last != null && last.equals(point))
          continue; // ensures no consecutive points are duplicates

        points.add(point);
        last = point;
      }
    }

    if (this.autoClose &&
        points.length > 1 &&
        !points[points.length - 1].equals(points[0])) {
      points.add(points[0]);
    }

    return points;
  }

  copy(source) {
    super.copy(source);

    this.curves = [];

    for (var i = 0, l = source.curves.length; i < l; i++) {
      var curve = source.curves[i];

      this.curves.add(curve.clone());
    }

    this.autoClose = source.autoClose;

    return this;
  }

  toJSON() {
    var data = super.toJSON();

    data["autoClose"] = this.autoClose;
    data["curves"] = [];

    for (var i = 0, l = this.curves.length; i < l; i++) {
      var curve = this.curves[i];
      data["curves"].add(curve.toJSON());
    }

    return data;
  }

  fromJSON(json) {
    super.fromJSON(json);

    this.autoClose = json.autoClose;
    this.curves = [];

    for (var i = 0, l = json.curves.length; i < l; i++) {
      var curve = json.curves[i];

      throw (" CurvePath fromJSON todo ");
      // this.curves.add( new Curves[ curve.type ]().fromJSON( curve ) );

    }

    return this;
  }
}
