// ConvexBufferGeometry
part of three_geometries;

class ConvexGeometry extends BufferGeometry {
  ConvexGeometry(points) : super() {
    var vertices = [];
    var normals = [];

    // buffers

    var convexHull = new ConvexHull().setFromPoints(points);

    // generate vertices and normals

    var faces = convexHull.faces;

    for (var i = 0; i < faces.length; i++) {
      var face = faces[i];
      var edge = face.edge;

      // we move along a doubly-connected edge list to access all face points (see HalfEdge docs)

      do {
        var point = edge.head().point;

        vertices.addAll([point.x, point.y, point.z]);
        normals.addAll([face.normal.x, face.normal.y, face.normal.z]);

        edge = edge.next;
      } while (edge != face.edge);
    }

    // build geometry

    this.setAttribute(
        'position', new Float32BufferAttribute(vertices, 3, false));
    this.setAttribute('normal', new Float32BufferAttribute(normals, 3, false));
  }
}
