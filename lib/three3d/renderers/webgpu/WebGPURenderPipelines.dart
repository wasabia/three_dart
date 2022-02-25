part of three_webgpu;



class _Stages {
  Map vertex;
  Map fragment;
  _Stages({
    required this.vertex, required this.fragment
  }) {}
}

extension MapExt on Map {
  get(key) {
    return this[key];
  }

  set(key, value) {
    this[key] = value;
  }

  delete(key) {
    remove(key);
  }
}

class WebGPURenderPipelines {

  late WebGPURenderer renderer;
  late GPUDevice device;
  late int sampleCount;
  late WebGPUNodes nodes;
  late dynamic bindings;
  late List pipelines;
  late WeakMap objectCache;
  late _Stages stages;


	WebGPURenderPipelines( renderer, device, sampleCount, nodes, [bindings = null] ) {

		this.renderer = renderer;
		this.device = device;
		this.sampleCount = sampleCount;
		this.nodes = nodes;
		this.bindings = bindings;

		this.pipelines = [];
		this.objectCache = new WeakMap();

		this.stages = _Stages(
      vertex: new Map(),
			fragment: new Map()
    );

	}

	get( object ) {

		var device = this.device;
		var material = object.material;

		Map<String, dynamic> cache = this._getCache( object );

		var currentPipeline;

		if ( this._needsUpdate( object, cache ) ) {

			// release previous cache

			if ( cache["currentPipeline"] != undefined ) {

				this._releaseObject( object );

			}

			// get shader

			WebGPUNodeBuilder nodeBuilder = this.nodes.get( object );

			// programmable stages

      
			var stageVertex = this.stages.vertex.get( nodeBuilder.vertexShader );
        
			if ( stageVertex == undefined ) {

				stageVertex = new WebGPUProgrammableStage( device, nodeBuilder.vertexShader, 'vertex' );
				this.stages.vertex.set( nodeBuilder.vertexShader, stageVertex );

			}

      
      
			var stageFragment = this.stages.fragment.get( nodeBuilder.fragmentShader );

			if ( stageFragment == undefined ) {

				stageFragment = new WebGPUProgrammableStage( device, nodeBuilder.fragmentShader, 'fragment' );
				this.stages.fragment.set( nodeBuilder.fragmentShader, stageFragment );

			}
      

			// determine render pipeline

			currentPipeline = this._acquirePipeline( stageVertex, stageFragment, object, nodeBuilder );

			cache["currentPipeline"] = currentPipeline;

			// keep track of all used times

			currentPipeline.usedTimes ++;
			stageVertex.usedTimes ++;
			stageFragment.usedTimes ++;

			// events

			material.addEventListener( 'dispose', cache["dispose"] );

		} else {

			currentPipeline = cache["currentPipeline"];

		}

		return currentPipeline;

	}

	dispose() {

		this.pipelines = [];
		this.objectCache = new WeakMap();
		// this.shaderModules = _Stages(
		// 	vertex: new Map(),
		// 	fragment: new Map()
    // );

	}

	_acquirePipeline( stageVertex, stageFragment, object, nodeBuilder ) {

		var pipeline;
		var pipelines = this.pipelines;

		// check for existing pipeline

		var cacheKey = this._computeCacheKey( stageVertex, stageFragment, object );

		for ( var i = 0, il = pipelines.length; i < il; i ++ ) {

			var preexistingPipeline = pipelines[ i ];

			if ( preexistingPipeline.cacheKey == cacheKey ) {

				pipeline = preexistingPipeline;
				break;

			}

		}

		if ( pipeline == undefined ) {

			pipeline = new WebGPURenderPipeline( this.device, this.renderer, this.sampleCount );
			pipeline.init( cacheKey, stageVertex, stageFragment, object, nodeBuilder );

			pipelines.add( pipeline );

		}

		return pipeline;

	}

	_computeCacheKey( stageVertex, stageFragment, object ) {

		var material = object.material;
		var renderer = this.renderer;

		var parameters = [
			stageVertex.id, stageFragment.id,
			material.transparent, material.blending, material.premultipliedAlpha,
			material.blendSrc, material.blendDst, material.blendEquation,
			material.blendSrcAlpha, material.blendDstAlpha, material.blendEquationAlpha,
			material.colorWrite,
			material.depthWrite, material.depthTest, material.depthFunc,
			material.stencilWrite, material.stencilFunc,
			material.stencilFail, material.stencilZFail, material.stencilZPass,
			material.stencilFuncMask, material.stencilWriteMask,
			material.side,
			this.sampleCount,
			renderer.getCurrentEncoding(), renderer.getCurrentColorFormat(), renderer.getCurrentDepthStencilFormat()
		];

		return parameters.join();

	}

