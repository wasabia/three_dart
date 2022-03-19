// ConvexBufferGeometry
part of three_geometries;

class ConvexGeometry extends BufferGeometry {
  ConvexGeometry(points) : super() {
    List<double> vertices = [];
    List<double> normals = [];

    // buffers

    var convexHull = ConvexHull().setFromPoints(points);

    // generate vertices and normals

    var faces = convexHull.faces;

    for (var i = 0; i < faces.length; i++) {
      var face = faces[i];
      var edge = face.edge;

      // we move along a doubly-connected edge list to access all face points (see HalfEdge docs)

      do {
        var point = edge!.head().point;

        vertices.addAll(
            [point.x.toDouble(), point.y.toDouble(), point.z.toDouble()]);
        normals.addAll([
          face.normal.x.toDouble(),
          face.normal.y.toDouble(),
          face.normal.z.toDouble()
        ]);

        edge = edge.next;
      } while (edge != face.edge);
    }

    // build geometry

    setAttribute('position',
        Float32BufferAttribute(Float32List.fromList(vertices), 3, false));
    setAttribute('normal',
        Float32BufferAttribute(Float32List.fromList(normals), 3, false));
  }
}
