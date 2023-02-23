import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/extras/curves/quadratic_bezier_curve.dart';
import 'package:three_dart/three3d/math/index.dart';

class TubeGeometry extends BufferGeometry {
  NativeArray? verticesArray;
  NativeArray? normalsArray;
  NativeArray? uvsArray;

  TubeGeometry([
    curve,
    tubularSegments = 64,
    radius = 1,
    radialSegments = 8,
    closed = false,
  ]) : super() {
    type = "TubeGeometry";
    var path = curve ?? QuadraticBezierCurve(Vector2(), Vector2(), Vector2());
    parameters = {
      "path": path,
      "radius": radius,
      "tubularSegments": tubularSegments,
      "radialSegments": radialSegments,
      "closed": closed,
    };

    final frames = path.computeFrenetFrames(tubularSegments, closed);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    var vertex = Vector3.init();
    var normal = Vector3.init();
    var uv = Vector2();
    var P = Vector3();

    generateSegment(i) {
      // we use getPointAt to sample evenly distributed points from the given path
      P = path.getPointAt(i / tubularSegments, P);
      // // retrieve corresponding normal and binormal
      final N = frames["normals"][i];
      final B = frames["binormals"][i];
      // generate normals and vertices for the current segment
      for (var j = 0; j <= radialSegments; j++) {
        var v = j / radialSegments * Math.pi * 2;
        var sin = Math.sin(v);
        var cos = -Math.cos(v);
        // normal
        normal.x = (cos * N.x + sin * B.x);
        normal.y = (cos * N.y + sin * B.y);
        normal.z = (cos * N.z + sin * B.z);
        normal.normalize();
        normals.addAll([normal.x, normal.y, normal.z]);
        // vertex
        vertex.x = P.x + radius * normal.x;
        vertex.y = P.y + radius * normal.y;
        vertex.z = P.z + radius * normal.z;
        vertices.addAll([vertex.x, vertex.y, vertex.z]);
      }
    }

    generateIndices() {
      for (var j = 1; j <= tubularSegments; j++) {
        for (var i = 1; i <= radialSegments; i++) {
          final a = (radialSegments + 1) * (j - 1) + (i - 1);
          final b = (radialSegments + 1) * j + (i - 1);
          final c = (radialSegments + 1) * j + i;
          final d = (radialSegments + 1) * (j - 1) + i;

          // faces

          indices.addAll([a, b, d]);
          indices.addAll([b, c, d]);
        }
      }
    }

    generateUVs() {
      for (var i = 0; i <= tubularSegments; i++) {
        for (var j = 0; j <= radialSegments; j++) {
          uv.x = i / tubularSegments;
          uv.y = j / radialSegments;

          uvs.addAll([uv.x, uv.y]);
        }
      }
    }

    generateBufferData() {
      for (var i = 0; i < tubularSegments; i++) {
        generateSegment(i);
      }

      // if the geometry is not closed, generate the last row of vertices and normals
      // at the regular position on the given path
      //
      // if the geometry is closed, duplicate the first row of vertices and normals (uvs will differ)

      generateSegment((closed == false) ? tubularSegments : 0);

      // uvs are generated in a separate function.
      // this makes it easy compute correct values for closed geometries

      generateUVs();

      // finally create faces

      generateIndices();
    }

    // build geometry

    generateBufferData();

    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(verticesArray = Float32Array.from(vertices), 3, false));
    setAttribute('normal', Float32BufferAttribute(normalsArray = Float32Array.from(normals), 3, false));
    setAttribute('uv', Float32BufferAttribute(uvsArray = Float32Array.from(uvs), 2, false));
  }

  @override
  void dispose() {
    verticesArray?.dispose();
    normalsArray?.dispose();
    uvsArray?.dispose();
    super.dispose();
  }
}
