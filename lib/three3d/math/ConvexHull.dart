part of three_math;

/**
 * Ported from: https://github.com/maurizzzio/quickhull3d/ by Mauricio Poppe (https://github.com/maurizzzio)
 */

var Visible = 0;
var Deleted = 1;

class ConvexHull {
  Vector3 v1 = new Vector3.init();

  num tolerance = -1;
  List<Face2> faces = []; // the generated faces of the convex hull
  List<Face2> newFace2s =
      []; // this array holds the faces that are generated within a single iteration

  VertexList assigned = VertexList();
  VertexList unassigned = VertexList();

  // vertices of the hull (internal representation of given geometry data)
  List<VertexNode> vertices = [];

  // the vertex lists work as follows:
  //
  // let 'a' and 'b' be 'Face2' instances
  // let 'v' be points wrapped as instance of 'Vertex'
  //
  //     [v, v, ..., v, v, v, ...]
  //      ^             ^
  //      |             |
  //  a.outside     b.outside
  //

  ConvexHull() {}

  setFromPoints(List<Vector3> points) {
    // The algorithm needs at least four points.

    if (points.length >= 4) {
      this.makeEmpty();

      for (var i = 0, l = points.length; i < l; i++) {
        this.vertices.add(new VertexNode(points[i]));
      }

      this.compute();
    }

    return this;
  }

  setFromObject(Object3D object) {
    List<Vector3> points = [];

    object.updateMatrixWorld(true);

    object.traverse((node) {
      var point;

      var geometry = node.geometry;

      if (geometry != null) {
        if (geometry.isGeometry) {
          var vertices = geometry.vertices;

          for (var i = 0, l = vertices.length; i < l; i++) {
            point = vertices[i].clone();
            point.applyMatrix4(node.matrixWorld);

            points.add(point);
          }
        } else if (geometry.isBufferGeometry) {
          var attribute = geometry.attributes.position;

          if (attribute != null) {
            for (var i = 0, l = attribute.count; i < l; i++) {
              point = new Vector3.init();

              point
                  .fromBufferAttribute(attribute, i)
                  .applyMatrix4(node.matrixWorld);

              points.add(point);
            }
          }
        }
      }
    });

    return this.setFromPoints(points);
  }

  containsPoint(point) {
    var faces = this.faces;

    for (var i = 0, l = faces.length; i < l; i++) {
      var face = faces[i];

      // compute signed distance and check on what half space the point lies

      if (face.distanceToPoint(point) > this.tolerance) return false;
    }

    return true;
  }

  intersectRay(ray, target) {
    // based on "Fast Ray-Convex Polyhedron Intersection"  by Eric Haines, GRAPHICS GEMS II

    var faces = this.faces;

    var tNear = -Math.Infinity;
    var tFar = Math.Infinity;

    for (var i = 0, l = faces.length; i < l; i++) {
      var face = faces[i];

      // interpret faces as planes for the further computation

      var vN = face.distanceToPoint(ray.origin);
      var vD = face.normal.dot(ray.direction);

      // if the origin is on the positive side of a plane (so the plane can "see" the origin) and
      // the ray is turned away or parallel to the plane, there is no intersection

      if (vN > 0 && vD >= 0) return null;

      // compute the distance from the ray’s origin to the intersection with the plane

      var t = (vD != 0) ? (-vN / vD) : 0;

      // only proceed if the distance is positive. a negative distance means the intersection point
      // lies "behind" the origin

      if (t <= 0) continue;

      // now categorized plane as front-facing or back-facing

      if (vD > 0) {
        //  plane faces away from the ray, so this plane is a back-face

        tFar = Math.min(t, tFar);
      } else {
        // front-face

        tNear = Math.max(t, tNear);
      }

      if (tNear > tFar) {
        // if tNear ever is greater than tFar, the ray must miss the convex hull

        return null;
      }
    }

    // evaluate intersection point

    // always try tNear first since its the closer intersection point

    if (tNear != -Math.Infinity) {
      ray.at(tNear, target);
    } else {
      ray.at(tFar, target);
    }

    return target;
  }

