import 'package:three_dart/three_dart.dart';

arrayMin( array ) {

	if ( array.length == 0 ) return 9999999;

	var min = array[ 0 ];

	for ( var i = 1, l = array.length; i < l; ++ i ) {

		if ( array[ i ] < min ) min = array[ i ];

	}

	return min;

}

arrayMax( array ) {

	if ( array.length == 0 ) return - 99999999;

	var max = array[ 0 ];

	for ( var i = 1, l = array.length; i < l; ++ i ) {

		if ( array[ i ] > max ) max = array[ i ];

	}

	return max;

}

// var TYPED_ARRAYS = {
// 	Int8Array: Int8Array,
// 	Uint8Array: Uint8Array,
// 	// Workaround for IE11 pre KB2929437. See #11440
// 	Uint8ClampedArray: typeof Uint8ClampedArray !== 'undefined' ? Uint8ClampedArray : Uint8Array,
// 	Int16Array: Int16Array,
// 	Uint16Array: Uint16Array,
// 	Int32Array: Int32Array,
// 	Uint32Array: Uint32Array,
// 	Float32Array: Float32Array,
// 	Float64Array: Float64Array
// };

getTypedArray( type, buffer ) {

  if(type == "Uint32Array") {
    return Uint32Array.from(buffer);
  } else if(type == "Uint16Array") {
    return Uint16Array.from(buffer);
  } else if(type == "Float32Array") {
    return Float32Array.from(buffer);  
  } else {
    throw(" Util.dart getTypedArray type: ${type} is not support "); 
  }

}

