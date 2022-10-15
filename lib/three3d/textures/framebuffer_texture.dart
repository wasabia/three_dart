
import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/constants.dart';

class FramebufferTexture extends Texture {
  FramebufferTexture(width, height, format)
      : super(null, null, null, null, null, null, format, null, null, null) {
    this.format = format;
    
    magFilter = NearestFilter;
    minFilter = NearestFilter;
    generateMipmaps = false;
    needsUpdate = true;
  }
}