  intersectsRay(ray) {
    return this.intersectRay(ray, v1) != null;
  }

  makeEmpty() {
    this.faces = [];
    this.vertices = [];

    return this;
  }

  // Adds a vertex to the 'assigned' list of vertices and assigns it to the given face

  addVertexToFace2(vertex, face) {
    vertex.face = face;

    if (face.outside == null) {
      this.assigned.append(vertex);
    } else {
      this.assigned.insertBefore(face.outside, vertex);
    }

    face.outside = vertex;

    return this;
  }

  // Removes a vertex from the 'assigned' list of vertices and from the given face

  removeVertexFromFace2(vertex, face) {
    if (vertex == face.outside) {
      // fix face.outside link

      if (vertex.next != null && vertex.next.face == face) {
        // face has at least 2 outside vertices, move the 'outside' reference

        face.outside = vertex.next;
      } else {
        // vertex was the only outside vertex that face had

        face.outside = null;
      }
    }

    this.assigned.remove(vertex);

    return this;
  }

  // Removes all the visible vertices that a given face is able to see which are stored in the 'assigned' vertext list

  removeAllVerticesFromFace2(face) {
    if (face.outside != null) {
      // reference to the first and last vertex of this face

      var start = face.outside;
      var end = face.outside;

      while (end.next != null && end.next.face == face) {
        end = end.next;
      }

      this.assigned.removeSubList(start, end);

      // fix references

      start.prev = end.next = null;
      face.outside = null;

      return start;
    }
  }

  // Removes all the visible vertices that 'face' is able to see

  deleteFace2Vertices(face, absorbingFace2) {
    var faceVertices = this.removeAllVerticesFromFace2(face);

    if (faceVertices != null) {
      if (absorbingFace2 == null) {
        // mark the vertices to be reassigned to some other face

        this.unassigned.appendChain(faceVertices);
      } else {
        // if there's an absorbing face try to assign as many vertices as possible to it

        var vertex = faceVertices;

        do {
          // we need to buffer the subsequent vertex at this point because the 'vertex.next' reference
          // will be changed by upcoming method calls

          var nextVertex = vertex.next;

          var distance = absorbingFace2.distanceToPoint(vertex.point);

          // check if 'vertex' is able to see 'absorbingFace2'

          if (distance > this.tolerance) {
            this.addVertexToFace2(vertex, absorbingFace2);
          } else {
            this.unassigned.append(vertex);
          }

          // now assign next vertex

          vertex = nextVertex;
        } while (vertex != null);
      }
    }

    return this;
  }

  // Reassigns as many vertices as possible from the unassigned list to the new faces

  resolveUnassignedPoints(newFace2s) {
    if (this.unassigned.isEmpty() == false) {
      var vertex = this.unassigned.first();

      do {
        // buffer 'next' reference, see .deleteFace2Vertices()

        var nextVertex = vertex.next;

        var maxDistance = this.tolerance;

        var maxFace2 = null;

        for (var i = 0; i < newFace2s.length; i++) {
          var face = newFace2s[i];

          if (face.mark == Visible) {
            var distance = face.distanceToPoint(vertex.point);

            if (distance > maxDistance) {
              maxDistance = distance;
              maxFace2 = face;
            }

            if (maxDistance > 1000 * this.tolerance) break;
          }
        }

        // 'maxFace2' can be null e.g. if there are identical vertices

        if (maxFace2 != null) {
          this.addVertexToFace2(vertex, maxFace2);
        }

        vertex = nextVertex;
      } while (vertex != null);
    }

    return this;
  }

  // Computes the extremes of a simplex which will be the initial hull

