part of three_webgpu;


class WebGPURenderPipeline {
  
  String? cacheKey;
  late dynamic shaderAttributes;
  late WebGPUProgrammableStage stageVertex;
  late WebGPUProgrammableStage stageFragment;
  late int usedTimes;
  late GPUDevice _device;
  late dynamic _renderer;
  late int _sampleCount;
  late dynamic pipeline;

	WebGPURenderPipeline( device, renderer, sampleCount ) {

		this.cacheKey = null;
		this.shaderAttributes = null;
		// this.stageVertex = null;
		// this.stageFragment = null;
		this.usedTimes = 0;

		this._device = device;
		this._renderer = renderer;
		this._sampleCount = sampleCount;

	}

	init( cacheKey, WebGPUProgrammableStage stageVertex, WebGPUProgrammableStage stageFragment, object, nodeBuilder ) {

		var material = object.material;
		var geometry = object.geometry;

		// determine shader attributes

		var shaderAttributes = this._getShaderAttributes( nodeBuilder, geometry );

		// vertex buffers

		List<GPUVertexBufferLayout> vertexBuffers = [];

		for ( var attribute in shaderAttributes ) {

			var name = attribute["name"];
			var geometryAttribute = geometry.getAttribute( name );
			var stepMode = ( geometryAttribute != undefined && geometryAttribute.isInstancedBufferAttribute ) ? GPUInputStepMode.Instance : GPUInputStepMode.Vertex;

			vertexBuffers.add( GPUVertexBufferLayout(
				arrayStride: attribute["arrayStride"],
				attributes: [ GPUVertexAttribute( shaderLocation: attribute["slot"], offset: 0, format: attribute["format"] ) ],
				stepMode: stepMode
      ) );

		}

		this.cacheKey = cacheKey;
		this.shaderAttributes = shaderAttributes;
		this.stageVertex = stageVertex;
		this.stageFragment = stageFragment;

		// blending

		var alphaBlend = {};
		var colorBlend = {};

		if ( material.transparent == true && material.blending != NoBlending ) {

			alphaBlend = this._getAlphaBlend( material );
			colorBlend = this._getColorBlend( material );

		}

		// stencil

		var stencilFront = {};

		if ( material.stencilWrite == true ) {

			stencilFront = {
				"compare": this._getStencilCompare( material ),
				"failOp": this._getStencilOperation( material.stencilFail ),
				"depthFailOp": this._getStencilOperation( material.stencilZFail ),
				"passOp": this._getStencilOperation( material.stencilZPass )
			};

		}

		//

		var primitiveState = this._getPrimitiveState( object, material );
		var colorWriteMask = this._getColorWriteMask( material );
		var depthCompare = this._getDepthCompare( material );
		var colorFormat = this._renderer.getCurrentColorFormat();
		var depthStencilFormat = this._renderer.getCurrentDepthStencilFormat();




    var _vertexState = GPUVertexState(
      module: stageVertex.stage["module"],
      entryPoint: stageVertex.stage["entryPoint"],
      buffers: vertexBuffers
    );
    var _fragmentState = GPUFragmentState(
      entryPoint: stageFragment.stage["entryPoint"],
      module: stageFragment.stage["module"],
      targets: GPUColorTargetState(
        blend: GPUBlendState(
          alpha: GPUBlendComponent(
            srcFactor: alphaBlend["srcFactor"],
            dstFactor: alphaBlend["dstFactor"],
            operation: alphaBlend["operation"],
          ), color: GPUBlendComponent(
            srcFactor: alphaBlend["srcFactor"],
            dstFactor: alphaBlend["dstFactor"],
            operation: alphaBlend["operation"],
          )
        ),
        format: colorFormat,
        writeMask: colorWriteMask
      )
    );
    var _depthStencilState = GPUDepthStencilState(
      format: depthStencilFormat,
      depthWriteEnabled: material.depthWrite,
      depthCompare: depthCompare,
      stencilFront: GPUStencilFaceState(
        compare: stencilFront['compare']
      ),
      // stencilBack: {}, // three.js does not provide an API to configure the back function (gl.stencilFuncSeparate() was never used)
      // stencilBack: GPUStencilFaceState(
      //   compare: GPUCompareFunction.Never
      // ),
      stencilReadMask: material.stencilFuncMask,
      stencilWriteMask: material.stencilWriteMask
    );



    var _renderPipelineDescriptor = GPURenderPipelineDescriptor(
      vertex: _vertexState,
      fragment: _fragmentState,
      primitive: primitiveState,
      depthStencil: _depthStencilState,
      multisample: GPUMultisampleState(count: this._sampleCount)
    );

		this.pipeline = this._device.createRenderPipeline( _renderPipelineDescriptor );

	}

