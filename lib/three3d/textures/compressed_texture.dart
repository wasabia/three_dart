import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/textures/image_element.dart';

class CompressedTexture extends Texture {
  CompressedTexture(
      mipmaps, width, height, format, type, mapping, wrapS, wrapT, magFilter, minFilter, anisotropy, encoding)
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, encoding) {
    // this.image = ImageDataInfo(null, width, height, null);
    isCompressedTexture = true;
    print(" CompressedTexture todo ============ ");

    image = ImageElement(width: width, height: height);

    this.mipmaps = mipmaps;

    // no flipping for cube textures
    // (also flipping doesn't work for compressed textures )

    flipY = false;

    // can't generate mipmaps for compressed textures
    // mips must be embedded in DDS files

    generateMipmaps = false;
  }
}
