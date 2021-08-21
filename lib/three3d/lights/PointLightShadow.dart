part of three_lights;

class PointLightShadow extends LightShadow {
  late List<Vector3> _cubeDirections;
  late List<Vector3> _cubeUps;

  PointLightShadow() : super(PerspectiveCamera( fov: 90, aspect: 1, near: 0.5, far: 500 )) {

    this.isPointLightShadow = true;
    this._frameExtents = new Vector2( 4, 2 );

    this._viewportCount = 6;

    this._viewports = [
      // These viewports map a cube-map onto a 2D texture with the
      // following orientation:
      //
      //  xzXZ
      //   y Y
      //
      // X - Positive x direction
      // x - Negative x direction
      // Y - Positive y direction
      // y - Negative y direction
      // Z - Positive z direction
      // z - Negative z direction

      // positive X
      new Vector4( 2, 1, 1, 1 ),
      // negative X
      new Vector4( 0, 1, 1, 1 ),
      // positive Z
      new Vector4( 3, 1, 1, 1 ),
      // negative Z
      new Vector4( 1, 1, 1, 1 ),
      // positive Y
      new Vector4( 3, 0, 1, 1 ),
      // negative Y
      new Vector4( 1, 0, 1, 1 )
    ];

    this._cubeDirections = [
      new Vector3( 1, 0, 0 ), new Vector3( - 1, 0, 0 ), new Vector3( 0, 0, 1 ),
      new Vector3( 0, 0, - 1 ), new Vector3( 0, 1, 0 ), new Vector3( 0, - 1, 0 )
    ];

    this._cubeUps = [
      new Vector3( 0, 1, 0 ), new Vector3( 0, 1, 0 ), new Vector3( 0, 1, 0 ),
      new Vector3( 0, 1, 0 ), new Vector3( 0, 0, 1 ),	new Vector3( 0, 0, - 1 )
    ];

  }

  PointLightShadow.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    camera = Object3D.castJSON(json["camera"], rootJSON);
  }

  updateMatrices( light, {viewportIndex = 0} ) {

		var camera = this.camera;
		var shadowMatrix = this.matrix;

		var far = light.distance ?? camera!.far;

		if ( far != camera!.far ) {

			camera.far = far;
			camera.updateProjectionMatrix();

		}

		_lightPositionWorld.setFromMatrixPosition( light.matrixWorld );
		camera.position.copy( _lightPositionWorld );

		_lookTarget.copy( camera.position );
		_lookTarget.add( this._cubeDirections[ viewportIndex ] );
		camera.up.copy( this._cubeUps[ viewportIndex ] );
		camera.lookAt( _lookTarget );
		camera.updateMatrixWorld(false);

		shadowMatrix.makeTranslation( - _lightPositionWorld.x, - _lightPositionWorld.y, - _lightPositionWorld.z );

		_projScreenMatrix.multiplyMatrices( camera.projectionMatrix, camera.matrixWorldInverse );
		this._frustum.setFromProjectionMatrix( _projScreenMatrix );

	}

}

