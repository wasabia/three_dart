
import 'package:three_dart/three3d/textures/texture.dart';

class CanvasTexture extends Texture {
  bool isCanvasTexture = true;

  CanvasTexture(canvas, mapping, wrapS, wrapT, magFilter, minFilter, format,
      type, anisotropy)
      : super(canvas, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, null) {
    needsUpdate = true;
  }
}
