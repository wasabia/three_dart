import 'package:three_dart/three3d/loaders/loading_manager.dart';

abstract class Loader {
  late LoadingManager manager;
  late String crossOrigin;
  late bool withCredentials;
  late String path;
  String? resourcePath;
  late Map<String, dynamic> requestHeader;
  String responseType = "text";
  late String mimeType;

  // 加载纹理时  是否需要垂直翻转
  bool flipY = false;

  Loader([manager]) {
    this.manager = (manager != null) ? manager : defaultLoadingManager;

    crossOrigin = 'anonymous';
    withCredentials = false;
    path = '';
    resourcePath = '';
    requestHeader = {};
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
    withCredentials = value;
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
