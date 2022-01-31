part of three_textures;

class DataTexture extends Texture {
  bool isDataTexture = true;

  DataTexture(data, int? width, int? height, format, type, mapping, wrapS,
      wrapT, magFilter, minFilter, anisotropy, encoding)
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, encoding) {
    this.image =
        ImageElement(data: data, width: width ?? 1, height: height ?? 1);

    this.magFilter = magFilter ?? NearestFilter;
    this.minFilter = minFilter ?? NearestFilter;

    this.generateMipmaps = false;
    this.flipY = false;
    this.unpackAlignment = 1;

  }
}