	_getArrayStride( type, bytesPerElement ) {

		// @TODO: This code is GLSL specific. We need to update when we switch to WGSL.

		if ( type == 'float' || type == 'int' || type == 'uint' ) return bytesPerElement;
		if ( type == 'vec2' || type == 'ivec2' || type == 'uvec2' ) return bytesPerElement * 2;
		if ( type == 'vec3' || type == 'ivec3' || type == 'uvec3' ) return bytesPerElement * 3;
		if ( type == 'vec4' || type == 'ivec4' || type == 'uvec4' ) return bytesPerElement * 4;

		console.error( 'THREE.WebGPURenderer: Shader variable type not supported yet.', type );

	}

	_getAlphaBlend( material ) {

		var blending = material.blending;
		var premultipliedAlpha = material.premultipliedAlpha;

		var alphaBlend = undefined;

		switch ( blending ) {

			case NormalBlending:

				if ( premultipliedAlpha == false ) {

					alphaBlend = {
						"srcFactor": GPUBlendFactor.One,
						"dstFactor": GPUBlendFactor.OneMinusSrcAlpha,
						"operation": GPUBlendOperation.Add
					};

				}

				break;

			case AdditiveBlending:
				// no alphaBlend settings
				break;

			case SubtractiveBlending:

				if ( premultipliedAlpha == true ) {

					alphaBlend = {
						"srcFactor": GPUBlendFactor.OneMinusSrcColor,
						"dstFactor": GPUBlendFactor.OneMinusSrcAlpha,
						"operation": GPUBlendOperation.Add
					};

				}

				break;

			case MultiplyBlending:
				if ( premultipliedAlpha == true ) {

					alphaBlend = {
						"srcFactor": GPUBlendFactor.Zero,
						"dstFactor": GPUBlendFactor.SrcAlpha,
						"operation": GPUBlendOperation.Add
					};

				}

				break;

			case CustomBlending:

				var blendSrcAlpha = material.blendSrcAlpha;
				var blendDstAlpha = material.blendDstAlpha;
				var blendEquationAlpha = material.blendEquationAlpha;

				if ( blendSrcAlpha != null && blendDstAlpha != null && blendEquationAlpha != null ) {

					alphaBlend = {
						"srcFactor": this._getBlendFactor( blendSrcAlpha ),
						"dstFactor": this._getBlendFactor( blendDstAlpha ),
						"operation": this._getBlendOperation( blendEquationAlpha )
					};

				}

				break;

			default:
				console.error( 'THREE.WebGPURenderer: Blending not supported.', blending );

		}

		return alphaBlend;

	}

