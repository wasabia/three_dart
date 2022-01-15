part of three_textures;

class OpenGLTexture extends Texture {
  bool isOpenGLTexture = true;
  dynamic openGLTexture;

  OpenGLTexture(openGLTexture, mapping, wrapS, wrapT, magFilter, minFilter,
      format, type, anisotropy)
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, null) {
    this.openGLTexture = openGLTexture;

    this.format = format ?? RGBFormat;

    this.minFilter = minFilter ?? LinearFilter;
    this.magFilter = magFilter ?? LinearFilter;

    this.generateMipmaps = false;
    this.needsUpdate = true;
  }

  clone() {
    return OpenGLTexture(
            this.image, null, null, null, null, null, null, null, null)
        .copy(this);
  }

  update() {
    this.needsUpdate = true;
  }
}
