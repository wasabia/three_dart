part of three_extra;

class ShapeUtils {
  // calculate area of the contour polygon

  static area(contour) {
    var n = contour.length;
    var a = 0.0;

    for (var p = n - 1, q = 0; q < n; p = q++) {
      a += contour[p].x * contour[q].y - contour[q].x * contour[p].y;
    }

    return a * 0.5;
  }

  static isClockWise(pts) {
    return ShapeUtils.area(pts) < 0;
  }

  static triangulateShape(contour, holes) {
    var vertices =
        []; // flat array of vertices like [ x0,y0, x1,y1, x2,y2, ... ]
    List<num> holeIndices = []; // array of hole indices
    var faces =
        []; // final array of vertex indices like [ [ a,b,d ], [ b,c,d ] ]

    removeDupEndPts(contour);
    addContour(vertices, contour);

    //

    var holeIndex = contour.length;

    holes.forEach(removeDupEndPts);

    for (var i = 0; i < holes.length; i++) {
      holeIndices.add(holeIndex);
      holeIndex += holes[i].length;
      addContour(vertices, holes[i]);
    }

    //

    var triangles = Earcut.triangulate(vertices, holeIndices, null);

    //

    for (var i = 0; i < triangles.length; i += 3) {
      faces.add(triangles.sublist(i, i + 3));
    }

    return faces;
  }
}

removeDupEndPts(points) {
  var l = points.length;

  if (l > 2 && points[l - 1].equals(points[0])) {
    points.removeLast();
  }
}

addContour(vertices, contour) {
  for (var i = 0; i < contour.length; i++) {
    vertices.add(contour[i].x);
    vertices.add(contour[i].y);
  }
}
