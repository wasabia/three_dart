part of three_geometries;


class CylinderGeometry extends Geometry {

  String type = "CylinderGeometry";

	CylinderGeometry( radiusTop, radiusBottom, height, radialSegments, heightSegments, openEnded, thetaStart, thetaLength ) : super() {


		this.parameters = {
			"radiusTop": radiusTop,
			"radiusBottom": radiusBottom,
			"height": height,
			"radialSegments": radialSegments,
			"heightSegments": heightSegments,
			"openEnded": openEnded,
			"thetaStart": thetaStart,
			"thetaLength": thetaLength
		};

		this.fromBufferGeometry( 
      CylinderBufferGeometry( 
        radiusTop: radiusTop, 
        radiusBottom: radiusBottom, 
        height: height, 
        radialSegments: radialSegments, 
        heightSegments: heightSegments, 
        openEnded: openEnded, 
        thetaStart: thetaStart, 
        thetaLength: thetaLength 
      ) 
    );
		this.mergeVertices();

	}

}
