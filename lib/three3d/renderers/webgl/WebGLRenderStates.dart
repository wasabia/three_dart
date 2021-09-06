part of three_webgl;

class WebGLRenderState {

  late WebGLLights lights;
  WebGLExtensions extensions;
  WebGLCapabilities capabilities;
  List<Light> lightsArray = [];
  List<Light> shadowsArray = [];


  WebGLRenderState( this.extensions, this.capabilities ) {

    lights = WebGLLights( extensions, capabilities );
  }

  RenderState get state {
    RenderState _state = RenderState(lights, lightsArray, shadowsArray);
    return _state;
  } 


	init() {

		lightsArray.length = 0;
		shadowsArray.length = 0;

	}

	pushLight( light ) {
		lightsArray.add( light );
	}

	pushShadow( shadowLight ) {


		shadowsArray.add( shadowLight );

	}

	setupLights(physicallyCorrectLights) {

		lights.setup( lightsArray, physicallyCorrectLights );

	}

	setupLightsView( camera ) {

		lights.setupView( lightsArray, camera );

	}

}

class WebGLRenderStates {

  WebGLExtensions extensions;
  WebGLCapabilities capabilities;
  var renderStates = WeakMap();


  WebGLRenderStates( this.extensions, this.capabilities ) {
  }


	WebGLRenderState get( scene, {int renderCallDepth = 0} ) {

		var renderState;

		if ( renderStates.has( scene ) == false ) {

			renderState = new WebGLRenderState( extensions, capabilities );
			renderStates.add( key: scene, value: [renderState] );


		} else {

			if ( renderCallDepth >= renderStates.get( scene ).length ) {

				renderState = WebGLRenderState( extensions, capabilities );
				renderStates.get( scene ).add( renderState );

			} else {

				renderState = renderStates.get( scene )[ renderCallDepth ];

			}

		}

		return renderState;

	}

	dispose() {

		renderStates = new WeakMap();

	}


}


class RenderState {
  WebGLLights lights;
  List<Light> lightsArray;
  List<Light> shadowsArray;


  RenderState(this.lights, this.lightsArray, this.shadowsArray) {
  }

}