import 'dart:async';
import 'dart:convert' as convert;
import 'dart:html';
import 'dart:typed_data';

import 'package:three_dart/three3d/WeakMap.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/jsm/loaders/darco/index.dart';
import 'package:three_dart/three3d/loaders/index.dart';



class DRACOLoaderPlatform extends Loader with DRACOLoader {
  static WeakMap taskCache = new WeakMap();

  WeakMap workerData = WeakMap();

  String decoderPath = "";
  Map<String, dynamic> decoderConfig = {};
  late dynamic decoderBinary;
  dynamic? decoderPending;
  int workerLimit = 4;
  List workerPool = [];
  int workerNextTaskID = 1;
  String workerSourceURL = '';

  Map defaultAttributeIDs = {
    "position": 'POSITION',
    "normal": 'NORMAL',
    "color": 'COLOR',
    "uv": 'TEX_COORD'
  };
  Map defaultAttributeTypes = {
    "position": "Float32Array",
    "normal": "Float32Array",
    "color": "Float32Array",
    "uv": "Float32Array"
  };

  DRACOLoaderPlatform ( manager ) : super( manager ) {
  }

  setDecoderPath ( path ) {

		this.decoderPath = path;

		return this;

	}

	setDecoderConfig ( Map<String, dynamic> config ) {

		this.decoderConfig = config;

		return this;

	}

	setWorkerLimit ( workerLimit ) {

		this.workerLimit = workerLimit;

		return this;

	}

	load ( url, onLoad, onProgress, onError ) async {

		var loader = new FileLoader( this.manager );

		loader.setPath( this.path );
		loader.setResponseType( 'arraybuffer' );
		loader.setRequestHeader( this.requestHeader );
		loader.setWithCredentials( this.withCredentials );

		var buffer = await loader.loadAsync( url, onProgress );


    var taskConfig = {
      "attributeIDs": this.defaultAttributeIDs,
      "attributeTypes": this.defaultAttributeTypes,
      "useUniqueIDs": false
    };

    await this.decodeGeometry( buffer, taskConfig );

    if(onLoad != null) onLoad();
	}

	/** @deprecated Kept for backward-compatibility with previous DRACOLoader versions. */
	decodeDracoFile ( buffer, callback, attributeIDs, attributeTypes ) {

		var taskConfig = {
			"attributeIDs": attributeIDs ?? this.defaultAttributeIDs,
			"attributeTypes": attributeTypes ?? this.defaultAttributeTypes,
			"useUniqueIDs": attributeIDs != null
		};

		this.decodeGeometry( buffer, taskConfig ).then( callback );

	}

	decodeGeometry ( ByteBuffer buffer, taskConfig ) async {

		// TODO: For backward-compatibility, support 'attributeTypes' objects containing
		// references (rather than names) to typed array constructors. These must be
		// serialized before sending them to the worker.
		taskConfig["attributeTypes"].forEach( (attribute, _value) {

			var type = taskConfig["attributeTypes"][ attribute ];

			// if ( type.bytesPerElement != null ) {
			// 	taskConfig["attributeTypes"][ attribute ] = type.name;
			// }
      
      if(type == Float32List) {
        taskConfig["attributeTypes"][ attribute ] = "Float32Array";
      } else {
        print("DRACOLoader-Web taskConfig attributeTypes attribute: ${attribute} type: ${type} ${type.runtimeType} is not support ");
      }

		} );

		//

		String taskKey = convert.jsonEncode( taskConfig );

		// Check for an existing task using this buffer. A transferred buffer cannot be transferred
		// again from this thread.
		if ( DRACOLoaderPlatform.taskCache.has( buffer ) ) {

			var cachedTask = DRACOLoaderPlatform.taskCache.get( buffer );

			if ( cachedTask.key == taskKey ) {

				return cachedTask.promise;

			} else if ( buffer.lengthInBytes == 0 ) {

				// Technically, it would be possible to wait for the previous task to complete,
				// transfer the buffer back, and decode again with the second configuration. That
				// is complex, and I don't know of any reason to decode a Draco buffer twice in
				// different ways, so this is left unimplemented.
				throw(

					'THREE.DRACOLoader: Unable to re-decode a buffer with different ' +
					'settings. Buffer has already been transferred.'

				);

			}

		}

		//

		var worker;
		var taskID = this.workerNextTaskID ++;
		var taskCost = buffer.lengthInBytes;

		// Obtain a worker and assign a task, and construct a geometry instance
		// when the task completes.
    
    worker = await this._getWorker( taskID, taskCost );

    var completer = Completer();

    var _data = getWorkData(worker);
    var _callbacks = _data["_callbacks"] ?? {};
    _callbacks[taskID] = { "resolve": completer, "reject": null };
    _data["_callbacks"] = _callbacks;
 
    worker.postMessage( { "type": 'decode', "id": taskID, "taskConfig": taskConfig, "buffer": buffer }, [ buffer ] );

    var message = await completer.future;

    var geometryPending = this._createGeometry( message["geometry"] );

		// Remove task from the task list.
		// Note: replaced '.finally()' with '.catch().then()' block - iOS 11 support (#19416)
    if ( worker != null && taskID != null ) {
      this._releaseTask( worker, taskID );
      // this.debug();
    }

		// Cache the task result.
		DRACOLoaderPlatform.taskCache[buffer] = {
			"key": taskKey,
			"promise": geometryPending
		};

		return geometryPending;

	}

