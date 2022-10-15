
import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/textures/image_element.dart';
import 'package:three_dart/three3d/constants.dart';

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
