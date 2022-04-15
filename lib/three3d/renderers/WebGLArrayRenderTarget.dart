part of three_renderers;

class WebGLArrayRenderTarget extends WebGLRenderTarget {
  WebGLArrayRenderTarget(int width, int height, int depth)
      : super(width, height) {
		this.depth = depth;
    texture = DataArrayTexture(null, width, height, depth);
    texture.isRenderTargetTexture = true;
  }
}

