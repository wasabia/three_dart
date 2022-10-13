part of three_geometries;

class PlaneGeometry extends BufferGeometry {
  PlaneGeometry(
      [num width = 1,
      num height = 1,
      num widthSegments = 1,
      num heightSegments = 1])
      : super() {
    type = 'PlaneGeometry';

    parameters = {
      "width": width,
      "height": height,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments
    };

    num widthHalf = width / 2.0;
    num heightHalf = height / 2.0;

    num gridX = Math.floor(widthSegments);
    num gridY = Math.floor(heightSegments);

    num gridX1 = gridX + 1;
    num gridY1 = gridY + 1;

    num segmentWidth = width / gridX;
    num segmentHeight = height / gridY;

    //

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    for (var iy = 0; iy < gridY1; iy++) {
      var y = iy * segmentHeight - heightHalf;

      for (var ix = 0; ix < gridX1; ix++) {
        var x = ix * segmentWidth - widthHalf;

        vertices.addAll([x.toDouble(), -y.toDouble(), 0.0]);

        normals.addAll([0.0, 0.0, 1.0]);

        uvs.add(ix / gridX);
        uvs.add(1 - (iy / gridY));
      }
    }

    for (var iy = 0; iy < gridY; iy++) {
      for (var ix = 0; ix < gridX; ix++) {
        var a = ix + gridX1 * iy;
        var b = ix + gridX1 * (iy + 1);
        var c = (ix + 1) + gridX1 * (iy + 1);
        var d = (ix + 1) + gridX1 * iy;

        indices.addAll([a, b, d]);
        indices.addAll([b, c, d]);
      }
    }

    setIndex(indices);
    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    setAttribute('normal',
        Float32BufferAttribute(Float32Array.from(normals), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));
  }

  static fromJSON(data) {
    return PlaneGeometry(data["width"], data["height"],
        data["widthSegments"], data["heightSegments"]);
  }
}
