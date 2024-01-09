import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:image/image.dart';
import 'package:three_dart/extra/blob.dart';
import 'package:three_dart/three3d/loaders/index.dart';
import 'package:three_dart/three3d/textures/index.dart';

class TextureLoader extends Loader {
  TextureLoader(manager) : super(manager);

  @override
  Future<Texture> loadAsync(url, [Function? onProgress]) async {
    var completer = Completer<Texture>();

    load(url, (texture) {
      completer.complete(texture);
    }, onProgress, () {});

    return completer.future;
  }

  @override
  load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    Texture texture;

    // if(kIsWeb) {
    texture = Texture(null, null, null, null, null, null, null, null, null, null);
    // } else {
    //   texture = DataTexture(null, null, null,null, null, null,null, null, null, null, null, null);
    // }

    var loader = ImageLoader(manager);
    loader.setCrossOrigin(crossOrigin);
    loader.setPath(path);

    var completer = Completer<Texture>();
    loader.flipY = flipY;
    loader.load(url, (image) {
      ImageElement imageElement;

      // Web better way ???
      if (kIsWeb && image is! Image) {
        imageElement = ImageElement(
            url: url is Blob ? "" : url, data: image, width: image.width!.toDouble(), height: image.height!.toDouble());
      } else {
        var pixels = image.getBytes(order: ChannelOrder.rgba);

        // print(" _pixels : ${_pixels.length} ");
        // print(" ------------------------------------------- ");
        imageElement = ImageElement(url: url, data: Uint8Array.from(pixels), width: image.width, height: image.height);
      }

      // print(" image.width: ${image.width} image.height: ${image.height} isJPEG: ${isJPEG} ");

      texture.image = imageElement;
      texture.needsUpdate = true;

      onLoad(texture);

      completer.complete(texture);
    }, onProgress, onError);

    return completer.future;
  }
}
