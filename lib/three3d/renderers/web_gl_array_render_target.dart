
import 'package:three_dart/three3d/renderers/web_gl_render_target.dart';
import 'package:three_dart/three3d/textures/index.dart';

class WebGLArrayRenderTarget extends WebGLRenderTarget {
  WebGLArrayRenderTarget(int width, int height, int depth)
      : super(width, height) {
		this.depth = depth;
    texture = DataArrayTexture(null, width, height, depth);
    texture.isRenderTargetTexture = true;
  }
}

