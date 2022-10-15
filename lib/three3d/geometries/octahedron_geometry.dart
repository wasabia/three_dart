
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/geometries/polyhedron_geometry.dart';
import 'package:three_dart/three3d/math/index.dart';

class OctahedronGeometry extends PolyhedronGeometry {
  OctahedronGeometry.create(vertices, indices, radius, detail)
      : super(vertices, indices, radius, detail);

  factory OctahedronGeometry([radius = 1, detail = 0]) {
    var vertices = [1, 0, 0, -1, 0, 0, 0, 1, 0, 0, -1, 0, 0, 0, 1, 0, 0, -1];

    var indices = [
      0,
      2,
      4,
      0,
      4,
      3,
      0,
      3,
      5,
      0,
      5,
      2,
      1,
      2,
      5,
      1,
      5,
      3,
      1,
      3,
      4,
      1,
      4,
      2
    ];

    var _octahedronGeometry =
        OctahedronGeometry.create(vertices, indices, radius, detail);

    _octahedronGeometry.type = 'OctahedronGeometry';

    _octahedronGeometry.parameters = {"radius": radius, "detail": detail};

    return _octahedronGeometry;
  }

  static fromJSON(data) {
    return OctahedronGeometry(data.radius, data.detail);
  }
}
