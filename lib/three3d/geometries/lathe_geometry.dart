import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class LatheGeometry extends BufferGeometry {
  LatheGeometry(
    points, {
    segments = 12,
    phiStart = 0,
    double phiLength = Math.pi * 2,
  }) : super() {
    type = 'LatheGeometry';
    parameters = {
      "points": points,
      "segments": segments,
      "phiStart": phiStart,
      "phiLength": phiLength,
    };

    segments = Math.floor(segments);

    // clamp phiLength so it's in range of [ 0, 2PI ]

    phiLength = MathUtils.clamp(phiLength, 0, Math.pi * 2);

    // buffers

    var indices = [];
    List<double> vertices = [];
    List<double> uvs = [];
    var initNormals = [];
    List<double> normals = [];

    // helper variables

    var inverseSegments = 1.0 / segments;
    var vertex = Vector3.init();
    var uv = Vector2(null, null);
    var normal = Vector3();
    var curNormal = Vector3();
    var prevNormal = Vector3();
    double dx = 0;
    double dy = 0;

    // pre-compute normals for initial "meridian"

    for (var j = 0; j <= (points.length - 1); j++) {
      // special handling for 1st vertex on path
      if (j == 0) {
        dx = points[j + 1].x - points[j].x;
        dy = points[j + 1].y - points[j].y;

        normal.x = dy * 1.0;
        normal.y = -dx;
        normal.z = dy * 0.0;

        prevNormal.copy(normal);

        normal.normalize();

        initNormals.addAll([normal.x, normal.y, normal.z]);
      } else if (j == points.length - 1) {
        // special handling for last Vertex on path
        initNormals.addAll([prevNormal.x, prevNormal.y, prevNormal.z]);
      } else {
        // default handling for all vertices in between
        dx = points[j + 1].x - points[j].x;
        dy = points[j + 1].y - points[j].y;

        normal.x = dy * 1.0;
        normal.y = -dx;
        normal.z = dy * 0.0;

        curNormal.copy(normal);

        normal.x += prevNormal.x;
        normal.y += prevNormal.y;
        normal.z += prevNormal.z;

        normal.normalize();

        initNormals.addAll([normal.x, normal.y, normal.z]);

        prevNormal.copy(curNormal);
      }
    }

    // generate vertices, uvs and normals

    // generate vertices and uvs

    for (var i = 0; i <= segments; i++) {
      var phi = phiStart + i * inverseSegments * phiLength;

      var sin = Math.sin(phi);
      var cos = Math.cos(phi);

      for (var j = 0; j <= (points.length - 1); j++) {
        // vertex

        vertex.x = points[j].x * sin;
        vertex.y = points[j].y;
        vertex.z = points[j].x * cos;

        vertices.addAll([vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // uv

        uv.x = i / segments;
        uv.y = j / (points.length - 1);

        uvs.addAll([uv.x.toDouble(), uv.y.toDouble()]);

        // normal

        var x = initNormals[3 * j + 0] * sin;
        var y = initNormals[3 * j + 1];
        var z = initNormals[3 * j + 0] * cos;

        normals.addAll([x, y, z]);
      }
    }

    // indices

    for (var i = 0; i < segments; i++) {
      for (var j = 0; j < (points.length - 1); j++) {
        var base = j + i * points.length;

        var a = base;
        var b = base + points.length;
        var c = base + points.length + 1;
        var d = base + 1;

        // faces

        indices.addAll([a, b, d]);
        indices.addAll([c, d, b]);
      }
    }

    // build geometry

    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute('uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));
    setAttribute('normal', Float32BufferAttribute(Float32Array.from(normals), 3, false));
  }
}
