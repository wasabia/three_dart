
import 'package:three_dart/three3d/dart_helpers.dart';
import 'package:three_dart/three3d/math/index.dart';

class SVGLoaderPointsToStroke {
  var tempV2_1 = Vector2(null, null);
  var tempV2_2 = Vector2(null, null);
  var tempV2_3 = Vector2(null, null);
  var tempV2_4 = Vector2(null, null);
  var tempV2_5 = Vector2(null, null);
  var tempV2_6 = Vector2(null, null);
  var tempV2_7 = Vector2(null, null);
  var lastPointL = Vector2(null, null);
  var lastPointR = Vector2(null, null);
  var point0L = Vector2(null, null);
  var point0R = Vector2(null, null);
  var currentPointL = Vector2(null, null);
  var currentPointR = Vector2(null, null);
  var nextPointL = Vector2(null, null);
  var nextPointR = Vector2(null, null);
  var innerPoint = Vector2(null, null);
  var outerPoint = Vector2(null, null);

  num arcDivisions = 12;
  num minDistance = 0.001;
  int vertexOffset = 0;

  late List points;
  late dynamic style;

  List<double> vertices = List<double>.of([], growable: true);
  List<double> normals = List<double>.of([], growable: true);
  List<double> uvs = List<double>.of([], growable: true);

  int numVertices = 0;
  var currentPoint;

  // This function can be called to update existing arrays or buffers.
  // Accepts same parameters as pointsToStroke, plus the buffers and optional offset.
  // Param vertexOffset: Offset vertices to start writing in the buffers (3 elements/vertex for vertices and normals, and 2 elements/vertex for uvs)
  // Returns number of written vertices / normals / uvs pairs
  // if 'vertices' parameter is null no triangles will be generated, but the returned vertices count will still be valid (useful to preallocate the buffers)
  // 'normals' and 'uvs' buffers are optional
  int currentCoordinate = 0;
  int currentCoordinateUV = 0;

  num u0 = 0.0;

  SVGLoaderPointsToStroke(points, style, arcDivisions, minDistance, vertices,
      normals, uvs, vertexOffset) {
    arcDivisions = arcDivisions ?? 12;
    minDistance = minDistance ?? 0.001;
    vertexOffset = vertexOffset ?? 0;

    // First ensure there are no duplicated points
    this.points = removeDuplicatedPoints(points);
    this.style = style;
    this.vertices = vertices;
    this.normals = normals;
    this.uvs = uvs;
    currentCoordinate = vertexOffset * 3;
    currentCoordinateUV = vertexOffset * 2;
  }

