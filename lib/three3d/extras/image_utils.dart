// var _canvas;

class ImageUtils {
  static getDataURL(image) {
    if (RegExp(r"^data:").hasMatch(image.src)) {
      return image.src;
    }

    // if ( typeof HTMLCanvasElement == 'undefined' ) {

    // 	return image.src;

    // }

    // var canvas;

    // if ( image instanceof HTMLCanvasElement ) {

    // 	canvas = image;

    // } else {

    // 	if ( _canvas == undefined ) _canvas = document.createElementNS( 'http://www.w3.org/1999/xhtml', 'canvas' );

    // 	_canvas.width = image.width;
    // 	_canvas.height = image.height;

    // 	const context = _canvas.getContext( '2d' );

    // 	if ( image instanceof ImageData ) {

    // 		context.putImageData( image, 0, 0 );

    // 	} else {

    // 		context.drawImage( image, 0, 0, image.width, image.height );

    // 	}

    // 	canvas = _canvas;

    // }

    // if ( canvas.width > 2048 || canvas.height > 2048 ) {

    // 	console.warn( 'three.ImageUtils.getDataURL: Image converted to jpg for performance reasons', image );

    // 	return canvas.toDataURL( 'image/jpeg', 0.6 );

    // } else {

    // 	return canvas.toDataURL( 'image/png' );

    // }
  }

  static sRGBToLinear(image) {
    // TODO
    return image;
    // if ( ( typeof HTMLImageElement !== 'undefined' && image instanceof HTMLImageElement ) ||
    // 	( typeof HTMLCanvasElement !== 'undefined' && image instanceof HTMLCanvasElement ) ||
    // 	( typeof ImageBitmap !== 'undefined' && image instanceof ImageBitmap ) ) {

    // 	const canvas = createElementNS( 'canvas' );

    // 	canvas.width = image.width;
    // 	canvas.height = image.height;

    // 	var context = canvas.getContext( '2d' );
    // 	context.drawImage( image, 0, 0, image.width, image.height );

    // 	var imageData = context.getImageData( 0, 0, image.width, image.height );
    // 	var data = imageData.data;

    // 	for ( var i = 0; i < data.length; i ++ ) {

    // 		data[ i ] = SRGBToLinear( data[ i ] / 255 ) * 255;

    // 	}

    // 	context.putImageData( imageData, 0, 0 );

    // 	return canvas;

    // } else if ( image.data ) {

    // 	var data = image.data.slice( 0 );

    // 	for ( var i = 0; i < data.length; i ++ ) {

    // 		if ( data is Uint8Array || data is Uint8ClampedArray ) {

    // 			data[ i ] = Math.floor( SRGBToLinear( data[ i ] / 255 ) * 255 );

    // 		} else {

    // 			// assuming float

    // 			data[ i ] = SRGBToLinear( data[ i ] );

    // 		}

    // 	}

    // 	return {
    // 		"data": data,
    // 		"width": image.width,
    // 		"height": image.height
    // 	};

    // } else {
    // 	return image;
    // }
  }
}