	_createGeometry ( geometryData ) {

		var geometry = new BufferGeometry();

		if ( geometryData["index"] != null ) {

			geometry.setIndex( new BufferAttribute( geometryData["index"]["array"], 1, false ) );

		}

		for ( var i = 0; i < geometryData["attributes"].length; i ++ ) {

			var attribute = geometryData["attributes"][ i ];
			var name = attribute["name"];
			var array = attribute["array"];
			var itemSize = attribute["itemSize"];

			geometry.setAttribute( name, new BufferAttribute( array, itemSize, false ) );

		}

		return geometry;

	}

	_loadLibrary ( url, responseType ) async {

		var loader = new FileLoader( this.manager );
		loader.setPath( this.decoderPath );
		loader.setResponseType( responseType );
		loader.setWithCredentials( this.withCredentials );

    final _data = await loader.loadAsync( url, null );

		return _data;
	}

	preload () async {

		await this._initDecoder();

		return this;

	}

	_initDecoder () async {

		if ( this.decoderPending != null ) return this.decoderPending;

		var useJS = this.decoderConfig["type"] == 'js';
		String jsContent;
    Uint8List? wasmLib;

		if ( useJS ) {

			jsContent = await this._loadLibrary( 'draco_decoder.js', 'text' );

		} else {

			jsContent = await this._loadLibrary( 'draco_wasm_wrapper.js', 'text' );
			wasmLib = await this._loadLibrary( 'draco_decoder.wasm', 'arraybuffer' );

		}


    if ( ! useJS ) {
      this.decoderConfig["wasmBinary"] = wasmLib!;
    }

    String fn = DRACOWorker.toString();

    var body = [
      '/* draco decoder */',
      jsContent,
      '',
      '/* worker */',
      fn.substring( fn.indexOf( '{' ) + 1, fn.lastIndexOf( '}' ) )
    ].join( '\n' );

    this.workerSourceURL = Url.createObjectUrlFromBlob( new Blob( [ body ] ) );

		return this.decoderPending;

	}

  getWorkData(worker) {

    var _data = workerData[worker];

    if(_data == null) {
      workerData[worker] = {};
      _data = workerData[worker];
    }

    return _data;
  }

