
part of jsm_postprocessing;



class Pass {
  // if set to true, the pass is processed by the composer
	bool enabled = true;

	// if set to true, the pass indicates to swap read and write buffer after rendering
	bool needsSwap = true;

	// if set to true, the pass clears its buffer before rendering
	bool clear = false;

	// if set to true, the result of the pass is rendered to screen. This is set automatically by EffectComposer.
	bool renderToScreen = false;

  late Object3D scene;
  late Camera camera;
  late Map<String, dynamic> uniforms;
  late Material material;

  late FullScreenQuad fsQuad;

  Pass() { }

  setSize ( width, height ) {
    
  }

	render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {

		throw( 'THREE.Pass: .render() must be implemented in derived pass.' );

	}
	

}


// Helper for passes that need to fill the viewport with a single quad.

// Important: It's actually a hack to put FullScreenQuad into the Pass namespace. This is only
// done to make examples/js code work. Normally, FullScreenQuad should be exported
// from this module like Pass.

class FullScreenQuad {

	var camera = new OrthographicCamera( left: -1, right: 1, top: 1, bottom: -1, near: 0, far: 1 );
	var geometry = new PlaneBufferGeometry( width: 2, height: 2 );
  
  late Mesh _mesh;

  FullScreenQuad(material) {
    geometry.name = "FullScreenQuadGeometry";
    this._mesh = new Mesh( geometry, material );
  }

  get material => this._mesh.material;

  set material(value) {
    this._mesh.material = value;
  }

  render( renderer ) {
    renderer.render( this._mesh, camera );
  }

  dispose() {
    this._mesh.geometry.dispose();
  }

}


