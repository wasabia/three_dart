part of three_textures;

class DataArrayTexture extends Texture {
  bool isDataTexture2DArray = true;
  late int wrapR;

  DataArrayTexture(data, [int width = 1, int height = 1, int depth = 1])
      : super(null, null, null, null, null, null, null, null, null, null) {
    this.image =
        ImageElement(data: data, width: width, height: height, depth: depth);

    this.magFilter = NearestFilter;
    this.minFilter = NearestFilter;

    this.wrapR = ClampToEdgeWrapping;

    this.generateMipmaps = false;
    this.flipY = false;
    this.unpackAlignment = 1;
  }
}
