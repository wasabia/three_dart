part of three_geometries;

/// Creates extruded geometry from a path shape.
///
/// parameters = {
///
///  curveSegments: <int>, // number of points on the curves
///  steps: <int>, // number of points for z-side extrusions / used for subdividing segments of extrude spline too
///  depth: <float>, // Depth to extrude the shape
///
///  bevelEnabled: <bool>, // turn on bevel
///  bevelThickness: <float>, // how deep into the original shape bevel goes
///  bevelSize: <float>, // how far from shape outline (including bevelOffset) is bevel
///  bevelOffset: <float>, // how far from shape outline does bevel start
///  bevelSegments: <int>, // number of bevel layers
///
///  extrudePath: <THREE.Curve> // curve to extrude shape along
///
///  UVGenerator: <Object> // object that provides UV generator functions
///
/// }

// import { BufferGeometry } from '../core/BufferGeometry.js';
// import { Float32BufferAttribute } from '../core/BufferAttribute.js';
// import { Vector2 } from '../math/Vector2.js';
// import { Vector3 } from '../math/Vector3.js';
// import { ShapeUtils } from '../extras/ShapeUtils.js';

class ExtrudeGeometry extends BufferGeometry {
  @override
  String type = "ExtrudeGeometry";

  ExtrudeGeometry(List<Shape> shapes, Map<String, dynamic> options) : super() {
    parameters = {"shapes": shapes, "options": options};

    this.shapes = shapes;

    var scope = this;

    List<double> verticesArray = [];
    List<double> uvArray = [];

    addShape(Shape shape) {
      List<double> placeholder = [];

      // options

      var curveSegments =
          options["curveSegments"] ?? 12;
      var steps = options["steps"] ?? 1;
      var depth = options["depth"] ?? 100;

      bool bevelEnabled =
          options["bevelEnabled"] ?? true;
      var bevelThickness =
          options["bevelThickness"] ?? 6;
      var bevelSize = options["bevelSize"] ?? bevelThickness - 2;
      var bevelOffset =
          options["bevelOffset"] ?? 0;
      var bevelSegments =
          options["bevelSegments"] ?? 3;

      var extrudePath = options["extrudePath"];

      var uvgen = options["UVGenerator"] ?? "WorldUVGenerator";

      // deprecated options

      if (options["amount"] != null) {
        print('THREE.ExtrudeBufferGeometry: amount has been renamed to depth.');
        depth = options["amount"];
      }

      //

      var extrudePts;
      bool extrudeByPath = false;
      var splineTube, binormal, normal, position2;

      if (extrudePath != null) {
        extrudePts = extrudePath.getSpacedPoints(divisions: steps);

        extrudeByPath = true;
        bevelEnabled = false; // bevels not supported for path extrusion

        // SETUP TNB variables

        // TODO1 - have a .isClosed in spline?

        splineTube = extrudePath.computeFrenetFrames(steps, false);

        // console.log(splineTube, 'splineTube', splineTube.normals.length, 'steps', steps, 'extrudePts', extrudePts.length);

        binormal = Vector3.init();
        normal = Vector3.init();
        position2 = Vector3.init();
      }

      // Safeguards if bevels are not enabled

      if (!bevelEnabled) {
        bevelSegments = 0;
        bevelThickness = 0;
        bevelSize = 0;
        bevelOffset = 0;
      }

      // Variables initialization

      var shapePoints = shape.extractPoints(curveSegments);

      List vertices = shapePoints["shape"];
      List holes = shapePoints["holes"];

      var reverse = !ShapeUtils.isClockWise(vertices);

      if (reverse) {
        vertices = vertices.reversed.toList();

        // Maybe we should also check if holes are in the opposite direction, just to be safe ...

        for (var h = 0, hl = holes.length; h < hl; h++) {
          var ahole = holes[h];

          if (ShapeUtils.isClockWise(ahole)) {
            holes[h] = ahole.reversed.toList();
          }
        }
      }

      var faces = ShapeUtils.triangulateShape(vertices, holes);

      /* Vertices */

      // 去除引用
      List contour = vertices.sublist(
          0); // vertices has all points but contour has only points of circumference

      for (var h = 0, hl = holes.length; h < hl; h++) {
        List ahole = holes[h];
        vertices.addAll(ahole);
      }

      scalePt2(pt, vec, size) {
        if (vec == null) {
          print('THREE.ExtrudeGeometry: vec does not exist');
        }

        return vec.clone().multiplyScalar(size).add(pt);
      }

      var vlen = vertices.length, flen = faces.length;

      // Find directions for point movement

      Vector2 getBevelVec(inPt, inPrev, inNext) {
        // computes for inPt the corresponding point inPt' on a new contour
        //   shifted by 1 unit (length of normalized vector) to the left
        // if we walk along contour clockwise, this new contour is outside the old one
        //
        // inPt' is the intersection of the two lines parallel to the two
        //  adjacent edges of inPt at a distance of 1 unit on the left side.

        var vTransX,
            vTransY,
            shrinkBy; // resulting translation vector for inPt

        // good reading for geometry algorithms (here: line-line intersection)
        // http://geomalgorithms.com/a05-_intersect-1.html

        var vPrevX = inPt.x - inPrev.x, vPrevY = inPt.y - inPrev.y;
        var vNextX = inNext.x - inPt.x, vNextY = inNext.y - inPt.y;

        var vPrevLensq = (vPrevX * vPrevX + vPrevY * vPrevY);

        // check for collinear edges
        var collinear0 = (vPrevX * vNextY - vPrevY * vNextX);

        if (Math.abs(collinear0) > Math.EPSILON) {
          // not collinear

          // length of vectors for normalizing

          var vPrevLen = Math.sqrt(vPrevLensq);
          var vNextLen = Math.sqrt(vNextX * vNextX + vNextY * vNextY);

          // shift adjacent points by unit vectors to the left

          var ptPrevShiftX = (inPrev.x - vPrevY / vPrevLen);
          var ptPrevShiftY = (inPrev.y + vPrevX / vPrevLen);

          var ptNextShiftX = (inNext.x - vNextY / vNextLen);
          var ptNextShiftY = (inNext.y + vNextX / vNextLen);

          // scaling factor for v_prev to intersection point

          var sf = ((ptNextShiftX - ptPrevShiftX) * vNextY -
                  (ptNextShiftY - ptPrevShiftY) * vNextX) /
              (vPrevX * vNextY - vPrevY * vNextX);

          // vector from inPt to intersection point

          vTransX = (ptPrevShiftX + vPrevX * sf - inPt.x);
          vTransY = (ptPrevShiftY + vPrevY * sf - inPt.y);

          // Don't normalize!, otherwise sharp corners become ugly
          //  but prevent crazy spikes
          var vTransLensq = (vTransX * vTransX + vTransY * vTransY);
          if (vTransLensq <= 2) {
            return Vector2(vTransX, vTransY);
          } else {
            shrinkBy = Math.sqrt(vTransLensq / 2);
          }
        } else {
          // handle special case of collinear edges

          var directionEq = false; // assumes: opposite

          if (vPrevX > Math.EPSILON) {
            if (vNextX > Math.EPSILON) {
              directionEq = true;
            }
          } else {
            if (vPrevX < -Math.EPSILON) {
              if (vNextX < -Math.EPSILON) {
                directionEq = true;
              }
            } else {
              if (Math.sign(vPrevY) == Math.sign(vNextY)) {
                directionEq = true;
              }
            }
          }

          if (directionEq) {
            // console.log("Warning: lines are a straight sequence");
            vTransX = -vPrevY;
            vTransY = vPrevX;
            shrinkBy = Math.sqrt(vPrevLensq);
          } else {
            // console.log("Warning: lines are a straight spike");
            vTransX = vPrevX;
            vTransY = vPrevY;
            shrinkBy = Math.sqrt(vPrevLensq / 2);
          }
        }

        return Vector2(vTransX / shrinkBy, vTransY / shrinkBy);
      }

      var contourMovements = [];

      for (var i = 0, il = contour.length, j = il - 1, k = i + 1;
          i < il;
          i++, j++, k++) {
        if (j == il) j = 0;
        if (k == il) k = 0;

        //  (j)---(i)---(k)
        // console.log('i,j,k', i, j , k)

        var _v = getBevelVec(contour[i], contour[j], contour[k]);

        contourMovements.add(_v);
      }

      var holesMovements = [];
      var oneHoleMovements, verticesMovements = contourMovements.sublist(0);

      for (var h = 0, hl = holes.length; h < hl; h++) {
        var ahole = holes[h];

        oneHoleMovements = List<Vector2>.filled(ahole.length, Vector2(0, 0));

        for (var i = 0, il = ahole.length, j = il - 1, k = i + 1;
            i < il;
            i++, j++, k++) {
          if (j == il) j = 0;
          if (k == il) k = 0;

          //  (j)---(i)---(k)
          oneHoleMovements[i] = getBevelVec(ahole[i], ahole[j], ahole[k]);
        }

        holesMovements.add(oneHoleMovements);
        verticesMovements.addAll(oneHoleMovements);
      }

      v(double x, double y, double z) {
        placeholder.add(x);
        placeholder.add(y);
        placeholder.add(z);
      }

      // Loop bevelSegments, 1 for the front, 1 for the back

      for (var b = 0; b < bevelSegments; b++) {
        //for ( b = bevelSegments; b > 0; b -- ) {

        var t = b / bevelSegments;
        var z = bevelThickness * Math.cos(t * Math.PI / 2);
        var bs = bevelSize * Math.sin(t * Math.PI / 2) + bevelOffset;

        // contract shape

        for (var i = 0, il = contour.length; i < il; i++) {
          var vert = scalePt2(contour[i], contourMovements[i], bs);

          v(vert.x, vert.y, -z);
        }

        // expand holes

        for (var h = 0, hl = holes.length; h < hl; h++) {
          var ahole = holes[h];
          oneHoleMovements = holesMovements[h];

          for (var i = 0, il = ahole.length; i < il; i++) {
            var vert = scalePt2(ahole[i], oneHoleMovements[i], bs);

            v(vert.x, vert.y, -z);
          }
        }
      }

      var bs = bevelSize + bevelOffset;

      // Back facing vertices

      for (var i = 0; i < vlen; i++) {
        var vert = bevelEnabled
            ? scalePt2(vertices[i], verticesMovements[i], bs)
            : vertices[i];

        if (!extrudeByPath) {
          v(vert.x, vert.y, 0);
        } else {
          // v( vert.x, vert.y + extrudePts[ 0 ].y, extrudePts[ 0 ].x );

          normal.copy(splineTube.normals[0]).multiplyScalar(vert.x);
          binormal.copy(splineTube.binormals[0]).multiplyScalar(vert.y);

          position2.copy(extrudePts[0]).add(normal).add(binormal);

          v(position2.x, position2.y, position2.z);
        }
      }

      // Add stepped vertices...
      // Including front facing vertices

      for (var s = 1; s <= steps; s++) {
        for (var i = 0; i < vlen; i++) {
          var vert = bevelEnabled
              ? scalePt2(vertices[i], verticesMovements[i], bs)
              : vertices[i];

          if (!extrudeByPath) {
            v(vert.x, vert.y, depth / steps * s);
          } else {
            // v( vert.x, vert.y + extrudePts[ s - 1 ].y, extrudePts[ s - 1 ].x );

            normal.copy(splineTube.normals[s]).multiplyScalar(vert.x);
            binormal.copy(splineTube.binormals[s]).multiplyScalar(vert.y);

            position2.copy(extrudePts[s]).add(normal).add(binormal);

            v(position2.x, position2.y, position2.z);
          }
        }
      }

      // Add bevel segments planes

      //for ( b = 1; b <= bevelSegments; b ++ ) {
      for (var b = bevelSegments - 1; b >= 0; b--) {
        var t = b / bevelSegments;
        var z = bevelThickness * Math.cos(t * Math.PI / 2);
        var bs = bevelSize * Math.sin(t * Math.PI / 2) + bevelOffset;

        // contract shape

        for (var i = 0, il = contour.length; i < il; i++) {
          var vert = scalePt2(contour[i], contourMovements[i], bs);
          v(vert.x, vert.y, depth + z);
        }

        // expand holes
        for (var h = 0, hl = holes.length; h < hl; h++) {
          var ahole = holes[h];
          oneHoleMovements = holesMovements[h];

          for (var i = 0, il = ahole.length; i < il; i++) {
            var vert = scalePt2(ahole[i], oneHoleMovements[i], bs);

            if (!extrudeByPath) {
              v(vert.x, vert.y, depth + z);
            } else {
              v(vert.x, vert.y + extrudePts[steps - 1].y,
                  extrudePts[steps - 1].x + z);
            }
          }
        }
      }

      addUV(vector2) {
        uvArray.add(vector2.x);
        uvArray.add(vector2.y);
      }

      addVertex(num index) {
        // print(" addVertex index: ${index} ${placeholder.length} ");

        verticesArray.add(placeholder[index.toInt() * 3 + 0]);
        verticesArray.add(placeholder[index.toInt() * 3 + 1]);
        verticesArray.add(placeholder[index.toInt() * 3 + 2]);
      }

      f3(a, b, c) {
        addVertex(a);
        addVertex(b);
        addVertex(c);

        var nextIndex = verticesArray.length / 3;
        var uvs;

        if (uvgen == "WorldUVGenerator") {
          uvs = WorldUVGenerator.generateTopUV(scope, verticesArray,
              nextIndex - 3, nextIndex - 2, nextIndex - 1);
        } else {
          throw ("ExtrudeBufferGeometry uvgen: $uvgen is not support yet ");
        }

        // var uvs = uvgen.generateTopUV( scope, verticesArray, nextIndex - 3, nextIndex - 2, nextIndex - 1 );

        addUV(uvs[0]);
        addUV(uvs[1]);
        addUV(uvs[2]);
      }

      buildLidFaces() {
        var start = verticesArray.length / 3;

        if (bevelEnabled) {
          var layer = 0; // steps + 1
          var offset = vlen * layer;

          // Bottom faces

          for (var i = 0; i < flen; i++) {
            var face = faces[i];
            f3(face[2] + offset, face[1] + offset, face[0] + offset);
          }

          layer = steps + bevelSegments * 2;
          offset = vlen * layer;

          // Top faces

          for (var i = 0; i < flen; i++) {
            var face = faces[i];
            f3(face[0] + offset, face[1] + offset, face[2] + offset);
          }
        } else {
          // Bottom faces

          for (var i = 0; i < flen; i++) {
            var face = faces[i];
            f3(face[2], face[1], face[0]);
          }

          // Top faces

          for (var i = 0; i < flen; i++) {
            var face = faces[i];
            f3(face[0] + vlen * steps, face[1] + vlen * steps,
                face[2] + vlen * steps);
          }
        }

        scope.addGroup(
            start.toInt(), (verticesArray.length / 3 - start).toInt(),
            0);
      }

      f4(a, b, c, d) {
        addVertex(a);
        addVertex(b);
        addVertex(d);

        addVertex(b);
        addVertex(c);
        addVertex(d);

        var nextIndex = verticesArray.length / 3;

        var uvs;

        if (uvgen == "WorldUVGenerator") {
          uvs = WorldUVGenerator.generateSideWallUV(scope, verticesArray,
              nextIndex - 6, nextIndex - 3, nextIndex - 2, nextIndex - 1);
        } else {
          throw ("ExtrudeBufferGeometry uvgen: $uvgen is not support yet ");
        }
        // var uvs = uvgen.generateSideWallUV( scope, verticesArray, nextIndex - 6, nextIndex - 3, nextIndex - 2, nextIndex - 1 );

        addUV(uvs[0]);
        addUV(uvs[1]);
        addUV(uvs[3]);

        addUV(uvs[1]);
        addUV(uvs[2]);
        addUV(uvs[3]);
      }

      sidewalls(contour, int layeroffset) {
        var i = contour.length;

        while (--i >= 0) {
          var j = i;
          var k = i - 1;
          if (k < 0) k = contour.length - 1;

          //console.log('b', i,j, i-1, k,vertices.length);

          for (var s = 0, sl = (steps + bevelSegments * 2); s < sl; s++) {
            var slen1 = vlen * s;
            var slen2 = vlen * (s + 1);

            var a = layeroffset + j + slen1;
            var b = layeroffset + k + slen1;
            var c = layeroffset + k + slen2;
            var d = layeroffset + j + slen2;

            f4(a, b, c, d);
          }
        }
      }

      // Create faces for the z-sides of the shape

      buildSideFaces() {
        int start = verticesArray.length ~/ 3.0;
        int layeroffset = 0;
        sidewalls(contour, layeroffset);
        layeroffset = layeroffset + contour.length;

        for (var h = 0, hl = holes.length; h < hl; h++) {
          List ahole = holes[h];

          sidewalls(ahole, layeroffset);

          //, true
          layeroffset += ahole.length;
        }

        // TODO WHY???  need fix ???
        scope.addGroup(start, (verticesArray.length / 3 - start).toInt(),
            1);
      }

      /* Faces */

      // Top and bottom faces

      buildLidFaces();

      // Sides faces
      buildSideFaces();

      /////  Internal functions

      ///
    }

    for (var i = 0, l = shapes.length; i < l; i++) {
      var shape = shapes[i];
      addShape(shape);
    }

    // build geometry

    setAttribute('position',
        Float32BufferAttribute(Float32Array.from(verticesArray), 3, false));
    setAttribute(
        'uv', Float32BufferAttribute(Float32Array.from(uvArray), 2, false));

    computeVertexNormals();

    // functions
  }

