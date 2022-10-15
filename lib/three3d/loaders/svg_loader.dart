
import 'dart:async';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/extras/index.dart';
import 'package:three_dart/three3d/loaders/file_loader.dart';
import 'package:three_dart/three3d/loaders/loader.dart';
import 'package:three_dart/three3d/loaders/svg_loader_parser.dart';
import 'package:three_dart/three3d/loaders/svg_loader_points_to_stroke.dart';
import 'package:three_dart/three3d/math/index.dart';

class SVGLoader extends Loader {
  // Default dots per inch
  num defaultDPI = 90;

  // Accepted units: 'mm', 'cm', 'in', 'pt', 'pc', 'px'
  String defaultUnit = 'px';

  SVGLoader(manager) : super(manager);

  @override
  loadAsync(url, [onProgress]) async {
    var completer = Completer();

    load(url, (result) {
      completer.complete(result);
    }, onProgress, () {});

    return completer.future;
  }

  @override
  load(url, onLoad, [onProgress, onError]) {
    var scope = this;

    var loader = FileLoader(scope.manager);
    loader.setPath(scope.path);
    loader.setRequestHeader(scope.requestHeader);
    loader.setWithCredentials(scope.withCredentials);
    loader.load(url, (text) {
      // try {
      onLoad(scope.parse(text));

      // } catch ( e ) {

      // 	if ( onError != null ) {

      // 		onError( e );

      // 	} else {
      //     print("SVGLoader load error.... ");
      // 		print( e );

      // 	}

      // 	scope.manager.itemError( url );

      // }
    }, onProgress, onError);
  }

  // Function parse =========== start
  @override
  parse(text, [String? path, Function? onLoad, Function? onError]) {
    var _parse = SVGLoaderParser(text, defaultUnit: defaultUnit, defaultDPI: defaultDPI);
    return _parse.parse(text);
  }
  // Function parse ================ end

  static Map<String, dynamic> getStrokeStyle(width, color, lineJoin, lineCap, miterLimit) {
    // Param width: Stroke width
    // Param color: As returned by three.Color.getStyle()
    // Param lineJoin: One of "round", "bevel", "miter" or "miter-limit"
    // Param lineCap: One of "round", "square" or "butt"
    // Param miterLimit: Maximum join length, in multiples of the "width" parameter (join is truncated if it exceeds that distance)
    // Returns style object

    width = width ?? 1;
    color = color ?? '#000';
    lineJoin = lineJoin ?? 'miter';
    lineCap = lineCap ?? 'butt';
    miterLimit = miterLimit ?? 4;

    return {
      "strokeColor": color,
      "strokeWidth": width,
      "strokeLineJoin": lineJoin,
      "strokeLineCap": lineCap,
      "strokeMiterLimit": miterLimit
    };
  }

  static pointsToStroke(points, style, [arcDivisions, minDistance]) {
    // Generates a stroke with some witdh around the given path.
    // The path can be open or closed (last point equals to first point)
    // Param points: Array of Vector2D (the path). Minimum 2 points.
    // Param style: Object with SVG properties as returned by SVGLoader.getStrokeStyle(), or SVGLoader.parse() in the path.userData.style object
    // Params arcDivisions: Arc divisions for round joins and endcaps. (Optional)
    // Param minDistance: Points closer to this distance will be merged. (Optional)
    // Returns BufferGeometry with stroke triangles (In plane z = 0). UV coordinates are generated ('u' along path. 'v' across it, from left to right)

    List<double> vertices = [];
    List<double> normals = [];
    List<double> uvs = [];

    if (SVGLoader.pointsToStrokeWithBuffers(points, style, arcDivisions, minDistance, vertices, normals, uvs, 0) == 0) {
      return null;
    }

    var geometry = BufferGeometry();
    geometry.setAttribute('position', Float32BufferAttribute(Float32Array.from(vertices), 3, false));
    geometry.setAttribute('normal', Float32BufferAttribute(Float32Array.from(normals), 3, false));
    geometry.setAttribute('uv', Float32BufferAttribute(Float32Array.from(uvs), 2, false));

    return geometry;
  }

