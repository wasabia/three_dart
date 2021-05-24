
// ConvexGeometry
part of three_geometries;

class ConvexGeometry extends Geometry {

  String type = "ConvexGeometry";

	ConvexGeometry(points) : super() {
    this.fromBufferGeometry( ConvexBufferGeometry( points ) );
	  this.mergeVertices();
  }



}

