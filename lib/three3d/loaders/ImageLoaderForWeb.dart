

import 'dart:async';
import 'package:three_dart/extra/Blob.dart';
import 'package:three_dart/three3d/textures/index.dart';
import 'dart:html' as html;

class ImageLoaderLoader {

  static Future<ImageElement> loadImage(url, {Function? imageDecoder}) {
    var completer = Completer<ImageElement>();
    var imageDom = html.ImageElement();

    imageDom.onLoad.listen((e) {
      
      ImageElement imageElement = ImageElement(url: url is Blob ? "" : url, data: imageDom, width: imageDom.width!, height: imageDom.height!);

      completer.complete(imageElement);
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