  computeExtremes() {
    var min = new Vector3.init();
    var max = new Vector3.init();

    List<VertexNode> minVertices = [];
    List<VertexNode> maxVertices = [];

    var i, l, j;

    // initially assume that the first vertex is the min/max

    for (i = 0; i < 3; i++) {
      // minVertices[ i ] = maxVertices[ i ] = this.vertices[ 0 ];
      minVertices.add(this.vertices[0]);
      maxVertices.add(this.vertices[0]);
    }

    min.copy(this.vertices[0].point);
    max.copy(this.vertices[0].point);

    // compute the min/max vertex on all six directions

    for (var i = 0, l = this.vertices.length; i < l; i++) {
      var vertex = this.vertices[i];
      var point = vertex.point;

      // update the min coordinates

      for (j = 0; j < 3; j++) {
        if (point.getComponent(j) < min.getComponent(j)) {
          min.setComponent(j, point.getComponent(j));
          minVertices[j] = vertex;
        }
      }

      // update the max coordinates

      for (j = 0; j < 3; j++) {
        if (point.getComponent(j) > max.getComponent(j)) {
          max.setComponent(j, point.getComponent(j));
          maxVertices[j] = vertex;
        }
      }
    }

    // use min/max vectors to compute an optimal epsilon

    this.tolerance = 3 *
        Math.EPSILON *
        (Math.max(Math.abs(min.x), Math.abs(max.x)) +
            Math.max(Math.abs(min.y), Math.abs(max.y)) +
            Math.max(Math.abs(min.z), Math.abs(max.z)));

    return {"min": minVertices, "max": maxVertices};
  }

  // Computes the initial simplex assigning to its faces all the points
  // that are candidates to form part of the hull

  computeInitialHull() {
    var line3, plane, closestPoint;

    if (line3 == null) {
      line3 = new Line3(null, null);
      plane = new Plane(null, null);
      closestPoint = new Vector3.init();
    }

    var vertex, vertices = this.vertices;
    var extremes = this.computeExtremes();
    var min = extremes["min"];
    var max = extremes["max"];

    var v0, v1, v2, v3;
    var i, l, j;

    // 1. Find the two vertices 'v0' and 'v1' with the greatest 1d separation
    // (max.x - min.x)
    // (max.y - min.y)
    // (max.z - min.z)

    var distance;
    num maxDistance = 0;
    var index = 0;

    for (i = 0; i < 3; i++) {
      distance = max[i].point.getComponent(i) - min[i].point.getComponent(i);

      if (distance > maxDistance) {
        maxDistance = distance;
        index = i;
      }
    }

    v0 = min[index];
    v1 = max[index];

    // 2. The next vertex 'v2' is the one farthest to the line formed by 'v0' and 'v1'

    maxDistance = 0;
    line3.set(v0.point, v1.point);

    for (var i = 0, l = this.vertices.length; i < l; i++) {
      vertex = vertices[i];

      if (vertex != v0 && vertex != v1) {
        line3.closestPointToPoint(vertex.point, true, closestPoint);

        distance = closestPoint.distanceToSquared(vertex.point);

        if (distance > maxDistance) {
          maxDistance = distance;
          v2 = vertex;
        }
      }
    }

    // 3. The next vertex 'v3' is the one farthest to the plane 'v0', 'v1', 'v2'

    maxDistance = -1;
    plane.setFromCoplanarPoints(v0.point, v1.point, v2.point);

    for (var i = 0, l = this.vertices.length; i < l; i++) {
      vertex = vertices[i];

      if (vertex != v0 && vertex != v1 && vertex != v2) {
        distance = Math.abs(plane.distanceToPoint(vertex.point));

        if (distance > maxDistance) {
          maxDistance = distance;
          v3 = vertex;
        }
      }
    }

    List<Face2> _faces = [];

    if (plane.distanceToPoint(v3.point) < 0) {
      // the face is not able to see the point so 'plane.normal' is pointing outside the tetrahedron

      _faces.addAll([
        Face2.create(v0, v1, v2),
        Face2.create(v3, v1, v0),
        Face2.create(v3, v2, v1),
        Face2.create(v3, v0, v2)
      ]);

      // set the twin edge

      for (i = 0; i < 3; i++) {
        j = (i + 1) % 3;

        // join face[ i ] i > 0, with the first face

        _faces[i + 1].getEdge(2).setTwin(_faces[0].getEdge(j));

        // join face[ i ] with face[ i + 1 ], 1 <= i <= 3

        _faces[i + 1].getEdge(1).setTwin(_faces[j + 1].getEdge(0));
      }
    } else {
      // the face is able to see the point so 'plane.normal' is pointing inside the tetrahedron

      _faces.addAll([
        Face2.create(v0, v2, v1),
        Face2.create(v3, v0, v1),
        Face2.create(v3, v1, v2),
        Face2.create(v3, v2, v0)
      ]);

      // set the twin edge

      for (i = 0; i < 3; i++) {
        j = (i + 1) % 3;

        // join face[ i ] i > 0, with the first face

        _faces[i + 1].getEdge(2).setTwin(_faces[0].getEdge((3 - i) % 3));

        // join face[ i ] with face[ i + 1 ]

        _faces[i + 1].getEdge(0).setTwin(_faces[j + 1].getEdge(1));
      }
    }

    // the initial hull is the tetrahedron

    for (i = 0; i < 4; i++) {
      this.faces.add(_faces[i]);
    }

    // initial assignment of vertices to the faces of the tetrahedron

    for (var i = 0, l = vertices.length; i < l; i++) {
      vertex = vertices[i];

      if (vertex != v0 && vertex != v1 && vertex != v2 && vertex != v3) {
        maxDistance = this.tolerance;
        var maxFace2 = null;

        for (j = 0; j < 4; j++) {
          distance = this.faces[j].distanceToPoint(vertex.point);

          if (distance > maxDistance) {
            maxDistance = distance;
            maxFace2 = this.faces[j];
          }
        }

        if (maxFace2 != null) {
          this.addVertexToFace2(vertex, maxFace2);
        }
      }
    }

    return this;
  }