	_getBlendFactor( blend ) {

		var blendFactor;

		switch ( blend ) {

			case ZeroFactor:
				blendFactor = GPUBlendFactor.Zero;
				break;

			case OneFactor:
				blendFactor = GPUBlendFactor.One;
				break;

			case SrcColorFactor:
				blendFactor = GPUBlendFactor.SrcColor;
				break;

			case OneMinusSrcColorFactor:
				blendFactor = GPUBlendFactor.OneMinusSrcColor;
				break;

			case SrcAlphaFactor:
				blendFactor = GPUBlendFactor.SrcAlpha;
				break;

			case OneMinusSrcAlphaFactor:
				blendFactor = GPUBlendFactor.OneMinusSrcAlpha;
				break;

			case DstColorFactor:
				blendFactor = GPUBlendFactor.DstColor;
				break;

			case OneMinusDstColorFactor:
				blendFactor = GPUBlendFactor.OneMinusDstColor;
				break;

			case DstAlphaFactor:
				blendFactor = GPUBlendFactor.DstAlpha;
				break;

			case OneMinusDstAlphaFactor:
				blendFactor = GPUBlendFactor.OneMinusDstAlpha;
				break;

			case SrcAlphaSaturateFactor:
				blendFactor = GPUBlendFactor.SrcAlphaSaturated;
				break;

			// case BlendColorFactor:
			// 	blendFactor = GPUBlendFactor.BlendColor;
			// 	break;

			// case OneMinusBlendColorFactor:
			// 	blendFactor = GPUBlendFactor.OneMinusBlendColor;
			// 	break;


			default:
				console.error( 'THREE.WebGPURenderer: Blend factor not supported.', blend );

		}

		return blendFactor;

	}

	_getBlendOperation( blendEquation ) {

		var blendOperation;

		switch ( blendEquation ) {

			case AddEquation:
				blendOperation = GPUBlendOperation.Add;
				break;

			case SubtractEquation:
				blendOperation = GPUBlendOperation.Subtract;
				break;

			case ReverseSubtractEquation:
				blendOperation = GPUBlendOperation.ReverseSubtract;
				break;

			case MinEquation:
				blendOperation = GPUBlendOperation.Min;
				break;

			case MaxEquation:
				blendOperation = GPUBlendOperation.Max;
				break;

			default:
				console.error( 'THREE.WebGPURenderer: Blend equation not supported.', blendEquation );

		}

		return blendOperation;

	}

	_getColorBlend( material ) {

		var blending = material.blending;
		var premultipliedAlpha = material.premultipliedAlpha;

		var colorBlend = {
			// "srcFactor": null,
			// "dstFactor": null,
			// "operation": null
		};

		switch ( blending ) {

			case NormalBlending:

				colorBlend["srcFactor"] = ( premultipliedAlpha == true ) ? GPUBlendFactor.One : GPUBlendFactor.SrcAlpha;
				colorBlend["dstFactor"] = GPUBlendFactor.OneMinusSrcAlpha;
				colorBlend["operation"] = GPUBlendOperation.Add;
				break;

			case AdditiveBlending:
				colorBlend["srcFactor"] = ( premultipliedAlpha == true ) ? GPUBlendFactor.One : GPUBlendFactor.SrcAlpha;
				colorBlend["operation"] = GPUBlendOperation.Add;
				break;

			case SubtractiveBlending:
				colorBlend["srcFactor"] = GPUBlendFactor.Zero;
				colorBlend["dstFactor"] = ( premultipliedAlpha == true ) ? GPUBlendFactor.Zero : GPUBlendFactor.OneMinusSrcColor;
				colorBlend["operation"] = GPUBlendOperation.Add;
				break;

			case MultiplyBlending:
				colorBlend["srcFactor"] = GPUBlendFactor.Zero;
				colorBlend["dstFactor"] = GPUBlendFactor.SrcColor;
				colorBlend["operation"] = GPUBlendOperation.Add;
				break;

			case CustomBlending:
				colorBlend["srcFactor"] = this._getBlendFactor( material.blendSrc );
				colorBlend["dstFactor"] = this._getBlendFactor( material.blendDst );
				colorBlend["operation"] = this._getBlendOperation( material.blendEquation );
				break;

			default:
				console.error( 'THREE.WebGPURenderer: Blending not supported.', blending );

		}

		return colorBlend;

	}

	_getColorWriteMask( material ) {

		return ( material.colorWrite == true ) ? GPUColorWriteFlags.All : GPUColorWriteFlags.None;

	}

