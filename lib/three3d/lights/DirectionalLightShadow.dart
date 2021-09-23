part of three_lights;


class DirectionalLightShadow extends LightShadow {

  bool isDirectionalLightShadow = true;

  DirectionalLightShadow() : super(OrthographicCamera( -5, 5, 5, -5, 0.5, 500 )) {

  }

  updateMatrices ( light, {int viewportIndex = 0} ) {
  
		super.updateMatrices( light, viewportIndex: viewportIndex );

	}

}