  static pointsToStrokeWithBuffers(points, style, arcDivisions, minDistance, vertices, normals, uvs, vertexOffset) {
    var svgLPTS =
        SVGLoaderPointsToStroke(points, style, arcDivisions, minDistance, vertices, normals, uvs, vertexOffset);
    return svgLPTS.convert();
  }

  static createShapes(shapePath) {
    // Param shapePath: a shapepath as returned by the parse function of this class
    // Returns Shape object

    const BIGNUMBER = 99999999999999.0;

    var IntersectionLocationType = {
      "ORIGIN": 0,
      "DESTINATION": 1,
      "BETWEEN": 2,
      "LEFT": 3,
      "RIGHT": 4,
      "BEHIND": 5,
      "BEYOND": 6
    };

    Map<String, dynamic> classifyResult = {"loc": IntersectionLocationType["ORIGIN"], "t": 0};

    classifyPoint(p, edgeStart, edgeEnd) {
      var ax = edgeEnd.x - edgeStart.x;
      var ay = edgeEnd.y - edgeStart.y;
      var bx = p.x - edgeStart.x;
      var by = p.y - edgeStart.y;
      var sa = ax * by - bx * ay;

      if ((p.x == edgeStart.x) && (p.y == edgeStart.y)) {
        classifyResult["loc"] = IntersectionLocationType["ORIGIN"];
        classifyResult["t"] = 0;
        return;
      }

      if ((p.x == edgeEnd.x) && (p.y == edgeEnd.y)) {
        classifyResult["loc"] = IntersectionLocationType["DESTINATION"];
        classifyResult["t"] = 1;
        return;
      }

      if (sa < -Math.EPSILON) {
        classifyResult["loc"] = IntersectionLocationType["LEFT"];
        return;
      }

      if (sa > Math.EPSILON) {
        classifyResult["loc"] = IntersectionLocationType["RIGHT"];
        return;
      }

      if (((ax * bx) < 0) || ((ay * by) < 0)) {
        classifyResult["loc"] = IntersectionLocationType["BEHIND"];
        return;
      }

      if ((Math.sqrt(ax * ax + ay * ay)) < (Math.sqrt(bx * bx + by * by))) {
        classifyResult["loc"] = IntersectionLocationType["BEYOND"];
        return;
      }

      var t;

      if (ax != 0) {
        t = bx / ax;
      } else {
        t = by / ay;
      }

      classifyResult["loc"] = IntersectionLocationType["BETWEEN"];
      classifyResult["t"] = t;
    }

    findEdgeIntersection(a0, a1, b0, b1) {
      var x1 = a0.x;
      var x2 = a1.x;
      var x3 = b0.x;
      var x4 = b1.x;
      var y1 = a0.y;
      var y2 = a1.y;
      var y3 = b0.y;
      var y4 = b1.y;
      var nom1 = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
      var nom2 = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
      var denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
      var t1 = nom1 / denom;
      var t2 = nom2 / denom;

      if (((denom == 0) && (nom1 != 0)) || (t1 <= 0) || (t1 >= 1) || (t2 < 0) || (t2 > 1)) {
        //1. lines are parallel or edges don't intersect

        return null;
      } else if ((nom1 == 0) && (denom == 0)) {
        //2. lines are colinear

        //check if endpoints of edge2 (b0-b1) lies on edge1 (a0-a1)
        for (var i = 0; i < 2; i++) {
          classifyPoint(i == 0 ? b0 : b1, a0, a1);
          //find position of this endpoints relatively to edge1
          if (classifyResult["loc"] == IntersectionLocationType["ORIGIN"]) {
            var point = (i == 0 ? b0 : b1);
            return {"x": point.x, "y": point.y, "t": classifyResult["t"]};
          } else if (classifyResult["loc"] == IntersectionLocationType["BETWEEN"]) {
            var x = num.parse((x1 + classifyResult["t"]! * (x2 - x1)).toStringAsPrecision(10));
            var y = num.parse((y1 + classifyResult["t"]! * (y2 - y1)).toStringAsPrecision(10));
            return {"x": x, "y": y, "t": classifyResult["t"]};
          }
        }

        return null;
      } else {
        //3. edges intersect

        for (var i = 0; i < 2; i++) {
          classifyPoint(i == 0 ? b0 : b1, a0, a1);

          if (classifyResult["loc"] == IntersectionLocationType["ORIGIN"]) {
            var point = (i == 0 ? b0 : b1);
            return {"x": point.x, "y": point.y, "t": classifyResult["t"]};
          }
        }

        var x = num.parse((x1 + t1 * (x2 - x1)).toStringAsPrecision(10));
        var y = num.parse((y1 + t1 * (y2 - y1)).toStringAsPrecision(10));
        return {"x": x, "y": y, "t": t1};
      }
    }

    getIntersections(path1, path2) {
      var intersectionsRaw = [];
      var intersections = [];

      for (var index = 1; index < path1.length; index++) {
        var path1EdgeStart = path1[index - 1];
        var path1EdgeEnd = path1[index];

        for (var index2 = 1; index2 < path2.length; index2++) {
          var path2EdgeStart = path2[index2 - 1];
          var path2EdgeEnd = path2[index2];

          var intersection = findEdgeIntersection(path1EdgeStart, path1EdgeEnd, path2EdgeStart, path2EdgeEnd);

          if (intersection != null &&
              intersectionsRaw.indexWhere(
                      (i) => i["t"] <= intersection["t"] + Math.EPSILON && i["t"] >= intersection["t"] - Math.EPSILON) <
                  0) {
            intersectionsRaw.add(intersection);
            intersections.add(Vector2(intersection["x"], intersection["y"]));
          }
        }
      }

      return intersections;
    }

    getScanlineIntersections(scanline, boundingBox, paths) {
      var center = Vector2();
      boundingBox.getCenter(center);

      var allIntersections = [];

      paths.forEach((path) {
        // check if the center of the bounding box is in the bounding box of the paths.
        // this is a pruning method to limit the search of intersections in paths that can't envelop of the current path.
        // if a path envelops another path. The center of that oter path, has to be inside the bounding box of the enveloping path.
        if (path["boundingBox"].containsPoint(center)) {
          var intersections = getIntersections(scanline, path["points"]);

          for (var p in intersections) {
            allIntersections.add({"identifier": path["identifier"], "isCW": path["isCW"], "point": p});
          }
        }
      });

      allIntersections.sort((i1, i2) {
        return i1["point"].x >= i2["point"].x ? 1 : -1;
      });

      return allIntersections;
    }

    isHoleTo(simplePath, allPaths, scanlineMinX, scanlineMaxX, _fillRule) {
      if (_fillRule == null || _fillRule == '') {
        _fillRule = 'nonzero';
      }

      var centerBoundingBox = Vector2();
      simplePath["boundingBox"].getCenter(centerBoundingBox);

      var scanline = [Vector2(scanlineMinX, centerBoundingBox.y), Vector2(scanlineMaxX, centerBoundingBox.y)];

      var scanlineIntersections = getScanlineIntersections(scanline, simplePath["boundingBox"], allPaths);

      scanlineIntersections.sort((i1, i2) {
        return i1["point"].x >= i2["point"].x ? 1 : -1;
      });

      var baseIntersections = [];
      var otherIntersections = [];

      for (var i in scanlineIntersections) {
        if (i["identifier"] == simplePath["identifier"]) {
          baseIntersections.add(i);
        } else {
          otherIntersections.add(i);
        }
      }

      var firstXOfPath = baseIntersections[0]["point"].x;

      // build up the path hierarchy
      var stack = [];
      var i = 0;

      while (i < otherIntersections.length && otherIntersections[i]["point"].x < firstXOfPath) {
        if (stack.isNotEmpty && stack[stack.length - 1] == otherIntersections[i]["identifier"]) {
          stack.removeLast();
        } else {
          stack.add(otherIntersections[i]["identifier"]);
        }

        i++;
      }

      stack.add(simplePath["identifier"]);

      if (_fillRule == 'evenodd') {
        var isHole = stack.length % 2 == 0 ? true : false;
        var isHoleFor = stack[stack.length - 2];

        return {"identifier": simplePath["identifier"], "isHole": isHole, "for": isHoleFor};
      } else if (_fillRule == 'nonzero') {
        // check if path is a hole by counting the amount of paths with alternating rotations it has to cross.
        var isHole = true;
        var isHoleFor;
        var lastCWValue;

        for (var i = 0; i < stack.length; i++) {
          var identifier = stack[i];
          if (isHole) {
            lastCWValue = allPaths[identifier]["isCW"];
            isHole = false;
            isHoleFor = identifier;
          } else if (lastCWValue != allPaths[identifier]["isCW"]) {
            lastCWValue = allPaths[identifier]["isCW"];
            isHole = true;
          }
        }

        return {"identifier": simplePath["identifier"], "isHole": isHole, "for": isHoleFor};
      } else {
        print('fill-rule: "' + _fillRule + '" is currently not implemented.');
      }
    }

    // check for self intersecting paths
    // TODO

    // check intersecting paths
    // TODO

    // prepare paths for hole detection
    var identifier = 0;

    num scanlineMinX = BIGNUMBER;
    num scanlineMaxX = -BIGNUMBER;

    List simplePaths = shapePath.subPaths.map((p) {
      var points = p.getPoints();
      double maxY = -BIGNUMBER;
      double minY = BIGNUMBER;
      double maxX = -BIGNUMBER;
      double minX = BIGNUMBER;

      //points.forEach(p => p.y *= -1);

      for (var i = 0; i < points.length; i++) {
        var p = points[i];

        if (p.y > maxY) {
          maxY = p.y;
        }

        if (p.y < minY) {
          minY = p.y;
        }

        if (p.x > maxX) {
          maxX = p.x;
        }

        if (p.x < minX) {
          minX = p.x;
        }
      }

      //
      if (scanlineMaxX <= maxX) {
        scanlineMaxX = maxX + 1;
      }

      if (scanlineMinX >= minX) {
        scanlineMinX = minX - 1;
      }

      return {
        "curves": p.curves,
        "points": points,
        "isCW": ShapeUtils.isClockWise(points),
        "identifier": identifier++,
        "boundingBox": Box2(Vector2(minX, minY), Vector2(maxX, maxY))
      };
    }).toList();

    simplePaths = simplePaths.where((sp) {
      return sp["points"].length > 1;
    }).toList();

    // check if path is solid or a hole
    var isAHole = simplePaths
        .map((p) => isHoleTo(p, simplePaths, scanlineMinX, scanlineMaxX, shapePath.userData["style"]["fillRule"]))
        .toList();

    var shapesToReturn = [];
    for (var p in simplePaths) {
      var amIAHole = isAHole[p["identifier"]]!;

      if (!amIAHole["isHole"]) {
        var shape = Shape(null);
        shape.curves = p["curves"];
        var holes = isAHole.where((h) => h!["isHole"] && h["for"] == p["identifier"]).toList();
        for (var h in holes) {
          var hole = simplePaths[h!["identifier"]];
          var path = Path(null);
          path.curves = hole["curves"];
          shape.holes.add(path);
        }
        shapesToReturn.add(shape);
      }
    }

    return shapesToReturn;
  }
}
