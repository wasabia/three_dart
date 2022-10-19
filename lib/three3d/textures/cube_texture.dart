import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/constants.dart';

class CubeTexture extends Texture {
  bool isCubeTexture = true;

  CubeTexture([images, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding])
      : super(images, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding) {
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
