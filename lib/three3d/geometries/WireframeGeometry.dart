part of three_geometries;

class WireframeGeometry extends BufferGeometry {
  @override
  String type = "WireframeGeometry";

  WireframeGeometry(BufferGeometry geometry) : super() {
    // buffer

    List<double> vertices = [];
    var edges = <dynamic>{};

    // helper variables

    var start = Vector3.init();
    var end = Vector3.init();

    if (geometry.index != null) {
      // indexed BufferGeometry

      var position = geometry.attributes["position"];
      var indices = geometry.index;
      var groups = geometry.groups;

      if (groups.isEmpty) {
        groups = [
          {"start": 0, "count": indices!.count, "materialIndex": 0}
        ];
      }

      // create a data structure that contains all eges without duplicates

      for (var o = 0, ol = groups.length; o < ol; ++o) {
        var group = groups[o];

        var groupStart = group["start"];
        var groupCount = group["count"];

        for (var i = groupStart, l = (groupStart + groupCount); i < l; i += 3) {
          for (var j = 0; j < 3; j++) {
            int index1 = indices!.getX(i + j)!.toInt();
            int index2 = indices.getX(i + (j + 1) % 3)!.toInt();

            start.fromBufferAttribute(position, index1);
            end.fromBufferAttribute(position, index2);

            if (isUniqueEdge(start, end, edges) == true) {
              vertices.addAll(
                  [start.x.toDouble(), start.y.toDouble(), start.z.toDouble()]);
              vertices.addAll(
                  [end.x.toDouble(), end.y.toDouble(), end.z.toDouble()]);
            }
          }
        }
      }
    } else {
      // non-indexed BufferGeometry

      var position = geometry.attributes["position"];

      for (var i = 0, l = (position.count / 3); i < l; i++) {
        for (var j = 0; j < 3; j++) {
          // three edges per triangle, an edge is represented as (index1, index2)
          // e.g. the first triangle has the following edges: (0,1),(1,2),(2,0)

          var index1 = 3 * i + j;
          var index2 = 3 * i + ((j + 1) % 3);

          start.fromBufferAttribute(position, index1);
          end.fromBufferAttribute(position, index2);

          if (isUniqueEdge(start, end, edges) == true) {
            vertices.addAll(
                [start.x.toDouble(), start.y.toDouble(), start.z.toDouble()]);
            vertices
                .addAll([end.x.toDouble(), end.y.toDouble(), end.z.toDouble()]);
          }
        }
      }
    }

    // build geometry

    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(vertices), 3, false));
  }
}

isUniqueEdge(start, end, edges) {
  var hash1 = "${start.x},${start.y},${start.z}-${end.x},${end.y},${end.z}";
  var hash2 =
      "${end.x},${end.y},${end.z}-${start.x},${start.y},${start.z}"; // coincident edge

  if (edges.contains(hash1) == true || edges.contains(hash2) == true) {
    return false;
  } else {
    edges.addAll([hash1, hash2]);
    return true;
  }
}
