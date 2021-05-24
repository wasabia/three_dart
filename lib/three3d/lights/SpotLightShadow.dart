part of three_lights;

class SpotLightShadow extends LightShadow {

  SpotLightShadow() : super( PerspectiveCamera( fov: 50, aspect: 1, near: 0.5, far: 500 ) ) {
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


}

