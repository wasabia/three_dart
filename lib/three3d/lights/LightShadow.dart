part of three_lights;


class LightShadow {

  Camera? camera;

  num bias = 0;
  num normalBias = 0;
  num radius = 1;
  num blurSamples = 8;

  Vector2 mapSize = Vector2( 512, 512 );

  RenderTarget? map;
  RenderTarget? mapPass;
  Matrix4 matrix = Matrix4();

  bool autoUpdate = true;
  bool needsUpdate = false;

  Frustum _frustum = new Frustum(null,null,null,null,null,null);
  Vector2 _frameExtents = new Vector2( 1, 1 );

  num _viewportCount = 1;

  List<Vector4> _viewports = [
    Vector4( 0, 0, 1, 1 )
  ];

  Matrix4 _projScreenMatrix = Matrix4();
  Vector3 _lightPositionWorld = Vector3.init();
  Vector3 _lookTarget = Vector3.init();

  late num focus;
  bool isSpotLightShadow = false;
  bool isPointLightShadow = false;



  LightShadow( this.camera ) {
  }

  LightShadow.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    
  }



	getViewportCount () {

		return this._viewportCount;

	}

	getFrustum () {

		return this._frustum;

	}

	updateMatrices ( light, {int viewportIndex = 0} ) {

		var shadowCamera = this.camera;
		var shadowMatrix = this.matrix;

		var lightPositionWorld = this._lightPositionWorld;


		lightPositionWorld.setFromMatrixPosition( light.matrixWorld );
		shadowCamera!.position.copy( lightPositionWorld );

		_lookTarget.setFromMatrixPosition( light.target.matrixWorld );
		shadowCamera.lookAt( _lookTarget);
		shadowCamera.updateMatrixWorld(false);

		_projScreenMatrix.multiplyMatrices( shadowCamera.projectionMatrix, shadowCamera.matrixWorldInverse );
		this._frustum.setFromProjectionMatrix( _projScreenMatrix );

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

		return this._viewports[ viewportIndex ];

	}

	getFrameExtents () {

		return this._frameExtents;

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

  dispose() {

		if ( this.map != null ) {

			this.map!.dispose();

		}

		if ( this.mapPass != null ) {

			this.mapPass!.dispose();

		}

	}

}

