
import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/textures/image_element.dart';

class DataTexture extends Texture {
  DataTexture(
      [data,
      int? width,
      int? height,
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