	_getWorker( int taskID, taskCost ) async {

    await this._initDecoder();

		if ( this.workerPool.length < this.workerLimit ) {

      var worker = new Worker( this.workerSourceURL );

      Map _data = this.getWorkData(worker);

      _data["_callbacks"] = {};
      _data["_taskCosts"] = {};
      _data["_taskLoad"] = 0;

      worker.postMessage( { "type": 'init', "decoderConfig": this.decoderConfig } );


      worker.onMessage.listen(( e ) {

        var message = e.data;

        // print("DRACOLoader-Web e.............on message  ");

        switch ( message["type"] ) {

          case 'decode':
            var _data = this.getWorkData(worker);
            var _callbacks = _data["_callbacks"];
            _callbacks[message["id"]]["resolve"].complete(message);
            // worker._callbacks[ message.id ].resolve( message );
            break;

          case 'error':
            // worker._callbacks[ message.id ].reject( message );
            // TODO
            throw("DRACOLoader-Web error message: ${message} ");
            break;

          default:
            print( 'THREE.DRACOLoader: Unexpected message, ${message.type}' );

        }

      });

      this.workerPool.add( worker );

    } else {

      this.workerPool.sort( ( a, b ) {

        var _dataA = getWorkData(a);
        var _dataB = getWorkData(b);

        return _dataA["_taskLoad"] > _dataB["_taskLoad"] ? - 1 : 1;

      } );

    }

    var worker = this.workerPool[ this.workerPool.length - 1 ];

    var _data = getWorkData(worker);
    var _taskCosts = _data["_taskCosts"];
    _taskCosts[taskID] = taskCost;
    _data["_taskLoad"] = _data["_taskLoad"] + taskCost;

    // worker._taskCosts[ taskID ] = taskCost;
    // worker._taskLoad += taskCost;
    return worker;

	}

	_releaseTask( worker, int taskID ) {

    Map _data = this.getWorkData(worker);
    Map<int, int> _taskCosts = Map<int, int>.from(_data["_taskCosts"]);

    int _taskLoad = _data["_taskLoad"];
		_taskLoad -= _taskCosts[ taskID ]!;
    _data["_taskLoad"] = _taskLoad;

    var _callbacks = _data["_callbacks"];
    _callbacks.remove(taskID);

    _taskCosts.remove(taskID);
		// delete worker._callbacks[ taskID ];
		// delete worker._taskCosts[ taskID ];

	}

	debug () {

		print( 'Task load: ${this.workerPool.map( ( worker ) => worker._taskLoad )}' );

	}

	dispose () {

		for ( var i = 0; i < this.workerPool.length; ++ i ) {

			this.workerPool[ i ].terminate();

		}

		this.workerPool.length = 0;

		return this;

	}


}


/* WEB WORKER */

