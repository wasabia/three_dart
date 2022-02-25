part of three_webgpu;

class WebGPUAttributes {

  late WeakMap buffers;
  late GPUDevice device;

	WebGPUAttributes( device ) {

		this.buffers = new WeakMap();
		this.device = device;

	}

	get( attribute ) {

		if ( attribute.isInterleavedBufferAttribute ) attribute = attribute.data;

		return this.buffers.get( attribute );

	}

	remove( attribute ) {

		if ( attribute.isInterleavedBufferAttribute ) attribute = attribute.data;

		var data = this.buffers.get( attribute );

		if ( data != null ) {

			data.buffer.destroy();

			this.buffers.delete( attribute );

		}

	}

	update( attribute, [isIndex = false, usage = null] ) {

		if ( attribute.isInterleavedBufferAttribute ) attribute = attribute.data;

		var data = this.buffers.get( attribute );

		if ( data == undefined ) {

			if ( usage == null ) {

				usage = ( isIndex == true ) ? GPUBufferUsage.Index : GPUBufferUsage.Vertex;

			}

			data = this._createBuffer( attribute, usage );

			this.buffers.set( attribute, data );

		} else if ( usage && usage != data.usage ) {

			data.buffer.destroy();

			data = this._createBuffer( attribute, usage );

			this.buffers.set( attribute, data );

		} else if ( data.version < attribute.version ) {

			this._writeBuffer( data.buffer, attribute );

			data.version = attribute.version;

		}

	}

	_createBuffer( attribute, usage ) {

		var array = attribute.array;
		var size = array.byteLength + ( ( 4 - ( array.byteLength % 4 ) ) % 4 ); // ensure 4 byte alignment, see #20441

		var buffer = this.device.createBuffer( 
      GPUBufferDescriptor(
        size: size,
        usage: usage | GPUBufferUsage.CopyDst,
        mappedAtCreation: true
      ));

    Pointer<Uint8> p = buffer.getMappedRange().cast();

    for(var i = 0; i < array.len; i ++) {
      p[i] = array[i];
    }

		buffer.unmap();

		attribute.onUploadCallback();

		return {
			"version": attribute.version,
			"buffer": buffer,
			"usage": usage
		};

	}

	_writeBuffer( buffer, attribute ) {

		var array = attribute.array;
		var updateRange = attribute.updateRange;

		if ( updateRange.count == - 1 ) {

			// Not using update ranges

			this.device.queue.writeBuffer(
				buffer,
				0,
				array,
				0
			);

		} else {

			this.device.queue.writeBuffer(
				buffer,
        0,
				array,
				updateRange.count * array.BYTES_PER_ELEMENT
			);

			updateRange.count = - 1; // reset range

		}

	}

}
