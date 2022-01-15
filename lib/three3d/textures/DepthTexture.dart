part of three_textures;

class DepthTexture extends Texture {
  bool isDepthTexture = true;

  DepthTexture(width, height, type, mapping, wrapS, wrapT, magFilter, minFilter,
      anisotropy, format)
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, null) {
    format = format ?? DepthFormat;

    if (format != DepthFormat && format != DepthStencilFormat) {
      throw ('DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat');
    }

    if (type == null && format == DepthFormat) type = UnsignedShortType;
    if (type == null && format == DepthStencilFormat) type = UnsignedInt248Type;

    this.image = ImageElement(width: width, height: height);

    this.magFilter = magFilter != null ? magFilter : NearestFilter;
    this.minFilter = minFilter != null ? minFilter : NearestFilter;

    this.flipY = false;
    this.generateMipmaps = false;
  }
}
