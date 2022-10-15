/*
 In options, we can specify:
 * Texture parameters for an auto-generated target texture
 * depthBuffer/stencilBuffer: Booleans to indicate if we should generate these buffers
*/
// import "package:universal_html/html.dart";


import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/event_dispatcher.dart';
import 'package:three_dart/three3d/math/vector4.dart';
import 'package:three_dart/three3d/textures/index.dart';



abstract class RenderTarget with EventDispatcher {
  late int width;
  late int height;
  int depth = 1;

  late bool depthBuffer;
  bool isWebGLCubeRenderTarget = false;
  bool isWebGLMultisampleRenderTarget = false;
  bool isWebGLMultipleRenderTargets = false;
  bool isXRRenderTarget = false;

  bool useMultisampleRenderToTexture = false;
  bool useMultisampleRenderbuffer = false;
  bool ignoreDepthForMultisampleCopy = false;
  bool hasExternalTextures = false;
  bool useRenderToTexture = false;
  bool useRenderbuffer = false;

  // Texture or List<Texture> ???
  dynamic texture;
  late Vector4 scissor;
  late bool scissorTest;
  late Vector4 viewport;

  late bool stencilBuffer;
  DepthTexture? depthTexture;

  late int _samples;

  int get samples => _samples;

  set samples(int value) {
    print("Important warn: make sure set samples before setRenderTarget  ");
    _samples = value;
  }

  WebGLRenderTarget clone() {
    throw ("RenderTarget clone need implemnt ");
  }

  void setSize(int width, int height, [int depth = 1]) {
    throw ("RenderTarget setSize need implemnt ");
  }

  bool is3D() {
    throw ("RenderTarget is3D need implemnt ");
  }

  void dispose() {
    throw ("RenderTarget dispose need implemnt ");
  }
}

class WebGLRenderTarget extends RenderTarget {
  bool isWebGLRenderTarget = true;
  late WebGLRenderTargetOptions options;

  WebGLRenderTarget(int width, int height, [WebGLRenderTargetOptions? options]) {
    this.width = width;
    this.height = height;
    scissor = Vector4(0, 0, width, height);
    scissorTest = false;

    viewport = Vector4(0, 0, width, height);

    this.options = options ?? WebGLRenderTargetOptions({});

    var image = ImageElement( width: width, height: height, depth: 1 );

    texture = Texture(
        image,
        this.options.mapping,
        this.options.wrapS,
        this.options.wrapT,
        this.options.magFilter,
        this.options.minFilter,
        this.options.format,
        this.options.type,
        this.options.anisotropy,
        this.options.encoding);
    texture.isRenderTargetTexture = true;
    texture.flipY = false;
    texture.generateMipmaps = this.options.generateMipmaps;
    texture.minFilter =
        this.options.minFilter != null ? this.options.minFilter! : LinearFilter;

    depthBuffer =
        this.options.depthBuffer != null ? this.options.depthBuffer! : true;
    stencilBuffer = this.options.stencilBuffer;
    depthTexture = this.options.depthTexture;

    ignoreDepthForMultisampleCopy = this.options.ignoreDepth;
    hasExternalTextures = false;
    useMultisampleRenderToTexture = false;
    useMultisampleRenderbuffer = false;

    _samples  =
        (options != null && options.samples != null) ? options.samples! : 0;
  }

  @override
  void setSize(int width, int height, [int depth = 1]) {
    if (this.width != width || this.height != height || this.depth != depth) {
      this.width = width;
      this.height = height;
      this.depth = depth;

      texture.image!.width = width;
      texture.image!.height = height;
      texture.image!.depth = depth;

      dispose();
    }

    viewport.set(0, 0, width, height);
    scissor.set(0, 0, width, height);
  }

  @override
  WebGLRenderTarget clone() {
    return WebGLRenderTarget(width, height, options).copy(this);
  }

  WebGLRenderTarget copy(WebGLRenderTarget source) {
    width = source.width;
    height = source.height;
    depth = source.depth;

    viewport.copy(source.viewport);
    scissor.copy(source.scissor);

    texture = source.texture.clone();
    texture.isRenderTargetTexture = true;

		texture.source = Source( source.texture.image );

    depthBuffer = source.depthBuffer;
    stencilBuffer = source.stencilBuffer;
    if (source.depthTexture != null) {
      depthTexture = source.depthTexture!.clone();
    }

    samples = source.samples;

    return this;
  }

  @override
  bool is3D() {
    return texture.isDataTexture3D || texture.isDataTexture2DArray;
  }

  @override
  void dispose() {
    dispatchEvent(Event({"type": "dispose"}));
  }
}

class WebGLRenderTargetOptions {
  int? wrapS;
  int? wrapT;
  int? magFilter;
  int? minFilter;
  int? format;
  int? type;
  int? anisotropy;
  bool? depthBuffer;
  int? mapping;

  bool stencilBuffer = false;
  bool generateMipmaps = false;
  DepthTexture? depthTexture;
  int? encoding;

  bool useMultisampleRenderToTexture = false;
  bool ignoreDepth = false;
  bool useRenderToTexture = false;

  int? samples;

  WebGLRenderTargetOptions(Map<String, dynamic> json) {
    if (json["wrapS"] != null) {
      wrapS = json["wrapS"];
    }
    if (json["wrapT"] != null) {
      wrapT = json["wrapT"];
    }
    if (json["magFilter"] != null) {
      magFilter = json["magFilter"];
    }
    if (json["minFilter"] != null) {
      minFilter = json["minFilter"];
    }
    if (json["format"] != null) {
      format = json["format"];
    }
    if (json["type"] != null) {
      type = json["type"];
    }
    if (json["anisotropy"] != null) {
      anisotropy = json["anisotropy"];
    }
    if (json["depthBuffer"] != null) {
      depthBuffer = json["depthBuffer"];
    }
    if (json["mapping"] != null) {
      mapping = json["mapping"];
    }
    if (json["generateMipmaps"] != null) {
      generateMipmaps = json["generateMipmaps"];
    }
    if (json["depthTexture"] != null) {
      depthTexture = json["depthTexture"];
    }
    if (json["encoding"] != null) {
      encoding = json["encoding"];
    }
    if (json["useMultisampleRenderToTexture"] != null) {
      useMultisampleRenderToTexture = json["useMultisampleRenderToTexture"];
    }
    if (json["ignoreDepth"] != null) {
      ignoreDepth = json["ignoreDepth"];
    }
    if (json["useRenderToTexture"] != null) {
      useRenderToTexture = json["useRenderToTexture"];
    }

    samples = json["samples"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "wrapS": wrapS,
      "wrapT": wrapT,
      "magFilter": magFilter,
      "minFilter": minFilter,
      "format": format,
      "type": type,
      "anisotropy": anisotropy,
      "depthBuffer": depthBuffer,
      "mapping": mapping,
      "stencilBuffer": stencilBuffer,
      "generateMipmaps": generateMipmaps,
      "depthTexture": depthTexture,
      "encoding": encoding,
      "useMultisampleRenderToTexture": useMultisampleRenderToTexture,
      "ignoreDepth": ignoreDepth,
      "useRenderToTexture": useRenderToTexture,
      "samples": samples
    };
  }
}