	_getDepthCompare( material ) {

		var depthCompare;

		if ( material.depthTest == false ) {

			depthCompare = GPUCompareFunction.Always;

		} else {

			var depthFunc = material.depthFunc;

			switch ( depthFunc ) {

				case NeverDepth:
					depthCompare = GPUCompareFunction.Never;
					break;

				case AlwaysDepth:
					depthCompare = GPUCompareFunction.Always;
					break;

				case LessDepth:
					depthCompare = GPUCompareFunction.Less;
					break;

				case LessEqualDepth:
					depthCompare = GPUCompareFunction.LessEqual;
					break;

				case EqualDepth:
					depthCompare = GPUCompareFunction.Equal;
					break;

				case GreaterEqualDepth:
					depthCompare = GPUCompareFunction.GreaterEqual;
					break;

				case GreaterDepth:
					depthCompare = GPUCompareFunction.Greater;
					break;

				case NotEqualDepth:
					depthCompare = GPUCompareFunction.NotEqual;
					break;

				default:
					console.error( 'THREE.WebGPURenderer: Invalid depth function.', depthFunc );

			}

		}

		return depthCompare;

	}

	_getPrimitiveState( object, material ) {

		var descriptor = {};

		descriptor["topology"] = this._getPrimitiveTopology( object );

		if ( object.isLine == true && object.isLineSegments != true ) {

			var geometry = object.geometry;
			var count = ( geometry.index ) ? geometry.index.count : geometry.attributes.position.count;
			descriptor["stripIndexFormat"] = ( count > 65535 ) ? GPUIndexFormat.Uint32 : GPUIndexFormat.Uint16; // define data type for primitive restart value

		}

		switch ( material.side ) {

			case FrontSide:
				descriptor["frontFace"] = GPUFrontFace.CCW;
				descriptor["cullMode"] = GPUCullMode.Back;
				break;

			case BackSide:
				descriptor["frontFace"] = GPUFrontFace.CW;
				descriptor["cullMode"] = GPUCullMode.Back;
				break;

			case DoubleSide:
				descriptor["frontFace"] = GPUFrontFace.CCW;
				descriptor["cullMode"] = GPUCullMode.None;
				break;

			default:
				console.error( 'THREE.WebGPURenderer: Unknown Material.side value.', material.side );
				break;

		}

		return GPUPrimitiveState(
      topology: descriptor["topology"],
      stripIndexFormat: descriptor["stripIndexFormat"],
      frontFace: descriptor["frontFace"],
      cullMode: descriptor["cullMode"],
    );

	}

	_getPrimitiveTopology( object ) {

		if ( object.isMesh ) return GPUPrimitiveTopology.TriangleList;
		else if ( object.isPoints ) return GPUPrimitiveTopology.PointList;
		else if ( object.isLineSegments ) return GPUPrimitiveTopology.LineList;
		else if ( object.isLine ) return GPUPrimitiveTopology.LineStrip;

	}

	_getStencilCompare( material ) {

		var stencilCompare;

		var stencilFunc = material.stencilFunc;

		switch ( stencilFunc ) {

			case NeverStencilFunc:
				stencilCompare = GPUCompareFunction.Never;
				break;

			case AlwaysStencilFunc:
				stencilCompare = GPUCompareFunction.Always;
				break;

			case LessStencilFunc:
				stencilCompare = GPUCompareFunction.Less;
				break;

			case LessEqualStencilFunc:
				stencilCompare = GPUCompareFunction.LessEqual;
				break;

			case EqualStencilFunc:
				stencilCompare = GPUCompareFunction.Equal;
				break;

			case GreaterEqualStencilFunc:
				stencilCompare = GPUCompareFunction.GreaterEqual;
				break;

			case GreaterStencilFunc:
				stencilCompare = GPUCompareFunction.Greater;
				break;

			case NotEqualStencilFunc:
				stencilCompare = GPUCompareFunction.NotEqual;
				break;

			default:
				console.error( 'THREE.WebGPURenderer: Invalid stencil function.', stencilFunc );

		}

		return stencilCompare;

	}

