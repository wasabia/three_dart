part of three_textures;

class CubeTexture extends Texture {

  bool isCubeTexture = true;

  CubeTexture( images, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding ) : super(images, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding) {
    images = images != null ? images : [];
    mapping = mapping != null ? mapping : CubeReflectionMapping;
    format = format != null ? format : RGBFormat;

    this.flipY = false;

  }

  get images {

		return this.image;

	}

	set images ( value ) {

		this.image = value;

	}


}
