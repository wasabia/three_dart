part of three_webgpu;


class WebGPUComputePipelines {

  late GPUDevice device;
  late WeakMap pipelines;
  late Map stages;

	WebGPUComputePipelines( device ) {

		this.device = device;

		this.pipelines = new WeakMap();
		this.stages = {
			"compute": new WeakMap()
		};

	}

	get( param ) {

		var pipeline = this.pipelines.get( param );

		// @TODO: Reuse compute pipeline if possible, introduce WebGPUComputePipeline

		if ( pipeline == undefined ) {

			var device = this.device;

			var shader = {
				"computeShader": param.shader
			};

			// programmable stage

			var stageCompute = this.stages["compute"].get( shader );

			if ( stageCompute == undefined ) {

 				stageCompute = new WebGPUProgrammableStage( device, shader["computeShader"], 'compute' );

				this.stages["compute"].set( shader, stageCompute );

			}

			pipeline = device.createComputePipeline( GPUComputePipelineDescriptor(compute: stageCompute.stage) );

			this.pipelines.set( param, pipeline );

		}

		return pipeline;

	}

	dispose() {

		this.pipelines = new WeakMap();
		this.stages = {
			"compute": new WeakMap()
		};

	}

}

