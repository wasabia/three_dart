part of three_loaders;

var loading = {};

class FileLoader extends Loader {
  FileLoader(manager) : super(manager);

  @override
  loadAsync(url) async {
    var completer = Completer();

    load(url, (buffer) {
      completer.complete(buffer);
    });

    return completer.future;
  }

  @override
  load(url, onLoad, [onProgress, onError]) async {
    url ??= '';

    url = path + url;

    url = manager.resolveURL(url);

    var scope = this;

    var cached = Cache.get(url);

    if (cached != null) {
      scope.manager.itemStart(url);

      onLoad(cached);
      scope.manager.itemEnd(url);

      return cached;
    }

    // Check if request is duplicate

    if (loading[url] != null) {
      loading[url].add({"onLoad": onLoad, "onProgress": onProgress, "onError": onError});

      return;
    }

    // Check for data: URI
    var dataUriRegex = RegExp(r"^data:(.*?)(;base64)?,(.*)$");
    var dataUriRegexResult = dataUriRegex.firstMatch(url);
    var request;

    // Safari can not handle Data URIs through XMLHttpRequest so process manually
    if (dataUriRegex.hasMatch(url)) {
      var dataUriRegexResult = dataUriRegex.firstMatch(url)!;

      var mimeType = dataUriRegexResult.group(1);
      var isBase64 = dataUriRegexResult.group(2) != null;

      var data = dataUriRegexResult.group(3)!;
      // data = decodeURIComponent( data );

      Uint8List? base64Data;

      if (isBase64) base64Data = convert.base64.decode(data);

      // try {

      var response;
      var responseType = (this.responseType).toLowerCase();

      switch (responseType) {
        case 'arraybuffer':
        case 'blob':
          if (responseType == 'blob') {
            // response = new Blob( [ view.buffer ], { type: mimeType } );
            throw (" FileLoader responseType: $responseType need support .... ");
          } else {
            response = base64Data;
          }

          break;

        case 'document':

          // var parser = new DOMParser();
          // response = parser.parseFromString( data, mimeType );

          throw ("FileLoader responseType: $responseType is not support ....  ");

          break;

        case 'json':
          response = convert.jsonDecode(data);

          break;

        default: // 'text' or other

          response = data;

          break;
      }

      // Wait for next browser tick like standard XMLHttpRequest event dispatching does
      Future.delayed(Duration.zero, () {
        onLoad(response);

        scope.manager.itemEnd(url);
      });

      // } catch ( error ) {

      // Wait for next browser tick like standard XMLHttpRequest event dispatching does
      // setTimeout( function () {

      // 	if ( onError ) onError( error );

      // 	scope.manager.itemError( url );
      // 	scope.manager.itemEnd( url );

      // }, 0 );

      //   Future.delayed(Duration.zero, () {

      // 		if ( onError != null ) onError( error );

      // 		scope.manager.itemError( url );
      // 		scope.manager.itemEnd( url );

      //   });

      // }

      return;
    }

    // Initialise array for duplicate requests

    loading[url] = [];

    loading[url].add({"onLoad": onLoad, "onProgress": onProgress, "onError": onError});

    var callbacks = loading[url];

    dynamic respData;
    if (!kIsWeb && !url.startsWith("http")) {
      if (url.startsWith("assets")) {
        if (responseType == "text") {
          respData = await rootBundle.loadString(url);
        } else {
          ByteData resp = await rootBundle.load(url);
          respData = Uint8List.view(resp.buffer);
        }
      } else {
        var file = File(url);

        if (responseType == "text") {
          respData = await file.readAsString();
        } else {
          respData = await file.readAsBytes();
        }
      }
    } else {
      // load assets file TODO
      if (url.startsWith("assets")) {
        url = "assets/" + url;
      }

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        for (var i = 0, il = callbacks.length; i < il; i++) {
          var callback = callbacks[i];
          if (callback["onError"] != null) callback["onError"](response.body);
        }

        scope.manager.itemError(url);
        scope.manager.itemEnd(url);
      }

      if (responseType == "text") {
        respData = response.body;
      } else {
        respData = response.bodyBytes;
      }
    }

    loading.remove(url);

    // Add to cache only on HTTP success, so that we do not cache
    // error response bodies as proper responses to requests.
    Cache.add(url, respData);

    for (var i = 0, il = callbacks.length; i < il; i++) {
      var callback = callbacks[i];
      if (callback["onLoad"] != null) callback["onLoad"](respData);
    }

    scope.manager.itemEnd(url);

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
    //       print( 'three.FileLoader: HTTP Status 0 received.' );
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

  setResponseType(value) {
    responseType = value;
    return this;
  }

  setMimeType(value) {
    mimeType = value;
    return this;
  }
}
