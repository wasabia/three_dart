part of three_loaders;

class BufferGeometryLoader extends Loader {

	BufferGeometryLoader( manager ) : super(manager) {

	}

  loadAsync (  url, Function? onProgress ) async {
    var completer = Completer();

    load(
      url, 
      (data) {
        completer.complete(data);
      }, 
      onProgress, 
      () {}
    );

    return completer.future;
	}

	load( url, onLoad, onProgress, onError ) {

		var scope = this;

		var loader = new FileLoader( scope.manager );
		loader.setPath( scope.path );
		loader.setRequestHeader( scope.requestHeader );
		loader.setWithCredentials( scope.withCredentials );
		loader.load( url, ( text ) {

			// try {

				onLoad!( scope.parse( convert.jsonDecode( text ) ) );

			// } catch ( e ) {

			// 	if ( onError != null ) {

			// 		onError( e );

			// 	} else {

			// 		print( e );

			// 	}

			// 	scope.manager.itemError( url );

			// }

		}, onProgress, onError );

	}

	parse( json, {String? path, Function? onLoad, Function? onError} ) {

		var interleavedBufferMap = {};
		var arrayBufferMap = {};

    Function getArrayBuffer = ( json, uuid ) {

			if ( arrayBufferMap[ uuid ] != null ) return arrayBufferMap[ uuid ];

			var arrayBuffers = json.arrayBuffers;
			var arrayBuffer = arrayBuffers[ uuid ];

			var ab = new Uint32Array( arrayBuffer ).buffer;

			arrayBufferMap[ uuid ] = ab;

			return ab;

		};

		Function getInterleavedBuffer = ( json, uuid ) {

			if ( interleavedBufferMap[ uuid ] != null ) return interleavedBufferMap[ uuid ];

			var interleavedBuffers = json.interleavedBuffers;
			var interleavedBuffer = interleavedBuffers[ uuid ];

			var buffer = getArrayBuffer( json, interleavedBuffer.buffer );

			var array = getTypedArray( interleavedBuffer.type, buffer );
			var ib = new InterleavedBuffer( array, interleavedBuffer.stride );
			ib.uuid = interleavedBuffer.uuid;

			interleavedBufferMap[ uuid ] = ib;

			return ib;

		};

		

		var geometry = json["isInstancedBufferGeometry"] == true ? new InstancedBufferGeometry() : new BufferGeometry();

		var index = json["data"]["index"];

		if ( index != null ) {

			var typedArray = getTypedArray( index["type"], index["array"] );
			geometry.setIndex( new BufferAttribute( typedArray, 1, false ) );

		}

		var attributes = json["data"]["attributes"];

		for ( var key in attributes.keys ) {

			var attribute = attributes[ key ];
			var bufferAttribute;

			if ( attribute["isInterleavedBufferAttribute"] == true ) {

				var interleavedBuffer = getInterleavedBuffer( json["data"], attribute["data"] );
				bufferAttribute = new InterleavedBufferAttribute( interleavedBuffer, attribute["itemSize"], attribute["offset"], attribute["normalized"] );

			} else {

				var typedArray = getTypedArray( attribute["type"], attribute["array"] );
				// var bufferAttributeConstr = attribute.isInstancedBufferAttribute ? InstancedBufferAttribute : BufferAttribute;
				if(attribute["isInstancedBufferAttribute"] == true) {
          bufferAttribute = new InstancedBufferAttribute( typedArray, attribute["itemSize"], attribute["normalized"] );
        } else {
          bufferAttribute = new BufferAttribute( typedArray, attribute["itemSize"], attribute["normalized"] == true );
        }
			}

			if ( attribute["name"] != null ) bufferAttribute.name = attribute["name"];
			if ( attribute["usage"] != null ) bufferAttribute.setUsage( attribute["usage"] );

			if ( attribute["updateRange"] != null ) {

				bufferAttribute.updateRange.offset = attribute["updateRange"]["offset"];
				bufferAttribute.updateRange.count = attribute["updateRange"]["count"];

			}

			geometry.setAttribute( key, bufferAttribute );

		}

		var morphAttributes = json["data"]["morphAttributes"];

		if ( morphAttributes != null ) {

			for ( var key in morphAttributes.keys ) {

				var attributeArray = morphAttributes[ key ];

				List<BufferAttribute> array = [];

				for ( var i = 0, il = attributeArray.length; i < il; i ++ ) {

					var attribute = attributeArray[ i ];
					var bufferAttribute;

					if ( attribute.isInterleavedBufferAttribute ) {

						var interleavedBuffer = getInterleavedBuffer( json["data"], attribute.data );
						bufferAttribute = new InterleavedBufferAttribute( interleavedBuffer, attribute.itemSize, attribute.offset, attribute.normalized );

					} else {

						var typedArray = getTypedArray( attribute.type, attribute.array );
						bufferAttribute = new BufferAttribute( typedArray, attribute.itemSize, attribute.normalized );

					}

					if ( attribute.name != null ) bufferAttribute.name = attribute.name;
					array.add( bufferAttribute );

				}

				geometry.morphAttributes[ key ] = array;

			}

		}

		var morphTargetsRelative = json["data"]["morphTargetsRelative"];

		if ( morphTargetsRelative == true ) {

			geometry.morphTargetsRelative = true;

		}

		var groups = json["data"]["groups"] ?? json["data"]["drawcalls"] ?? json["data"]["offsets"];

		if ( groups != null ) {

			for ( var i = 0, n = groups.length; i != n; ++ i ) {

				var group = groups[ i ];

				geometry.addGroup( group["start"], group["count"], materialIndex: group["materialIndex"] );

			}

		}

		var boundingSphere = json["data"]["boundingSphere"];

		if ( boundingSphere != null ) {

			var center = new Vector3(0,0,0);

			if ( boundingSphere["center"] != null ) {

				center.fromArray( boundingSphere["center"] );

			}

			geometry.boundingSphere = new Sphere( center, boundingSphere["radius"] );

		}

		if ( json["name"] != null ) geometry.name = json["name"];
		if ( json["userData"] != null ) geometry.userData = json["userData"];

		return geometry;

	}

}

