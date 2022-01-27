part of three_loaders;

class TextureLoader extends Loader {
  // 非web环境下加载纹理时翻转纹理
  // https://github.com/wasabia/three_dart/issues/10
  bool flipY = true;

  TextureLoader(manager) : super(manager) {}

  Future<Texture> loadAsync(url, [Function? onProgress]) async {
    var completer = Completer<Texture>();

    load(url, (texture) {
      completer.complete(texture);
    }, onProgress, () {});

    return completer.future;
  }

  load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    Texture texture;

    // if(kIsWeb) {
    texture =
        Texture(null, null, null, null, null, null, null, null, null, null);
    // } else {
    //   texture = DataTexture(null, null, null,null, null, null,null, null, null, null, null, null);
    // }

    var loader = new ImageLoader(this.manager);
    loader.setCrossOrigin(this.crossOrigin);
    loader.setPath(this.path);

    var completer = Completer<Texture>();
    loader.flipY = flipY;
    loader.load(url, (image) {
      // JPEGs can't have an alpha channel, so memory can be saved by storing them as RGB.
      bool isJPEG = false;
      if (url is String) {
        isJPEG = url.indexOf(".JPG") > 0 ||
            url.indexOf(".JPEG") > 0 ||
            url.indexOf(".jpg") > 0 ||
            url.indexOf(".jpeg") > 0 ||
            url.indexOf("data:image/jpeg") == 0;
      }

      ImageElement imageElement;

      // Web better way ???
      if (kIsWeb && !(image is Image)) {
        imageElement = ImageElement(
            url: url is Blob ? "" : url,
            data: image,
            width: image.width!,
            height: image.height!);
      } else {
        var _pixels = image.getBytes(format: isJPEG ? Format.rgb : Format.rgba);
        imageElement = ImageElement(
            url: url,
            data: Uint8Array.from(_pixels),
            width: image.width,
            height: image.height);
      }

      // print(" image.width: ${image.width} image.height: ${image.height} isJPEG: ${isJPEG} ");

      texture.image = imageElement;
      texture.format = isJPEG ? RGBFormat : RGBAFormat;
      texture.needsUpdate = true;

      if (onLoad != null) {
        onLoad(texture);
      }

      completer.complete(texture);
    }, onProgress, onError);

    return completer.future;
  }
}
