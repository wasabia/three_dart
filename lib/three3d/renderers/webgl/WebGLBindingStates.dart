part of three_webgl;

class WebGLBindingStates {

  dynamic gl;
  WebGLExtensions extensions;
  WebGLAttributes attributes;
  WebGLCapabilities capabilities;

  late int maxVertexAttributes;
  var extension = null;
  bool vaoAvailable = true;

  late Map<String, dynamic> defaultState;
  late Map<String, dynamic> currentState;
  late Map<int, dynamic> bindingStates;

  WebGLBindingStates(this.gl, this.extensions, this.attributes, this.capabilities ) {
  
	  maxVertexAttributes = gl.getParameter( gl.MAX_VERTEX_ATTRIBS );

	  bindingStates = Map<int, dynamic>();

	  this.defaultState = createBindingState( null );
	  this.currentState = defaultState;
  }



	setup( object, material, program, geometry, index ) {

    // print(" WebGLBindingStates.setup object: ${object.type} ${object.id} vaoAvailable: ${vaoAvailable}  ");

		bool updateBuffers = false;

		if ( vaoAvailable ) {
			var state = getBindingState( geometry, program, material );

			if ( currentState != state ) {
        
				currentState = state;
				bindVertexArrayObject( currentState["object"] );

			}

			updateBuffers = needsUpdate( geometry, index );
  
			if ( updateBuffers ) saveCache( geometry, index );

		} else {

			var wireframe = ( material.wireframe == true );

			if ( currentState["geometry"] != geometry.id ||
				currentState["program"] != program.id ||
				currentState["wireframe"] != wireframe ) {

				currentState["geometry"] = geometry.id;
				currentState["program"] = program.id;
				currentState["wireframe"] = wireframe;

				updateBuffers = true;

			}

		}

		if ( object.isInstancedMesh == true ) {

			updateBuffers = true;

		}

		if ( index != null ) {

  
			attributes.update( index, gl.ELEMENT_ARRAY_BUFFER );

		}


		if ( updateBuffers ) {

			setupVertexAttributes( object, material, program, geometry );

			if ( index != null ) {

        var _buffer = attributes.get( index )["buffer"];

      
				gl.bindBuffer( gl.ELEMENT_ARRAY_BUFFER, _buffer);

			}

		}

	}

	createVertexArrayObject() {

		if ( capabilities.isWebGL2 ) return gl.createVertexArray();

		return extension.createVertexArrayOES();

	}

	bindVertexArrayObject( vao ) {

		if ( capabilities.isWebGL2 ) return gl.bindVertexArray( vao );

		return extension.bindVertexArrayOES( vao );

	}

	deleteVertexArrayObject( vao ) {

		if ( capabilities.isWebGL2 ) return gl.deleteVertexArray( vao );

		return extension.deleteVertexArrayOES( vao );

	}

	getBindingState( geometry, program, material ) {

		var wireframe = ( material.wireframe == true );

		var programMap = bindingStates[ geometry.id ];

		if ( programMap == null ) {

			programMap = {};
			bindingStates[ geometry.id ] = programMap;

		}

		var stateMap = programMap[ program.id ];

		if ( stateMap == null ) {

			stateMap = {};
			programMap[ program.id ] = stateMap;

		}

		var state = stateMap[ wireframe ];

		if ( state == null ) {

			state = createBindingState( createVertexArrayObject() );
			stateMap[ wireframe ] = state;

		}

		return state;

	}

	Map<String, dynamic> createBindingState( vao ) {

		var newAttributes = List<int>.filled(maxVertexAttributes, 0);
		var enabledAttributes = List<int>.filled(maxVertexAttributes, 0);
		var attributeDivisors = List<int>.filled(maxVertexAttributes, 0);

		for ( var i = 0; i < maxVertexAttributes; i ++ ) {

			newAttributes[ i ] = 0;
			enabledAttributes[ i ] = 0;
			attributeDivisors[ i ] = 0;

		}

		return {

			// for backward compatibility on non-VAO support browser
			"geometry": null,
			"program": null,
			"wireframe": false,

			"newAttributes": newAttributes,
			"enabledAttributes": enabledAttributes,
			"attributeDivisors": attributeDivisors,
			"object": vao,
			"attributes": {},
			"index": null

		};

	}

	needsUpdate( geometry, index ) {

		var cachedAttributes = currentState["attributes"];
		var geometryAttributes = geometry.attributes;

		var attributesNum = 0;

		geometryAttributes.keys.forEach(( key ) {

			var cachedAttribute = cachedAttributes[ key ];
			var geometryAttribute = geometryAttributes[ key ];

			if ( cachedAttribute == null ) return true;

			if ( cachedAttribute["attribute"] != geometryAttribute ) return true;

			if ( cachedAttribute["data"] != geometryAttribute.data ) return true;

			attributesNum ++;

		});

		if ( currentState["attributesNum"] != attributesNum ) return true;

		if ( currentState["index"] != index ) return true;

		return false;

	}

