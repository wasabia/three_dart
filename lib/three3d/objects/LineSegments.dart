part of three_objects;

var _lsstart = Vector3.init();
var _lsend = Vector3.init();

class LineSegments extends Line {
  LineSegments(BufferGeometry? geometry, Material? material)
      : super(geometry, material) {
    type = 'LineSegments';
    isLineSegments = true;
  }

  @override
  LineSegments computeLineDistances() {
    var geometry = this.geometry!;

    if (geometry.isBufferGeometry) {
      // we assume non-indexed geometry

      if (geometry.index == null) {
        var positionAttribute = geometry.attributes["position"];
        var lineDistances = Float32List(positionAttribute.count);

        for (var i = 0, l = positionAttribute.count; i < l; i += 2) {
          _lsstart.fromBufferAttribute(positionAttribute, i);
          _lsend.fromBufferAttribute(positionAttribute, i + 1);

          lineDistances[i] = (i == 0) ? 0 : lineDistances[i - 1];
          lineDistances[i + 1] = lineDistances[i] + _lsstart.distanceTo(_lsend);
        }

        geometry.setAttribute('lineDistance',
            Float32BufferAttribute(lineDistances, 1, false));
      } else {
        print(
            'THREE.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.');
      }
    } else if (geometry.isGeometry) {
      throw ('THREE.LineSegments.computeLineDistances() no longer supports THREE.Geometry. Use THREE.BufferGeometry instead.');
    }

    return this;
  }
}
