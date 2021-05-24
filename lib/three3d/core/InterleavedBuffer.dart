
part of three_core;

class InterleavedBuffer {

  List<num> array;
  int stride;
  
  late int count;
  late int usage;
  late Map<String, dynamic> updateRange;
  late int version;
  late String uuid;
  bool isInterleavedBuffer = true;
  late Function onUploadCallback;


  InterleavedBuffer( this.array, this.stride ) {
    this.count = array != null ? (array.length / stride).toInt() : 0;

    this.usage = StaticDrawUsage;
    this.updateRange = { "offset": 0, "count": - 1 };

    this.version = 0;

    this.uuid = MathUtils.generateUUID();
  }

  set needsUpdate(bool value) {
    if ( value == true ) {
      this.version ++;
    }
  }



	setUsage ( value ) {

		this.usage = value;

		return this;

	}

	// copy ( source ) {

	// 	this.array = new source.array.constructor( source.array );
	// 	this.count = source.count;
	// 	this.stride = source.stride;
	// 	this.usage = source.usage;

	// 	return this;

	// }

	copyAt ( index1, attribute, index2 ) {

		index1 *= this.stride;
		index2 *= attribute.stride;

		for ( var i = 0, l = this.stride; i < l; i ++ ) {

			this.array[ index1 + i ] = attribute.array[ index2 + i ];

		}

		return this;

	}

	// set ( value, {int offset = 0} ) {

	// 	this.array.set( value, offset );

	// 	return this;

	// }

	// clone ( data ) {

	// 	if ( data.arrayBuffers == null ) {

	// 		data.arrayBuffers = {};

	// 	}

	// 	if ( this.array.buffer._uuid == null ) {

	// 		this.array.buffer._uuid = MathUtils.generateUUID();

	// 	}

	// 	if ( data.arrayBuffers[ this.array.buffer._uuid ] == null ) {

	// 		data.arrayBuffers[ this.array.buffer._uuid ] = this.array.slice( 0 ).buffer;

	// 	}

	// 	const array = new this.array.constructor( data.arrayBuffers[ this.array.buffer._uuid ] );

	// 	const ib = new InterleavedBuffer( array, this.stride );
	// 	ib.setUsage( this.usage );

	// 	return ib;

	// }

	onUpload ( callback ) {

		this.onUploadCallback = callback;

		return this;

	}

	toJSON ( data ) {

		if ( data.arrayBuffers == null ) {

			data.arrayBuffers = {};

		}

		// generate UUID for array buffer if necessary

		// if ( this.array.buffer._uuid == null ) {

		// 	this.array.buffer._uuid = MathUtils.generateUUID();

		// }

		// if ( data.arrayBuffers[ this.array.buffer._uuid ] == null ) {

		// 	data.arrayBuffers[ this.array.buffer._uuid ] = Array.prototype.slice.call( new Uint32Array( this.array.buffer ) );

		// }

		//

		return {
			"uuid": this.uuid,
			// "buffer": this.array.buffer._uuid,
			// "type": this.array.constructor.name,
      "buffer": this.array,
      "type": "List",
			"stride": this.stride
		};

	}


}


