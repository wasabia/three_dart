part of three_webgpu;


var _frustum = new Frustum();
var _projScreenMatrix = new Matrix4();
var _vector3 = new Vector3();

class WebGPURenderer {

  late dynamic domElement;
  late bool autoClear;
  late bool autoClearColor;
  late bool autoClearDepth;
  late bool autoClearStencil;
  late int outputEncoding;
  late bool sortObjects;

  late Map _parameters;
  late num _pixelRatio;
  late int _width;
  late int _height;

  Map<String, dynamic>? _viewport;
  Map<String, dynamic>? _scissor;

  GPUAdapter? _adapter;
  GPUDevice? _device;
  dynamic _context;
  GPUTexture? _colorBuffer;
  GPUTexture? _depthBuffer;
  dynamic _info;
  dynamic _properties;
  dynamic _attributes;
  dynamic _geometries;
  dynamic _nodes;
  late WebGPUBindings _bindings;
  dynamic _objects = null;
  late WebGPURenderPipelines _renderPipelines;
  dynamic _computePipelines = null;
  dynamic _renderLists = null;
	dynamic _textures = null;
  dynamic _background = null;

  dynamic _currentRenderList = null;
  dynamic _opaqueSort = null;
  dynamic _transparentSort = null;

  int _clearAlpha = 1;
  late Color _clearColor;
	late int _clearDepth;
	late int _clearStencil;

	dynamic _renderTarget;

	late GPURenderPassDescriptor _renderPassDescriptor;

	WebGPURenderer( [Map? parameters] ) {
    
    parameters ??= {};

		// public

		// this.domElement = ( parameters.canvas != undefined ) ? parameters.canvas : this._createCanvasElement();

		this.autoClear = true;
		this.autoClearColor = true;
		this.autoClearDepth = true;
		this.autoClearStencil = true;

		this.outputEncoding = LinearEncoding;

		this.sortObjects = true;

		// internals

		this._parameters = {};
    this._parameters.addAll(parameters);

		this._pixelRatio = 1;
		// this._width = this.domElement.width;
		// this._height = this.domElement.height;
    this._width = this._parameters["width"];
		this._height = this._parameters["height"];

		this._viewport = null;
		this._scissor = null;

		this._adapter = null;
		this._device = null;
		this._context = null;
		this._colorBuffer = null;
		this._depthBuffer = null;

		this._info = null;
		this._properties = null;
		this._attributes = null;
		this._geometries = null;
		this._nodes = null;
		// this._bindings = null;
		this._objects = null;
		// this._renderPipelines = null;
		this._computePipelines = null;
		this._renderLists = null;
		this._textures = null;
		this._background = null;

		// this._renderPassDescriptor = null;

		this._currentRenderList = null;
		this._opaqueSort = null;
		this._transparentSort = null;

		this._clearAlpha = 1;
		this._clearColor = new Color( 0x000000 );
		this._clearDepth = 1;
		this._clearStencil = 0;

		this._renderTarget = null;

		// some parameters require default values other than "undefined"

		this._parameters["antialias"] = ( parameters["antialias"] == true );

		if ( this._parameters["antialias"] == true ) {

			this._parameters["sampleCount"] = ( parameters["sampleCount"] == undefined ) ? 4 : parameters["sampleCount"];

		} else {

			this._parameters["sampleCount"] = 1;

		}

		this._parameters["requiredFeatures"] = ( parameters["requiredFeatures"] == undefined ) ? [] : parameters["requiredFeatures"];
		this._parameters["requiredLimits"] = ( parameters["requiredLimits"] == undefined ) ? {} : parameters["requiredLimits"];

	}

