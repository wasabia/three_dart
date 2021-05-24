part of three_lights;


class DirectionalLightShadow extends LightShadow {

  bool isDirectionalLightShadow = true;

  DirectionalLightShadow() : super(OrthographicCamera( left: -5, right: 5, top: 5, bottom: -5, near: 0.5, far: 500 )) {

  }

  updateMatrices ( light, {int viewportIndex = 0} ) {
  
		super.updateMatrices( light, viewportIndex: viewportIndex );

	}

}



