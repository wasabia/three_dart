part of three_math;

final _startP = /*@__PURE__*/ Vector3.init();
final _startEnd = /*@__PURE__*/ Vector3.init();

class Line3 {
  late Vector3 start;
  late Vector3 end;

  Line3([Vector3? start, Vector3? end]) {
    this.start = (start != null) ? start : Vector3.init();
    this.end = (end != null) ? end : Vector3.init();
  }

  Line3 set(Vector3 start, Vector3 end) {
    this.start.copy(start);
    this.end.copy(end);

    return this;
  }

  Line3 clone() {
    return Line3(null, null).copy(this);
  }

  Line3 copy(Line3 line) {
    start.copy(line.start);
    end.copy(line.end);

    return this;
  }

  Vector3 getCenter(Vector3 target) {
    return target.addVectors(start, end).multiplyScalar(0.5);
  }

  Vector3 delta(Vector3 target) {
    return target.subVectors(end, start);
  }

  num distanceSq() {
    return start.distanceToSquared(end);
  }

  double distance() {
    return start.distanceTo(end);
  }

  Vector3 at(num t, Vector3 target) {
    return delta(target).multiplyScalar(t).add(start);
  }

  double closestPointToPointParameter(Vector3 point, bool clampToLine) {
    _startP.subVectors(point, start);
    _startEnd.subVectors(end, start);

    final startEnd2 = _startEnd.dot(_startEnd);
    final startEndStartP = _startEnd.dot(_startP);

    var t = startEndStartP / startEnd2;

    if (clampToLine) {
      t = MathUtils.clamp(t, 0, 1);
    }

    return t;
  }

  Vector3 closestPointToPoint(Vector3 point, bool clampToLine, Vector3 target) {
    final t = closestPointToPointParameter(point, clampToLine);

    return delta(target).multiplyScalar(t).add(start);
  }

  Line3 applyMatrix4(Matrix4 matrix) {
    start.applyMatrix4(matrix);
    end.applyMatrix4(matrix);

    return this;
  }

  bool equals(Line3 line) {
    return line.start.equals(start) && line.end.equals(end);
  }
}
