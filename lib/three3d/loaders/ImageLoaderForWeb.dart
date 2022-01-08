

import 'dart:async';
import 'package:three_dart/extra/Blob.dart';
import 'package:three_dart/three3d/textures/index.dart';
import 'dart:html' as html;

class ImageLoaderLoader {

  // flipY 在web环境下 忽略
  static Future<html.ImageElement> loadImage(url, flipY, {Function? imageDecoder}) {
    var completer = Completer<html.ImageElement>();
    var imageDom = html.ImageElement();

    print(" ImageLoaderLoader.web  loadImage url: ${url} ...");

    imageDom.onLoad.listen((e) {
      
      // ImageElement imageElement = ImageElement(url: url is Blob ? "" : url, data: imageDom, width: imageDom.width!, height: imageDom.height!);

      completer.complete(imageDom);
    });

    if(url is Blob) {
      var blob = new html.Blob( [url.data.buffer], url.options["mimeType"]);
			imageDom.src = html.Url.createObjectUrl( blob );
    } else {
      imageDom.src = url;
    }

    return completer.future;
  }

}

