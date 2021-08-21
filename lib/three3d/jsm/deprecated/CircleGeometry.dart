part of jsm_deprecated;

class CircleGeometry extends Geometry {

  String type = "CircleGeometry";

	CircleGeometry( radius, segments, thetaStart, thetaLength ) : super() {
		this.parameters = {
			"radius": radius,
			"segments": segments,
			"thetaStart": thetaStart,
			"thetaLength": thetaLength
		};

		this.fromBufferGeometry( 
      CircleBufferGeometry( 
        radius: radius, 
        segments: segments, 
        thetaStart: thetaStart,
        thetaLength: thetaLength 
      ) 
    );
		this.mergeVertices();

	}

}

