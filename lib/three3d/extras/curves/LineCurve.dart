part of three_extra;

class LineCurve extends Curve {
  @override
  bool isLineCurve = true;

  LineCurve(Vector2 v1, Vector2 v2) {
    type = 'LineCurve';

    this.v1 = v1;
    this.v2 = v2;
  }

  LineCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json);

  @override
  getPoint(t, optionalTarget) {
    var point = optionalTarget ?? Vector2(null, null);

    if (t == 1) {
      point.copy(v2);
    } else {
      point.copy(v2).sub(v1);
      point.multiplyScalar(t).add(v1);
    }

    return point;
  }

  // Line curve is linear, so we can overwrite default getPointAt

  @override
  getPointAt(u, optionalTarget) {
    return getPoint(u, optionalTarget);
  }

  @override
  getTangent(t, [optionalTarget]) {
    var tangent = optionalTarget ?? Vector2(null, null);

    tangent.copy(v2).sub(v1).normalize();

    return tangent;
  }

  @override
  copy(source) {
    super.copy(source);

    v1.copy(source.v1);
    v2.copy(source.v2);

    return this;
  }

  @override
  toJSON() {
    var data = super.toJSON();

    data["v1"] = v1.toArray();
    data["v2"] = v2.toArray();

    return data;
  }
}
