part of three_loaders;


// loader font from typeface json

class FontLoader extends Loader {

  FontLoader( manager ) : super(manager) {
    
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

      jsonData = json.decode(text);

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
		return Font( json );
	}

}