	_getCache( object ) {

		var cache = this.objectCache.get( object );

		if ( cache == undefined ) {

      Map<String, dynamic> _cache = {

				"dispose": () {

					this._releaseObject( object );

					this.objectCache.delete( object );

					object.material.removeEventListener( 'dispose', cache.dispose );

				}

			};

			cache = _cache;

			this.objectCache.set( object, cache );

		}

		return cache;

	}

	_releaseObject( object ) {

		var cache = this.objectCache.get( object );

		this._releasePipeline( cache.currentPipeline );
    cache.currentPipeline = null;

		this.nodes.remove( object );
		this.bindings.remove( object );

	}

	_releasePipeline( pipeline ) {

		if ( -- pipeline.usedTimes == 0 ) {

			var pipelines = this.pipelines;

			var i = pipelines.indexOf( pipeline );
			pipelines[ i ] = pipelines[ pipelines.length - 1 ];
			pipelines.removeLast();

			this._releaseStage( pipeline.stageVertex );
			this._releaseStage( pipeline.stageFragment );

		}

	}

	_releaseStage( stage ) {

		if ( -- stage.usedTimes == 0 ) {

			var code = stage.code;
			var type = stage.type;

      if(type == "verter") {
        this.stages.vertex.delete( code );
      } else if(type == "fragment") {
        this.stages.fragment.delete( code );
      }

			

		}

	}

	_needsUpdate( object, Map<String, dynamic> cache ) {

		var material = object.material;

		var needsUpdate = false;

		// check material state

		if ( cache["material"] != material || cache["materialVersion"] != material.version ||
			cache["transparent"] != material.transparent || cache["blending"] != material.blending || cache["premultipliedAlpha"] != material.premultipliedAlpha ||
			cache["blendSrc"] != material.blendSrc || cache["blendDst"] != material.blendDst || cache["blendEquation"] != material.blendEquation ||
			cache["blendSrcAlpha"] != material.blendSrcAlpha || cache["blendDstAlpha"] != material.blendDstAlpha || cache["blendEquationAlpha"] != material.blendEquationAlpha ||
			cache["colorWrite"] != material.colorWrite ||
			cache["depthWrite"] != material.depthWrite || cache["depthTest"] != material.depthTest || cache["depthFunc"] != material.depthFunc ||
			cache["stencilWrite"] != material.stencilWrite || cache["stencilFunc"] != material.stencilFunc ||
			cache["stencilFail"] != material.stencilFail || cache["stencilZFail"] != material.stencilZFail || cache["stencilZPass"] != material.stencilZPass ||
			cache["stencilFuncMask"] != material.stencilFuncMask || cache["stencilWriteMask"] != material.stencilWriteMask ||
			cache["side"] != material.side
		) {

			cache["material"] = material; cache["materialVersion"] = material.version;
			cache["transparent"] = material.transparent; cache["blending"] = material.blending; cache["premultipliedAlpha"] = material.premultipliedAlpha;
			cache["blendSrc"] = material.blendSrc; cache["blendDst"] = material.blendDst; cache["blendEquation"] = material.blendEquation;
			cache["blendSrcAlpha"] = material.blendSrcAlpha; cache["blendDstAlpha"] = material.blendDstAlpha; cache["blendEquationAlpha"] = material.blendEquationAlpha;
			cache["colorWrite"] = material.colorWrite;
			cache["depthWrite"] = material.depthWrite; cache["depthTest"] = material.depthTest; cache["depthFunc"] = material.depthFunc;
			cache["stencilWrite"] = material.stencilWrite; cache["stencilFunc"] = material.stencilFunc;
			cache["stencilFail"] = material.stencilFail; cache["stencilZFail"] = material.stencilZFail; cache["stencilZPass"] = material.stencilZPass;
			cache["stencilFuncMask"] = material.stencilFuncMask; cache["stencilWriteMask"] = material.stencilWriteMask;
			cache["side"] = material.side;

			needsUpdate = true;

		}

		// check renderer state

		var renderer = this.renderer;

		var encoding = renderer.getCurrentEncoding();
		var colorFormat = renderer.getCurrentColorFormat();
		var depthStencilFormat = renderer.getCurrentDepthStencilFormat();

		if ( cache["sampleCount"] != this.sampleCount || cache["encoding"] != encoding ||
			cache["colorFormat"] != colorFormat || cache["depthStencilFormat"] != depthStencilFormat ) {

			cache["sampleCount"] = this.sampleCount;
			cache["encoding"] = encoding;
			cache["colorFormat"] = colorFormat;
			cache["depthStencilFormat"] = depthStencilFormat;

			needsUpdate = true;

		}

		return needsUpdate;

	}

}

