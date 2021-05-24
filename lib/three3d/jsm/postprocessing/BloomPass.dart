part of jsm_postprocessing;


class BloomPass extends Pass {

  late WebGLRenderTarget renderTargetX;
	late WebGLRenderTarget renderTargetY;
  late Map<String, dynamic> copyUniforms;
  late ShaderMaterial materialCopy;
  late Map<String, dynamic> convolutionUniforms;
  late ShaderMaterial materialConvolution;

  BloomPass( strength, num? kernelSize, sigma, resolution ) : super() {
      
    strength = ( strength != null ) ? strength : 1;
    kernelSize = ( kernelSize != null ) ? kernelSize : 25;
    sigma = ( sigma != null ) ? sigma : 4.0;
    resolution = ( resolution != null ) ? resolution : 256;

    // render targets

    var pars = { "minFilter": LinearFilter, "magFilter": LinearFilter, "format": RGBAFormat };

    this.renderTargetX = new WebGLRenderTarget( resolution, resolution, WebGLRenderTargetOptions(pars) );
    this.renderTargetX.texture.name = 'BloomPass.x';
    this.renderTargetY = new WebGLRenderTarget( resolution, resolution, WebGLRenderTargetOptions(pars) );
    this.renderTargetY.texture.name = 'BloomPass.y';

    // copy material

    if ( CopyShader == null ) print( 'THREE.BloomPass relies on CopyShader' );

    var copyShader = CopyShader;

    this.copyUniforms = UniformsUtils.clone( copyShader["uniforms"] );

    this.copyUniforms[ 'opacity' ]["value"] = strength;

    this.materialCopy = new ShaderMaterial( {

      "uniforms": this.copyUniforms,
      "vertexShader": copyShader["vertexShader"],
      "fragmentShader": copyShader["fragmentShader"],
      "blending": AdditiveBlending,
      "transparent": true

    } );

    // convolution material

    if ( ConvolutionShader == null ) print( 'THREE.BloomPass relies on ConvolutionShader' );

    var convolutionShader = ConvolutionShader;

    this.convolutionUniforms = UniformsUtils.clone( convolutionShader["uniforms"] );

    this.convolutionUniforms[ 'uImageIncrement' ]["value"] = BloomPass.blurX;
    this.convolutionUniforms[ 'cKernel' ]["value"] = ConvolutionShader_buildKernel( sigma );

    this.materialConvolution = new ShaderMaterial( {

      "uniforms": this.convolutionUniforms,
      "vertexShader": convolutionShader["vertexShader"],
      "fragmentShader": convolutionShader["fragmentShader"],
      "defines": {
        'KERNEL_SIZE_FLOAT': toFixed(kernelSize, 1 ),
        'KERNEL_SIZE_INT': toFixed(kernelSize, 0 )
      }

    } );

    this.needsSwap = false;

    this.fsQuad = new FullScreenQuad( null );

  }

  render( renderer, writeBuffer, readBuffer, {num? deltaTime, bool? maskActive} ) {

		if ( maskActive == true ) renderer.state.buffers.stencil.setTest( false );

		// Render quad with blured scene into texture (convolution pass 1)

		this.fsQuad.material = this.materialConvolution;

		this.convolutionUniforms[ 'tDiffuse' ]["value"] = readBuffer.texture;
		this.convolutionUniforms[ 'uImageIncrement' ]["value"] = BloomPass.blurX;

		renderer.setRenderTarget( this.renderTargetX );
		renderer.clear(null, null, null);
		this.fsQuad.render( renderer );


		// Render quad with blured scene into texture (convolution pass 2)

		this.convolutionUniforms[ 'tDiffuse' ]["value"] = this.renderTargetX.texture;
		this.convolutionUniforms[ 'uImageIncrement' ]["value"] = BloomPass.blurY;

		renderer.setRenderTarget( this.renderTargetY );
		renderer.clear(null, null, null);
		this.fsQuad.render( renderer );

		// Render original scene with superimposed blur to texture

		this.fsQuad.material = this.materialCopy;

		this.copyUniforms[ 'tDiffuse' ]["value"] = this.renderTargetY.texture;

		if ( maskActive == true ) renderer.state.buffers.stencil.setTest( true );

		renderer.setRenderTarget( readBuffer );
		if ( this.clear ) renderer.clear(null, null, null);
		this.fsQuad.render( renderer );

	}


  static Vector2 blurX = new Vector2( 0.001953125, 0.0 );
  static Vector2 blurY = new Vector2( 0.0, 0.001953125 );

}






