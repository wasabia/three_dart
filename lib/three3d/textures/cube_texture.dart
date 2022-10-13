part of three_textures;

class CubeTexture extends Texture {
  bool isCubeTexture = true;

  CubeTexture([images, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
      anisotropy, encoding])
      : super(images, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, encoding) {
    images = images ?? [];
    mapping = mapping ?? CubeReflectionMapping;

    flipY = false;
  }

  get images {
    return image;
  }

  set images(value) {
    image = value;
  }
}
