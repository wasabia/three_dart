part of jsm_postprocessing;


class AfterimagePass extends Pass {

  late Map<String, dynamic> shader;
  late ShaderMaterial shaderMaterial;
  late WebGLRenderTarget textureComp;
  late WebGLRenderTarget textureOld;
  late FullScreenQuad compFsQuad;
  late FullScreenQuad copyFsQuad;

  AfterimagePass( damp, bufferSizeMap ) : super() {

    this.shader = AfterimageShader;

    this.uniforms = UniformsUtils.clone( this.shader["uniforms"] );

    this.uniforms[ 'damp' ]["value"] = damp != null ? damp : 0.96;

    this.textureComp = new WebGLRenderTarget( bufferSizeMap["width"], bufferSizeMap["height"], 
      WebGLRenderTargetOptions({
        "minFilter": LinearFilter,
        "magFilter": NearestFilter,
        "format": RGBAFormat
      })
    );

    this.textureOld = new WebGLRenderTarget( 
      bufferSizeMap["width"], bufferSizeMap["height"], 
      WebGLRenderTargetOptions({
        "minFilter": LinearFilter,
        "magFilter": NearestFilter,
        "format": RGBAFormat
      }) 
      );

    this.shaderMaterial = new ShaderMaterial( {
      "uniforms": this.uniforms,
      "vertexShader": this.shader["vertexShader"],
      "fragmentShader": this.shader["fragmentShader"]
    } );

    this.compFsQuad = new FullScreenQuad( this.shaderMaterial );

    var material = new MeshBasicMaterial();
    this.copyFsQuad = new FullScreenQuad( material );
  }

  render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {

		this.uniforms[ 'tOld' ]["value"] = this.textureOld.texture;
		this.uniforms[ 'tNew' ]["value"] = readBuffer.texture;

		renderer.setRenderTarget( this.textureComp );
		this.compFsQuad.render( renderer );

		this.copyFsQuad.material.map = this.textureComp.texture;

		if ( this.renderToScreen ) {

			renderer.setRenderTarget( null );
			this.copyFsQuad.render( renderer );

		} else {

			renderer.setRenderTarget( writeBuffer );

			if ( this.clear ) renderer.clear(true, true, true);

			this.copyFsQuad.render( renderer );

		}

		// Swap buffers.
		var temp = this.textureOld;
		this.textureOld = this.textureComp;
		this.textureComp = temp;
		// Now textureOld contains the latest image, ready for the next frame.

	}

	setSize( width, height ) {
		this.textureComp.setSize( width, height );
		this.textureOld.setSize( width, height );
	}

}


