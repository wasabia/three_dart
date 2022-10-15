
import 'package:three_dart/three3d/loaders/loader.dart';

class LoadingManager {
  bool isLoading = false;
  int itemsLoaded = 0;
  int itemsTotal = 0;
  List handlers = [];

  Function? urlModifier;
  Function? onStart;
  Function? onLoad;
  Function? onProgress;
  Function? onError;

  LoadingManager([onLoad, onProgress, onError]) {
    // Refer to #5689 for the reason why we don't set .onStart
    // in the constructor

    onStart = null;
    this.onLoad = onLoad;
    this.onProgress = onProgress;
    this.onError = onError;
  }

  void itemStart(String url) {
    itemsTotal++;

    if (isLoading == false) {
      if (onStart != null) {
        onStart!(url, itemsLoaded, itemsTotal);
      }
    }

    isLoading = true;
  }

  itemEnd(url) {
    itemsLoaded++;

    if (onProgress != null) {
      onProgress!(url, itemsLoaded, itemsTotal);
    }

    if (itemsLoaded == itemsTotal) {
      isLoading = false;

      if (onLoad != null) {
        onLoad!();
      }
    }
  }

  itemError(url) {
    if (onError != null) {
      onError!(url);
    }
  }

  resolveURL(url) {
    if (urlModifier != null) {
      return urlModifier!(url);
    }

    return url;
  }

  setURLModifier(transform) {
    urlModifier = transform;

    return this;
  }

  addHandler(RegExp regex, Loader loader) {
    handlers.addAll([regex, loader]);

    return this;
  }

  removeHandler(RegExp regex) {
    var index = handlers.indexOf(regex);

    if (index != -1) {
      handlers.removeRange(index, index + 1);
    }

    return this;
  }

  getHandler(file) {
    for (var i = 0, l = handlers.length; i < l; i += 2) {
      var regex = handlers[i];
      var loader = handlers[i + 1];

      if (regex.global) regex.lastIndex = 0; // see #17920

      if (regex.test(file)) {
        return loader;
      }
    }

    return null;
  }
}

var DefaultLoadingManager = LoadingManager(null, null, null);
