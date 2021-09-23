part of three_lights;

class SpotLightShadow extends LightShadow {

  SpotLightShadow() : super( PerspectiveCamera( 50, 1, 0.5, 500 ) ) {
    	this.focus = 1;
      this.isSpotLightShadow = true;
  }


  updateMatrices ( light, {int viewportIndex = 0} ) {

		PerspectiveCamera camera = this.camera as PerspectiveCamera;

		var fov = MathUtils.RAD2DEG * 2 * light.angle * this.focus;
		var aspect = this.mapSize.width / this.mapSize.height;
		var far = light.distance ?? camera.far;

		if ( fov != camera.fov || aspect != camera.aspect || far != camera.far ) {

			camera.fov = fov;
			camera.aspect = aspect;
			camera.far = far;
			camera.updateProjectionMatrix();

		}

		super.updateMatrices( light, viewportIndex: viewportIndex );

	}

  copy( source ) {

		super.copy( source );

		this.focus = source.focus;

		return this;

	}

}

