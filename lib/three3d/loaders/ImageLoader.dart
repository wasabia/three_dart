part of three_loaders;

class ImageLoader extends Loader {
  @override
  bool flipY = true;

  ImageLoader(manager) : super(manager);

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

    final _resp = await ImageLoaderLoader.loadImage(url, flipY);
    onLoad(_resp);

    return _resp;
  }
}
