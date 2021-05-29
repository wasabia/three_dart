part of three_webgl;


class WebGLAttributes {

  dynamic gl;
  WebGLCapabilities capabilities;

  bool isWebGL2 = true;

  WeakMap buffers = WeakMap();

  WebGLAttributes( this.gl, this.capabilities ) {
   
    isWebGL2 = capabilities.isWebGL2;
  }

	createBuffer( BaseBufferAttribute attribute, int bufferType ) {

		final array = attribute.array;
		var usage = attribute.usage;

    dynamic arrayType = attribute.runtimeType;

    dynamic arrayList;

    var type = gl.FLOAT;
    int bytesPerElement = 4;

    if(arrayType == Float32BufferAttribute) {
      arrayList = Float32List.fromList(array.map((e) => e.toDouble()).toList());
    } else if (arrayType == Uint16BufferAttribute) {
      arrayList = Uint16List.fromList(array.map((e) => e.toInt()).toList());
    } else if (arrayType == Uint32BufferAttribute) {
      arrayList = Uint32List.fromList(array.map((e) => e.toInt()).toList());
    } else if (arrayType == InterleavedBufferAttribute || arrayType == BufferAttribute) {
      arrayList = array;
      final arrayType = array.runtimeType;
      if(arrayType == Uint8List) {
        type = gl.UNSIGNED_BYTE;
        bytesPerElement = Uint8List.bytesPerElement;
      } else if(arrayType == Float32List) {
        type = gl.FLOAT;
        bytesPerElement = Float32List.bytesPerElement;
      } else if(arrayType == Uint32List) {
        type = gl.UNSIGNED_INT;
        bytesPerElement = Uint32List.bytesPerElement;
      } else {

        // 保持抛出异常 及时发现异常情况
        throw("WebGLAttributes.createBuffer InterleavedBufferAttribute arrayType: ${array.runtimeType} is not support  ");
      }

    } else if(arrayType == InstancedBufferAttribute) {
      type = gl.UNSIGNED_BYTE;
      bytesPerElement = Uint8List.bytesPerElement;
      arrayList = array;

      final _arrayType = array.runtimeType;

      if(_arrayType == Uint8List) {
        type = gl.UNSIGNED_BYTE;
        bytesPerElement = Uint8List.bytesPerElement;
      } else if(_arrayType == Float32List) {
        type = gl.FLOAT;
        bytesPerElement = Float32List.bytesPerElement;
      } else if(_arrayType == Uint32List) {
        type = gl.UNSIGNED_INT;
        bytesPerElement = Uint32List.bytesPerElement;
      } else {
        // 保持抛出异常 及时发现异常情况
        throw("WebGLAttributes.createBuffer InstancedBufferAttribute arrayType: ${array.runtimeType} is not support  ");
      }
      print(" _arrayType: ${_arrayType} ");
    } else {
      print("createBuffer array: ${array.runtimeType} ");
      // arrayList = Float32List.fromList(array.map((e) => e.toDouble()).toList());
      // 保持抛出异常 及时发现异常情况
      throw("WebGLAttributes.createBuffer BufferAttribute arrayType: ${arrayType} is not support  ");
    }

    // print("WebGLAttributes.createBuffer attribute: ${attribute} arrayList: ${arrayList}   ");

		var buffer = gl.createBuffer();

		gl.bindBuffer( bufferType, buffer );
		gl.bufferData( bufferType, arrayList, usage );


		attribute.onUploadCallback();

		if ( arrayType == Float32BufferAttribute ) {

			type = gl.FLOAT;
      bytesPerElement = Float32List.bytesPerElement;

		} else if ( arrayType == Float64BufferAttribute ) {

			print( 'THREE.WebGLAttributes: Unsupported data buffer format: Float64Array.' );

		} else if ( arrayType == Uint16BufferAttribute ) {

      bytesPerElement = Uint16List.bytesPerElement;

			if ( attribute.isFloat16BufferAttribute ) {

				if ( isWebGL2 ) {

					type = gl.HALF_FLOAT;

				} else {

					print( 'THREE.WebGLAttributes: Usage of Float16BufferAttribute requires WebGL2.' );

				}

			} else {

				type = gl.UNSIGNED_SHORT;

			}

		} else if ( arrayType == Int16BufferAttribute ) {

      bytesPerElement = Int16List.bytesPerElement;

			type = gl.SHORT;

		} else if ( arrayType == Uint32BufferAttribute ) {
      bytesPerElement = Uint32List.bytesPerElement;

			type = gl.UNSIGNED_INT;

		} else if ( arrayType == Int32BufferAttribute ) {
      bytesPerElement = Int32List.bytesPerElement;

			type = gl.INT;

		} else if ( arrayType == Int8BufferAttribute ) {
      bytesPerElement = Int8List.bytesPerElement;

			type = gl.BYTE;

		} else if ( arrayType == Uint8BufferAttribute ) {
      bytesPerElement = Uint8List.bytesPerElement;

			type = gl.UNSIGNED_BYTE;

		}


    final _v = {
			"buffer": buffer,
			"type": type,
			"bytesPerElement": bytesPerElement,
      "array": arrayList,
			"version": attribute.version
		};

    // print(_v);

		return _v;
	}

