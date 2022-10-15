
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/line.dart';

var _lsstart = Vector3.init();
var _lsend = Vector3.init();

class LineSegments extends Line {
  LineSegments(BufferGeometry? geometry, material) : super(geometry, material) {
    type = 'LineSegments';
  }

  @override
  LineSegments computeLineDistances() {
    var geometry = this.geometry;

    if (geometry is BufferGeometry) {
      // we assume non-indexed geometry

      if (geometry.index == null) {
        var positionAttribute = geometry.attributes["position"];
        var lineDistances = Float32Array(positionAttribute.count);

        for (var i = 0, l = positionAttribute.count; i < l; i += 2) {
          _lsstart.fromBufferAttribute(positionAttribute, i);
          _lsend.fromBufferAttribute(positionAttribute, i + 1);

          lineDistances[i] = (i == 0) ? 0 : lineDistances[i - 1];
          lineDistances[i + 1] = lineDistances[i] + _lsstart.distanceTo(_lsend);
        }

        geometry.setAttribute('lineDistance', Float32BufferAttribute(lineDistances, 1, false));
      } else {
        print('three.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.');
      }
    }
    // else if (geometry.isGeometry) {
    //   throw ('three.LineSegments.computeLineDistances() no longer supports three.Geometry. Use three.BufferGeometry instead.');
    // }

    return this;
  }
}
