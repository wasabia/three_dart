part of three_loaders;



class LoaderUtils {

	static decodeText( array ) {

    var s = Utf8Decoder().convert(array);
    return s;

		// if ( typeof TextDecoder !== 'undefined' ) {
		// 	return new TextDecoder().decode( array );
		// }

		// Avoid the String.fromCharCode.apply(null, array) shortcut, which
		// throws a "maximum call stack size exceeded" error for large arrays.

		// String s = '';
		// for ( var i = 0, il = array.length; i < il; i ++ ) {
		// 	// Implicitly assumes little-endian.
		// 	s += String.fromCharCode( array[ i ] );
		// }
    // return s;

		// try {

		// 	// merges multi-byte utf-8 characters.

		// 	return Uri.encodeComponent( RegExp.escape( s ) );

		// } catch ( e ) { // see #16358

		// 	return s;

		// }

	}

	static extractUrlBase( String url ) {

		var index = url.lastIndexOf( '/' );

		if ( index == - 1 ) return './';

		return url.substring( 0, index + 1 );

	}

}
