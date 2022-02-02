part of three_loaders;

abstract class Loader {
  late LoadingManager manager;
  late String crossOrigin;
  late bool withCredentials;
  late String path;
  String? resourcePath;
  late Map<String, dynamic> requestHeader;
  String responseType = "text";
  late String mimeType;

  Loader([manager]) {
    this.manager = (manager != null) ? manager : DefaultLoadingManager;

    this.crossOrigin = 'anonymous';
    this.withCredentials = false;
    this.path = '';
    this.resourcePath = '';
    this.requestHeader = {};
  }

  load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    throw (" load need implement ............. ");
  }

  loadAsync(url) async {
    throw (" loadAsync need implement ............. ");
  }

  parse(json, [String? path, Function? onLoad, Function? onError]) {}

  setCrossOrigin(crossOrigin) {
    this.crossOrigin = crossOrigin;
    return this;
  }

  setWithCredentials(value) {
    this.withCredentials = value;
    return this;
  }

  setPath(path) {
    this.path = path;
    return this;
  }

  setResourcePath(resourcePath) {
    this.resourcePath = resourcePath;
    return this;
  }

  setRequestHeader(requestHeader) {
    this.requestHeader = requestHeader;
    return this;
  }
}
