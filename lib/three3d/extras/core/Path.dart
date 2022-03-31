part of three_extra;

class Path extends CurvePath {
  @override
  String type = 'Path';

  Path(points) : super() {
    if (points != null) {
      setFromPoints(points);
    }
  }

  Path.fromJSON(json) : super.fromJSON(json) {
    currentPoint.fromArray(json["currentPoint"]);
  }

  setFromPoints(points) {
    moveTo(points[0].x, points[0].y);

    for (var i = 1, l = points.length; i < l; i++) {
      lineTo(points[i].x, points[i].y);
    }

    return this;
  }

  moveTo(num x, num y) {
    currentPoint
        .set(x.toDouble(), y.toDouble()); // TODO consider referencing vectors instead of copying?

    return this;
  }

  lineTo(num x, num y) {
    var curve = LineCurve(currentPoint.clone(), Vector2(x.toDouble(), y.toDouble()));
    curves.add(curve);

    currentPoint.set(x.toDouble(), y.toDouble());

    return this;
  }

  quadraticCurveTo(num aCPx, num aCPy, num aX, num aY) {
    var curve = QuadraticBezierCurve(currentPoint.clone(),
        Vector2(aCPx.toDouble(), aCPy.toDouble()), Vector2(aX.toDouble(), aY.toDouble()));

    curves.add(curve);

    currentPoint.set(aX.toDouble(), aY.toDouble());

    return this;
  }

  bezierCurveTo(num aCP1x, num aCP1y, num aCP2x, num aCP2y, num aX, num aY) {
    var curve = CubicBezierCurve(
        currentPoint.clone(),
        Vector2(aCP1x.toDouble(), aCP1y.toDouble()),
        Vector2(aCP2x.toDouble(), aCP2y.toDouble()),
        Vector2(aX.toDouble(), aY.toDouble()));

    curves.add(curve);

    currentPoint.set(aX.toDouble(), aY.toDouble());

    return this;
  }

  splineThru(pts /*Array of Vector*/) {
    var npts = [currentPoint.clone()];
    npts.addAll(pts);

    var curve = SplineCurve(npts);
    curves.add(curve);

    currentPoint.copy(pts[pts.length - 1]);

    return this;
  }

  arc(aX, aY, aRadius, aStartAngle, aEndAngle, aClockwise) {
    var x0 = currentPoint.x;
    var y0 = currentPoint.y;

    absarc(aX + x0, aY + y0, aRadius, aStartAngle, aEndAngle, aClockwise);

    return this;
  }

  absarc(aX, aY, aRadius, aStartAngle, aEndAngle, aClockwise) {
    absellipse(
        aX, aY, aRadius, aRadius, aStartAngle, aEndAngle, aClockwise, null);

    return this;
  }

  ellipse(
      aX, aY, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise, aRotation) {
    var x0 = currentPoint.x;
    var y0 = currentPoint.y;

    absellipse(aX + x0, aY + y0, xRadius, yRadius, aStartAngle, aEndAngle,
        aClockwise, aRotation);

    return this;
  }

  absellipse(
      aX, aY, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise, aRotation) {
    var curve = EllipseCurve(aX, aY, xRadius, yRadius, aStartAngle,
        aEndAngle, aClockwise, aRotation);

    if (curves.isNotEmpty) {
      // if a previous curve is present, attempt to join
      var firstPoint = curve.getPoint(0, null);

      if (!firstPoint.equals(currentPoint)) {
        lineTo(firstPoint.x, firstPoint.y);
      }
    }

    curves.add(curve);

    var lastPoint = curve.getPoint(1, null);
    currentPoint.copy(lastPoint);

    return this;
  }

  @override
  copy(source) {
    super.copy(source);

    currentPoint.copy(source.currentPoint);

    return this;
  }

  @override
  toJSON() {
    var data = super.toJSON();

    data["currentPoint"] = currentPoint.toArray();

    return data;
  }

  @override
  fromJSON(json) {
    super.fromJSON(json);

    currentPoint.fromArray(json.currentPoint);

    return this;
  }
}
