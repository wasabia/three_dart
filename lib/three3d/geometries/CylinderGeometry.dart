part of three_geometries;

// radiusTop — 顶部圆柱体的半径。默认值为1.
// radiusBottom — 底部圆柱体的半径。默认值为1.
// height — 圆柱体的高度。默认值为1.
// radialSegments — 圆柱周围的分段面数。默认值为8
// heightSegments — 沿圆柱体高度的面的行数。默认值为1.
// openEnded — 圆柱体的两端是否显示，默认值是false，显示。
// thetaStart — 第一段的起始角度，默认值是0（Three.js的0度位置）。
// thetaLength — 圆形扇形的中心角，通常称为theta。默认值是2 * Pi，画出一个整圆

class CylinderGeometry extends BufferGeometry {
  String type = "CylinderGeometry";

  CylinderGeometry(
      [radiusTop = 1,
      radiusBottom = 1,
      height = 1,
      radialSegments = 8,
      heightSegments = 1,
      bool openEnded = false,
      thetaStart = 0,
      thetaLength = Math.PI * 2])
      : super() {
    parameters = {
      "radiusTop": radiusTop,
      "radiusBottom": radiusBottom,
      "height": height,
      "radialSegments": radialSegments,
      "heightSegments": heightSegments,
      "openEnded": openEnded,
      "thetaStart": thetaStart,
      "thetaLength": thetaLength
    };

    var scope = this;

    radialSegments = Math.floor(radialSegments);
    heightSegments = Math.floor(heightSegments);

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    // helper variables

    var index = 0;
    var indexArray = [];
    var halfHeight = height / 2;
    var groupStart = 0;

    // generate geometry

    generateTorso() {
      var normal = Vector3.init();
      var vertex = Vector3.init();

      var groupCount = 0;

      // this will be used to calculate the normal
      var slope = (radiusBottom - radiusTop) / height;

      // generate vertices, normals and uvs

      for (var y = 0; y <= heightSegments; y++) {
        var indexRow = [];

        var v = y / heightSegments;

        // calculate the radius of the current row

        var radius = v * (radiusBottom - radiusTop) + radiusTop;

        for (var x = 0; x <= radialSegments; x++) {
          var u = x / radialSegments;

          var theta = u * thetaLength + thetaStart;

          var sinTheta = Math.sin(theta);
          var cosTheta = Math.cos(theta);

          // vertex

          vertex.x = radius * sinTheta;
          vertex.y = -v * height + halfHeight;
          vertex.z = radius * cosTheta;
          vertices.addAll(
              [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

          // normal

          normal.set(sinTheta, slope, cosTheta).normalize();
          normals.addAll(
              [normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);

          // uv

          uvs.addAll([u, 1 - v]);

          // save index of vertex in respective row

          indexRow.add(index++);
        }

        // now save vertices of the row in our index array

        indexArray.add(indexRow);
      }

      // generate indices

      for (var x = 0; x < radialSegments; x++) {
        for (var y = 0; y < heightSegments; y++) {
          // we use the index array to access the correct indices

          var a = indexArray[y][x];
          var b = indexArray[y + 1][x];
          var c = indexArray[y + 1][x + 1];
          var d = indexArray[y][x + 1];

          // faces

          indices.addAll([a, b, d]);
          indices.addAll([b, c, d]);

          // update group counter

          groupCount += 6;
        }
      }

      // add a group to the geometry. this will ensure multi material support

      scope.addGroup(groupStart, groupCount, 0);

      // calculate new start value for groups

      groupStart += groupCount;
    }

    generateCap(top) {
      // save the index of the first center vertex
      var centerIndexStart = index;

      var uv = Vector2(null, null);
      var vertex = Vector3.init();

      var groupCount = 0;

      var radius = (top == true) ? radiusTop : radiusBottom;
      var sign = (top == true) ? 1 : -1;

      // first we generate the center vertex data of the cap.
      // because the geometry needs one set of uvs per face,
      // we must generate a center vertex per face/segment

      for (var x = 1; x <= radialSegments; x++) {
        // vertex

        vertices.addAll([0, halfHeight * sign, 0]);

        // normal

        normals.addAll([0, sign.toDouble(), 0]);

        // uv

        uvs.addAll([0.5, 0.5]);

        // increase index

        index++;
      }

      // save the index of the last center vertex
      var centerIndexEnd = index;

      // now we generate the surrounding vertices, normals and uvs

      for (var x = 0; x <= radialSegments; x++) {
        var u = x / radialSegments;
        var theta = u * thetaLength + thetaStart;

        var cosTheta = Math.cos(theta);
        var sinTheta = Math.sin(theta);

        // vertex

        vertex.x = radius * sinTheta;
        vertex.y = halfHeight * sign;
        vertex.z = radius * cosTheta;
        vertices.addAll(
            [vertex.x.toDouble(), vertex.y.toDouble(), vertex.z.toDouble()]);

        // normal

        normals.addAll([0, sign.toDouble(), 0]);

        // uv

        uv.x = (cosTheta * 0.5) + 0.5;
        uv.y = (sinTheta * 0.5 * sign) + 0.5;
        uvs.addAll([uv.x.toDouble(), uv.y.toDouble()]);

        // increase index

        index++;
      }

      // generate indices

      for (var x = 0; x < radialSegments; x++) {
        var c = centerIndexStart + x;
        var i = centerIndexEnd + x;

        if (top == true) {
          // face top

          indices.addAll([i, i + 1, c]);
        } else {
          // face bottom

          indices.addAll([i + 1, i, c]);
        }

        groupCount += 3;
      }

      // add a group to the geometry. this will ensure multi material support

      scope.addGroup(groupStart, groupCount,
          top == true ? 1 : 2);

      // calculate new start value for groups

      groupStart += groupCount;
    }

    generateTorso();

    if (openEnded == false) {
      if (radiusTop > 0) generateCap(true);
      if (radiusBottom > 0) generateCap(false);
    }

    // build geometry

    setIndex(indices);
    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute('normal',
        Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }

  static CylinderGeometry fromJSON(data) {
    return CylinderGeometry(
        data["radiusTop"],
        data["radiusBottom"],
        data["height"],
        data["radialSegments"],
        data["heightSegments"],
        data["openEnded"],
        data["thetaStart"],
        data["thetaLength"]);
  }
}
