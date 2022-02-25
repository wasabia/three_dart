part of three_webgpu;

class WebGPUNodeUniformsGroup extends WebGPUUniformsGroup {

	WebGPUNodeUniformsGroup( shaderStage ) : super( 'nodeUniforms' ) {
		var shaderStageVisibility;

		if ( shaderStage == 'vertex' ) shaderStageVisibility = GPUShaderStage.Vertex;
		else if ( shaderStage == 'fragment' ) shaderStageVisibility = GPUShaderStage.Fragment;

		this.setVisibility( shaderStageVisibility );

	}

}

