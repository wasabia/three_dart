part of three_webgpu;


class WebGPUNodeSampledTexture extends WebGPUSampledTexture {

  late dynamic textureNode;

	WebGPUNodeSampledTexture( name, textureNode ) : super( name, textureNode.value ) {

		

		this.textureNode = textureNode;

	}

	getTexture() {

		return this.textureNode.value;

	}

}