  ExtrudeGeometry.fromJSON(
      Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON);

  @override
  toJSON({Object3dMeta? meta}) {
    var data = super.toJSON(meta: meta);

    var shapes = parameters?["shapes"];
    var options = parameters?["options"];

    return toJSON2(shapes, options, data);
  }
}

class WorldUVGenerator {
  static generateTopUV(geometry, vertices, num indexA, num indexB, num indexC) {
    var aX = vertices[indexA.toInt() * 3];
    var aY = vertices[indexA.toInt() * 3 + 1];
    var bX = vertices[indexB.toInt() * 3];
    var bY = vertices[indexB.toInt() * 3 + 1];
    var cX = vertices[indexC.toInt() * 3];
    var cY = vertices[indexC.toInt() * 3 + 1];

    return [
      Vector2(aX, aY), Vector2(bX, bY), Vector2(cX, cY)
    ];
  }

  static generateSideWallUV(
      geometry, vertices, num indexA, num indexB, num indexC, num indexD) {
    num aX = vertices[indexA.toInt() * 3];
    num aY = vertices[indexA.toInt() * 3 + 1];
    num aZ = vertices[indexA.toInt() * 3 + 2];
    num bX = vertices[indexB.toInt() * 3];
    num bY = vertices[indexB.toInt() * 3 + 1];
    num bZ = vertices[indexB.toInt() * 3 + 2];
    num cX = vertices[indexC.toInt() * 3];
    num cY = vertices[indexC.toInt() * 3 + 1];
    num cZ = vertices[indexC.toInt() * 3 + 2];
    num dX = vertices[indexD.toInt() * 3];
    num dY = vertices[indexD.toInt() * 3 + 1];
    num dZ = vertices[indexD.toInt() * 3 + 2];

    if (Math.abs(aY - bY) < Math.abs(aX - bX)) {
      return [
        Vector2(aX, 1 - aZ),
        Vector2(bX, 1 - bZ),
        Vector2(cX, 1 - cZ),
        Vector2(dX, 1 - dZ)
      ];
    } else {
      return [
        Vector2(aY, 1 - aZ),
        Vector2(bY, 1 - bZ),
        Vector2(cY, 1 - cZ),
        Vector2(dY, 1 - dZ)
      ];
    }
  }
}

toJSON2(shapes, Map<String, dynamic>? options, data) {
  if (shapes != null) {
    data["shapes"] = [];

    for (var i = 0, l = shapes.length; i < l; i++) {
      var shape = shapes[i];

      data["shapes"].add(shape.uuid);
    }
  }

  if (options != null && options["extrudePath"] != null) {
    data["options"]["extrudePath"] = options["extrudePath"].toJSON();
  }

  return data;
}
