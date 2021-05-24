part of three_textures;

class OpenGLTexture extends Texture {


  bool isOpenGLTexture = true;
  dynamic openGLTexture;

  OpenGLTexture( openGLTexture, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy ) : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, null) {
    this.openGLTexture = openGLTexture;

    this.format = format != null ? format : RGBFormat;

    this.minFilter = minFilter != null ? minFilter : LinearFilter;
    this.magFilter = magFilter != null ? magFilter : LinearFilter;

    this.generateMipmaps = false;
    this.needsUpdate = true;
  }


  clone () {

		return OpenGLTexture( this.image, null, null, null, null, null, null,null,null ).copy( this );

	}


}
