part of three_lights;

class PointLightShadow extends LightShadow {

  PointLightShadow() : super(PerspectiveCamera( fov: 90, aspect: 1, near: 0.5, far: 500 )) {

    this.isPointLightShadow = true;
    this.frameExtents = new Vector2( 4, 2 );

    this.viewportCount = 6;

    this.viewports = [
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

    this.cubeDirections = [
      new Vector3( 1, 0, 0 ), new Vector3( - 1, 0, 0 ), new Vector3( 0, 0, 1 ),
      new Vector3( 0, 0, - 1 ), new Vector3( 0, 1, 0 ), new Vector3( 0, - 1, 0 )
    ];

    this.cubeUps = [
      new Vector3( 0, 1, 0 ), new Vector3( 0, 1, 0 ), new Vector3( 0, 1, 0 ),
      new Vector3( 0, 1, 0 ), new Vector3( 0, 0, 1 ),	new Vector3( 0, 0, - 1 )
    ];

  }

  PointLightShadow.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    camera = Object3D.castJSON(json["camera"], rootJSON);
  }



  updateMatrices ( light, {int viewportIndex = 0} ) {

		var camera = this.camera;

			var shadowMatrix = this.matrix,
			lightPositionWorld = this.lightPositionWorld,
			lookTarget = this.lookTarget,
			projScreenMatrix = this.projScreenMatrix;

		lightPositionWorld.setFromMatrixPosition( light.matrixWorld );
		camera!.position.copy( lightPositionWorld );

		lookTarget.copy( camera.position );
		lookTarget.add( this.cubeDirections[ viewportIndex ] );
		camera.up.copy( this.cubeUps[ viewportIndex ] );
		camera.lookAt( lookTarget );
		camera.updateMatrixWorld(false);

		shadowMatrix.makeTranslation( - lightPositionWorld.x, - lightPositionWorld.y, - lightPositionWorld.z );

		projScreenMatrix.multiplyMatrices( camera.projectionMatrix, camera.matrixWorldInverse );
		this.frustum.setFromProjectionMatrix( projScreenMatrix );

	}

}

