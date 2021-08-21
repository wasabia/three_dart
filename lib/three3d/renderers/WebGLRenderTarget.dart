/*
 In options, we can specify:
 * Texture parameters for an auto-generated target texture
 * depthBuffer/stencilBuffer: Booleans to indicate if we should generate these buffers
*/
// import "package:universal_html/html.dart";

part of three_renderers;


class RenderTarget with EventDispatcher {
  late int width;
  late int height;
  int depth = 1;
  
  late bool depthBuffer;
  bool isWebGLCubeRenderTarget = false;
  bool isWebGLMultisampleRenderTarget = false;
  bool isWebGLMultipleRenderTargets = false;

  // Texture or List<Texture> ???
  dynamic texture;
  late Vector4 scissor;
  late bool scissorTest;
  late Vector4 viewport;


  late bool stencilBuffer;
  DepthTexture? depthTexture;

  clone() {
    throw("RenderTarget clone need implemnt ");
  }

  setSize(width, height) {
    throw("RenderTarget setSize need implemnt ");
  }

  is3D() {
    throw("RenderTarget is3D need implemnt ");
  }

  dispose() {
    throw("RenderTarget dispose need implemnt ");
  }
}

class WebGLRenderTarget extends RenderTarget {
  
  bool isWebGLRenderTarget = true;
  late WebGLRenderTargetOptions options;
  

  WebGLRenderTarget(int width, int height, WebGLRenderTargetOptions? options) {
    this.width = width;
    this.height = height;
    this.scissor = Vector4(0, 0, width, height);
    this.scissorTest = false;

    this.viewport = Vector4(0, 0, width, height);

    this.options = options ?? WebGLRenderTargetOptions({});

    this.texture = Texture(null,
      this.options.mapping,
      this.options.wrapS,
      this.options.wrapT,
      this.options.magFilter,
      this.options.minFilter,
      this.options.format,
      this.options.type,
      this.options.anisotropy,
      this.options.encoding);

    ImageElement image = ImageElement(width: width, height: height);

    this.texture.image = image;


    this.texture.generateMipmaps = this.options.generateMipmaps != null ? this.options.generateMipmaps : false;
    this.texture.minFilter = this.options.minFilter != null ? this.options.minFilter! : LinearFilter;

    this.depthBuffer = this.options.depthBuffer != null ? this.options.depthBuffer! : true;
    this.stencilBuffer = this.options.stencilBuffer != null ? this.options.stencilBuffer : false;
    this.depthTexture = this.options.depthTexture != null ? this.options.depthTexture : null;
  }

  setTexture( texture ) {
    texture.image!.width = this.width;
    texture.image!.height = this.height;
    texture.image!.depth = this.depth;

		this.texture = texture;

	}

	setSize( width, height, {depth = 1} ) {

		if ( this.width != width || this.height != height || this.depth != depth ) {

			this.width = width;
			this.height = height;
			this.depth = depth;

			this.texture.image!.width = width;
			this.texture.image!.height = height;
			this.texture.image!.depth = depth;

			this.dispose();

		}

		this.viewport.set( 0, 0, width, height );
		this.scissor.set( 0, 0, width, height );

	}


  clone() {
    return WebGLRenderTarget(this.width, this.height, this.options).copy(this);
  }

  copy(source) {
    this.width = source.width;
    this.height = source.height;
    this.depth = source.depth;

    this.viewport.copy(source.viewport);
    this.scissor.copy(source.scissor);

    this.texture = source.texture.clone();

    this.depthBuffer = source.depthBuffer;
    this.stencilBuffer = source.stencilBuffer;
    this.depthTexture = source.depthTexture;

    return this;
  }

  is3D() {
		return this.texture.isDataTexture3D || this.texture.isDataTexture2DArray;
	}

  dispose() {
    print(" WebGLRenderTarget dispose() ......... ");
    this.dispatchEvent(Event({"type": "dispose"}));
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

  WebGLRenderTargetOptions(Map<String, dynamic> json) {
    if(json["wrapS"] != null) {
      wrapS = json["wrapS"];
    }
    if(json["wrapT"] != null) {
      wrapT = json["wrapT"];
    }
    if(json["magFilter"] != null) {
      magFilter = json["magFilter"];
    }
    if(json["minFilter"] != null) {
      minFilter = json["minFilter"];
    }
    if(json["format"] != null) {
      format = json["format"];
    }
    if(json["type"] != null) {
      type = json["type"];
    }
    if(json["anisotropy"] != null) {
      anisotropy = json["anisotropy"];
    }
    if(json["depthBuffer"] != null) {
      depthBuffer = json["depthBuffer"];
    }
    if(json["mapping"] != null) {
      mapping = json["mapping"];
    }
    if(json["generateMipmaps"] != null) {
      generateMipmaps = json["generateMipmaps"];
    }
    if(json["depthTexture"] != null) {
      depthTexture = json["depthTexture"];
    }
    if(json["encoding"] != null) {
      encoding = json["encoding"];
    }
  }

  toJSON() {
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
      "encoding": encoding
    };
  }

}