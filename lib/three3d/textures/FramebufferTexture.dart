part of three_textures;

class FramebufferTexture extends Texture {
  FramebufferTexture(width, height, format)
      : super(null, null, null, null, null, null, format, null, null, null) {
    this.format = format;

    this.magFilter = NearestFilter;
    this.minFilter = NearestFilter;

    this.generateMipmaps = false;

    this.needsUpdate = true;
  }
}
