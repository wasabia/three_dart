part of three_lights;


class LightShadow {

  Camera? camera;

  num bias = 0;
  num normalBias = 0;
  num radius = 1;

  Vector2 mapSize = Vector2( 512, 512 );

  RenderTarget? map;
  RenderTarget? mapPass;
  Matrix4 matrix = Matrix4();

  bool autoUpdate = true;
  bool needsUpdate = false;

  Frustum frustum = new Frustum(null,null,null,null,null,null);
  Vector2 frameExtents = new Vector2( 1, 1 );

  num viewportCount = 1;

  List<Vector4> viewports = [
    Vector4( 0, 0, 1, 1 )
  ];

  Matrix4 projScreenMatrix = Matrix4();
  Vector3 lightPositionWorld = Vector3.init();
  Vector3 lookTarget = Vector3.init();

  late num focus;
  bool isSpotLightShadow = false;
  bool isPointLightShadow = false;

  late List<Vector3> cubeDirections;
  late List<Vector3> cubeUps;

  LightShadow( this.camera ) {
  }

  LightShadow.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    
  }



	getViewportCount () {

		return this.viewportCount;

	}

	getFrustum () {

		return this.frustum;

	}

	updateMatrices ( light, {int viewportIndex = 0} ) {

		var shadowCamera = this.camera;
		var shadowMatrix = this.matrix;
		var projScreenMatrix = this.projScreenMatrix;
		var lookTarget = this.lookTarget;
		var lightPositionWorld = this.lightPositionWorld;


		lightPositionWorld.setFromMatrixPosition( light.matrixWorld );
		shadowCamera!.position.copy( lightPositionWorld );

		lookTarget.setFromMatrixPosition( light.target.matrixWorld );
		shadowCamera.lookAt( lookTarget);
		shadowCamera.updateMatrixWorld(false);

		projScreenMatrix.multiplyMatrices( shadowCamera.projectionMatrix, shadowCamera.matrixWorldInverse );
		this.frustum.setFromProjectionMatrix( projScreenMatrix );

		shadowMatrix.set(
			0.5, 0.0, 0.0, 0.5,
			0.0, 0.5, 0.0, 0.5,
			0.0, 0.0, 0.5, 0.5,
			0.0, 0.0, 0.0, 1.0
		);

		shadowMatrix.multiply( shadowCamera.projectionMatrix );
		shadowMatrix.multiply( shadowCamera.matrixWorldInverse );

	}

	getViewport ( viewportIndex ) {

		return this.viewports[ viewportIndex ];

	}

	getFrameExtents () {

		return this.frameExtents;

	}

	copy ( source ) {

		this.camera = source.camera.clone();

		this.bias = source.bias;
		this.radius = source.radius;

		this.mapSize.copy( source.mapSize );

		return this;

	}

	clone () {

		return LightShadow(null).copy( this );

	}

	toJSON () {

		Map<String, dynamic> object = {};

		if ( this.bias != 0 ) object["bias"] = this.bias;
		if ( this.normalBias != 0 ) object["normalBias"] = this.normalBias;
		if ( this.radius != 1 ) object["radius"] = this.radius;
		if ( this.mapSize.x != 512 || this.mapSize.y != 512 ) object["mapSize"] = this.mapSize.toArray();

		object["camera"] = this.camera!.toJSON()["object"];

		return object;

	}

}

