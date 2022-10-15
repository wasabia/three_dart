

import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/extras/core/interpolations.dart';
import 'package:three_dart/three3d/math/index.dart';

class SplineCurve extends Curve {
  @override
  bool isSplineCurve = true;

  SplineCurve(points) : super() {
    type = 'SplineCurve';
    this.points = points;
  }

  SplineCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    points = [];

    for (var i = 0, l = json["points"].length; i < l; i++) {
      var point = json["points"][i];
      points.add(Vector2(null, null).fromArray(point));
    }
  }

  @override
  getPoint(num t, optionalTarget) {
    var point = optionalTarget ?? Vector2(null, null);

    var points = this.points;
    num p = (points.length - 1) * t;

    var intPoint = Math.floor(p).toInt();
    var weight = p - intPoint;

    var p0 = points[intPoint == 0 ? intPoint : intPoint - 1];
    var p1 = points[intPoint];
    var p2 =
        points[intPoint > points.length - 2 ? points.length - 1 : intPoint + 1];
    var p3 =
        points[intPoint > points.length - 3 ? points.length - 1 : intPoint + 2];

    point.set(CatmullRom(weight, p0.x, p1.x, p2.x, p3.x),
        CatmullRom(weight, p0.y, p1.y, p2.y, p3.y));

    return point;
  }

  @override
  copy(source) {
    super.copy(source);

    points = [];

    for (var i = 0, l = source.points.length; i < l; i++) {
      var point = source.points[i];

      points.add(point.clone());
    }

    return this;
  }

  @override
  toJSON() {
    var data = super.toJSON();

    data["points"] = [];

    for (var i = 0, l = points.length; i < l; i++) {
      var point = points[i];
      data["points"].add(point.toArray());
    }

    return data;
  }
}
