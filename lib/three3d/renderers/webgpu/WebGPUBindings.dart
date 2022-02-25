part of three_webgpu;

class WebGPUBindings {

  late GPUDevice device;
  late WebGPUInfo info;
  late WebGPUProperties properties;
  late WebGPUTextures textures;
  late WebGPURenderPipelines renderPipelines;
  late WebGPUComputePipelines computePipelines;
  late WebGPUAttributes attributes;
  late WebGPUNodes nodes;
  late WeakMap uniformsData;
  late WeakMap updateMap;

	WebGPUBindings( device, info, properties, textures, renderPipelines, computePipelines, attributes, nodes ) {

		this.device = device;
		this.info = info;
		this.properties = properties;
		this.textures = textures;
		this.renderPipelines = renderPipelines;
		this.computePipelines = computePipelines;
		this.attributes = attributes;
		this.nodes = nodes;

		this.uniformsData = new WeakMap();

		this.updateMap = new WeakMap();

	}

	Map get( object ) {

		var data = this.uniformsData.get( object );

		if ( data == undefined ) {

			// each object defines an array of bindings (ubos, textures, samplers etc.)

			var nodeBuilder = this.nodes.get( object );
			var bindings = nodeBuilder.getBindings();

			// setup (static) binding layout and (dynamic) binding group

			var renderPipeline = this.renderPipelines.get( object );

			// var bindLayout = renderPipeline.pipeline.getBindGroupLayout( 0 );
			// var bindGroup = this._createBindGroup( bindings, bindLayout );

			data = {
				// "layout": bindLayout,
				// "group": bindGroup,
				"bindings": bindings
			};

			this.uniformsData.set( object, data );

		}

		return data;

	}

	remove( object ) {

		this.uniformsData.delete( object );

	}

	getForCompute( param ) {

		var data = this.uniformsData.get( param );

		if ( data == undefined ) {

			// bindings are not yet retrieved via node material

			var bindings = param.bindings != undefined ? param.bindings.slice() : [];

			var computePipeline = this.computePipelines.get( param );

			var bindLayout = computePipeline.getBindGroupLayout( 0 );
			var bindGroup = this._createBindGroup( bindings, bindLayout );

			data = {
				"layout": bindLayout,
				"group": bindGroup,
				"bindings": bindings
			};

			this.uniformsData.set( param, data );

		}

		return data;

	}

	update( object ) {

    
		var textures = this.textures;

		var data = this.get( object );

		var bindings = data["bindings"];

		var updateMap = this.updateMap;
		var frame = this.info.render["frame"];

		var needsBindGroupRefresh = false;

		// iterate over all bindings and check if buffer updates or a new binding group is required
    
		for ( var binding in bindings ) {
			var isShared = binding.isShared;
			var isUpdated = updateMap.get( binding ) == frame;

			if ( isShared && isUpdated ) continue;
			if ( binding is WebGPUUniformBuffer ) {

				var buffer = binding.getBuffer();
				var bufferGPU = binding.bufferGPU!;

				var needsBufferWrite = binding.update();

				if ( needsBufferWrite == true ) {

					this.device.queue.writeBuffer( bufferGPU, 0, buffer, 0 );

				}

			} else if ( binding.isStorageBuffer ) {

				var attribute = binding.attribute;
				this.attributes.update( attribute, false, binding.usage );

			} else if ( binding.isSampler ) {

				var texture = binding.getTexture();

				textures.updateSampler( texture );

				var samplerGPU = textures.getSampler( texture );

				if ( binding.samplerGPU != samplerGPU ) {

					binding.samplerGPU = samplerGPU;
					needsBindGroupRefresh = true;

				}

			} else if ( binding.isSampledTexture ) {

				var texture = binding.getTexture();

				var needsTextureRefresh = textures.updateTexture( texture );
				var textureGPU = textures.getTextureGPU( texture );

				if ( textureGPU != undefined && binding.textureGPU != textureGPU || needsTextureRefresh == true ) {

					binding.textureGPU = textureGPU;
					needsBindGroupRefresh = true;

				}

			}

			updateMap.set( binding, frame );

		}

		if ( needsBindGroupRefresh == true ) {

			data["group"] = this._createBindGroup( bindings, data["layout"] );

		}

	}

	dispose() {

		this.uniformsData = new WeakMap();
		this.updateMap = new WeakMap();

	}

	_createBindGroup( bindings, layout ) {

		var bindingPoint = 0;
		List<GPUBindGroupEntry> entries = [];

		for ( var binding in bindings ) {

			if ( binding.isUniformBuffer ) {

				if ( binding.bufferGPU == null ) {

					var byteLength = binding.getByteLength();

					binding.bufferGPU = this.device.createBuffer(
            GPUBufferDescriptor(size: byteLength, usage: binding["usage"])
          );

				}

				entries.add( GPUBindGroupEntry( binding: bindingPoint, buffer: binding.bufferGPU ) );

			} else if ( binding.isStorageBuffer ) {

				if ( binding.bufferGPU == null ) {

					var attribute = binding["attribute"];

					this.attributes.update( attribute, false, binding["usage"] );
					binding.bufferGPU = this.attributes.get( attribute ).buffer;

				}

				entries.add( GPUBindGroupEntry( binding: bindingPoint, buffer: binding.bufferGPU ) );

			} else if ( binding.isSampler ) {

				if ( binding.samplerGPU == null ) {

					binding.samplerGPU = this.textures.getDefaultSampler();

				}

				entries.add( GPUBindGroupEntry( binding: bindingPoint, sampler: binding.samplerGPU ) );

			} else if ( binding.isSampledTexture ) {

				if ( binding.textureGPU == null ) {

					if ( binding.isSampledCubeTexture ) {

						binding.textureGPU = this.textures.getDefaultCubeTexture();

					} else {

						binding.textureGPU = this.textures.getDefaultTexture();

					}

				}

				entries.add( 
          GPUBindGroupEntry( 
            binding: bindingPoint, 
            textureView: binding.textureGPU.createView( GPUTextureViewDescriptor( dimension: binding.dimension ) )
          )
        );

			}

			bindingPoint ++;

		}

		return this.device.createBindGroup( 
      GPUBindGroupDescriptor(
        layout: layout,
        entries: entries,
        entryCount: entries.length
      )
    );

	}

}
