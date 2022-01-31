part of three_renderers;

class WebGLMultisampleRenderTarget extends WebGLRenderTarget {
  bool isWebGLMultisampleRenderTarget = true;
  int samples = 4;
  

  WebGLMultisampleRenderTarget(width, height, [WebGLRenderTargetOptions? options])
      : super(width, height, options) {
    
    this.ignoreDepthForMultisampleCopy = this.options.ignoreDepth != undefined ? this.options.ignoreDepth : true;
		this.useRenderToTexture = ( this.options.useRenderToTexture != undefined ) ? this.options.useRenderToTexture : false;
		this.useRenderbuffer = this.useRenderToTexture == false;
  }

  clone() {
    return WebGLMultisampleRenderTarget(this.width, this.height, this.options)
        .copy(this);
  }

  copy(source) {
    super.copy(source);

    this.samples = source.samples;
    this.useMultisampleRenderToTexture = source.useMultisampleRenderToTexture;
		this.useMultisampleRenderbuffer = source.useMultisampleRenderbuffer;

    return this;
  }
}
