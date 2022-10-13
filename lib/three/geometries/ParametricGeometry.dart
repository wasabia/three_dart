part of three_geometries;

/// Parametric Surfaces Geometry
/// based on the brilliant article by @prideout https://prideout.net/blog/old/blog/index.html@p=44.html

class ParametricGeometry extends BufferGeometry {
  @override
  String type = "ParametricGeometry";

  ParametricGeometry(func, slices, stacks) : super() {
    parameters = {"func": func, "slices": slices, "stacks": stacks};

    // buffers

    List<num> indices = [];
    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    var EPS = 0.00001;

    var normal = Vector3();

    var p0 = Vector3(), p1 = Vector3();
    var pu = Vector3(), pv = Vector3();

    // if ( func.length < 3 ) {

    // 	print( 'THREE.ParametricGeometry: Function must now modify a Vector3 as third parameter.' );

    // }

    // generate vertices, normals and uvs

    var sliceCount = slices + 1;

    for (var i = 0; i <= stacks; i++) {
      var v = i / stacks;

      for (var j = 0; j <= slices; j++) {
        var u = j / slices;

        // vertex

        func(u, v, p0);
        vertices.addAll([p0.x.toDouble(), p0.y.toDouble(), p0.z.toDouble()]);

        // normal

        // approximate tangent vectors via finite differences

        if (u - EPS >= 0) {
          func(u - EPS, v, p1);
          pu.subVectors(p0, p1);
        } else {
          func(u + EPS, v, p1);
          pu.subVectors(p1, p0);
        }

        if (v - EPS >= 0) {
          func(u, v - EPS, p1);
          pv.subVectors(p0, p1);
        } else {
          func(u, v + EPS, p1);
          pv.subVectors(p1, p0);
        }

        // cross product of tangent vectors returns surface normal

        normal.crossVectors(pu, pv).normalize();
        normals.addAll(
            [normal.x.toDouble(), normal.y.toDouble(), normal.z.toDouble()]);

        // uv

        uvs.addAll([u, v]);
      }
    }

    // generate indices

    for (var i = 0; i < stacks; i++) {
      for (var j = 0; j < slices; j++) {
        var a = i * sliceCount + j;
        var b = i * sliceCount + j + 1;
        var c = (i + 1) * sliceCount + j + 1;
        var d = (i + 1) * sliceCount + j;

        // faces one and two

        indices.addAll([a, b, d]);
        indices.addAll([b, c, d]);
      }
    }

    // build geometry

    setIndex(indices);
    setAttribute(
        'position', Float32BufferAttribute(Float32Array.from(vertices), 3));
    setAttribute(
        'normal', Float32BufferAttribute(Float32Array.from(normals), 3));
    setAttribute('uv', Float32BufferAttribute(Float32Array.from(uvs), 2));
  }
}
