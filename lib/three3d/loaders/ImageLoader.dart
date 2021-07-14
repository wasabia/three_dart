part of three_loaders;



class ImageLoader extends Loader {

  ImageLoader( manager ) : super(manager) {

  }

  loadAsync(String url, Function? onProgress, {Function? imageDecoder}) async {
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

  load ( String url, onLoad, onProgress, onError, {Function? imageDecoder} ) async {

		if ( this.path != null ) {
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


    // var completer = Completer<ImageElement>();
    // var element = ImageElement();
    // element.onLoad.listen((e) {
    //   if ( onLoad != null ) {
    //     onLoad(element);
    //   }
      
    //   completer.complete(element);
    // });
    // element.src = url;
    // return completer.future;


		// ImageElement image = ImageElement();
		// Function onImageLoad = (event) {

		// 	// image.removeEventListener( 'load', onImageLoad, false );
		// 	// image.removeEventListener( 'error', onImageError, false );

		// 	Cache.add( url, this );

		// 	if ( onLoad != null ) {
    //     onLoad( image );
    //   }

    //   this.manager.itemEnd( url );

		// };

		// Function onImageError = ( event ) {

		// 	// image.removeEventListener( 'load', onImageLoad, false );
		// 	// image.removeEventListener( 'error', onImageError, false );

		// 	if ( onError != null ) {
    //     onError( event );
    //   }

		// 	this.manager.itemError( url );
		// 	this.manager.itemEnd( url );

		// };

		// image.addEventListener( 'load', onImageLoad, false );
		// image.addEventListener( 'error', onImageError, false );

		// if ( url.substring( 0, 5 ) != 'data:' ) {

		// 	if ( this.crossOrigin != null ) {
    //     image.crossOrigin = this.crossOrigin;
    //   }

		// }

		// this.manager.itemStart( url );

		// image.src = url;

		// return image;

	}


}