  // Removes inactive faces

  reindexFace2s() {
    List<Face2> activeFace2s = [];

    for (var i = 0; i < this.faces.length; i++) {
      var face = this.faces[i];

      if (face.mark == Visible) {
        activeFace2s.add(face);
      }
    }

    this.faces = activeFace2s;

    return this;
  }

  // Finds the next vertex to create faces with the current hull

  nextVertexToAdd() {
    // if the 'assigned' list of vertices is empty, no vertices are left. return with 'undefined'

    if (this.assigned.isEmpty() == false) {
      var eyeVertex;
      num maxDistance = 0;

      // grap the first available face and start with the first visible vertex of that face

      var eyeFace2 = this.assigned.first().face;
      var vertex = eyeFace2.outside;

      // now calculate the farthest vertex that face can see

      do {
        var distance = eyeFace2.distanceToPoint(vertex.point);

        if (distance > maxDistance) {
          maxDistance = distance;
          eyeVertex = vertex;
        }

        vertex = vertex.next;
      } while (vertex != null && vertex.face == eyeFace2);

      return eyeVertex;
    }
  }

  // Computes a chain of half edges in CCW order called the 'horizon'.
  // For an edge to be part of the horizon it must join a face that can see
  // 'eyePoint' and a face that cannot see 'eyePoint'.

  computeHorizon(eyePoint, crossEdge, face, horizon) {
    // moves face's vertices to the 'unassigned' vertex list

    this.deleteFace2Vertices(face, null);

    face.mark = Deleted;

    var edge;

    if (crossEdge == null) {
      edge = crossEdge = face.getEdge(0);
    } else {
      // start from the next edge since 'crossEdge' was already analyzed
      // (actually 'crossEdge.twin' was the edge who called this method recursively)

      edge = crossEdge.next;
    }

    do {
      var twinEdge = edge.twin;
      var oppositeFace2 = twinEdge.face;

      if (oppositeFace2.mark == Visible) {
        if (oppositeFace2.distanceToPoint(eyePoint) > this.tolerance) {
          // the opposite face can see the vertex, so proceed with next edge

          this.computeHorizon(eyePoint, twinEdge, oppositeFace2, horizon);
        } else {
          // the opposite face can't see the vertex, so this edge is part of the horizon

          horizon.add(edge);
        }
      }

      edge = edge.next;
    } while (edge != crossEdge);

    return this;
  }

