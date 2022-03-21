part of three_textures;

class CanvasTexture extends Texture {
  bool isCanvasTexture = true;

  CanvasTexture(canvas, mapping, wrapS, wrapT, magFilter, minFilter, format,
      type, anisotropy)
      : super(canvas, mapping, wrapS, wrapT, magFilter, minFilter, format, type,
            anisotropy, null) {
    needsUpdate = true;
  }
}
