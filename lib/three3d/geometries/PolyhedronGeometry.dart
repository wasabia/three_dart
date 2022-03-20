part of three_geometries;

class PolyhedronGeometry extends BufferGeometry {
  String type = "PolyhedronGeometry";

  PolyhedronGeometry(vertices, indices, [radius = 1, detail = 0]) : super() {
    // default buffer data
    List<num> vertexBuffer = [];
    List<num> uvBuffer = [];

    // helper functions ----------------- start
    Function pushVertex = (vertex) {
      vertexBuffer.addAll([vertex.x, vertex.y, vertex.z]);
    };

    Function subdivideFace = (Vector3 a, Vector3 b, Vector3 c, detail) {
      var cols = detail + 1;

      // we use this multidimensional array as a data structure for creating the subdivision

      List<List<Vector3>> v = List<List<Vector3>>.filled(cols + 1, []);

      // construct all of the vertices for this subdivision

      for (var i = 0; i <= cols; i++) {
        var aj = a.clone().lerp(c, i / cols);
        var bj = b.clone().lerp(c, i / cols);

        var rows = cols - i;

        v[i] = List<Vector3>.filled(rows + 1, Vector3.init());

        for (var j = 0; j <= rows; j++) {
          if (j == 0 && i == cols) {
            v[i][j] = aj;
          } else {
            v[i][j] = aj.clone().lerp(bj, j / rows);
          }
        }
      }

      // construct all of the faces

      for (var i = 0; i < cols; i++) {
        for (var j = 0; j < 2 * (cols - i) - 1; j++) {
          int k = Math.floor(j / 2).toInt();

          if (j % 2 == 0) {
            pushVertex(v[i][k + 1]);
            pushVertex(v[i + 1][k]);
            pushVertex(v[i][k]);
          } else {
            pushVertex(v[i][k + 1]);
            pushVertex(v[i + 1][k + 1]);
            pushVertex(v[i + 1][k]);
          }
        }
      }
    };

    Function getVertexByIndex = (index, vertex) {
      var stride = index * 3;

      vertex.x = vertices[stride + 0];
      vertex.y = vertices[stride + 1];
      vertex.z = vertices[stride + 2];
    };

    Function subdivide = (detail) {
      var a = new Vector3.init();
      var b = new Vector3.init();
      var c = new Vector3.init();

      // iterate over all faces and apply a subdivison with the given detail value

      for (var i = 0; i < indices.length; i += 3) {
        // get the vertices of the face

        getVertexByIndex(indices[i + 0], a);
        getVertexByIndex(indices[i + 1], b);
        getVertexByIndex(indices[i + 2], c);

        // perform subdivision

        subdivideFace(a, b, c, detail);
      }
    };

    Function applyRadius = (radius) {
      var vertex = new Vector3.init();

      // iterate over the entire buffer and apply the radius to each vertex

      for (var i = 0; i < vertexBuffer.length; i += 3) {
        vertex.x = vertexBuffer[i + 0];
        vertex.y = vertexBuffer[i + 1];
        vertex.z = vertexBuffer[i + 2];

        vertex.normalize().multiplyScalar(radius);

        vertexBuffer[i + 0] = vertex.x;
        vertexBuffer[i + 1] = vertex.y;
        vertexBuffer[i + 2] = vertex.z;
      }
    };

    Function correctUV = (uv, stride, vector, azimuth) {
      if ((azimuth < 0) && (uv.x == 1)) {
        uvBuffer[stride] = uv.x - 1;
      }

      if ((vector.x == 0) && (vector.z == 0)) {
        uvBuffer[stride] = azimuth / 2 / Math.PI + 0.5;
      }
    };

    // Angle around the Y axis, counter-clockwise when looking from above.

    Function azimuth = (vector) {
      return Math.atan2(vector.z, -vector.x);
    };

    // Angle above the XZ plane.

    Function inclination = (vector) {
      return Math.atan2(
          -vector.y, Math.sqrt((vector.x * vector.x) + (vector.z * vector.z)));
    };

    Function correctUVs = () {
      var a = Vector3.init();
      var b = new Vector3.init();
      var c = new Vector3.init();

      var centroid = new Vector3.init();

      var uvA = new Vector2(null, null);
      var uvB = new Vector2(null, null);
      var uvC = new Vector2(null, null);

      for (var i = 0, j = 0; i < vertexBuffer.length; i += 9, j += 6) {
        a.set(vertexBuffer[i + 0], vertexBuffer[i + 1], vertexBuffer[i + 2]);
        b.set(vertexBuffer[i + 3], vertexBuffer[i + 4], vertexBuffer[i + 5]);
        c.set(vertexBuffer[i + 6], vertexBuffer[i + 7], vertexBuffer[i + 8]);

        uvA.set(uvBuffer[j + 0], uvBuffer[j + 1]);
        uvB.set(uvBuffer[j + 2], uvBuffer[j + 3]);
        uvC.set(uvBuffer[j + 4], uvBuffer[j + 5]);

        centroid.copy(a).add(b).add(c).divideScalar(3);

        var azi = azimuth(centroid);

        correctUV(uvA, j + 0, a, azi);
        correctUV(uvB, j + 2, b, azi);
        correctUV(uvC, j + 4, c, azi);
      }
    };

    Function correctSeam = () {
      // handle case when face straddles the seam, see #3269

      for (var i = 0; i < uvBuffer.length; i += 6) {
        // uv data of a single face

        var x0 = uvBuffer[i + 0];
        var x1 = uvBuffer[i + 2];
        var x2 = uvBuffer[i + 4];

        var max = Math.max3(x0, x1, x2);
        var min = Math.min3(x0, x1, x2);

        // 0.9 is somewhat arbitrary

        if (max > 0.9 && min < 0.1) {
          if (x0 < 0.2) uvBuffer[i + 0] += 1;
          if (x1 < 0.2) uvBuffer[i + 2] += 1;
          if (x2 < 0.2) uvBuffer[i + 4] += 1;
        }
      }
    };

    Function generateUVs = () {
      var vertex = new Vector3.init();

      for (var i = 0; i < vertexBuffer.length; i += 3) {
        vertex.x = vertexBuffer[i + 0];
        vertex.y = vertexBuffer[i + 1];
        vertex.z = vertexBuffer[i + 2];

        var u = azimuth(vertex) / 2 / Math.PI + 0.5;
        double v = inclination(vertex) / Math.PI + 0.5;
        uvBuffer.addAll([u, 1 - v]);
      }

      correctUVs();

      correctSeam();
    };

    // helper functions ----------------- end

    this.parameters = {
      "vertices": vertices,
      "indices": indices,
      "radius": radius,
      "detail": detail
    };

    // the subdivision creates the vertex buffer data

    subdivide(detail);

    // all vertices should lie on a conceptual sphere with a given radius

    applyRadius(radius);

    // finally, create the uv data

    generateUVs();

    // build non-indexed geometry

    this.setAttribute(
        'position', new Float32BufferAttribute(vertexBuffer, 3, false));
    this.setAttribute(
        'normal', new Float32BufferAttribute(slice(vertexBuffer, 0), 3, false));
    this.setAttribute('uv', new Float32BufferAttribute(uvBuffer, 2, false));

    if (detail == 0) {
      this.computeVertexNormals(); // flat normals

    } else {
      this.normalizeNormals(); // smooth normals

    }
  }
}
