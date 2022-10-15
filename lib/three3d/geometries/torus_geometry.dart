
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class TorusGeometry extends BufferGeometry {
  @override
  String type = "TorusGeometry";

  TorusGeometry(
      [radius = 1,
      tube = 0.4,
      radialSegments = 8,
      tubularSegments = 6,
      arc = Math.PI * 2])
      : super() {
    parameters = {
      "radius": radius,
      "tube": tube,
      "radialSegments": radialSegments,
      "tubularSegments": tubularSegments,
      "arc": arc
    };

    radialSegments = Math.floor(radialSegments);
    tubularSegments = Math.floor(tubularSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    var center = Vector3();
    var vertex = Vector3();
    var normal = Vector3();

    // generate vertices, normals and uvs

    for (var j = 0; j <= radialSegments; j++) {
      for (var i = 0; i <= tubularSegments; i++) {
        var u = i / tubularSegments * arc;
        var v = j / radialSegments * Math.PI * 2;

        // vertex

        vertex.x = (radius + tube * Math.cos(v)) * Math.cos(u);
        vertex.y = (radius + tube * Math.cos(v)) * Math.sin(u);
        vertex.z = tube * Math.sin(v);

        vertices.addAll(
            [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // normal

        center.x = radius * Math.cos(u);
        center.y = radius * Math.sin(u);
        normal.subVectors(vertex, center).normalize();

        normals.addAll(
            [normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);

        // uv

        uvs.add(i / tubularSegments);
        uvs.add(j / radialSegments);
      }
    }

    // generate indices

    for (var j = 1; j <= radialSegments; j++) {
      for (var i = 1; i <= tubularSegments; i++) {
        // indices

        var a = (tubularSegments + 1) * j + i - 1;
        var b = (tubularSegments + 1) * (j - 1) + i - 1;
        var c = (tubularSegments + 1) * (j - 1) + i;
        var d = (tubularSegments + 1) * j + i;

        // faces

        indices.addAll([a, b, d]);
        indices.addAll([b, c, d]);
      }
    }

    // build geometry

    setIndex(indices);
    setAttribute(
        'position', Float32BufferAttribute(Float32Array.from(vertices), 3));
    setAttribute(
        'normal', Float32BufferAttribute(Float32Array.from(normals), 3));
    setAttribute('uv', Float32BufferAttribute(Float32Array.from(uvs), 2));
  }

  static fromJSON(data) {
    return TorusGeometry(data.radius, data.tube, data.radialSegments,
        data.tubularSegments, data.arc);
  }
}
