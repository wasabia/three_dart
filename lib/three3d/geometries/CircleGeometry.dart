part of three_geometries;

class CircleGeometry extends BufferGeometry {
  CircleGeometry(
      {radius = 1, segments = 8, thetaStart = 0, thetaLength = Math.PI * 2})
      : super() {
    this.type = 'CircleGeometry';

    this.parameters = {
      "radius": radius,
      "segments": segments,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };

    segments = Math.max(3, segments);

    // buffers

    List<int> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    var vertex = new Vector3.init();
    var uv = new Vector2(null, null);

    // center point

    vertices.addAll([0, 0, 0]);
    normals.addAll([0, 0, 1]);
    uvs.addAll([0.5, 0.5]);

    for (var s = 0, i = 3; s <= segments; s++, i += 3) {
      var segment = thetaStart + s / segments * thetaLength;

      // vertex

      vertex.x = radius * Math.cos(segment);
      vertex.y = radius * Math.sin(segment);

      vertices.addAll(
          [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

      // normal

      normals.addAll([0.0, 0.0, 1.0]);

      // uvs

      uv.x = (vertices[i] / radius + 1) / 2;
      uv.y = (vertices[i + 1] / radius + 1) / 2;

      uvs.addAll([uv.x.toDouble(), uv.y.toDouble()]);
    }

    // indices

    for (var i = 1; i <= segments; i++) {
      indices.addAll([i, i + 1, 0]);
    }

    // build geometry

    this.setIndex(indices);
    this.setAttribute('position',
        new Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    this.setAttribute('normal',
        new Float32BufferAttribute(Float32Array.from(normals), 3, false));
    this.setAttribute(
        'uv', new Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }
}
