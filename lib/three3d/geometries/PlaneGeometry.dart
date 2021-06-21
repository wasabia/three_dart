part of three_geometries;


class PlaneGeometry extends Geometry {

  String type = "PlaneGeometry";

	PlaneGeometry( width, height, widthSegments, heightSegments ) : super() {

		this.parameters = {
			"width": width,
			"height": height,
			"widthSegments": widthSegments,
			"heightSegments": heightSegments
		};

		this.fromBufferGeometry( 
      PlaneBufferGeometry( 
        width: width, 
        height: height, 
        widthSegments: widthSegments, 
        heightSegments: heightSegments 
      ) 
    );
		this.mergeVertices();

	}

}
