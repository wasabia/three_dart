part of three_geometries;

class DodecahedronGeometry extends Geometry {

  String type = "DodecahedronGeometry";

	DodecahedronGeometry( {radius = 0, detail = 0} ) : super() {

		this.parameters = {
			"radius": radius,
			"detail": detail
		};

		this.fromBufferGeometry( DodecahedronBufferGeometry.create( radius: radius, detail: detail ) );
		this.mergeVertices();

	}

}

