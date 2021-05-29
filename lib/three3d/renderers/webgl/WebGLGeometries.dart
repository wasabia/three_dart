
part of three_webgl;

class WebGLGeometries {
  dynamic gl;
  WebGLAttributes attributes;
  WebGLInfo info;
  WebGLBindingStates bindingStates;

  WebGLGeometries(this.gl, this.attributes, this.info, this.bindingStates ) {
  }


	var geometries = new WeakMap();
	var wireframeAttributes = new WeakMap();

	onGeometryDispose( event ) {

		var geometry = event.target;
		var buffergeometry = geometries.get( geometry );

		if ( buffergeometry.index != null ) {

			attributes.remove( buffergeometry.index );

		}

		for ( var name in buffergeometry.attributes.keys ) {

			attributes.remove( buffergeometry.attributes[ name ] );

		}

		geometry.removeEventListener( 'dispose', onGeometryDispose );

		geometries.delete( geometry );

		var attribute = wireframeAttributes.get( buffergeometry );

		if ( attribute != null ) {

			attributes.remove( attribute );
			wireframeAttributes.delete( buffergeometry );

		}

		bindingStates.releaseStatesOfGeometry( buffergeometry );

		if ( geometry.isInstancedBufferGeometry == true ) {
			// geometry.remove("maxInstanceCount");
      geometry.maxInstanceCount = null;
		}

		//

		info.memory["geometries"] = info.memory["geometries"]! - 1;

	}

	BufferGeometry get( object, geometry ) {
		var buffergeometry = geometries.get( geometry );

    // print("WebGLGeometries get object: ${object.type} ${object.id} geometry: ${geometry.name} geometry: ${geometry.type} ${geometry.id} ");
    // print("WebGLGeometries buffergeometry: ${buffergeometry} ");

		if ( buffergeometry != null ) return buffergeometry;

		geometry.addEventListener( 'dispose', onGeometryDispose );

		if ( geometry.isBufferGeometry ) {

			buffergeometry = geometry;

		} else if ( geometry.isGeometry ) {

			if ( geometry._bufferGeometry == null ) {

				geometry._bufferGeometry = new BufferGeometry().setFromObject( object );

			}

			buffergeometry = geometry._bufferGeometry;

		}

		geometries.add( key: geometry, value: buffergeometry );

		info.memory["geometries"] = info.memory["geometries"]! + 1;

		return buffergeometry;

	}

	update( geometry ) {


		var geometryAttributes = geometry.attributes;

		// Updating index buffer in VAO now. See WebGLBindingStates.

		geometryAttributes.keys.forEach(( name ) {

			attributes.update( geometryAttributes[ name ], gl.ARRAY_BUFFER, name: name );

		});

		// morph targets

		var morphAttributes = geometry.morphAttributes;

		morphAttributes.keys.forEach(( name ) {

			var array = morphAttributes[ name ];

			for ( var i = 0, l = array.length; i < l; i ++ ) {

				attributes.update( array[ i ], gl.ARRAY_BUFFER, name: "${name} - morphAttributes i: ${i}" );

			}

		});

	}

	updateWireframeAttribute( geometry ) {

		List<num> indices = [];

		var geometryIndex = geometry.index;
		var geometryPosition = geometry.attributes["position"];
		var version = 0;

		if ( geometryIndex != null ) {

			var array = geometryIndex.array;
			version = geometryIndex.version;

			for ( var i = 0, l = array.length; i < l; i += 3 ) {

				var a = array[ i + 0 ];
				var b = array[ i + 1 ];
				var c = array[ i + 2 ];

				indices.addAll( [a, b, b, c, c, a] );

			}

		} else {

			var array = geometryPosition.array;
			version = geometryPosition.version;

			for ( var i = 0, l = ( array.length / 3 ) - 1; i < l; i += 3 ) {

				var a = i + 0;
				var b = i + 1;
				var c = i + 2;

				indices.addAll( [a, b, b, c, c, a] );

			}

		}



    BufferAttribute attribute;

    if(arrayMax( indices ) > 65535) {
      attribute = Uint32BufferAttribute(indices, 1, false);
    } else {
      attribute = Uint16BufferAttribute(indices, 1, false);
    }

    attribute.version = version;

		// Updating index buffer in VAO now. See WebGLBindingStates

		//

		var previousAttribute = wireframeAttributes.get( geometry );

		if ( previousAttribute != null ) attributes.remove( previousAttribute );

		//

		wireframeAttributes.add( key: geometry, value: attribute );

	}

	getWireframeAttribute( geometry ) {

		var currentAttribute = wireframeAttributes.get( geometry );

		if ( currentAttribute != null ) {

			var geometryIndex = geometry.index;

			if ( geometryIndex != null ) {

				// if the attribute is obsolete, create a new one

				if ( currentAttribute.version < geometryIndex.version ) {

					updateWireframeAttribute( geometry );

				}

			}

		} else {

			updateWireframeAttribute( geometry );

		}

		return wireframeAttributes.get( geometry );

	}

	

}


