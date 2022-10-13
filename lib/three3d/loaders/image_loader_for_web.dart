import 'dart:async';
import 'package:three_dart/extra/blob.dart';
import 'dart:html' as html;

class ImageLoaderLoader {
  // flipY 在web环境下 忽略
  static Future<html.ImageElement> loadImage(url, flipY, {Function? imageDecoder}) {
    var completer = Completer<html.ImageElement>();
    var imageDom = html.ImageElement();
    imageDom.crossOrigin = "";

    imageDom.onLoad.listen((e) {
      completer.complete(imageDom);
    });

    if (url is Blob) {
      var blob = html.Blob([url.data.buffer], url.options["type"]);
      imageDom.src = html.Url.createObjectUrl(blob);
    } else {
      // flutter web for assets need add assets TODO
      if (url.startsWith("assets")) {
        imageDom.src = "assets/" + url;
      } else {
        imageDom.src = url;
      }
    }

    return completer.future;
  }
}
