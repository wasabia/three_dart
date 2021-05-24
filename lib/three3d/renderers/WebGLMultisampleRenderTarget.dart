part of three_renderers;



class WebGLMultisampleRenderTarget extends WebGLRenderTarget{

  bool isWebGLMultisampleRenderTarget = true;
  int samples = 4;

  WebGLMultisampleRenderTarget( width, height, options ) : super(width, height, options) {
    
  }

  clone() {
    return WebGLMultisampleRenderTarget(this.width, this.height, this.options).copy(this);
  }

	copy( source ) {

		super.copy(source);

		this.samples = source.samples;

		return this;

	}

}
