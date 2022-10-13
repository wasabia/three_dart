part of three_textures;

class ImageElement {
  String? uuid;
  dynamic url;
  late int width;
  late int height;
  String? src;
  bool complete = true;

  // NativeArray or ImageElement from dart:html
  dynamic data;
  int depth = 1;

  ImageElement({
    this.url,
    this.data,
    this.width = 1,
    this.height = 1,
    this.depth = 1,
  });

  dispose() {
    data?.dispose();
  }
}