  convert() {
    var numPoints = points.length;

    if (numPoints < 2) return 0;

    var isClosed = points[0].equals(points[numPoints - 1]);

    var previousPoint = points[0];
    var nextPoint;

    var strokeWidth2 = style["strokeWidth"] / 2;

    var deltaU = 1 / (numPoints - 1);

    bool innerSideModified = false;
    bool joinIsOnLeftSide = false;
    bool isMiter = false;
    bool initialJoinIsOnLeftSide = false;
    num u1 = 0;

    // Get initial left and right stroke points
    getNormal(points[0], points[1], tempV2_1).multiplyScalar(strokeWidth2);
    lastPointL.copy(points[0]).sub(tempV2_1);
    lastPointR.copy(points[0]).add(tempV2_1);
    point0L.copy(lastPointL);
    point0R.copy(lastPointR);

    for (var iPoint = 1; iPoint < numPoints; iPoint++) {
      currentPoint = points[iPoint];

      // Get next point
      if (iPoint == numPoints - 1) {
        if (isClosed) {
          // Skip duplicated initial point
          nextPoint = points[1];
        } else {
          nextPoint = null;
        }
      } else {
        nextPoint = points[iPoint + 1];
      }

      // Normal of previous segment in tempV2_1
      var normal1 = tempV2_1;
      getNormal(previousPoint, currentPoint, normal1);

      tempV2_3.copy(normal1).multiplyScalar(strokeWidth2);
      currentPointL.copy(currentPoint).sub(tempV2_3);
      currentPointR.copy(currentPoint).add(tempV2_3);

      u1 = u0 + deltaU;

      innerSideModified = false;

      if (nextPoint != null) {
        // Normal of next segment in tempV2_2
        getNormal(currentPoint, nextPoint, tempV2_2);

        tempV2_3.copy(tempV2_2).multiplyScalar(strokeWidth2);
        nextPointL.copy(currentPoint).sub(tempV2_3);
        nextPointR.copy(currentPoint).add(tempV2_3);

        joinIsOnLeftSide = true;
        tempV2_3.subVectors(nextPoint, previousPoint);
        if (normal1.dot(tempV2_3) < 0) {
          joinIsOnLeftSide = false;
        }

        if (iPoint == 1) initialJoinIsOnLeftSide = joinIsOnLeftSide;

        tempV2_3.subVectors(nextPoint, currentPoint);
        tempV2_3.normalize();
        var dot = Math.abs(normal1.dot(tempV2_3));

        // If path is straight, don't create join
        if (dot != 0) {
          // Compute inner and outer segment intersections
          var miterSide = strokeWidth2 / dot;
          tempV2_3.multiplyScalar(-miterSide);
          tempV2_4.subVectors(currentPoint, previousPoint);
          tempV2_5.copy(tempV2_4).setLength(miterSide).add(tempV2_3);
          innerPoint.copy(tempV2_5).negate();
          var miterLength2 = tempV2_5.length();
          var segmentLengthPrev = tempV2_4.length();
          tempV2_4.divideScalar(segmentLengthPrev);
          tempV2_6.subVectors(nextPoint, currentPoint);
          var segmentLengthNext = tempV2_6.length();
          tempV2_6.divideScalar(segmentLengthNext);
          // Check that previous and next segments doesn't overlap with the innerPoint of intersection
          if (tempV2_4.dot(innerPoint) < segmentLengthPrev &&
              tempV2_6.dot(innerPoint) < segmentLengthNext) {
            innerSideModified = true;
          }

          outerPoint.copy(tempV2_5).add(currentPoint);
          innerPoint.add(currentPoint);

          isMiter = false;

          if (innerSideModified) {
            if (joinIsOnLeftSide) {
              nextPointR.copy(innerPoint);
              currentPointR.copy(innerPoint);
            } else {
              nextPointL.copy(innerPoint);
              currentPointL.copy(innerPoint);
            }
          } else {
            // The segment triangles are generated here if there was overlapping

            makeSegmentTriangles(u1);
          }

          switch (style["strokeLineJoin"]) {
            case 'bevel':
              makeSegmentWithBevelJoin(
                  joinIsOnLeftSide, innerSideModified, u1, u1);

              break;

            case 'round':

              // Segment triangles

              createSegmentTrianglesWithMiddleSection(
                  joinIsOnLeftSide, innerSideModified, u1);

              // Join triangles

              if (joinIsOnLeftSide) {
                makeCircularSector(
                    currentPoint, currentPointL, nextPointL, u1, 0);
              } else {
                makeCircularSector(
                    currentPoint, nextPointR, currentPointR, u1, 1);
              }

              break;

            case 'miter':
            case 'miter-clip':
            default:
              var miterFraction =
                  (strokeWidth2 * style["strokeMiterLimit"]) / miterLength2;

              if (miterFraction < 1) {
                // The join miter length exceeds the miter limit

                if (style["strokeLineJoin"] != 'miter-clip') {
                  makeSegmentWithBevelJoin(
                      joinIsOnLeftSide, innerSideModified, u1, u1);
                  break;
                } else {
                  // Segment triangles

                  createSegmentTrianglesWithMiddleSection(
                      joinIsOnLeftSide, innerSideModified, u1);

                  // Miter-clip join triangles

                  if (joinIsOnLeftSide) {
                    tempV2_6
                        .subVectors(outerPoint, currentPointL)
                        .multiplyScalar(miterFraction)
                        .add(currentPointL);
                    tempV2_7
                        .subVectors(outerPoint, nextPointL)
                        .multiplyScalar(miterFraction)
                        .add(nextPointL);

                    addVertex(currentPointL, u1, 0);
                    addVertex(tempV2_6, u1, 0);
                    addVertex(currentPoint, u1, 0.5);

                    addVertex(currentPoint, u1, 0.5);
                    addVertex(tempV2_6, u1, 0);
                    addVertex(tempV2_7, u1, 0);

                    addVertex(currentPoint, u1, 0.5);
                    addVertex(tempV2_7, u1, 0);
                    addVertex(nextPointL, u1, 0);
                  } else {
                    tempV2_6
                        .subVectors(outerPoint, currentPointR)
                        .multiplyScalar(miterFraction)
                        .add(currentPointR);
                    tempV2_7
                        .subVectors(outerPoint, nextPointR)
                        .multiplyScalar(miterFraction)
                        .add(nextPointR);

                    addVertex(currentPointR, u1, 1);
                    addVertex(tempV2_6, u1, 1);
                    addVertex(currentPoint, u1, 0.5);

                    addVertex(currentPoint, u1, 0.5);
                    addVertex(tempV2_6, u1, 1);
                    addVertex(tempV2_7, u1, 1);

                    addVertex(currentPoint, u1, 0.5);
                    addVertex(tempV2_7, u1, 1);
                    addVertex(nextPointR, u1, 1);
                  }
                }
              } else {
                // Miter join segment triangles

                if (innerSideModified) {
                  // Optimized segment + join triangles

                  if (joinIsOnLeftSide) {
                    addVertex(lastPointR, u0, 1);
                    addVertex(lastPointL, u0, 0);
                    addVertex(outerPoint, u1, 0);

                    addVertex(lastPointR, u0, 1);
                    addVertex(outerPoint, u1, 0);
                    addVertex(innerPoint, u1, 1);
                  } else {
                    addVertex(lastPointR, u0, 1);
                    addVertex(lastPointL, u0, 0);
                    addVertex(outerPoint, u1, 1);

                    addVertex(lastPointL, u0, 0);
                    addVertex(innerPoint, u1, 0);
                    addVertex(outerPoint, u1, 1);
                  }

                  if (joinIsOnLeftSide) {
                    nextPointL.copy(outerPoint);
                  } else {
                    nextPointR.copy(outerPoint);
                  }
                } else {
                  // Add extra miter join triangles

                  if (joinIsOnLeftSide) {
                    addVertex(currentPointL, u1, 0);
                    addVertex(outerPoint, u1, 0);
                    addVertex(currentPoint, u1, 0.5);

                    addVertex(currentPoint, u1, 0.5);
                    addVertex(outerPoint, u1, 0);
                    addVertex(nextPointL, u1, 0);
                  } else {
                    addVertex(currentPointR, u1, 1);
                    addVertex(outerPoint, u1, 1);
                    addVertex(currentPoint, u1, 0.5);

                    addVertex(currentPoint, u1, 0.5);
                    addVertex(outerPoint, u1, 1);
                    addVertex(nextPointR, u1, 1);
                  }
                }

                isMiter = true;
              }

              break;
          }
        } else {
          // The segment triangles are generated here when two consecutive points are collinear

          makeSegmentTriangles(u1);
        }
      } else {
        // The segment triangles are generated here if it is the ending segment

        makeSegmentTriangles(u1);
      }

      if (!isClosed && iPoint == numPoints - 1) {
        // Start line endcap
        addCapGeometry(points[0], point0L, point0R, joinIsOnLeftSide, true, u0);
      }

      // Increment loop variables

      u0 = u1;

      previousPoint = currentPoint;

      lastPointL.copy(nextPointL);
      lastPointR.copy(nextPointR);
    }

    if (!isClosed) {
      // Ending line endcap
      addCapGeometry(currentPoint, currentPointL, currentPointR,
          joinIsOnLeftSide, false, u1);
    } else if (innerSideModified) {
      // Modify path first segment vertices to adjust to the segments inner and outer intersections

      var lastOuter = outerPoint;
      var lastInner = innerPoint;

      if (initialJoinIsOnLeftSide != joinIsOnLeftSide) {
        lastOuter = innerPoint;
        lastInner = outerPoint;
      }

      if (joinIsOnLeftSide) {
        if (isMiter || initialJoinIsOnLeftSide) {
          lastInner.toArray(vertices, 0 * 3);
          lastInner.toArray(vertices, 3 * 3);

          if (isMiter) {
            lastOuter.toArray(vertices, 1 * 3);
          }
        }
      } else {
        if (isMiter || !initialJoinIsOnLeftSide) {
          lastInner.toArray(vertices, 1 * 3);
          lastInner.toArray(vertices, 3 * 3);

          if (isMiter) {
            lastOuter.toArray(vertices, 0 * 3);
          }
        }
      }
    }

    return numVertices;

    // -- End of algorithm
  }

