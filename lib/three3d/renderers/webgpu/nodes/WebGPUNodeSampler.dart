
part of three_webgpu;

class WebGPUNodeSampler extends WebGPUSampler {

  late dynamic textureNode;

	WebGPUNodeSampler( name, textureNode ) : super( name, textureNode.value ) {



		this.textureNode = textureNode;

	}

	getTexture() {

		return this.textureNode.value;

	}

}

