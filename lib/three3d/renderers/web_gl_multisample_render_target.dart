
import 'package:three_dart/extra/console.dart';
import 'package:three_dart/three3d/renderers/web_gl_render_target.dart';

class WebGLMultisampleRenderTarget extends WebGLRenderTarget {
  @override
  int samples = 4;

  WebGLMultisampleRenderTarget(int width, int height,
      [WebGLRenderTargetOptions? options])
      : super(width, height, options) {
    isWebGLMultisampleRenderTarget = true;
    ignoreDepthForMultisampleCopy =
        this.options.ignoreDepth != undefined ? this.options.ignoreDepth : true;
    useRenderToTexture = (this.options.useRenderToTexture != undefined)
        ? this.options.useRenderToTexture
        : false;
    useRenderbuffer = useRenderToTexture == false;
  }

  @override
  WebGLMultisampleRenderTarget clone() {
    return WebGLMultisampleRenderTarget(width, height, options).copy(this);
  }

  @override
  WebGLMultisampleRenderTarget copy(source) {
    super.copy(source);

    samples = source.samples;
    useMultisampleRenderToTexture = source.useMultisampleRenderToTexture;
    useMultisampleRenderbuffer = source.useMultisampleRenderbuffer;

    return this;
  }
}
