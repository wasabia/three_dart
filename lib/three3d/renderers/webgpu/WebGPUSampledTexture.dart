part of three_webgpu;

class WebGPUSampledTexture extends WebGPUBinding {

  late dynamic texture;
  late dynamic textureGPU;
  late String dimension;

  bool isSampledTexture = true;

	WebGPUSampledTexture( name, texture ) : super( name ) {
		this.texture = texture;

		this.dimension = GPUTextureViewDimension.TwoD;

		this.type = GPUBindingType.SampledTexture;
		this.visibility = GPUShaderStage.Fragment;

		this.textureGPU = null; // set by the renderer

	}

	getTexture() {

		return this.texture;

	}

}


class WebGPUSampledArrayTexture extends WebGPUSampledTexture {

	WebGPUSampledArrayTexture( name, texture ) : super( name, texture ) {


		this.dimension = GPUTextureViewDimension.TwoDArray;

	}

}


class WebGPUSampled3DTexture extends WebGPUSampledTexture {

	WebGPUSampled3DTexture( name, texture ) : super( name, texture ) {

		this.dimension = GPUTextureViewDimension.ThreeD;

	}

}

class WebGPUSampledCubeTexture extends WebGPUSampledTexture {

	WebGPUSampledCubeTexture( name, texture ) : super( name, texture ) {
		this.dimension = GPUTextureViewDimension.Cube;

	}

}