	updateBuffer( buffer, attribute, bufferType ) {

		var array = attribute.array;
		var updateRange = attribute.updateRange;


		gl.bindBuffer( bufferType, buffer );

		if ( updateRange["count"] == - 1 ) {

			// Not using update ranges

			gl.bufferSubData( bufferType, 0, array, 0 );

		} else {

			gl.bufferSubData( bufferType, updateRange["offset"] * array.BYTES_PER_ELEMENT, array, updateRange["offset"] );

			updateRange["count"] = - 1; // reset range

		}

	}

	

	get(BaseBufferAttribute attribute ) {

		if ( attribute.type == "InterleavedBufferAttribute" ) {
      return buffers.get( attribute.data );
    } else {
      return buffers.get( attribute );
    };
	}

	remove(BufferAttribute attribute ) {

		if ( attribute.type == "InterleavedBufferAttribute" ) {
  
      var data = buffers.get( attribute.data );

      if ( data ) {

        gl.deleteBuffer( data.buffer );

        buffers.delete( attribute.data );

      }
    } else {
      var data = buffers.get( attribute );

      if ( data != null ) {

        gl.deleteBuffer( data["buffer"] );

        buffers.delete( attribute );

      }
    }

	}

	update( BaseBufferAttribute attribute, bufferType, {String? name} ) {


		if ( attribute.type == "GLBufferAttribute" ) {

			var cached = buffers.get( attribute );

			if ( cached == null || cached["version"] < attribute.version ) {

				// buffers.add( 
        //   key: attribute, 
        //   value: {
        //     "buffer": attribute.buffer,
        //     "type": attribute.type,
        //     "bytesPerElement": attribute.elementSize,
        //     "version": attribute.version
        //   } 
        // );

        buffers.add( 
          key: attribute, 
          value: createBuffer(attribute, bufferType)
        );


			}

			return;

		}

		if ( attribute.type == "InterleavedBufferAttribute" ) {
     
      var data = buffers.get( attribute.data );

      if ( data == null ) {

        buffers.add( key: attribute, value: createBuffer( attribute, bufferType ) );

      } else if ( data.version < attribute.version ) {

        updateBuffer( data.buffer, attribute, bufferType );

        data.version = attribute.version;

      }
    } else {
      var data = buffers.get( attribute );

      if ( data == null ) {

        buffers.add( key: attribute, value: createBuffer( attribute, bufferType ) );

      } else if ( data["version"] < attribute.version ) {

        updateBuffer( data["buffer"], attribute, bufferType );

        data["version"] = attribute.version;

      }
    }

		

	}

}

