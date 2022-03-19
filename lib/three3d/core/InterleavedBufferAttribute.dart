part of three_core;

var _vector = Vector3.init();

class InterleavedBufferAttribute extends BaseBufferAttribute {
  int offset;

  InterleavedBufferAttribute(
      InterleavedBuffer? _data, int _itemSize, this.offset, bool _normalized)
      : super() {
    type = "InterleavedBufferAttribute";
    isInterleavedBufferAttribute = true;
    data = _data;
    itemSize = _itemSize;
    normalized = _normalized;
  }

  @override
  int get count {
    return data!.count;
  }

  @override
  get array {
    return data!.array;
  }

  set needsUpdate(bool value) {
    data!.needsUpdate = value;
  }

  InterleavedBufferAttribute applyMatrix4(Matrix4 m) {
    for (var i = 0, l = data!.count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyMatrix4(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  InterleavedBufferAttribute applyNormalMatrix(Matrix3 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyNormalMatrix(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  InterleavedBufferAttribute transformDirection(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.transformDirection(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  InterleavedBufferAttribute setX(int index, x) {
    data!.array[index * data!.stride + offset] = x;

    return this;
  }

  InterleavedBufferAttribute setY(int index, y) {
    data!.array[index * data!.stride + offset + 1] = y;

    return this;
  }

  InterleavedBufferAttribute setZ(int index, z) {
    data!.array[index * data!.stride + offset + 2] = z;

    return this;
  }

  InterleavedBufferAttribute setW(int index, w) {
    data!.array[index * data!.stride + offset + 3] = w;

    return this;
  }

  getX(int index) {
    return data!.array[index * data!.stride + offset];
  }

  getY(int index) {
    return data!.array[index * data!.stride + offset + 1];
  }

  getZ(int index) {
    return data!.array[index * data!.stride + offset + 2];
  }

  getW(int index) {
    return data!.array[index * data!.stride + offset + 3];
  }

  InterleavedBufferAttribute setXY(int index, x, y) {
    index = index * data!.stride + offset;

    data!.array[index + 0] = x;
    data!.array[index + 1] = y;

    return this;
  }

  InterleavedBufferAttribute setXYZ(int index, x, y, z) {
    index = index * data!.stride + offset;

    data!.array[index + 0] = x;
    data!.array[index + 1] = y;
    data!.array[index + 2] = z;

    return this;
  }

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

  // 		print( 'THREE.InterleavedBufferAttribute.clone(): Cloning an interlaved buffer attribute will deinterleave buffer data!.' );

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

  Map<String, Object> toJSON(data) {
    if (data == null) {
      print(
          'THREE.InterleavedBufferAttribute.toJSON(): Serializing an interlaved buffer attribute will deinterleave buffer data!.');

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
        "type": this.array.runtimeType.toString(),
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
