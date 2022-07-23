part of three_renderers;

class WebGLMultipleRenderTargets extends WebGLRenderTarget {
  WebGLMultipleRenderTargets(
    int width,
    int height,
    int count, [
    WebGLRenderTargetOptions? options,
  ]) : super(width, height, options) {
    isWebGLMultipleRenderTargets = true;
    var texture = this.texture;
    this.texture = [];
    for (var i = 0; i < count; i++) {
      this.texture.add(texture.clone());
    }
  }

  @override
  WebGLMultipleRenderTargets setSize(int width, int height, [int depth = 1]) {
    if (this.width != width || this.height != height || this.depth != depth) {
      this.width = width;
      this.height = height;
      this.depth = depth;

      for (var i = 0, il = texture.length; i < il; i++) {
        texture[i].image.width = width;
        texture[i].image.height = height;
        texture[i].image.depth = depth;
      }

      dispose();
    }

    viewport.set(0, 0, width, height);
    scissor.set(0, 0, width, height);

    return this;
  }

  @override
  WebGLMultipleRenderTargets copy(WebGLRenderTarget source) {
    dispose();

    width = source.width;
    height = source.height;
    depth = source.depth;

    viewport.set(0, 0, width, height);
    scissor.set(0, 0, width, height);

    depthBuffer = source.depthBuffer;
    stencilBuffer = source.stencilBuffer;
    if ( source.depthTexture != null ) {
      this.depthTexture = source.depthTexture!.clone();
    }

    texture.length = 0;

    for (var i = 0, il = source.texture.length; i < il; i++) {
      texture[i] = source.texture[i].clone();
    }

    return this;
  }
}
