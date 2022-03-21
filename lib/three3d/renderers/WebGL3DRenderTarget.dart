part of three_renderers;

class WebGL3DRenderTarget extends WebGLRenderTarget {

	WebGL3DRenderTarget( width, height, depth ) : super( width, height ) {
		this.depth = depth;
    texture = Data3DTexture(null, width, height, depth);
    texture.isRenderTargetTexture = true;
  }
}