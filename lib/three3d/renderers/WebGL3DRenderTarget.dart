part of three_renderers;

class WebGL3DRenderTarget extends WebGLRenderTarget {
  WebGL3DRenderTarget(double width, double height, int depth)
      : super(width, height) {
    this.depth = depth;
    texture = Data3DTexture(null, width, height, depth);
    texture.isRenderTargetTexture = true;
  }
}
