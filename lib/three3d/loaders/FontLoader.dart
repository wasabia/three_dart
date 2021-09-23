part of three_loaders;


// loader font from typeface json

class FontLoader extends Loader {

  FontLoader( manager ) : super(manager) {
    
  }

  loadAsync( url, Function? onProgress ) async {
		var loader = new FileLoader( this.manager );
		loader.setPath( this.path );
		loader.responseType = this.responseType;
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( this.withCredentials );
		var text = await loader.loadAsync( url, null );

    var jsonData = convert.jsonDecode(text);

    return this.parse( jsonData );
	}

  load( url, onLoad, onProgress, onError ) {

		var scope = this;

		var loader = FileLoader( this.manager );
    loader.responseType = this.responseType;
		loader.setPath( this.path );
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( scope.withCredentials );
		loader.load( url, ( text ) {

			var jsonData;

      jsonData = convert.jsonDecode(text);

			// try {
			// 	json = JSON.parse( text );
			// } catch ( e ) {
			// 	print( 'THREE.FontLoader: typeface.js support is being deprecated. Use typeface.json instead.' );
			// 	json = JSON.parse( text.substring( 65, text.length - 2 ) );
			// }

			var font = scope.parse( jsonData );

			if ( onLoad != null ) onLoad( font );

		}, onProgress, onError );

	}

	parse( json, {String? path, Function? onLoad, Function? onError}  ) {
		return TTFFont( json );
	}

}
