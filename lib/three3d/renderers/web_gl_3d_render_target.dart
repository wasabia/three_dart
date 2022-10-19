import 'package:three_dart/three3d/renderers/web_gl_render_target.dart';
import 'package:three_dart/three3d/textures/index.dart';

class WebGL3DRenderTarget extends WebGLRenderTarget {
  WebGL3DRenderTarget(int width, int height, int depth) : super(width, height) {
    this.depth = depth;
    texture = Data3DTexture(null, width, height, depth);
    texture.isRenderTargetTexture = true;
  }
}