String DRACOWorker = """
function () {

	var decoderConfig;
	var decoderPending;

	onmessage = function ( e ) {

		var message = e.data;

		switch ( message.type ) {

			case 'init':
				decoderConfig = message.decoderConfig;
				decoderPending = new Promise( function ( resolve/*, reject*/ ) {

					decoderConfig.onModuleLoaded = function ( draco ) {

						// Module is Promise-like. Wrap before resolving to avoid loop.
						resolve( { draco: draco } );

					};

					DracoDecoderModule( decoderConfig ); // eslint-disable-line no-undef

				} );
				break;

			case 'decode':
				var buffer = message.buffer;
				var taskConfig = message.taskConfig;
				decoderPending.then( ( module ) => {

					var draco = module.draco;
					var decoder = new draco.Decoder();
					var decoderBuffer = new draco.DecoderBuffer();
					decoderBuffer.Init( new Int8Array( buffer ), buffer.byteLength );

					try {

						var geometry = decodeGeometry( draco, decoder, decoderBuffer, taskConfig );

						var buffers = geometry.attributes.map( ( attr ) => attr.array.buffer );

						if ( geometry.index ) buffers.push( geometry.index.array.buffer );

						self.postMessage( { type: 'decode', id: message.id, geometry }, buffers );

					} catch ( error ) {

						console.error( error );

						self.postMessage( { type: 'error', id: message.id, error: error.message } );

					} finally {

						draco.destroy( decoderBuffer );
						draco.destroy( decoder );

					}

				} );
				break;

		}

	};

	function decodeGeometry( draco, decoder, decoderBuffer, taskConfig ) {

		var attributeIDs = taskConfig.attributeIDs;
		var attributeTypes = taskConfig.attributeTypes;

		var dracoGeometry;
		var decodingStatus;

		var geometryType = decoder.GetEncodedGeometryType( decoderBuffer );

		if ( geometryType === draco.TRIANGULAR_MESH ) {

			dracoGeometry = new draco.Mesh();
			decodingStatus = decoder.DecodeBufferToMesh( decoderBuffer, dracoGeometry );

		} else if ( geometryType === draco.POINT_CLOUD ) {

			dracoGeometry = new draco.PointCloud();
			decodingStatus = decoder.DecodeBufferToPointCloud( decoderBuffer, dracoGeometry );

		} else {

			throw new Error( 'THREE.DRACOLoader: Unexpected geometry type.' );

		}

		if ( ! decodingStatus.ok() || dracoGeometry.ptr === 0 ) {

			throw new Error( 'THREE.DRACOLoader: Decoding failed: ' + decodingStatus.error_msg() );

		}

		var geometry = { index: null, attributes: [] };

		// Gather all vertex attributes.
		for ( var attributeName in attributeIDs ) {

			var attributeType = self[ attributeTypes[ attributeName ] ];

			var attribute;
			var attributeID;

			// A Draco file may be created with default vertex attributes, whose attribute IDs
			// are mapped 1:1 from their semantic name (POSITION, NORMAL, ...). Alternatively,
			// a Draco file may contain a custom set of attributes, identified by known unique
			// IDs. glTF files always do the latter, and `.drc` files typically do the former.
			if ( taskConfig.useUniqueIDs ) {

				attributeID = attributeIDs[ attributeName ];
				attribute = decoder.GetAttributeByUniqueId( dracoGeometry, attributeID );

			} else {

				attributeID = decoder.GetAttributeId( dracoGeometry, draco[ attributeIDs[ attributeName ] ] );

				if ( attributeID === - 1 ) continue;

				attribute = decoder.GetAttribute( dracoGeometry, attributeID );

			}

			geometry.attributes.push( decodeAttribute( draco, decoder, dracoGeometry, attributeName, attributeType, attribute ) );

		}

		// Add index.
		if ( geometryType === draco.TRIANGULAR_MESH ) {

			geometry.index = decodeIndex( draco, decoder, dracoGeometry );

		}

		draco.destroy( dracoGeometry );

		return geometry;

	}

	function decodeIndex( draco, decoder, dracoGeometry ) {

		var numFaces = dracoGeometry.num_faces();
		var numIndices = numFaces * 3;
		var byteLength = numIndices * 4;

		var ptr = draco._malloc( byteLength );
		decoder.GetTrianglesUInt32Array( dracoGeometry, byteLength, ptr );
		var index = new Uint32Array( draco.HEAPF32.buffer, ptr, numIndices ).slice();
		draco._free( ptr );

		return { array: index, itemSize: 1 };

	}

	function decodeAttribute( draco, decoder, dracoGeometry, attributeName, attributeType, attribute ) {

		var numComponents = attribute.num_components();
		var numPoints = dracoGeometry.num_points();
		var numValues = numPoints * numComponents;
		var byteLength = numValues * attributeType.BYTES_PER_ELEMENT;
		var dataType = getDracoDataType( draco, attributeType );

		var ptr = draco._malloc( byteLength );
		decoder.GetAttributeDataArrayForAllPoints( dracoGeometry, attribute, dataType, byteLength, ptr );
		var array = new attributeType( draco.HEAPF32.buffer, ptr, numValues ).slice();
		draco._free( ptr );

		return {
			name: attributeName,
			array: array,
			itemSize: numComponents
		};

	}

	function getDracoDataType( draco, attributeType ) {

		switch ( attributeType ) {

			case Float32Array: return draco.DT_FLOAT32;
			case Int8Array: return draco.DT_INT8;
			case Int16Array: return draco.DT_INT16;
			case Int32Array: return draco.DT_INT32;
			case Uint8Array: return draco.DT_UINT8;
			case Uint16Array: return draco.DT_UINT16;
			case Uint32Array: return draco.DT_UINT32;

		}

	}

};
""";
