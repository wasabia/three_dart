import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:three_dart/three3d/loaders/cache.dart';
import 'package:three_dart/three3d/loaders/loader.dart';
import 'image_loader_for_app.dart' if (dart.library.js) 'image_loader_for_web.dart';

class ImageLoader extends Loader {
  ImageLoader(manager) : super(manager) {
    flipY = true;
  }

  @override
  loadAsync(url, [Function? onProgress]) async {
    var completer = Completer();

    load(url, (buffer) {
      completer.complete(buffer);
    }, onProgress, () {});

    return completer.future;
  }

  @override
  load(url, onLoad, [onProgress, onError]) async {
    if (path != "" && url is String) {
      url = path + url;
    }

    url = manager.resolveURL(url);

    var cached = Cache.get(url);

    if (cached != null) {
      manager.itemStart(url);

      Future.delayed(Duration(milliseconds: 0), () {
        onLoad(cached);

        manager.itemEnd(url);
      });

      return cached;
    }
    // Note - see conditional import - 'image_loader_for_app.dart' or 'image_loader_for_web.dart'
    final resp = await ImageLoaderLoader.loadImage(url, flipY);
    onLoad(resp);

    return resp;
  }
}
