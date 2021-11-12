part of three_webgl;

class WebGLObjects {

  var updateMap = WeakMap();
  WebGLInfo info;
  dynamic gl;
  WebGLGeometries geometries;
  WebGLAttributes attributes;

  WebGLObjects(this.gl, this.geometries, this.attributes, this.info ) {
  }

	

	update(  object ) {


		num frame = info.render["frame"]!;

		var geometry = object.geometry;

		var buffergeometry = geometries.get( object, geometry );

		// Update once per frame

		if ( updateMap.get( buffergeometry ) != frame ) {

			geometries.update( buffergeometry );
			updateMap.add( key: buffergeometry, value: frame );

		}

    // print(" WebGLObjects update object: ${object} ${object.type} ");

		if ( object is InstancedMesh ) {

			if ( object.hasEventListener( 'dispose', onInstancedMeshDispose ) == false ) {

				object.addEventListener( 'dispose', onInstancedMeshDispose );

			}

      // print(" WebGLObjects update 2 object: ${object} ${object.instanceMatrix} ");
			attributes.update( object.instanceMatrix, gl.ARRAY_BUFFER );

			if ( object.instanceColor != null ) {

				attributes.update( object.instanceColor, gl.ARRAY_BUFFER );

			}

		}

		return buffergeometry;

	}

	dispose() {

		updateMap.clear();

	}

	onInstancedMeshDispose( event ) {

		var instancedMesh = event.target;

		instancedMesh.removeEventListener( 'dispose', onInstancedMeshDispose );

		attributes.remove( instancedMesh.instanceMatrix );

		if ( instancedMesh.instanceColor != null ) attributes.remove( instancedMesh.instanceColor );

	}


}


