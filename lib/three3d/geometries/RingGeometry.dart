part of three_geometries;

class RingGeometry extends BufferGeometry {
  String type = 'RingGeometry';

  RingGeometry(
      [innerRadius = 0.5,
      outerRadius = 1,
      thetaSegments = 8,
      phiSegments = 1,
      thetaStart = 0,
      thetaLength = Math.PI * 2])
      : super() {
    parameters = {
      "innerRadius": innerRadius,
      "outerRadius": outerRadius,
      "thetaSegments": thetaSegments,
      "phiSegments": phiSegments,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };

    thetaSegments = Math.max(3, thetaSegments);
    phiSegments = Math.max(1, phiSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // some helper variables

    var radius = innerRadius;
    var radiusStep = ((outerRadius - innerRadius) / phiSegments);
    var vertex = Vector3();
    var uv = Vector2();

    // generate vertices, normals and uvs

    for (var j = 0; j <= phiSegments; j++) {
      for (var i = 0; i <= thetaSegments; i++) {
        // values are generate from the inside of the ring to the outside

        var segment = thetaStart + i / thetaSegments * thetaLength;

        // vertex

        vertex.x = radius * Math.cos(segment);
        vertex.y = radius * Math.sin(segment);

        vertices.addAll(
            [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // normal

        normals.addAll([0, 0, 1]);

        // uv

        uv.x = (vertex.x / outerRadius + 1) / 2;
        uv.y = (vertex.y / outerRadius + 1) / 2;

        uvs.addAll([uv.x.toDouble(), uv.y.toDouble()]);
      }

      // increase the radius for next row of vertices

      radius += radiusStep;
    }

    // indices

    for (var j = 0; j < phiSegments; j++) {
      var thetaSegmentLevel = j * (thetaSegments + 1);

      for (var i = 0; i < thetaSegments; i++) {
        var segment = i + thetaSegmentLevel;

        var a = segment;
        var b = segment + thetaSegments + 1;
        var c = segment + thetaSegments + 2;
        var d = segment + 1;

        // faces

        indices.addAll([a, b, d]);
        indices.addAll([b, c, d]);
      }
    }

    // build geometry

    setIndex(indices);
    setAttribute(
        'position', Float32BufferAttribute(Float32List.fromList(vertices), 3));
    setAttribute(
        'normal', Float32BufferAttribute(Float32List.fromList(normals), 3));
    setAttribute('uv', Float32BufferAttribute(Float32List.fromList(uvs), 2));
  }

  static fromJSON(data) {
    return RingGeometry(
        data.innerRadius,
        data.outerRadius,
        data.thetaSegments,
        data.phiSegments,
        data.thetaStart,
        data.thetaLength);
  }
}
