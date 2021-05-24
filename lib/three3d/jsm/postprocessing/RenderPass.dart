part of jsm_postprocessing;


class RenderPass extends Pass {

  bool clearDepth = false;
  num clearAlpha = 0;
  Color? clearColor;
  Material? overrideMaterial;
  Color _oldClearColor = Color(1,1,1);

  RenderPass( scene, camera, Material? overrideMaterial, Color? clearColor, num? clearAlpha ) : super() {
    this.scene = scene;
    this.camera = camera;

    this.overrideMaterial = overrideMaterial;

    this.clearColor = clearColor;
    this.clearAlpha = clearAlpha ?? 0;

    this.clear = true;
    this.needsSwap = false;
  }

  render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {

		var oldAutoClear = renderer.autoClear;
		renderer.autoClear = false;

		var oldClearAlpha, oldOverrideMaterial;

		if ( this.overrideMaterial != null ) {

			oldOverrideMaterial = this.scene.overrideMaterial;

			this.scene.overrideMaterial = this.overrideMaterial;

		}

		if ( this.clearColor != null ) {

			renderer.getClearColor( this._oldClearColor );
			oldClearAlpha = renderer.getClearAlpha();

			renderer.setClearColor( this.clearColor, alpha: this.clearAlpha );

		}

		if ( this.clearDepth ) {

			renderer.clearDepth();

		}

		renderer.setRenderTarget( this.renderToScreen ? null : readBuffer );

		// TODO: Avoid using autoClear properties, see https://github.com/mrdoob/three.js/pull/15571#issuecomment-465669600
		if ( this.clear ) renderer.clear( renderer.autoClearColor, renderer.autoClearDepth, renderer.autoClearStencil );
		renderer.render( this.scene, this.camera );

		if ( this.clearColor != null ) {

			renderer.setClearColor( this._oldClearColor, alpha: oldClearAlpha );

		}

		if ( this.overrideMaterial != null ) {

			this.scene.overrideMaterial = oldOverrideMaterial;

		}

		renderer.autoClear = oldAutoClear;

	}

}

