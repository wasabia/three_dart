part of three_textures;

class ImageElement {
  late int width;
  late int height;
  String? src;
  bool complete = true;
  dynamic? data;
  int depth = 1;

  ImageElement({dynamic? data, int width = 1, int height = 1, int depth = 1}) {
    this.data = data;
    this.width = width;
    this.height = height;
    this.depth = depth;
  }
}