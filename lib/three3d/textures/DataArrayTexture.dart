part of three_textures;

class DataArrayTexture extends Texture {
  bool isDataTexture2DArray = true;

  DataArrayTexture(data, [int width = 1, int height = 1, int depth = 1])
      : super(null, null, null, null, null, null, null, null, null, null) {
    image =
        ImageElement(data: data, width: width, height: height, depth: depth);

    magFilter = NearestFilter;
    minFilter = NearestFilter;

    wrapR = ClampToEdgeWrapping;

    generateMipmaps = false;
    flipY = false;
    unpackAlignment = 1;
  }
}
