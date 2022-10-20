import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class EdgesGeometry extends BufferGeometry {
  final _v0 = Vector3.init();
  final _v1 = Vector3.init();
  final _normal = Vector3.init();
  final _triangle = Triangle.init();

  EdgesGeometry(BufferGeometry geometry, thresholdAngle) : super() {
    type = "EdgesGeometry";
    parameters = {"thresholdAngle": thresholdAngle};

    thresholdAngle = (thresholdAngle != null) ? thresholdAngle : 1;

    var thresholdDot = Math.cos(MathUtils.deg2rad * thresholdAngle);

    var indexAttr = geometry.getIndex();
    var positionAttr = geometry.getAttribute('position');
    var indexCount = indexAttr != null ? indexAttr.count : positionAttr.count;

    var indexArr = [0, 0, 0];
    var vertKeys = ['a', 'b', 'c'];
    Map hashes = {};

    var edgeData = {};
    List<double> vertices = [];
    for (var i = 0; i < indexCount; i += 3) {
      if (indexAttr != null) {
        indexArr[0] = indexAttr.getX(i)!.toInt();
        indexArr[1] = indexAttr.getX(i + 1)!.toInt();
        indexArr[2] = indexAttr.getX(i + 2)!.toInt();
      } else {
        indexArr[0] = i;
        indexArr[1] = i + 1;
        indexArr[2] = i + 2;
      }

      var a = _triangle.a;
      var b = _triangle.b;
      var c = _triangle.c;

      a.fromBufferAttribute(positionAttr, indexArr[0]);
      b.fromBufferAttribute(positionAttr, indexArr[1]);
      c.fromBufferAttribute(positionAttr, indexArr[2]);
      _triangle.getNormal(_normal);

      // create hashes for the edge from the vertices
      hashes[0] = "${a.x},${a.y},${a.z}";
      hashes[1] = "${b.x},${b.y},${b.z}";
      hashes[2] = "${c.x},${c.y},${c.z}";

      // skip degenerate triangles
      if (hashes[0] == hashes[1] || hashes[1] == hashes[2] || hashes[2] == hashes[0]) {
        continue;
      }

      // iterate over every edge
      for (var j = 0; j < 3; j++) {
        // get the first and next vertex making up the edge
        var jNext = (j + 1) % 3;
        var vecHash0 = hashes[j];
        var vecHash1 = hashes[jNext];
        var v0 = _triangle[vertKeys[j]];
        var v1 = _triangle[vertKeys[jNext]];

        var hash = "${vecHash0}_$vecHash1";
        var reverseHash = "${vecHash1}_$vecHash0";

        if (edgeData.containsKey(reverseHash) && edgeData[reverseHash] != null) {
          // if we found a sibling edge add it into the vertex array if
          // it meets the angle threshold and delete the edge from the map.
          if (_normal.dot(edgeData[reverseHash]["normal"]) <= thresholdDot) {
            vertices.addAll([v0.x.toDouble(), v0.y.toDouble(), v0.z.toDouble()]);
            vertices.addAll([v1.x.toDouble(), v1.y.toDouble(), v1.z.toDouble()]);
          }

          edgeData[reverseHash] = null;
        } else if (!(edgeData.containsKey(hash))) {
          // if we've already got an edge here then skip adding a new one
          edgeData[hash] = {
            "index0": indexArr[j],
            "index1": indexArr[jNext],
            "normal": _normal.clone(),
          };
        }
      }
    }

    // iterate over all remaining, unmatched edges and add them to the vertex array
    for (var key in edgeData.keys) {
      if (edgeData[key] != null) {
        var ed = edgeData[key];
        var index0 = ed["index0"];
        var index1 = ed["index1"];
        _v0.fromBufferAttribute(positionAttr, index0);
        _v1.fromBufferAttribute(positionAttr, index1);

        vertices.addAll([_v0.x.toDouble(), _v0.y.toDouble(), _v0.z.toDouble()]);
        vertices.addAll([_v1.x.toDouble(), _v1.y.toDouble(), _v1.z.toDouble()]);
      }
    }

    setAttribute('position', Float32BufferAttribute(Float32Array.from(vertices), 3, false));
  }
}
