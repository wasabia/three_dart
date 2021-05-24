

import 'dart:async';
import 'package:three_dart/three3d/textures/index.dart';
import 'package:universal_html/html.dart' as html;

class ImageLoaderLoader {

  static Future<ImageElement> loadImage(String url) {
    var completer = Completer<ImageElement>();
    var imageDom = html.ImageElement();
    imageDom.onLoad.listen((e) {

      ImageElement imageElement = ImageElement(data: imageDom, width: imageDom.width!, height: imageDom.height!);

      completer.complete(imageElement);
    });
    imageDom.src = url;

    return completer.future;
  }

}