	saveCache( geometry, index ) {

		var cache = {};
		var attributes = geometry.attributes;
		var attributesNum = 0;

		attributes.keys.forEach( (key) {

			var attribute = attributes[ key ];

			var data = {};
			data["attribute"] = attribute;

			if ( attribute.data != null ) {

				data["data"] = attribute.data;

			}

			cache[ key ] = data;

			attributesNum ++;

		});

		currentState["attributes"] = cache;
		currentState["attributesNum"] = attributesNum;

		currentState["index"] = index;

	}

	initAttributes() {

		var newAttributes = currentState["newAttributes"];



		for ( var i = 0, il = newAttributes.length; i < il; i ++ ) {

			newAttributes[ i ] = 0;

		}

	}

	enableAttribute( attribute ) {

		enableAttributeAndDivisor( attribute, 0 );

	}

	enableAttributeAndDivisor( attribute, meshPerAttribute ) {


		var newAttributes = currentState["newAttributes"];
		var enabledAttributes = currentState["enabledAttributes"];
		var attributeDivisors = currentState["attributeDivisors"];

		newAttributes[ attribute ] = 1;


		if ( enabledAttributes[ attribute ] == 0 ) {

 
			gl.enableVertexAttribArray( attribute );
			enabledAttributes[ attribute ] = 1;

		}

		if ( attributeDivisors[ attribute ] != meshPerAttribute ) {

			var extension = capabilities.isWebGL2 ? gl : extensions.get( 'ANGLE_instanced_arrays' );

			extension[ capabilities.isWebGL2 ? 'vertexAttribDivisor' : 'vertexAttribDivisorANGLE' ]( attribute, meshPerAttribute );
			attributeDivisors[ attribute ] = meshPerAttribute;

		}

	}

	disableUnusedAttributes() {

		var newAttributes = currentState["newAttributes"];
		var enabledAttributes = currentState["enabledAttributes"];

		for ( var i = 0, il = enabledAttributes.length; i < il; i ++ ) {

			if ( enabledAttributes[ i ] != newAttributes[ i ] ) {

  

				gl.disableVertexAttribArray( i );
				enabledAttributes[ i ] = 0;

			}

		}

	}

	vertexAttribPointer( index, size, type, normalized, stride, offset ) {


		if ( capabilities.isWebGL2 == true && ( type == gl.INT || type == gl.UNSIGNED_INT ) ) {


			gl.vertexAttribIPointer( index, size, type, stride, offset );

		} else {

   

			gl.vertexAttribPointer( index, size, type, normalized, stride, offset );

		}

	}

