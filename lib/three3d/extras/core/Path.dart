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

  moveTo(x, y) {
    currentPoint
        .set(x, y); // TODO consider referencing vectors instead of copying?

    return this;
  }

  lineTo(x, y) {
    var curve = LineCurve(currentPoint.clone(), Vector2(x, y));
    curves.add(curve);

    currentPoint.set(x, y);

    return this;
  }

  quadraticCurveTo(aCPx, aCPy, aX, aY) {
    var curve = QuadraticBezierCurve(currentPoint.clone(),
        Vector2(aCPx, aCPy), Vector2(aX, aY));

    curves.add(curve);

    currentPoint.set(aX, aY);

    return this;
  }

  bezierCurveTo(aCP1x, aCP1y, aCP2x, aCP2y, aX, aY) {
    var curve = CubicBezierCurve(
        currentPoint.clone(),
        Vector2(aCP1x, aCP1y),
        Vector2(aCP2x, aCP2y),
        Vector2(aX, aY));

    curves.add(curve);

    currentPoint.set(aX, aY);

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
