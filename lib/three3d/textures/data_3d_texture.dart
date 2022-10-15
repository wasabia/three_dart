
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/textures/texture.dart';
import 'package:three_dart/three3d/textures/image_element.dart';
import 'package:three_dart/three3d/constants.dart';

class Data3DTexture extends Texture {
  bool isDataTexture3D = true;

  Data3DTexture([NativeArray? data, int width = 1, int height = 1, int depth = 1])
      : super(null, null, null, null, null, null, null, null, null, null) {
    image = ImageElement(data: data, width: width, height: height, depth: depth);

    magFilter = LinearFilter;
    minFilter = LinearFilter;

    wrapR = ClampToEdgeWrapping;

    generateMipmaps = false;
    flipY = false;
    unpackAlignment = 1;
  }

  // We're going to add .setXXX() methods for setting properties later.
  // Users can still set in DataTexture3D directly.
  //
  //	const texture = new three.DataTexture3D( data, width, height, depth );
  // 	texture.anisotropy = 16;
  //
  // See #14839

}
