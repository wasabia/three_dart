part of three_core;

class InterleavedBuffer {
  NativeArray array;
  int stride;

  late int count;
  late int usage;
  late Map<String, dynamic> updateRange;
  late int version;
  late String uuid;
  bool isInterleavedBuffer = true;
  Function? onUploadCallback;

  String type = "InterleavedBuffer";

  InterleavedBuffer(this.array, this.stride) {
    count = array.length ~/ stride;

    usage = StaticDrawUsage;
    updateRange = {"offset": 0, "count": -1};

    version = 0;

    uuid = MathUtils.generateUUID();
  }

  set needsUpdate(bool value) {
    if (value == true) {
      version++;
    }
  }

  InterleavedBuffer setUsage(int value) {
    usage = value;

    return this;
  }

  InterleavedBuffer copy(InterleavedBuffer source) {
    array = source.array.clone();
    count = source.count;
    stride = source.stride;
    usage = source.usage;

    return this;
  }

  InterleavedBuffer copyAt(
      int index1, InterleavedBuffer attribute, int index2) {
    index1 *= stride;
    index2 *= attribute.stride;

    for (var i = 0, l = stride; i < l; i++) {
      array[index1 + i] = attribute.array[index2 + i];
    }

    return this;
  }

  // set ( value, {int offset = 0} ) {

  // 	this.array.set( value, offset );

  // 	return this;

  // }

  clone(data) {
    data.arrayBuffers ??= {};

    print("InterleavedBuffer clone todo  ");

    // if ( this.array.buffer._uuid == null ) {

    // 	this.array.buffer._uuid = MathUtils.generateUUID();

    // }

    // if ( data.arrayBuffers[ this.array.buffer._uuid ] == null ) {

    // 	data.arrayBuffers[ this.array.buffer._uuid ] = this.array.slice( 0 ).buffer;

    // }

    // const array = new this.array.constructor( data.arrayBuffers[ this.array.buffer._uuid ] );

    // const ib = new InterleavedBuffer( array, this.stride );
    // ib.setUsage( this.usage );

    // return ib;
  }

  InterleavedBuffer onUpload(Function callback) {
    onUploadCallback = callback;

    return this;
  }

  Map<String, dynamic> toJSON(data) {
    data.arrayBuffers ??= {};

    // generate UUID for array buffer if necessary

    // if ( this.array.buffer._uuid == null ) {

    // 	this.array.buffer._uuid = MathUtils.generateUUID();

    // }

    // if ( data.arrayBuffers[ this.array.buffer._uuid ] == null ) {

    // 	data.arrayBuffers[ this.array.buffer._uuid ] = Array.prototype.slice.call( new Uint32Array( this.array.buffer ) );

    // }

    //

    return {
      "uuid": uuid,
      // "buffer": this.array.buffer._uuid,
      // "type": this.array.constructor.name,
      "buffer": array,
      "type": "List",
      "stride": stride
    };
  }
}
