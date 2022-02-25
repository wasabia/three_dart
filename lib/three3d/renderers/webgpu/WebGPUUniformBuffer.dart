part of three_webgpu;


class WebGPUUniformBuffer extends WebGPUBinding {

  late int bytesPerElement;
  late int usage;
  late dynamic buffer;
  GPUBuffer? bufferGPU;


	WebGPUUniformBuffer( name, [buffer = null] ) : super( name ) {

	

		this.bytesPerElement = Float32List.bytesPerElement;
		this.type = GPUBindingType.UniformBuffer;
		this.visibility = GPUShaderStage.Vertex;

		this.usage = GPUBufferUsage.Uniform | GPUBufferUsage.CopyDst;

		this.buffer = buffer;
		this.bufferGPU = null; // set by the renderer

	}

	getByteLength() {

		return getFloatLength( this.buffer.byteLength );

	}

	getBuffer() {

		return this.buffer;

	}

	update() {

		return true;

	}

}

