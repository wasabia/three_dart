part of three_core;

var _vector = Vector3.init();

class InterleavedBufferAttribute extends BufferAttribute {
  int offset;
  @override
  InterleavedBuffer? data;

  InterleavedBufferAttribute(this.data, int _itemSize, this.offset, bool _normalized)
      : super(Float32Array(0), _itemSize) {
    type = "InterleavedBufferAttribute";
    itemSize = _itemSize;
    normalized = _normalized;
  }

  @override
  int get count {
    return data!.count;
  }

  @override
  NativeArray get array {
    return data!.array;
  }

  @override
  set needsUpdate(bool value) {
    data!.needsUpdate = value;
  }

  @override
  InterleavedBufferAttribute applyMatrix4(Matrix4 m) {
    for (var i = 0, l = data!.count; i < l; i++) {
      _vector.fromBufferAttribute(this, i);

      _vector.applyMatrix4(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  @override
  InterleavedBufferAttribute applyNormalMatrix(m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.fromBufferAttribute(this, i);

      _vector.applyNormalMatrix(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  @override
  InterleavedBufferAttribute transformDirection(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i)!.toDouble();
      _vector.y = getY(i)!.toDouble();
      _vector.z = getZ(i)!.toDouble();

      _vector.transformDirection(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  @override
  InterleavedBufferAttribute setX(int index, x) {
    data!.array[index * data!.stride + offset] = x;

    return this;
  }

  @override
  InterleavedBufferAttribute setY(int index, y) {
    data!.array[index * data!.stride + offset + 1] = y;

    return this;
  }

  @override
  InterleavedBufferAttribute setZ(int index, z) {
    data!.array[index * data!.stride + offset + 2] = z;

    return this;
  }

  @override
  InterleavedBufferAttribute setW(int index, w) {
    data!.array[index * data!.stride + offset + 3] = w;

    return this;
  }

  @override
  getX(int index) {
    return data!.array[index * data!.stride + offset];
  }

  @override
  getY(int index) {
    return data!.array[index * data!.stride + offset + 1];
  }

  @override
  getZ(int index) {
    return data!.array[index * data!.stride + offset + 2];
  }

  @override
  getW(int index) {
    return data!.array[index * data!.stride + offset + 3];
  }

  @override
  InterleavedBufferAttribute setXY(int index, x, y) {
    index = index * data!.stride + offset;

    data!.array[index + 0] = x;
    data!.array[index + 1] = y;

    return this;
  }

  @override
  InterleavedBufferAttribute setXYZ(int index, x, y, z) {
    index = index * data!.stride + offset;

    data!.array[index + 0] = x;
    data!.array[index + 1] = y;
    data!.array[index + 2] = z;

    return this;
  }

  @override
  InterleavedBufferAttribute setXYZW(int index, x, y, z, w) {
    index = index * data!.stride + offset;

    data!.array[index + 0] = x;
    data!.array[index + 1] = y;
    data!.array[index + 2] = z;
    data!.array[index + 3] = w;

    return this;
  }

  // clone ( data ) {

  // 	if ( data == null ) {

  // 		print( 'three.InterleavedBufferAttribute.clone(): Cloning an interlaved buffer attribute will deinterleave buffer data!.' );

  // 		var array = [];

  // 		for ( var i = 0; i < this.count; i ++ ) {

  // 			var index = i * this.data!.stride + this.offset;

  // 			for ( var j = 0; j < this.itemSize; j ++ ) {

  // 				array.add( this.data!.array[ index + j ] );

  // 			}

  // 		}

  // 		return new BufferAttribute(array, this.itemSize, this.normalized );

  // 	} else {

  // 		if ( data!.interleavedBuffers == null ) {

  // 			data!.interleavedBuffers = {};

  // 		}

  // 		if ( data!.interleavedBuffers[ this.data!.uuid ] == null ) {

  // 			data!.interleavedBuffers[ this.data!.uuid ] = this.data!.clone( data );

  // 		}

  // 		return new InterleavedBufferAttribute( data!.interleavedBuffers[ this.data!.uuid ], this.itemSize, this.offset, this.normalized );

  // 	}

  // }

  @override
  Map<String, Object> toJSON([data]) {
    if (data == null) {
      print(
          'three.InterleavedBufferAttribute.toJSON(): Serializing an interlaved buffer attribute will deinterleave buffer data!.');

      var array = [];

      for (var i = 0; i < count; i++) {
        var index = i * this.data!.stride + offset;

        for (var j = 0; j < itemSize; j++) {
          array.add(this.data!.array[index + j]);
        }
      }

      // deinterleave data and save it as an ordinary buffer attribute for now

      return {
        "itemSize": itemSize,
        "type": this.array.runtimeType.toString(), // TODO remove runtimeType
        "array": array,
        "normalized": normalized
      };
    } else {
      // save as true interlaved attribtue

      data.interleavedBuffers ??= {};

      if (data.interleavedBuffers[this.data!.uuid] == null) {
        data.interleavedBuffers[this.data!.uuid] = this.data!.toJSON(data);
      }

      return {
        "isInterleavedBufferAttribute": true,
        "itemSize": itemSize,
        "data": this.data!.uuid,
        "offset": offset,
        "normalized": normalized
      };
    }
  }
}
