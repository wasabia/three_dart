part of three_textures;

class DataTexture extends Texture {
  DataTexture(
      [data,
      double? width,
      double? height,
      format,
      type,
      mapping,
      wrapS,
      wrapT,
      magFilter,
      minFilter,
      anisotropy,
      encoding])
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, encoding) {
    image = ImageElement(data: data, width: width ?? 1, height: height ?? 1);

    generateMipmaps = false;
    flipY = false;
    unpackAlignment = 1;
  }
}