	init() {

		var parameters = this._parameters;

		var adapterOptions = GPURequestAdapterOptions(
      powerPreference: parameters["powerPreference"]
    );
    
		var adapter = requestAdapter( adapterOptions );

		if ( adapter == null ) {

			throw( 'WebGPURenderer: Unable to create WebGPU adapter.' );

		}

		var deviceDescriptor = GPUDeviceDescriptor(maxBindGroups: 1);
    // "requiredFeatures": parameters["requiredFeatures"],
    // "requiredLimits": parameters["requiredLimits"]
		

		var device = adapter.requestDevice( deviceDescriptor );

		// var context = ( parameters["context"] != undefined ) ? parameters["context"] : this.domElement.getContext( 'webgpu' );

		// context.configure( {
		// 	"device": device,
		// 	"format": GPUTextureFormat.BGRA8Unorm // this is the only valid context format right now (r121)
		// } );

		this._adapter = adapter;
		this._device = device;
		// this._context = context;

		this._info = new WebGPUInfo();
		this._properties = new WebGPUProperties();
		this._attributes = new WebGPUAttributes( device );
		this._geometries = new WebGPUGeometries( this._attributes, this._info );
		this._textures = new WebGPUTextures( device, this._properties, this._info );
		this._objects = new WebGPUObjects( this._geometries, this._info );
		this._nodes = new WebGPUNodes( this );
		this._computePipelines = new WebGPUComputePipelines( device );
		this._renderPipelines = new WebGPURenderPipelines( this, device, parameters["sampleCount"], this._nodes );
    this._renderPipelines.bindings = new WebGPUBindings( device, this._info, this._properties, this._textures, this._renderPipelines, this._computePipelines, this._attributes, this._nodes );
		this._bindings = this._renderPipelines.bindings;
		this._renderLists = new WebGPURenderLists();
		this._background = new WebGPUBackground( this );

		//
        // TODO 每次都创建新对象 优化
    this._renderPassDescriptor = GPURenderPassDescriptor(
      colorAttachments: GPURenderPassColorAttachment(
        loadOp: GPULoadOp.Clear,
        storeOp: GPUStoreOp.Store
      ),
      depthStencilAttachment: GPURenderPassDepthStencilAttachment(
        depthStoreOp: GPUStoreOp.Store,
        stencilStoreOp: GPUStoreOp.Store
      )
    );

		this._setupColorBuffer();
		this._setupDepthBuffer();

	}

	render( Scene scene, camera ) {

		// @TODO: move this to animation loop

		this._nodes.updateFrame();

		if ( scene.autoUpdate == true ) scene.updateMatrixWorld();

		if ( camera.parent == null ) camera.updateMatrixWorld();

		if ( this._info.autoReset == true ) this._info.reset();

		_projScreenMatrix.multiplyMatrices( camera.projectionMatrix, camera.matrixWorldInverse );
		_frustum.setFromProjectionMatrix( _projScreenMatrix );

		this._currentRenderList = this._renderLists.get( scene, camera );
		this._currentRenderList.init();

		this._projectObject( scene, camera, 0 );

		this._currentRenderList.finish();

		if ( this.sortObjects == true ) {

			this._currentRenderList.sort( this._opaqueSort, this._transparentSort );

		}

		// prepare render pass descriptor

		var colorAttachment = this._renderPassDescriptor.colorAttachments;
		var depthStencilAttachment = this._renderPassDescriptor.depthStencilAttachment;

		var renderTarget = this._renderTarget;

		if ( renderTarget != null ) {

			// @TODO: Support RenderTarget with antialiasing.

			var renderTargetProperties = this._properties.get( renderTarget );

      GPUTexture colorTextureGPU = renderTargetProperties["colorTextureGPU"];
			colorAttachment.view = colorTextureGPU.createView();
      
      var depthTextureGPU = renderTargetProperties["depthTextureGPU"];
			depthStencilAttachment.view = depthTextureGPU.createView();


		} else {

			if ( this._parameters["antialias"] == true ) {

				colorAttachment.view = this._colorBuffer!.createView();
				colorAttachment.resolveTarget = this._context.getCurrentTexture().createView();

			} else {

				colorAttachment.view = this._context.getCurrentTexture().createView();
				colorAttachment.resolveTarget = null;

			}

			depthStencilAttachment.view = this._depthBuffer!.createView();

		}



		this._background.update( scene );

		// start render pass

		var device = this._device;
		var cmdEncoder = device!.createCommandEncoder();


		var passEncoder = cmdEncoder.beginRenderPass( this._renderPassDescriptor );

		// global rasterization settings for all renderable objects

		var vp = this._viewport;

		if ( vp != null ) {

			var width = Math.floor( vp["width"] * this._pixelRatio );
			var height = Math.floor( vp["height"] * this._pixelRatio );

			passEncoder.setViewport( vp["x"].toDouble(), vp["y"].toDouble(), width.toDouble(), height.toDouble(), vp["minDepth"].toDouble(), vp["maxDepth"].toDouble() );

		}

		var sc = this._scissor;

		if ( sc != null ) {

			var width = Math.floor( sc["width"] * this._pixelRatio );
			var height = Math.floor( sc["height"] * this._pixelRatio );

			passEncoder.setScissorRect( sc["x"], sc["y"], width, height );

		}

		// process render lists

		var opaqueObjects = this._currentRenderList.opaque;
		var transparentObjects = this._currentRenderList.transparent;

		if ( opaqueObjects.length > 0 ) this._renderObjects( opaqueObjects, camera, passEncoder );
		if ( transparentObjects.length > 0 ) this._renderObjects( transparentObjects, camera, passEncoder );

		// finish render pass

		passEncoder.endPass();
		device.queue.submit( cmdEncoder.finish() );

	}

