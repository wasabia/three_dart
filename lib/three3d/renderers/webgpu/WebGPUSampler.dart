part of three_webgpu;



class WebGPUSampler extends WebGPUBinding {

  bool isSampler = true;

  late dynamic texture;
  late dynamic samplerGPU;

	WebGPUSampler( name, texture ) : super(name) {

		this.texture = texture;

		this.type = GPUBindingType.Sampler;
		this.visibility = GPUShaderStage.Fragment;

		this.samplerGPU = null; // set by the renderer

	}

	getTexture() {

		return this.texture;

	}

}
