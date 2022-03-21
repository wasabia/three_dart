part of three_textures;

class OpenGLTexture extends Texture {
  dynamic openGLTexture;

  OpenGLTexture(this.openGLTexture, mapping, wrapS, wrapT, magFilter, minFilter,
      format, type, anisotropy)
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, null) {
    isOpenGLTexture = true;

    this.format = format ?? RGBAFormat;
    this.minFilter = minFilter ?? LinearFilter;
    this.magFilter = magFilter ?? LinearFilter;

    generateMipmaps = false;
    needsUpdate = true;
  }

  @override
  OpenGLTexture clone() {
    return OpenGLTexture(
            image, null, null, null, null, null, null, null, null)
      ..copy(this);
  }

  void update() {
    needsUpdate = true;
  }
}