	getContext() {

		return this._context;

	}

	getPixelRatio() {

		return this._pixelRatio;

	}

	getDrawingBufferSize( target ) {

		return target.set( this._width * this._pixelRatio, this._height * this._pixelRatio ).floor();

	}

	getSize( target ) {

		return target.set( this._width, this._height );

	}

	setPixelRatio( [value = 1] ) {

		this._pixelRatio = value;

		this.setSize( this._width, this._height, false );

	}

	setDrawingBufferSize( width, height, pixelRatio ) {

		this._width = width;
		this._height = height;

		this._pixelRatio = pixelRatio;

		this.domElement.width = Math.floor( width * pixelRatio );
		this.domElement.height = Math.floor( height * pixelRatio );

		this._configureContext();
		this._setupColorBuffer();
		this._setupDepthBuffer();

	}

	setSize( width, height, [updateStyle = true] ) {

		this._width = width;
		this._height = height;

		// this.domElement.width = Math.floor( width * this._pixelRatio );
		// this.domElement.height = Math.floor( height * this._pixelRatio );

		if ( updateStyle == true ) {

			// this.domElement.style.width = width + 'px';
			// this.domElement.style.height = height + 'px';

		}

		this._configureContext();
		this._setupColorBuffer();
		this._setupDepthBuffer();

	}

	setOpaqueSort( method ) {

		this._opaqueSort = method;

	}

	setTransparentSort( method ) {

		this._transparentSort = method;

	}

	getScissor( target ) {

		var scissor = this._scissor!;

		target.x = scissor["x"];
		target.y = scissor["y"];
		target.width = scissor["width"];
		target.height = scissor["height"];

		return target;

	}

	setScissor( x, y, width, height ) {

		if ( x == null ) {

			this._scissor = null;

		} else {

			this._scissor = {
				"x": x,
				"y": y,
				"width": width,
				"height": height
			};

		}

	}

	getViewport( target ) {

		var viewport = this._viewport!;

		target.x = viewport["x"];
		target.y = viewport["y"];
		target.width = viewport["width"];
		target.height = viewport["height"];
		target.minDepth = viewport["minDepth"];
		target.maxDepth = viewport["maxDepth"];

		return target;

	}

	setViewport( x, y, width, height, [minDepth = 0, maxDepth = 1] ) {

		if ( x == null ) {

			this._viewport = null;

		} else {

			this._viewport = {
				"x": x,
				"y": y,
				"width": width,
				"height": height,
				"minDepth": minDepth,
				"maxDepth": maxDepth
			};

		}

	}

	getCurrentEncoding() {

		var renderTarget = this.getRenderTarget();
		return ( renderTarget != null ) ? renderTarget.texture.encoding : this.outputEncoding;

	}

	getCurrentColorFormat() {

		var format;

		var renderTarget = this.getRenderTarget();

		if ( renderTarget != null ) {

			var renderTargetProperties = this._properties.get( renderTarget );
			format = renderTargetProperties["colorTextureFormat"];

		} else {

			format = GPUTextureFormat.BGRA8Unorm; // default context format

		}

		return format;

	}

	getCurrentDepthStencilFormat() {

		var format;

		var renderTarget = this.getRenderTarget();

		if ( renderTarget != null ) {

			var renderTargetProperties = this._properties.get( renderTarget );
			format = renderTargetProperties["depthTextureFormat"];

		} else {

			format = GPUTextureFormat.Depth24PlusStencil8;

		}

		return format;

	}

	getClearColor( target ) {

		return target.copy( this._clearColor );

	}

	setClearColor( color, [alpha = 1] ) {

		this._clearColor.set( color );
		this._clearAlpha = alpha;

	}

	getClearAlpha() {

		return this._clearAlpha;

	}

	setClearAlpha( alpha ) {

		this._clearAlpha = alpha;

	}

	getClearDepth() {

		return this._clearDepth;

	}

	setClearDepth( depth ) {

		this._clearDepth = depth;

	}

	getClearStencil() {

		return this._clearStencil;

	}

	setClearStencil( stencil ) {

		this._clearStencil = stencil;

	}

	clear() {

		this._background.clear();

	}

	dispose() {

		this._objects.dispose();
		this._properties.dispose();
		this._renderPipelines.dispose();
		this._computePipelines.dispose();
		this._nodes.dispose();
		this._bindings.dispose();
		this._info.dispose();
		this._renderLists.dispose();
		this._textures.dispose();

	}

