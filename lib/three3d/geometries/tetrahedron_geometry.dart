import 'package:three_dart/three3d/geometries/polyhedron_geometry.dart';

class TetrahedronGeometry extends PolyhedronGeometry {
  TetrahedronGeometry.create(
    vertices,
    indices,
    radius,
    detail,
  ) : super(
          vertices,
          indices,
          radius,
          detail,
        );

  factory TetrahedronGeometry([radius = 1, detail = 0]) {
    var vertices = [1, 1, 1, -1, -1, 1, -1, 1, -1, 1, -1, -1];

    var indices = [2, 1, 0, 0, 3, 2, 1, 3, 0, 2, 3, 1];

    var tetrahedronGeometry = TetrahedronGeometry.create(vertices, indices, radius, detail);

    tetrahedronGeometry.type = 'TetrahedronGeometry';

    tetrahedronGeometry.parameters = {"radius": radius, "detail": detail};

    return tetrahedronGeometry;
  }

  static fromJSON(data) {
    return TetrahedronGeometry(data.radius, data.detail);
  }
}
