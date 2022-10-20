import 'package:three_dart/three3d/dart_helpers.dart';
import 'package:three_dart/three3d/extras/core/path.dart';
import 'package:three_dart/three3d/extras/core/shape.dart';
import 'package:three_dart/three3d/extras/shape_utils.dart';
import 'package:three_dart/three3d/math/index.dart';

class ShapePath {
  String type = "ShapePath";
  Color color = Color(1, 1, 1);
  List<Path> subPaths = [];
  late Path currentPath;
  Map<String, dynamic>? userData;

  ShapePath();

  moveTo(double x, double y) {
    currentPath = Path(null);
    subPaths.add(currentPath);
    currentPath.moveTo(x, y);
    return this;
  }

  lineTo(double x, double y) {
    currentPath.lineTo(x, y);
    return this;
  }

  quadraticCurveTo(double aCPx, double aCPy, double aX, double aY) {
    currentPath.quadraticCurveTo(aCPx, aCPy, aX, aY);
    return this;
  }

  bezierCurveTo(num aCP1x, num aCP1y, num aCP2x, num aCP2y, num aX, num aY) {
    currentPath.bezierCurveTo(aCP1x, aCP1y, aCP2x, aCP2y, aX, aY);

    return this;
  }

  splineThru(pts) {
    currentPath.splineThru(pts);

    return this;
  }

  List<Shape> toShapes(bool isCCW, bool noHoles) {
    toShapesNoHoles(inSubpaths) {
      List<Shape> shapes = [];

      for (var i = 0, l = inSubpaths.length; i < l; i++) {
        var tmpPath = inSubpaths[i];

        var tmpShape = Shape(null);
        tmpShape.curves = tmpPath.curves;

        shapes.add(tmpShape);
      }

      return shapes;
    }

    isPointInsidePolygon(inPt, inPolygon) {
      var polyLen = inPolygon.length;

      // inPt on polygon contour => immediate success    or
      // toggling of inside/outside at every single! intersection point of an edge
      //  with the horizontal line through inPt, left of inPt
      //  not counting lowerY endpoints of edges and whole edges on that line
      var inside = false;
      for (var p = polyLen - 1, q = 0; q < polyLen; p = q++) {
        var edgeLowPt = inPolygon[p];
        var edgeHighPt = inPolygon[q];

        var edgeDx = edgeHighPt.x - edgeLowPt.x;
        var edgeDy = edgeHighPt.y - edgeLowPt.y;

        if (Math.abs(edgeDy) > Math.epsilon) {
          // not parallel
          if (edgeDy < 0) {
            edgeLowPt = inPolygon[q];
            edgeDx = -edgeDx;
            edgeHighPt = inPolygon[p];
            edgeDy = -edgeDy;
          }

          if ((inPt.y < edgeLowPt.y) || (inPt.y > edgeHighPt.y)) continue;

          if (inPt.y == edgeLowPt.y) {
            if (inPt.x == edgeLowPt.x) return true; // inPt is on contour ?
            // continue;				// no intersection or edgeLowPt => doesn't count !!!

          } else {
            var perpEdge = edgeDy * (inPt.x - edgeLowPt.x) - edgeDx * (inPt.y - edgeLowPt.y);
            if (perpEdge == 0) return true; // inPt is on contour ?
            if (perpEdge < 0) continue;
            inside = !inside; // true intersection left of inPt

          }
        } else {
          // parallel or collinear
          if (inPt.y != edgeLowPt.y) continue; // parallel
          // edge lies on the same horizontal line as inPt
          if (((edgeHighPt.x <= inPt.x) && (inPt.x <= edgeLowPt.x)) ||
              ((edgeLowPt.x <= inPt.x) && (inPt.x <= edgeHighPt.x))) {
            return true;
          } // inPt: Point on contour !
          // continue;

        }
      }

      return inside;
    }

    var isClockWise = ShapeUtils.isClockWise;

    var subPaths = this.subPaths;
    if (subPaths.isEmpty) return [];

    if (noHoles == true) return toShapesNoHoles(subPaths);

    var solid, tmpPath, tmpShape;
    List<Shape> shapes = [];

    if (subPaths.length == 1) {
      tmpPath = subPaths[0];
      tmpShape = Shape(null);
      tmpShape.curves = tmpPath.curves;
      shapes.add(tmpShape);
      return shapes;
    }

    var holesFirst = !isClockWise(subPaths[0].getPoints());
    holesFirst = isCCW ? !holesFirst : holesFirst;

    // console.log("Holes first", holesFirst);

    var betterShapeHoles = [];
    var newShapes = [];
    var newShapeHoles = [];
    var mainIdx = 0;
    var tmpPoints;

    // newShapes[ mainIdx ] = null;
    listSetter(newShapes, mainIdx, null);

    // newShapeHoles[ mainIdx ] = [];
    listSetter(newShapeHoles, mainIdx, []);

    for (var i = 0, l = subPaths.length; i < l; i++) {
      tmpPath = subPaths[i];
      tmpPoints = tmpPath.getPoints();
      solid = isClockWise(tmpPoints);
      solid = isCCW ? !solid : solid;

      if (solid) {
        if ((!holesFirst) && (newShapes[mainIdx] != null)) mainIdx++;

        // newShapes[ mainIdx ] = { "s": Shape(null), "p": tmpPoints };
        listSetter(newShapes, mainIdx, {"s": Shape(null), "p": tmpPoints});

        newShapes[mainIdx]["s"].curves = tmpPath.curves;

        if (holesFirst) mainIdx++;
        // newShapeHoles[ mainIdx ] = [];
        listSetter(newShapeHoles, mainIdx, []);

        //console.log('cw', i);

      } else {
        newShapeHoles[mainIdx].add({"h": tmpPath, "p": tmpPoints[0]});

        //console.log('ccw', i);

      }
    }

    // only Holes? -> probably all Shapes with wrong orientation
    if (newShapes.isEmpty || newShapes[0] == null) {
      return toShapesNoHoles(subPaths);
    }

    if (newShapes.length > 1) {
      var ambiguous = false;
      var toChange = 0;

      for (var sIdx = 0, sLen = newShapes.length; sIdx < sLen; sIdx++) {
        // betterShapeHoles[ sIdx ] = [];
        listSetter(betterShapeHoles, sIdx, []);
      }

      for (var sIdx = 0, sLen = newShapes.length; sIdx < sLen; sIdx++) {
        var sho = newShapeHoles[sIdx];

        for (var hIdx = 0; hIdx < sho.length; hIdx++) {
          var ho = sho[hIdx];
          var holeUnassigned = true;

          for (var s2Idx = 0; s2Idx < newShapes.length; s2Idx++) {
            if (isPointInsidePolygon(ho["p"], newShapes[s2Idx]["p"])) {
              if (sIdx != s2Idx) toChange++;
              if (holeUnassigned) {
                holeUnassigned = false;
                betterShapeHoles[s2Idx].add(ho);
              } else {
                ambiguous = true;
              }
            }
          }

          if (holeUnassigned) {
            betterShapeHoles[sIdx].add(ho);
          }
        }
      }
      if (toChange > 0 && ambiguous == false) {
        newShapeHoles = betterShapeHoles;
      }
    }

    var tmpHoles;

    for (var i = 0, il = newShapes.length; i < il; i++) {
      tmpShape = newShapes[i]["s"];
      shapes.add(tmpShape);
      tmpHoles = newShapeHoles[i];

      for (var j = 0, jl = tmpHoles.length; j < jl; j++) {
        tmpShape.holes.add(tmpHoles[j]["h"]);
      }
    }

    //console.log("shape", shapes);

    return shapes;
  }
}