  // Creates a face with the vertices 'eyeVertex.point', 'horizonEdge.tail' and 'horizonEdge.head' in CCW order

  addAdjoiningFace2(eyeVertex, horizonEdge) {
    // all the half edges are created in ccw order thus the face is always pointing outside the hull

    var face = Face2.create(eyeVertex, horizonEdge.tail(), horizonEdge.head());

    this.faces.add(face);

    // join face.getEdge( - 1 ) with the horizon's opposite edge face.getEdge( - 1 ) = face.getEdge( 2 )

    face.getEdge(-1).setTwin(horizonEdge.twin);

    return face.getEdge(0); // the half edge whose vertex is the eyeVertex
  }

  //  Adds 'horizon.length' faces to the hull, each face will be linked with the
  //  horizon opposite face and the face on the left/right

  addNewFace2s(eyeVertex, horizon) {
    this.newFace2s = [];

    var firstSideEdge = null;
    var previousSideEdge = null;

    for (var i = 0; i < horizon.length; i++) {
      var horizonEdge = horizon[i];

      // returns the right side edge

      var sideEdge = this.addAdjoiningFace2(eyeVertex, horizonEdge);

      if (firstSideEdge == null) {
        firstSideEdge = sideEdge;
      } else {
        // joins face.getEdge( 1 ) with previousFace2.getEdge( 0 )

        sideEdge.next.setTwin(previousSideEdge);
      }

      this.newFace2s.add(sideEdge.face);
      previousSideEdge = sideEdge;
    }

    // perform final join of new faces

    firstSideEdge.next.setTwin(previousSideEdge);

    return this;
  }

  // Adds a vertex to the hull

  addVertexToHull(eyeVertex) {
    var horizon = [];

    this.unassigned.clear();

    // remove 'eyeVertex' from 'eyeVertex.face' so that it can't be added to the 'unassigned' vertex list

    this.removeVertexFromFace2(eyeVertex, eyeVertex.face);

    this.computeHorizon(eyeVertex.point, null, eyeVertex.face, horizon);

    this.addNewFace2s(eyeVertex, horizon);

    // reassign 'unassigned' vertices to the new faces

    this.resolveUnassignedPoints(this.newFace2s);

    return this;
  }

  cleanup() {
    this.assigned.clear();
    this.unassigned.clear();
    this.newFace2s = [];

    return this;
  }

  compute() {
    var vertex;

    this.computeInitialHull();

    // add all available vertices gradually to the hull

    while ((vertex = this.nextVertexToAdd()) != null) {
      this.addVertexToHull(vertex);
    }

    this.reindexFace2s();

    this.cleanup();

    return this;
  }
}

class Face2 {
  Vector3 normal = Vector3.init();
  Vector3 midpoint = Vector3.init();
  num area = 0;

  num constant = 0; // signed distance from face to the origin
  VertexNode?
      outside; // reference to a vertex in a vertex list this face can see
  num mark = Visible;
  HalfEdge? edge;

  static create(a, b, c) {
    var face = new Face2();

    var e0 = new HalfEdge(a, face);
    var e1 = new HalfEdge(b, face);
    var e2 = new HalfEdge(c, face);

    // join edges

    e0.next = e2.prev = e1;
    e1.next = e0.prev = e2;
    e2.next = e1.prev = e0;

    // main half edge reference

    face.edge = e0;

    return face.compute();
  }

  getEdge(i) {
    var edge = this.edge;

    while (i > 0) {
      edge = edge!.next;
      i--;
    }

    while (i < 0) {
      edge = edge!.prev;
      i++;
    }

    return edge;
  }