	_getStencilOperation( op ) {

		var stencilOperation;

		switch ( op ) {

			case KeepStencilOp:
				stencilOperation = GPUStencilOperation.Keep;
				break;

			case ZeroStencilOp:
				stencilOperation = GPUStencilOperation.Zero;
				break;

			case ReplaceStencilOp:
				stencilOperation = GPUStencilOperation.Replace;
				break;

			case InvertStencilOp:
				stencilOperation = GPUStencilOperation.Invert;
				break;

			case IncrementStencilOp:
				stencilOperation = GPUStencilOperation.IncrementClamp;
				break;

			case DecrementStencilOp:
				stencilOperation = GPUStencilOperation.DecrementClamp;
				break;

			case IncrementWrapStencilOp:
				stencilOperation = GPUStencilOperation.IncrementWrap;
				break;

			case DecrementWrapStencilOp:
				stencilOperation = GPUStencilOperation.DecrementWrap;
				break;

			default:
				console.error( 'THREE.WebGPURenderer: Invalid stencil operation.', stencilOperation );

		}

		return stencilOperation;

	}

	_getVertexFormat( type, bytesPerElement ) {

		// float

		if ( type == 'float' ) return GPUVertexFormat.Float32;

		if ( type == 'vec2' ) {

			if ( bytesPerElement == 2 ) {

				return GPUVertexFormat.Float16x2;

			} else {

				return GPUVertexFormat.Float32x2;

			}

		}

		if ( type == 'vec3' ) return GPUVertexFormat.Float32x3;

		if ( type == 'vec4' ) {

			if ( bytesPerElement == 2 ) {

				return GPUVertexFormat.Float16x4;

			} else {

				return GPUVertexFormat.Float32x4;

			}

		}

		// int

		if ( type == 'int' ) return GPUVertexFormat.Sint32;

		if ( type == 'ivec2' ) {

			if ( bytesPerElement == 1 ) {

				return GPUVertexFormat.Sint8x2;

			} else if ( bytesPerElement == 2 ) {

				return GPUVertexFormat.Sint16x2;

			} else {

				return GPUVertexFormat.Sint32x2;

			}

		}

		if ( type == 'ivec3' ) return GPUVertexFormat.Sint32x3;

		if ( type == 'ivec4' ) {

			if ( bytesPerElement == 1 ) {

				return GPUVertexFormat.Sint8x4;

			} else if ( bytesPerElement == 2 ) {

				return GPUVertexFormat.Sint16x4;

			} else {

				return GPUVertexFormat.Sint32x4;

			}

		}

		// uint

		if ( type == 'uint' ) return GPUVertexFormat.Uint32;

		if ( type == 'uvec2' ) {

			if ( bytesPerElement == 1 ) {

				return GPUVertexFormat.Uint8x2;

			} else if ( bytesPerElement == 2 ) {

				return GPUVertexFormat.Uint16x2;

			} else {

				return GPUVertexFormat.Uint32x2;

			}

		}

		if ( type == 'uvec3' ) return GPUVertexFormat.Uint32x3;

		if ( type == 'uvec4' ) {

			if ( bytesPerElement == 1 ) {

				return GPUVertexFormat.Uint8x4;

			} else if ( bytesPerElement == 2 ) {

				return GPUVertexFormat.Uint16x4;

			} else {

				return GPUVertexFormat.Uint32x4;

			}

		}

		console.error( 'THREE.WebGPURenderer: Shader variable type not supported yet.', type );

	}

	_getShaderAttributes( nodeBuilder, geometry ) {

		var nodeAttributes = nodeBuilder.attributes;
		var attributes = [];

		for ( var slot = 0; slot < nodeAttributes.length; slot ++ ) {

			var nodeAttribute = nodeAttributes[ slot ];

			var name = nodeAttribute.name;
			var type = nodeAttribute.type;

			var geometryAttribute = geometry.getAttribute( name );
			var bytesPerElement = ( geometryAttribute != undefined ) ? geometryAttribute.array.BYTES_PER_ELEMENT : 4;

			var arrayStride = this._getArrayStride( type, bytesPerElement );
			var format = this._getVertexFormat( type, bytesPerElement );

			attributes.add( {
				"name": name,
				"arrayStride": arrayStride,
				"format": format,
				"slot": slot
			} );

		}

		return attributes;

	}

}
