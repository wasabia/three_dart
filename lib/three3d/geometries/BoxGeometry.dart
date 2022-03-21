part of three_geometries;

class BoxGeometry extends BufferGeometry {
  String type = "BoxGeometry";

  late int groupStart;
  late int numberOfVertices;

  BoxGeometry(
      [width = 1,
      height = 1,
      depth = 1,
      widthSegments = 1,
      heightSegments = 1,
      depthSegments = 1])
      : super() {
    parameters = {
      "width": width,
      "height": height,
      "depth": depth,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments,
      "depthSegments": depthSegments
    };

    // segments

    int _widthSegments = Math.floor(widthSegments);
    int _heightSegments = Math.floor(heightSegments);
    int _depthSegments = Math.floor(depthSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    numberOfVertices = 0;
    groupStart = 0;

    void buildPlane(String u, String v, String w, udir, vdir, width,
        height, depth, gridX, gridY, materialIndex) {
      var segmentWidth = width / gridX;
      var segmentHeight = height / gridY;

      var widthHalf = width / 2;
      var heightHalf = height / 2;
      var depthHalf = depth / 2;

      var gridX1 = gridX + 1;
      var gridY1 = gridY + 1;

      var vertexCounter = 0;
      var groupCount = 0;

      var vector = Vector3.init();

      // generate vertices, normals and uvs

      // print("buildPlane: u: ${u} v: ${v} w: ${w} udir: ${udir} vdir: ${vdir} width: ${width} height: ${height} depth: ${depth} gridX: ${gridX} gridY: ${gridY} materialIndex: ${materialIndex} ");

      for (var iy = 0; iy < gridY1; iy++) {
        var y = iy * segmentHeight - heightHalf;

        for (var ix = 0; ix < gridX1; ix++) {
          var x = ix * segmentWidth - widthHalf;

          // print("iy: ${iy} ix: ${ix} y: ${y} x: ${x} depthHalf: ${depthHalf} ");

          // set values to correct vector component

          // vector[ u ] = x * udir;
          // vector[ v ] = y * vdir;
          // vector[ w ] = depthHalf;

          vector.setP(u, x * udir);
          vector.setP(v, y * vdir);
          vector.setP(w, depthHalf);

          // now apply vector to vertex buffer

          vertices.addAll(
              [vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble()]);

          // set values to correct vector component

          // vector[ u ] = 0;
          // vector[ v ] = 0;
          // vector[ w ] = depth > 0 ? 1 : - 1;

          vector.setP(u, 0);
          vector.setP(v, 0);
          vector.setP(w, depth > 0 ? 1 : -1);

          // now apply vector to normal buffer

          normals.addAll(
              [vector.x.toDouble(), vector.y.toDouble(), vector.z.toDouble()]);

          // uvs

          uvs.add(ix / gridX);
          uvs.add(1 - (iy / gridY));

          // counters

          vertexCounter += 1;
        }
      }

      // indices

      // 1. you need three indices to draw a single face
      // 2. a single segment consists of two faces
      // 3. so we need to generate six (2*3) indices per segment

      for (var iy = 0; iy < gridY; iy++) {
        for (var ix = 0; ix < gridX; ix++) {
          var a = numberOfVertices + ix + gridX1 * iy;
          var b = numberOfVertices + ix + gridX1 * (iy + 1);
          var c = numberOfVertices + (ix + 1) + gridX1 * (iy + 1);
          var d = numberOfVertices + (ix + 1) + gridX1 * iy;

          // faces

          indices.addAll([a, b, d]);
          indices.addAll([b, c, d]);

          // increase counter

          groupCount += 6;
        }
      }

      // add a group to the geometry. this will ensure multi material support

      addGroup(groupStart, groupCount, materialIndex);

      // calculate new start value for groups

      groupStart += groupCount;

      // update total number of vertices

      numberOfVertices += vertexCounter;
    };

    // build each side of the box geometry

    buildPlane('z', 'y', 'x', -1, -1, depth, height, width, _depthSegments,
        _heightSegments, 0); // px
    buildPlane('z', 'y', 'x', 1, -1, depth, height, -width, _depthSegments,
        _heightSegments, 1); // nx
    buildPlane('x', 'z', 'y', 1, 1, width, depth, height, _widthSegments,
        _depthSegments, 2); // py
    buildPlane('x', 'z', 'y', 1, -1, width, depth, -height, _widthSegments,
        _depthSegments, 3); // ny
    buildPlane('x', 'y', 'z', 1, -1, width, height, depth, _widthSegments,
        _heightSegments, 4); // pz
    buildPlane('x', 'y', 'z', -1, -1, width, height, -depth, _widthSegments,
        _heightSegments, 5); // nz

    // build geometry

    setIndex(indices);
    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute('normal',
        Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }

  static fromJSON(data) {
    return BoxGeometry(data["width"], data["height"], data["depth"],
        data["widthSegments"], data["heightSegments"], data["depthSegments"]);
  }
}