  compute() {
    // todo test ???

    var triangle;

    if (triangle == null) triangle = new Triangle(null, null, null);

    var a = this.edge!.tail();
    var b = this.edge!.head();
    var c = this.edge!.next!.head();

    triangle.set(a.point, b.point, c.point);

    triangle.getNormal(this.normal);
    triangle.getMidpoint(this.midpoint);
    this.area = triangle.getArea();

    this.constant = this.normal.dot(this.midpoint);

    return this;
  }

  distanceToPoint(point) {
    return this.normal.dot(point) - this.constant;
  }
}

// Entity for a Doubly-Connected Edge List (DCEL).

class HalfEdge {
  VertexNode vertex;
  Face2 face;

  HalfEdge? prev;
  HalfEdge? next;
  HalfEdge? twin;

  HalfEdge(this.vertex, this.face) {}

  head() {
    return this.vertex;
  }

  tail() {
    return this.prev != null ? this.prev!.vertex : null;
  }

  length() {
    var head = this.head();
    var tail = this.tail();

    if (tail != null) {
      return tail.point.distanceTo(head.point);
    }

    return -1;
  }

  lengthSquared() {
    var head = this.head();
    var tail = this.tail();

    if (tail != null) {
      return tail.point.distanceToSquared(head.point);
    }

    return -1;
  }

  setTwin(edge) {
    this.twin = edge;
    edge.twin = this;

    return this;
  }
}

// A vertex as a double linked list node.

class VertexNode {
  Vector3 point;
  VertexNode? prev;
  VertexNode? next;
  Face2? face;
  // the face that is able to see this vertex

  VertexNode(this.point) {}
}

// A double linked list that contains vertex nodes.

class VertexList {
  VertexNode? head;
  VertexNode? tail;

  VertexList() {}

  first() {
    return this.head;
  }

  last() {
    return this.tail;
  }

  clear() {
    this.head = this.tail = null;

    return this;
  }

  // Inserts a vertex before the target vertex

  insertBefore(target, vertex) {
    vertex.prev = target.prev;
    vertex.next = target;

    if (vertex.prev == null) {
      this.head = vertex;
    } else {
      vertex.prev.next = vertex;
    }

    target.prev = vertex;

    return this;
  }

  // Inserts a vertex after the target vertex

  insertAfter(target, vertex) {
    vertex.prev = target;
    vertex.next = target.next;

    if (vertex.next == null) {
      this.tail = vertex;
    } else {
      vertex.next.prev = vertex;
    }

    target.next = vertex;

    return this;
  }

  // Appends a vertex to the end of the linked list

  append(vertex) {
    if (this.head == null) {
      this.head = vertex;
    } else {
      this.tail!.next = vertex;
    }

    vertex.prev = this.tail;
    vertex.next = null; // the tail has no subsequent vertex

    this.tail = vertex;

    return this;
  }

  // Appends a chain of vertices where 'vertex' is the head.

  appendChain(vertex) {
    if (this.head == null) {
      this.head = vertex;
    } else {
      this.tail!.next = vertex;
    }

    vertex.prev = this.tail;

    // ensure that the 'tail' reference points to the last vertex of the chain

    while (vertex.next != null) {
      vertex = vertex.next;
    }

    this.tail = vertex;

    return this;
  }

  // Removes a vertex from the linked list

  remove(vertex) {
    if (vertex.prev == null) {
      this.head = vertex.next;
    } else {
      vertex.prev.next = vertex.next;
    }

    if (vertex.next == null) {
      this.tail = vertex.prev;
    } else {
      vertex.next.prev = vertex.prev;
    }

    return this;
  }

  // Removes a list of vertices whose 'head' is 'a' and whose 'tail' is b

  removeSubList(a, b) {
    if (a.prev == null) {
      this.head = b.next;
    } else {
      a.prev.next = b.next;
    }

    if (b.next == null) {
      this.tail = a.prev;
    } else {
      b.next.prev = a.prev;
    }

    return this;
  }

  isEmpty() {
    return this.head == null;
  }
}
