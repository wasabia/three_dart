part of three_loaders;



class ImageLoader extends Loader {

  ImageLoader( manager ) : super(manager) {

  }

  loadAsync(url, Function? onProgress, {Function? imageDecoder}) async {
    var completer = Completer();

    load(
      url, 
      (buffer) {
        completer.complete(buffer);
      }, 
      onProgress, 
      () {

      },
      imageDecoder: imageDecoder
    );

    return completer.future;
  }

  load ( url, onLoad, onProgress, onError, {Function? imageDecoder} ) async {

		if ( this.path != "" && url is String ) {
      url = this.path + url;
    }

		url = this.manager.resolveURL( url );

		var cached = Cache.get( url );

		if ( cached != null ) {

			this.manager.itemStart( url );

      Future.delayed(Duration(milliseconds: 0), () {
        if ( onLoad != null ) {
          onLoad( cached );
        }

				this.manager.itemEnd( url );
      });

			return cached;

		}


    final _resp = await ImageLoaderLoader.loadImage(url, imageDecoder: imageDecoder);
    if ( onLoad != null ) {
      onLoad(_resp);
    }

    return _resp;
	}


}

