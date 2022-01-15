part of three_loaders;

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

    this.onStart = null;
    this.onLoad = onLoad;
    this.onProgress = onProgress;
    this.onError = onError;
  }

  itemStart(String url) {
    itemsTotal++;

    if (isLoading == false) {
      if (this.onStart != null) {
        this.onStart!(url, itemsLoaded, itemsTotal);
      }
    }

    isLoading = true;
  }

  itemEnd(url) {
    itemsLoaded++;

    if (this.onProgress != null) {
      this.onProgress!(url, itemsLoaded, itemsTotal);
    }

    if (itemsLoaded == itemsTotal) {
      isLoading = false;

      if (this.onLoad != null) {
        this.onLoad!();
      }
    }
  }

  itemError(url) {
    if (this.onError != null) {
      this.onError!(url);
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

var DefaultLoadingManager = new LoadingManager(null, null, null);
