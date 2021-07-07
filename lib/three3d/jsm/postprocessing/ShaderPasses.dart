part of jsm_postprocessing;

class ShaderPasses extends Pass {

  late dynamic textureID;
  late Map<String, dynamic> uniforms;
  late Material material;
  late FullScreenQuad fsQuad;
  late Color oldClearColor;
	late num oldClearAlpha;
  late bool oldAutoClear;
  late Color clearColor;
  List<dynamic>? passes;
  late Map<int, WebGLRenderTarget> renderTargetsPass;

  late int resx;
  late int resy;

  ShaderPasses( shader, textureID ) : super() {

    this.textureID = ( textureID != null ) ? textureID : 'tDiffuse';

    this.uniforms = UniformsUtils.clone( shader["uniforms"] );
    passes = shader["passes"];

    this.clearColor = new Color( 0, 0, 0 );
    this.oldClearColor = Color.fromHex(0xffffff);

    Map<String, dynamic> _defines = {};
    _defines.addAll(shader["defines"] ?? {});
    this.material = new ShaderMaterial( {
      "defines": _defines,
      "uniforms": this.uniforms,
      "vertexShader": shader["vertexShader"],
      "fragmentShader": shader["fragmentShader"]
    } );

    this.fsQuad = new FullScreenQuad( this.material );
    this.renderTargetsPass = {};    
  }


  render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {
		renderer.getClearColor( this.oldClearColor );
		this.oldClearAlpha = renderer.getClearAlpha();
		this.oldAutoClear = renderer.autoClear;
		renderer.autoClear = false;

    renderer.setClearColor( this.clearColor, alpha: 0.0 );

		if ( maskActive == true ) renderer.state.buffers.stencil.setTest( false );

		if ( this.uniforms[ this.textureID ] != null ) {
			this.uniforms[ this.textureID ]["value"] = readBuffer.texture;
		}



    if(passes != null) {
      int i = 0;
      int _lastPass = passes!.length - 1;
      WebGLRenderTarget? lastRenderTarget;
      for(Map<String, dynamic> _pass in passes!) { 
        this.material.uniforms!["acPass"] = {"value": i};
        if(lastRenderTarget != null) {
          this.material.uniforms!["acPassTexture"] = {"value": lastRenderTarget.texture};
        }

        this.material.needsUpdate = true;

        if(this.renderTargetsPass[i] == null) {
          var pars = WebGLRenderTargetOptions(
            { "minFilter": LinearFilter, "magFilter": LinearFilter, "format": RGBAFormat }
          );
          var renderTargetPass = new WebGLRenderTarget( readBuffer.width, readBuffer.height, pars );
          renderTargetPass.texture.name = 'renderTargetPass' + i.toString();
          renderTargetPass.texture.generateMipmaps = false;
          this.renderTargetsPass[i] = renderTargetPass;
        }

        if(i >= _lastPass) {
          if ( this.renderToScreen ) {
            renderPass(renderer, this.material, null, null, null, this.clear);
          } else {
            renderPass(renderer, this.material, writeBuffer, null, null, this.clear);
          }
        } else {
          renderPass(renderer, this.material, this.renderTargetsPass[i], null, null, this.clear);
        }

        lastRenderTarget = this.renderTargetsPass[i];
      
        i = i + 1;
      }

    } else {

      if ( this.renderToScreen ) {
        renderPass(renderer, this.material, null, null, null, this.clear);
      } else {
        renderPass(renderer, this.material, writeBuffer, null, null, this.clear);
      }

    }

		

	}

  renderPass( renderer, passMaterial, renderTarget, clearColor, clearAlpha, clear ) {

    // print("renderPass passMaterial: ${passMaterial} renderTarget: ${renderTarget}  ");
    // print(passMaterial.uniforms);

    // setup pass state
		renderer.autoClear = false;

		renderer.setRenderTarget( renderTarget );

		
		if ( clearColor != null ) {
			renderer.setClearColor( clearColor );
			renderer.setClearAlpha( clearAlpha ?? 0.0 );
			renderer.clear();
		}

    // TODO: Avoid using autoClear properties, see https://github.com/mrdoob/three.js/pull/15571#issuecomment-465669600
    if ( clear ) renderer.clear( renderer.autoClearColor, renderer.autoClearDepth, renderer.autoClearStencil );

		this.fsQuad.material = passMaterial;
		this.fsQuad.render( renderer );

		// restore original state
		renderer.autoClear = oldAutoClear;
		renderer.setClearColor( this.oldClearColor );
		renderer.setClearAlpha( oldClearAlpha );

	}


}
