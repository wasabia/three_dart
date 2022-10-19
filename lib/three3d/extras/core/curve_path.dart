import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/extras/curves/line_curve.dart';

/// ************************************************************
///	Curved Path - a curve path is simply a array of connected
///  curves, but retains the api of a curve
///*************************************************************/

class CurvePath extends Curve {
  CurvePath() : super() {
    type = 'CurvePath';
    curves = [];
    autoClose = false; // Automatically closes the path
  }

  CurvePath.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    autoClose = json["autoClose"];
    type = 'CurvePath';
    curves = [];

    for (var i = 0, l = json["curves"].length; i < l; i++) {
      var curve = json["curves"][i];
      curves.add(Curve.castJSON(curve));
    }
  }

  add(Curve curve) {
    curves.add(curve);
  }

  closePath() {
    // Add a line curve if start and end of lines are not connected
    var startPoint = curves[0].getPoint(0, null);
    var endPoint = curves[curves.length - 1].getPoint(1, null);

    if (!startPoint.equals(endPoint)) {
      curves.add(LineCurve(endPoint, startPoint));
    }
  }

  // To get accurate point with reference to
  // entire path distance at time t,
  // following has to be done:

  // 1. Length of each sub path have to be known
  // 2. Locate and identify type of curve
  // 3. Get t for the curve
  // 4. Return curve.getPointAt(t')

  @override
  getPoint(t, optionalTarget) {
    var d = t * getLength();
    var curveLengths = getCurveLengths();
    var i = 0;

    // To think about boundaries points.

    while (i < curveLengths.length) {
      if (curveLengths[i] >= d) {
        var diff = curveLengths[i] - d;
        var curve = curves[i];

        var segmentLength = curve.getLength();
        var u = segmentLength == 0 ? 0 : 1 - diff / segmentLength;

        return curve.getPointAt(u, optionalTarget);
      }

      i++;
    }

    return null;

    // loop where sum != 0, sum > d , sum+1 <d
  }

  // We cannot use the default three.Curve getPoint() with getLength() because in
  // three.Curve, getLength() depends on getPoint() but in three.CurvePath
  // getPoint() depends on getLength

  @override
  getLength() {
    var lens = getCurveLengths();
    return lens[lens.length - 1];
  }

  // cacheLengths must be recalculated.
  @override
  updateArcLengths() {
    needsUpdate = true;
    cacheLengths = null;
    getCurveLengths();
  }

  // Compute lengths and cache them
  // We cannot overwrite getLengths() because UtoT mapping uses it.

  List<num> getCurveLengths() {
    // We use cache values if curves and cache array are same length

    if (cacheLengths != null && cacheLengths!.length == curves.length) {
      return cacheLengths!;
    }

    // Get length of sub-curve
    // Push sums into cached array

    List<num> lengths = [];
    num sums = 0.0;

    for (var i = 0, l = curves.length; i < l; i++) {
      sums += curves[i].getLength();
      lengths.add(sums);
    }

    cacheLengths = lengths;

    return lengths;
  }

  @override
  getSpacedPoints([num divisions = 40, num offset = 0.0]) {
    var points = [];

    for (var i = 0; i <= divisions; i++) {
      var _offset = offset + i / divisions;
      if (_offset > 1.0) {
        _offset = _offset - 1.0;
      }

      points.add(getPoint(_offset, null));
    }

    if (autoClose) {
      points.add(points[0]);
    }

    return points;
  }

  @override
  List getPoints([num divisions = 12]) {
    var points = [];
    var last;

    for (var i = 0, curves = this.curves; i < curves.length; i++) {
      var curve = curves[i];
      var resolution = (curve.isEllipseCurve)
          ? divisions * 2
          : ((curve is LineCurve || curve is LineCurve3))
              ? 1
              : (curve.isSplineCurve)
                  ? divisions * curve.points.length
                  : divisions;

      var pts = curve.getPoints(resolution);

      for (var j = 0; j < pts.length; j++) {
        var point = pts[j];

        if (last != null && last.equals(point)) {
          continue;
        } // ensures no consecutive points are duplicates

        points.add(point);
        last = point;
      }
    }

    if (autoClose && points.length > 1 && !points[points.length - 1].equals(points[0])) {
      points.add(points[0]);
    }

    return points;
  }

  @override
  copy(source) {
    super.copy(source);

    curves = [];

    for (var i = 0, l = source.curves.length; i < l; i++) {
      var curve = source.curves[i];

      curves.add(curve.clone());
    }

    autoClose = source.autoClose;

    return this;
  }

  @override
  toJSON() {
    var data = super.toJSON();

    data["autoClose"] = autoClose;
    data["curves"] = [];

    for (var i = 0, l = curves.length; i < l; i++) {
      var curve = curves[i];
      data["curves"].add(curve.toJSON());
    }

    return data;
  }
}