	setRenderTarget( renderTarget ) {

		this._renderTarget = renderTarget;

		if ( renderTarget != null ) {

			this._textures.initRenderTarget( renderTarget );

		}

	}

	compute( computeParams ) {

		var device = this._device!;
		var cmdEncoder = device.createCommandEncoder();
		var passEncoder = cmdEncoder.beginComputePass();

		for ( var param in computeParams.keys ) {

			// pipeline

			var pipeline = this._computePipelines.get( param );
			passEncoder.setPipeline( pipeline );

			// bind group

			var bindGroup = this._bindings.getForCompute( param ).group;
			this._bindings.update( param );
			passEncoder.setBindGroup( 0, bindGroup );

			passEncoder.dispatch( param.num );

		}

		passEncoder.endPass();
		device.queue.submit( cmdEncoder.finish() );

	}

	getRenderTarget() {

		return this._renderTarget;

	}

	_projectObject( object, camera, groupOrder ) {

		var currentRenderList = this._currentRenderList;

		if ( object.visible == false ) return;

		var visible = object.layers.test( camera.layers );

		if ( visible ) {

			if ( object is Group ) {

				groupOrder = object.renderOrder;

			} else if ( object.type == "LOD" ) {

				if ( object.autoUpdate == true ) object.update( camera );

			} else if ( object is Light ) {

				//currentRenderState.pushLight( object );

				if ( object.castShadow ) {

					//currentRenderState.pushShadow( object );

				}

			} else if ( object is Sprite ) {

				if ( ! object.frustumCulled || _frustum.intersectsSprite( object ) ) {

					if ( this.sortObjects == true ) {

						_vector3.setFromMatrixPosition( object.matrixWorld ).applyMatrix4( _projScreenMatrix );

					}

					var geometry = object.geometry;
					var material = object.material;

					if ( material.visible ) {

						currentRenderList.push( object, geometry, material, groupOrder, _vector3.z, null );

					}

				}

			} else if ( object is LineLoop ) {

				console.error( 'THREE.WebGPURenderer: Objects of type THREE.LineLoop are not supported. Please use THREE.Line or THREE.LineSegments.' );

			} else if ( object.isMesh || object.isLine || object.isPoints ) {

				if ( ! object.frustumCulled || _frustum.intersectsObject( object ) ) {

					if ( this.sortObjects == true ) {

						_vector3.setFromMatrixPosition( object.matrixWorld ).applyMatrix4( _projScreenMatrix );

					}

					var geometry = object.geometry;
					var material = object.material;

					if ( material is List ) {

						var groups = geometry.groups;

						for ( var i = 0, l = groups.length; i < l; i ++ ) {

							var group = groups[ i ];
							var groupMaterial = material[ group.materialIndex ];

							if ( groupMaterial && groupMaterial.visible ) {

								currentRenderList.push( object, geometry, groupMaterial, groupOrder, _vector3.z, group );

							}

						}

					} else if ( material.visible ) {

						currentRenderList.push( object, geometry, material, groupOrder, _vector3.z, null );

					}

				}

			}

		}

		var children = object.children;

		for ( var i = 0, l = children.length; i < l; i ++ ) {

			this._projectObject( children[ i ], camera, groupOrder );

		}

	}

	_renderObjects( renderList, camera, passEncoder ) {
      
		// process renderable objects

		for ( var i = 0, il = renderList.length; i < il; i ++ ) {

			var renderItem = renderList[ i ];

			// @TODO: Add support for multiple materials per object. This will require to extract
			// the material from the renderItem object and pass it with its group data to _renderObject().

			var object = renderItem.object;

			object.modelViewMatrix.multiplyMatrices( camera.matrixWorldInverse, object.matrixWorld );
			object.normalMatrix.getNormalMatrix( object.modelViewMatrix );

			this._objects.update( object );

			if ( camera.isArrayCamera ) {

				var cameras = camera.cameras;

				for ( var j = 0, jl = cameras.length; j < jl; j ++ ) {

					var camera2 = cameras[ j ];

					if ( object.layers.test( camera2.layers ) ) {

						var vp = camera2.viewport;
						var minDepth = ( vp.minDepth == undefined ) ? 0 : vp.minDepth;
						var maxDepth = ( vp.maxDepth == undefined ) ? 1 : vp.maxDepth;

						passEncoder.setViewport( vp.x, vp.y, vp.width, vp.height, minDepth, maxDepth );

						this._nodes.update( object, camera2 );
						this._bindings.update( object );
						this._renderObject( object, passEncoder );

					}

				}

			} else {

				this._nodes.update( object, camera );

        
				this._bindings.update( object );

				this._renderObject( object, passEncoder );

			}

		}

	}

