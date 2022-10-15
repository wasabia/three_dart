
import 'package:three_dart/three3d/extras/core/curve.dart';
import 'package:three_dart/three3d/math/index.dart';

class EllipseCurve extends Curve {
  late num aX;
  late num aY;
  late num xRadius;
  late num yRadius;

  late num aStartAngle;
  late num aEndAngle;

  late bool aClockwise;

  late num aRotation;

  @override
  bool isEllipseCurve = true;

  EllipseCurve(
      aX, aY, xRadius, yRadius, [aStartAngle, aEndAngle, aClockwise, aRotation]) {
    type = 'EllipseCurve';

    this.aX = aX ?? 0;
    this.aY = aY ?? 0;

    this.xRadius = xRadius ?? 1;
    this.yRadius = yRadius ?? 1;

    this.aStartAngle = aStartAngle ?? 0;
    this.aEndAngle = aEndAngle ?? 2 * Math.PI;

    this.aClockwise = aClockwise ?? false;

    this.aRotation = aRotation ?? 0;
  }

  EllipseCurve.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    aX = json["aX"];
    aY = json["aY"];

    xRadius = json["xRadius"];
    yRadius = json["yRadius"];

    aStartAngle = json["aStartAngle"];
    aEndAngle = json["aEndAngle"];

    aClockwise = json["aClockwise"];

    aRotation = json["aRotation"];
  }

  @override
  getPoint(t, optionalTarget) {
    var point = optionalTarget ?? Vector2(null, null);

    var twoPi = Math.PI * 2;
    var deltaAngle = aEndAngle - aStartAngle;
    var samePoints = Math.abs(deltaAngle) < Math.EPSILON;

    // ensures that deltaAngle is 0 .. 2 PI
    while (deltaAngle < 0) {
      deltaAngle += twoPi;
    }
    while (deltaAngle > twoPi) {
      deltaAngle -= twoPi;
    }

    if (deltaAngle < Math.EPSILON) {
      if (samePoints) {
        deltaAngle = 0;
      } else {
        deltaAngle = twoPi;
      }
    }

    if (aClockwise == true && !samePoints) {
      if (deltaAngle == twoPi) {
        deltaAngle = -twoPi;
      } else {
        deltaAngle = deltaAngle - twoPi;
      }
    }

    var angle = aStartAngle + t * deltaAngle;
    var x = aX + xRadius * Math.cos(angle);
    var y = aY + yRadius * Math.sin(angle);

    if (aRotation != 0) {
      var cos = Math.cos(aRotation);
      var sin = Math.sin(aRotation);

      var tx = x - aX;
      var ty = y - aY;

      // Rotate the point about the center of the ellipse.
      x = tx * cos - ty * sin + aX;
      y = tx * sin + ty * cos + aY;
    }

    return point.set(x, y);
  }

  @override
  copy(source) {
    super.copy(source);

    aX = source.aX;
    aY = source.aY;

    xRadius = source.xRadius;
    yRadius = source.yRadius;

    aStartAngle = source.aStartAngle;
    aEndAngle = source.aEndAngle;

    aClockwise = source.aClockwise;

    aRotation = source.aRotation;

    return this;
  }

  @override
  toJSON() {
    var data = super.toJSON();

    data["aX"] = aX;
    data["aY"] = aY;

    data["xRadius"] = xRadius;
    data["yRadius"] = yRadius;

    data["aStartAngle"] = aStartAngle;
    data["aEndAngle"] = aEndAngle;

    data["aClockwise"] = aClockwise;

    data["aRotation"] = aRotation;

    return data;
  }
}
