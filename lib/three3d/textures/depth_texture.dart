
import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/textures/image_element.dart';
import 'package:three_dart/three3d/constants.dart';

class DepthTexture extends Texture {
  DepthTexture(int width, int height, type, mapping, wrapS, wrapT, magFilter, minFilter, anisotropy, format)
      : super(null, mapping, wrapS, wrapT, magFilter, minFilter, format, type, anisotropy, null) {
    isDepthTexture = true;
    format = format ?? DepthFormat;

    if (format != DepthFormat && format != DepthStencilFormat) {
      throw ('DepthTexture format must be either three.DepthFormat or three.DepthStencilFormat');
    }

    if (type == null && format == DepthFormat) type = UnsignedIntType;
    if (type == null && format == DepthStencilFormat) type = UnsignedInt248Type;

    image = ImageElement(width: width, height: height);

    this.magFilter = magFilter ?? NearestFilter;
    this.minFilter = minFilter ?? NearestFilter;

    flipY = false;
    generateMipmaps = false;
  }

  // TODO
  @override
  DepthTexture clone() {
    return super.clone() as DepthTexture;
  }
}
