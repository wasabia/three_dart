part of three_loaders;

// loader font from typeface json

class FontLoader extends Loader {
  FontLoader(manager) : super(manager);

  @override
  loadAsync(url, [Function? onProgress]) async {
    var loader = FileLoader(manager);
    loader.setPath(path);
    loader.responseType = responseType;
    loader.setRequestHeader(requestHeader);
    loader.setWithCredentials(withCredentials);
    var text = await loader.loadAsync(url);

    var jsonData = convert.jsonDecode(text);

    return parse(jsonData);
  }

  @override
  load(url, onLoad, [onProgress, onError]) {
    var scope = this;

    var loader = FileLoader(manager);
    loader.responseType = responseType;
    loader.setPath(path);
    loader.setRequestHeader(requestHeader);
    loader.setWithCredentials(scope.withCredentials);
    loader.load(url, (text) {
      var jsonData;

      jsonData = convert.jsonDecode(text);

      // try {
      // 	json = JSON.parse( text );
      // } catch ( e ) {
      // 	print( 'THREE.FontLoader: typeface.js support is being deprecated. Use typeface.json instead.' );
      // 	json = JSON.parse( text.substring( 65, text.length - 2 ) );
      // }

      var font = scope.parse(jsonData);

 onLoad(font);
    }, onProgress, onError);
  }

  @override
  parse(json, [String? path, Function? onLoad, Function? onError]) {
    return TTFFont(json);
  }
}