	_renderObject( object, passEncoder ) {

		var info = this._info;

		// pipeline

		var renderPipeline = this._renderPipelines.get( object );
		passEncoder.setPipeline( renderPipeline.pipeline );

		// bind group

		var bindGroup = this._bindings.get( object )["group"];
		passEncoder.setBindGroup( 0, bindGroup );

		// index

		var geometry = object.geometry;
		var index = geometry.index;

		var hasIndex = ( index != null );

		if ( hasIndex == true ) {

			this._setupIndexBuffer( index, passEncoder );

		}

		// vertex buffers

		this._setupVertexBuffers( geometry.attributes, passEncoder, renderPipeline );

		// draw

		var drawRange = geometry.drawRange;
		var firstVertex = drawRange.start;
		var instanceCount = ( geometry.isInstancedBufferGeometry ) ? geometry.instanceCount : 1;

		if ( hasIndex == true ) {

			var indexCount = ( drawRange.count != Math.Infinity ) ? drawRange.count : index.count;

			passEncoder.drawIndexed( indexCount, instanceCount, firstVertex, 0, 0 );

			info.update( object, indexCount, instanceCount );

		} else {

			var positionAttribute = geometry.attributes.position;
			var vertexCount = ( drawRange.count != Math.Infinity ) ? drawRange.count : positionAttribute.count;

			passEncoder.draw( vertexCount, instanceCount, firstVertex, 0 );

			info.update( object, vertexCount, instanceCount );

		}

	}

	_setupIndexBuffer( index, encoder ) {

		var buffer = this._attributes.get( index ).buffer;
		var indexFormat = ( index.array is Uint16Array ) ? GPUIndexFormat.Uint16 : GPUIndexFormat.Uint32;

		encoder.setIndexBuffer( buffer, indexFormat );

	}

	_setupVertexBuffers( geometryAttributes, encoder, renderPipeline ) {

		List shaderAttributes = renderPipeline.shaderAttributes;

		for ( var shaderAttribute in shaderAttributes ) {

			var name = shaderAttribute.name;
			var slot = shaderAttribute.slot;

			var attribute = geometryAttributes[ name ];

			if ( attribute != undefined ) {

				var buffer = this._attributes.get( attribute ).buffer;
				encoder.setVertexBuffer( slot, buffer );

			}

		}

	}

	_setupColorBuffer() {

		var device = this._device;

		if ( device != null ) {

			if ( this._colorBuffer != null ) this._colorBuffer!.destroy();

			this._colorBuffer = this._device!.createTexture(
        
        GPUTextureDescriptor(
          size: GPUExtent3D(
            width: Math.floor( this._width * this._pixelRatio ),
            height: Math.floor( this._height * this._pixelRatio ),
            depthOrArrayLayers: 1
          ),
          sampleCount: this._parameters["sampleCount"],
          format: GPUTextureFormat.BGRA8Unorm,
          usage: GPUTextureUsage.RenderAttachment
        )
      );

		}

	}

	_setupDepthBuffer() {

		var device = this._device;

		if ( device != null ) {

			if ( this._depthBuffer != null ) this._depthBuffer!.destroy();

			this._depthBuffer = this._device!.createTexture( 
        
        GPUTextureDescriptor(
          size: GPUExtent3D(
            width: Math.floor( this._width * this._pixelRatio ),
            height: Math.floor( this._height * this._pixelRatio ),
            depthOrArrayLayers: 1
          ),
          sampleCount: this._parameters["sampleCount"],
          format: GPUTextureFormat.Depth24PlusStencil8,
          usage: GPUTextureUsage.RenderAttachment
        )

      );

		}

	}

	_configureContext() {

		var device = this._device;

		if ( device != null ) {

			// this._context.configure( {
			// 	device: device,
			// 	format: GPUTextureFormat.BGRA8Unorm,
			// 	usage: GPUTextureUsage.RENDER_ATTACHMENT,
			// 	size: {
			// 		width: Math.floor( this._width * this._pixelRatio ),
			// 		height: Math.floor( this._height * this._pixelRatio ),
			// 		depthOrArrayLayers: 1
			// 	},
			// } );

		}

	}

	_createCanvasElement() {

		// var canvas = document.createElementNS( 'http://www.w3.org/1999/xhtml', 'canvas' );
		// canvas.style.display = 'block';
		// return canvas;

	}

}
