part of three_webgpu;


class WebGPUStorageBuffer extends WebGPUBinding {

  late int usage;
  late dynamic attribute;
  late dynamic bufferGPU;

	WebGPUStorageBuffer( name, attribute ) : super( name ) {

		this.type = GPUBindingType.StorageBuffer;

		this.usage = GPUBufferUsage.Vertex| GPUBufferUsage.Storage | GPUBufferUsage.CopyDst;

		this.attribute = attribute;
		this.bufferGPU = null; // set by the renderer

	}

}