  removeDuplicatedPoints(points) {
    // Creates a new array if necessary with duplicated points removed.
    // This does not remove duplicated initial and ending points of a closed path.

    var dupPoints = false;
    for (var i = 1, n = points.length - 1; i < n; i++) {
      if (points[i].distanceTo(points[i + 1]) < minDistance) {
        dupPoints = true;
        break;
      }
    }

    if (!dupPoints) return points;

    var newPoints = [];
    newPoints.add(points[0]);

    for (var i = 1, n = points.length - 1; i < n; i++) {
      if (points[i].distanceTo(points[i + 1]) >= minDistance) {
        newPoints.add(points[i]);
      }
    }

    newPoints.add(points[points.length - 1]);

    return newPoints;
  }

  getNormal(p1, p2, result) {
    result.subVectors(p2, p1);
    return result.set(-result.y, result.x).normalize();
  }

  addVertex(position, u, v) {
    listSetter(vertices, currentCoordinate, position.x);

    // vertices[ currentCoordinate + 1 ] = position.y;
    listSetter(vertices, currentCoordinate + 1, position.y);

    // vertices[ currentCoordinate + 2 ] = 0;
    listSetter(vertices, currentCoordinate + 2, 0.0);

    listSetter(normals, currentCoordinate, 0.0);

    // normals[ currentCoordinate + 1 ] = 0;
    listSetter(normals, currentCoordinate + 1, 0.0);

    // normals[ currentCoordinate + 2 ] = 1;
    listSetter(normals, currentCoordinate + 2, 1.0);

    currentCoordinate += 3;

    listSetter(uvs, currentCoordinateUV, u.toDouble());

    // uvs[ currentCoordinateUV + 1 ] = v;
    listSetter(uvs, currentCoordinateUV + 1, v.toDouble());

    currentCoordinateUV += 2;

    numVertices += 3;
  }

