part of three_textures;

class CubeTexture extends Texture {

  late bool needsFlipEnvMap;
  bool isCubeTexture = true;

  CubeTexture( images, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding ) : super(images, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding) {
    images = images != null ? images : [];
    mapping = mapping != null ? mapping : CubeReflectionMapping;
    format = format != null ? format : RGBFormat;

    this.flipY = false;

    this.needsFlipEnvMap = true;

  }

	

	// Why CubeTexture._needsFlipEnvMap is necessary:
	//
	// By convention -- likely based on the RenderMan spec from the 1990's -- cube maps are specified by WebGL (and three.js)
	// in a coordinate system in which positive-x is to the right when looking up the positive-z axis -- in other words,
	// in a left-handed coordinate system. By continuing this convention, preexisting cube maps continued to render correctly.

	// three.js uses a right-handed coordinate system. So environment maps used in three.js appear to have px and nx swapped
	// and the flag _needsFlipEnvMap controls this conversion. The flip is not required (and thus _needsFlipEnvMap is set to false)
	// when using WebGLCubeRenderTarget.texture as a cube texture.


  get images {

		return this.image;

	}

	set images ( value ) {

		this.image = value;

	}


}
