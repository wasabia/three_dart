part of three_loaders;

class ImageLoader extends Loader {
  bool flipY = true;

  ImageLoader(manager) : super(manager) {}

  loadAsync(url, [Function? onProgress]) async {
    var completer = Completer();

    load(url, (buffer) {
      completer.complete(buffer);
    }, onProgress, () {});

    return completer.future;
  }

  load(url, onLoad, [onProgress, onError]) async {
    if (this.path != "" && url is String) {
      url = this.path + url;
    }

    url = this.manager.resolveURL(url);

    var cached = Cache.get(url);

    if (cached != null) {
      this.manager.itemStart(url);

      Future.delayed(Duration(milliseconds: 0), () {
        if (onLoad != null) {
          onLoad(cached);
        }

        this.manager.itemEnd(url);
      });

      return cached;
    }

    final _resp = await ImageLoaderLoader.loadImage(url, flipY);
    if (onLoad != null) {
      onLoad(_resp);
    }

    return _resp;
  }
}