  makeCircularSector(center, p1, p2, u, v) {
    // param p1, p2: Points in the circle arc.
    // p1 and p2 are in clockwise direction.

    tempV2_1.copy(p1).sub(center).normalize();
    tempV2_2.copy(p2).sub(center).normalize();

    var angle = Math.PI;
    var dot = tempV2_1.dot(tempV2_2);
    if (Math.abs(dot) < 1) angle = Math.abs(Math.acos(dot)).toDouble();

    angle /= arcDivisions;

    tempV2_3.copy(p1);

    for (var i = 0, il = arcDivisions - 1; i < il; i++) {
      tempV2_4.copy(tempV2_3).rotateAround(center, angle);

      addVertex(tempV2_3, u, v);
      addVertex(tempV2_4, u, v);
      addVertex(center, u, 0.5);

      tempV2_3.copy(tempV2_4);
    }

    addVertex(tempV2_4, u, v);
    addVertex(p2, u, v);
    addVertex(center, u, 0.5);
  }

  makeSegmentTriangles(u1) {
    addVertex(lastPointR, u0, 1);
    addVertex(lastPointL, u0, 0);
    addVertex(currentPointL, u1, 0);

    addVertex(lastPointR, u0, 1);
    addVertex(currentPointL, u1, 1);
    addVertex(currentPointR, u1, 0);
  }

  makeSegmentWithBevelJoin(joinIsOnLeftSide, innerSideModified, u, u1) {
    if (innerSideModified) {
      // Optimized segment + bevel triangles

      if (joinIsOnLeftSide) {
        // Path segments triangles

        addVertex(lastPointR, u0, 1);
        addVertex(lastPointL, u0, 0);
        addVertex(currentPointL, u1, 0);

        addVertex(lastPointR, u0, 1);
        addVertex(currentPointL, u1, 0);
        addVertex(innerPoint, u1, 1);

        // Bevel join triangle

        addVertex(currentPointL, u, 0);
        addVertex(nextPointL, u, 0);
        addVertex(innerPoint, u, 0.5);
      } else {
        // Path segments triangles

        addVertex(lastPointR, u0, 1);
        addVertex(lastPointL, u0, 0);
        addVertex(currentPointR, u1, 1);

        addVertex(lastPointL, u0, 0);
        addVertex(innerPoint, u1, 0);
        addVertex(currentPointR, u1, 1);

        // Bevel join triangle

        addVertex(currentPointR, u, 1);
        addVertex(nextPointR, u, 0);
        addVertex(innerPoint, u, 0.5);
      }
    } else {
      // Bevel join triangle. The segment triangles are done in the main loop

      if (joinIsOnLeftSide) {
        addVertex(currentPointL, u, 0);
        addVertex(nextPointL, u, 0);
        addVertex(currentPoint, u, 0.5);
      } else {
        addVertex(currentPointR, u, 1);
        addVertex(nextPointR, u, 0);
        addVertex(currentPoint, u, 0.5);
      }
    }
  }