	setupVertexAttributes( object, material, program, geometry ) {



		if ( capabilities.isWebGL2 == false && ( object.isInstancedMesh || geometry.isInstancedBufferGeometry ) ) {

			if ( extensions.get( 'ANGLE_instanced_arrays' ) == null ) return;

		}

		initAttributes();

		var geometryAttributes = geometry.attributes;

		var programAttributes = program.getAttributes();

		var materialDefaultAttributeValues = material.defaultAttributeValues;


		for( var name in programAttributes.keys ) {

			var programAttribute = programAttributes[ name ];


			if ( programAttribute >= 0 ) {

				var geometryAttribute = geometryAttributes[ name ];

				if ( geometryAttribute != null ) {
      
					var normalized = geometryAttribute.normalized;
					var size = geometryAttribute.itemSize;

					var attribute = attributes.get( geometryAttribute );

					// TODO Attribute may not be available on context restore

					if ( attribute == null ) {
            continue;
          }

					var buffer = attribute["buffer"];
					var type = attribute["type"];
					var bytesPerElement = attribute["bytesPerElement"];

    
					if ( geometryAttribute.isInterleavedBufferAttribute ) {
    
						var data = geometryAttribute.data;
						var stride = data.stride;
						var offset = geometryAttribute.offset;

						if ( data && data.isInstancedInterleavedBuffer ) {

							enableAttributeAndDivisor( programAttribute, data.meshPerAttribute );

							if ( geometry._maxInstanceCount == null ) {

								geometry._maxInstanceCount = data.meshPerAttribute * data.count;

							}

						} else {

							enableAttribute( programAttribute );

						}

						gl.bindBuffer( gl.ARRAY_BUFFER, buffer );
						vertexAttribPointer( programAttribute, size, type, normalized, stride * bytesPerElement, offset * bytesPerElement );

					} else {

						if ( geometryAttribute.isInstancedBufferAttribute ) {

							enableAttributeAndDivisor( programAttribute, geometryAttribute.meshPerAttribute );

							if ( geometry._maxInstanceCount == null ) {

								geometry._maxInstanceCount = geometryAttribute.meshPerAttribute * geometryAttribute.count;

							}

						} else {

    

							enableAttribute( programAttribute );

						}

      
     
						gl.bindBuffer( gl.ARRAY_BUFFER, buffer );
						vertexAttribPointer( programAttribute, size, type, normalized, 0, 0 );

					}

				} else if ( name == 'instanceMatrix' ) {

 
					var attribute = attributes.get( object.instanceMatrix );

					// TODO Attribute may not be available on context restore

					if ( attribute == null ) {
            continue;
          }

					var buffer = attribute.buffer;
					var type = attribute.type;

					enableAttributeAndDivisor( programAttribute + 0, 1 );
					enableAttributeAndDivisor( programAttribute + 1, 1 );
					enableAttributeAndDivisor( programAttribute + 2, 1 );
					enableAttributeAndDivisor( programAttribute + 3, 1 );

					gl.bindBuffer( gl.ARRAY_BUFFER, buffer );

					gl.vertexAttribPointer( programAttribute + 0, 4, type, false, 64, 0 );
					gl.vertexAttribPointer( programAttribute + 1, 4, type, false, 64, 16 );
					gl.vertexAttribPointer( programAttribute + 2, 4, type, false, 64, 32 );
					gl.vertexAttribPointer( programAttribute + 3, 4, type, false, 64, 48 );

				} else if ( name == 'instanceColor' ) {

   
					var attribute = attributes.get( object.instanceColor );

					// TODO Attribute may not be available on context restore

					if ( attribute == null ) {
            continue;
          }

					var buffer = attribute.buffer;
					var type = attribute.type;

					enableAttributeAndDivisor( programAttribute, 1 );

					gl.bindBuffer( gl.ARRAY_BUFFER, buffer );

					gl.vertexAttribPointer( programAttribute, 3, type, false, 12, 0 );

				} else if ( materialDefaultAttributeValues != null ) {

      
					var value = materialDefaultAttributeValues[ name ];

					if ( value != null ) {

						switch ( value.length ) {

							case 2:
								gl.vertexAttrib2fv( programAttribute, value );
								break;

							case 3:
								gl.vertexAttrib3fv( programAttribute, value );
								break;

							case 4:
								gl.vertexAttrib4fv( programAttribute, value );
								break;

							default:
								gl.vertexAttrib1fv( programAttribute, value );

						}

					}

				}

			}
		};

		disableUnusedAttributes();

	}

	dispose() {

		reset();


		// for ( var geometryId in bindingStates ) {

		// 	var programMap = bindingStates[ geometryId ];

		// 	for ( var programId in programMap ) {

		// 		var stateMap = programMap[ programId ];

		// 		for ( var wireframe in stateMap ) {

		// 			deleteVertexArrayObject( stateMap[ wireframe ].object );

		// 			delete stateMap[ wireframe ];

		// 		}

		// 		delete programMap[ programId ];

		// 	}

		// 	delete bindingStates[ geometryId ];

		// }

	}

	releaseStatesOfGeometry( geometry ) {

		if ( this.bindingStates[ geometry.id ] == null ) return;

		var programMap = this.bindingStates[ geometry.id ];

		for ( var programId in programMap ) {

			var stateMap = programMap[ programId ];

			for ( var wireframe in stateMap ) {

				deleteVertexArrayObject( stateMap[ wireframe ].object );

				stateMap.remove(wireframe);

			}

			programMap.remove( programId );

		}

		bindingStates.remove( geometry.id );

	}

	releaseStatesOfProgram( program ) {

    print(" WebGLBindingStates releaseStatesOfProgram ");


		// for ( var geometryId in bindingStates ) {

		// 	var programMap = bindingStates[ geometryId ];

		// 	if ( programMap[ program.id ] == null ) continue;

		// 	var stateMap = programMap[ program.id ];

		// 	for ( var wireframe in stateMap ) {

		// 		deleteVertexArrayObject( stateMap[ wireframe ].object );

		// 		delete stateMap[ wireframe ];

		// 	}

		// 	delete programMap[ program.id ];

		// }

	}

	reset() {

		resetDefaultState();

		if ( currentState == defaultState ) return;

		currentState = defaultState;
		bindVertexArrayObject( currentState["object"] );

	}

	// for backward-compatilibity

	resetDefaultState() {

		defaultState["geometry"] = null;
		defaultState["program"] = null;
		defaultState["wireframe"] = false;

	}


}

