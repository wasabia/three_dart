part of three_renderers;

class WebGLArrayRenderTarget extends WebGLRenderTarget {

	WebGLArrayRenderTarget( width, height, depth ) : super( width, height ) {

		this.depth = depth;

		this.texture = new DataArrayTexture( null, width, height, depth );

		this.texture.isRenderTargetTexture = true;

	}

}