  createSegmentTrianglesWithMiddleSection(
      joinIsOnLeftSide, innerSideModified, u1) {
    if (innerSideModified) {
      if (joinIsOnLeftSide) {
        addVertex(lastPointR, u0, 1);
        addVertex(lastPointL, u0, 0);
        addVertex(currentPointL, u1, 0);

        addVertex(lastPointR, u0, 1);
        addVertex(currentPointL, u1, 0);
        addVertex(innerPoint, u1, 1);

        addVertex(currentPointL, u0, 0);
        addVertex(currentPoint, u1, 0.5);
        addVertex(innerPoint, u1, 1);

        addVertex(currentPoint, u1, 0.5);
        addVertex(nextPointL, u0, 0);
        addVertex(innerPoint, u1, 1);
      } else {
        addVertex(lastPointR, u0, 1);
        addVertex(lastPointL, u0, 0);
        addVertex(currentPointR, u1, 1);

        addVertex(lastPointL, u0, 0);
        addVertex(innerPoint, u1, 0);
        addVertex(currentPointR, u1, 1);

        addVertex(currentPointR, u0, 1);
        addVertex(innerPoint, u1, 0);
        addVertex(currentPoint, u1, 0.5);

        addVertex(currentPoint, u1, 0.5);
        addVertex(innerPoint, u1, 0);
        addVertex(nextPointR, u0, 1);
      }
    }
  }

  addCapGeometry(center, p1, p2, joinIsOnLeftSide, start, u) {
    // param center: End point of the path
    // param p1, p2: Left and right cap points

    switch (style["strokeLineCap"]) {
      case 'round':
        if (start) {
          makeCircularSector(center, p2, p1, u, 0.5);
        } else {
          makeCircularSector(center, p1, p2, u, 0.5);
        }

        break;

      case 'square':
        if (start) {
          tempV2_1.subVectors(p1, center);
          tempV2_2.set(tempV2_1.y, -tempV2_1.x);

          tempV2_3.addVectors(tempV2_1, tempV2_2).add(center);
          tempV2_4.subVectors(tempV2_2, tempV2_1).add(center);

          // Modify already existing vertices
          if (joinIsOnLeftSide) {
            tempV2_3.toArray(vertices, 1 * 3);
            tempV2_4.toArray(vertices, 0 * 3);
            tempV2_4.toArray(vertices, 3 * 3);
          } else {
            tempV2_3.toArray(vertices, 1 * 3);
            tempV2_3.toArray(vertices, 3 * 3);
            tempV2_4.toArray(vertices, 0 * 3);
          }
        } else {
          tempV2_1.subVectors(p2, center);
          tempV2_2.set(tempV2_1.y, -tempV2_1.x);

          tempV2_3.addVectors(tempV2_1, tempV2_2).add(center);
          tempV2_4.subVectors(tempV2_2, tempV2_1).add(center);

          var vl = vertices.length;

          // Modify already existing vertices
          if (joinIsOnLeftSide) {
            tempV2_3.toArray(vertices, vl - 1 * 3);
            tempV2_4.toArray(vertices, vl - 2 * 3);
            tempV2_4.toArray(vertices, vl - 4 * 3);
          } else {
            tempV2_3.toArray(vertices, vl - 2 * 3);
            tempV2_4.toArray(vertices, vl - 1 * 3);
            tempV2_4.toArray(vertices, vl - 4 * 3);
          }
        }

        break;

      case 'butt':
      default:

        // Nothing to do here
        break;
    }
  }
}
