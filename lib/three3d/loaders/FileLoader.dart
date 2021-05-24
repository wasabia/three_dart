part of three_loaders;

var loading = {};

class FileLoader extends Loader {

  FileLoader( manager ) : super(manager) {

  }

  loadAsync ( String url, Function? onProgress ) async {
    var completer = Completer();

    load(
      url, 
      (buffer) {
        completer.complete(buffer);
      }, 
      onProgress, 
      () {

      }
    );

    return completer.future;
	}


  load ( url, onLoad, onProgress, onError ) async {

		if ( url == null ) url = '';

		if ( this.path != null ) url = this.path + url;

		url = this.manager.resolveURL( url );

		var scope = this;

		var cached = Cache.get( url );

		if ( cached != null ) {

			scope.manager.itemStart( url );

      Future.delayed(Duration.zero, () {
        if ( onLoad != null ) onLoad( cached );

				scope.manager.itemEnd( url );
      });

			return cached;

		}

		// Check if request is duplicate

		if ( loading[ url ] != null ) {

			loading[ url ].add( {

				"onLoad": onLoad,
				"onProgress": onProgress,
				"onError": onError

			} );

			return;

		}


    // Initialise array for duplicate requests

    loading[ url ] = [];

    loading[ url ].add( {

      "onLoad": onLoad,
      "onProgress": onProgress,
      "onError": onError

    } );

    var callbacks = loading[ url ];

    dynamic respData;
    if(!kIsWeb && !url.startsWith("http")) {
      if(this.responseType == "text") {
        respData = await rootBundle.loadString(url);
      } else if(url.startsWith("assets")) {
        ByteData resp = await rootBundle.load(url);
        respData = Uint8List.view(resp.buffer);
      } else {
        var file = File(url);
        respData = file.readAsBytesSync();
      }
    } else {
      http.Response response = await http.get(Uri.parse(url));
      
      if(response.statusCode != 200) {
        for ( var i = 0, il = callbacks.length; i < il; i ++ ) {
          var callback = callbacks[ i ];
          if ( callback.onError ) callback.onError(response.body);
        }

        scope.manager.itemError( url );
        scope.manager.itemEnd( url );
      }

      if(this.responseType == "text") {
        respData = response.body;
      } else {
        respData = response.bodyBytes;
      }
    }
    
    loading.remove(url);

    
    

    // Add to cache only on HTTP success, so that we do not cache
    // error response bodies as proper responses to requests.
    Cache.add( url, respData );

    for ( var i = 0, il = callbacks.length; i < il; i ++ ) {

      var callback = callbacks[ i ];
      if ( callback["onLoad"] != null ) callback["onLoad"]( respData );

    }

    scope.manager.itemEnd( url );

    

    return respData;
  
    // request = new XMLHttpRequest();
    // request.open( 'GET', url, true );
    // request.addEventListener( 'load', ( event ) {

    //   var response = this.response;

    //   var callbacks = loading[ url ];

    //   delete loading[ url ];

    //   if ( this.status == 200 || this.status == 0 ) {

    //     // Some browsers return HTTP Status 0 when using non-http protocol
    //     // e.g. 'file://' or 'data://'. Handle as success.

    //     if ( this.status == 0 ) {
    //       print( 'THREE.FileLoader: HTTP Status 0 received.' );
    //     }

    //     // Add to cache only on HTTP success, so that we do not cache
    //     // error response bodies as proper responses to requests.
    //     Cache.add( url, response );

    //     for ( var i = 0, il = callbacks.length; i < il; i ++ ) {

    //       var callback = callbacks[ i ];
    //       if ( callback.onLoad ) callback.onLoad( response );

    //     }

    //     scope.manager.itemEnd( url );

    //   } else {

    //     for ( var i = 0, il = callbacks.length; i < il; i ++ ) {

    //       var callback = callbacks[ i ];
    //       if ( callback.onError ) callback.onError( event );

    //     }

    //     scope.manager.itemError( url );
    //     scope.manager.itemEnd( url );

    //   }

    // }, false );

    // request.addEventListener( 'progress', ( event ) {

    //   var callbacks = loading[ url ];

    //   for ( var i = 0, il = callbacks.length; i < il; i ++ ) {

    //     var callback = callbacks[ i ];
    //     if ( callback.onProgress ) callback.onProgress( event );

    //   }

    // }, false );

    // request.addEventListener( 'error', ( event ) {

    //   var callbacks = loading[ url ];

    //   delete loading[ url ];

    //   for ( var i = 0, il = callbacks.length; i < il; i ++ ) {

    //     var callback = callbacks[ i ];
    //     if ( callback.onError ) callback.onError( event );

    //   }

    //   scope.manager.itemError( url );
    //   scope.manager.itemEnd( url );

    // }, false );

    // request.addEventListener( 'abort', ( event ) {

    //   var callbacks = loading[ url ];

    //   delete loading[ url ];

    //   for ( var i = 0, il = callbacks.length; i < il; i ++ ) {

    //     var callback = callbacks[ i ];
    //     if ( callback.onError ) callback.onError( event );

    //   }

    //   scope.manager.itemError( url );
    //   scope.manager.itemEnd( url );

    // }, false );

    // if ( this.responseType != null ) request.responseType = this.responseType;
    // if ( this.withCredentials != null ) request.withCredentials = this.withCredentials;

    // if ( request.overrideMimeType ) request.overrideMimeType( this.mimeType != null ? this.mimeType : 'text/plain' );

    // for ( var header in this.requestHeader ) {

    //   request.setRequestHeader( header, this.requestHeader[ header ] );

    // }

    // request.send( null );

		

		// scope.manager.itemStart( url );

		// return request;

	}

	setResponseType ( value ) {
		this.responseType = value;
		return this;

	}

	setMimeType ( value ) {

		this.mimeType = value;
		return this;

	}

}
