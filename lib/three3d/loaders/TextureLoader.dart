part of three_loaders;

class TextureLoader extends Loader {

  TextureLoader( manager ) : super(manager) {

  }

  Future<Texture> loadAsync(String url, Function? onProgress, {Function? imageDecoder}) async {
    var completer = Completer<Texture>();

    load(
      url, 
      (texture) {
        completer.complete(texture);
      }, 
      onProgress, 
      () {

      },
      imageDecoder: imageDecoder
    );

    return completer.future;
  }


  Future<Texture> load(String url, Function? onLoad, Function? onProgress, Function? onError, {Function? imageDecoder} ) {

    Texture texture;

    if(kIsWeb) {
      texture = Texture(null, null, null,null, null, null,null, null, null, null);
    } else {
      texture = DataTexture(null, null, null, null, null,null, null, null,null, null, null, null);
    }
    


		var loader = new ImageLoader( this.manager );
		loader.setCrossOrigin( this.crossOrigin );
		loader.setPath( this.path );

    var completer = Completer<Texture>();

		loader.load(url, ( image ) {

  
			texture.image = image;

			// JPEGs can't have an alpha channel, so memory can be saved by storing them as RGB.
			var isJPEG = url.indexOf(".JPG") > 0 || url.indexOf(".JPEG") > 0 || url.indexOf(".jpg") > 0 || url.indexOf(".jpeg") > 0 || url.indexOf("data:image/jpeg") == 0;

			texture.format = RGBAFormat;
			texture.needsUpdate = true;

      

			if ( onLoad != null ) {

				onLoad( texture );

			}

      completer.complete(texture);

		}, onProgress, onError, imageDecoder: imageDecoder );

		return completer.future;

	}

}



