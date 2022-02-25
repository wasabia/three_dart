part of three_webgpu;

class WebGPUGeometries {

  late WebGPUAttributes attributes;
  late WebGPUInfo info;
  late WeakMap geometries;

	WebGPUGeometries( WebGPUAttributes attributes, WebGPUInfo info ) {

		this.attributes = attributes;
		this.info = info;

		this.geometries = new WeakMap();

	}

	update( geometry ) {

		// if ( this.geometries.has( geometry ) == false ) {

		// 	var disposeCallback = onGeometryDispose.bind( this );

		// 	this.geometries.set( geometry, onGeometryDispose );

		// 	this.info.memory["geometries"] ++;

		// 	geometry.addEventListener( 'dispose', onGeometryDispose );

		// }

		// var geometryAttributes = geometry.attributes;

		// for ( const name in geometryAttributes ) {

		// 	this.attributes.update( geometryAttributes[ name ] );

		// }

		// var index = geometry.index;

		// if ( index != null ) {

		// 	this.attributes.update( index, true );

		// }

	}


  // onGeometryDispose( event ) {

  //   var geometry = event.target;
  //   var disposeCallback = this.geometries.get( geometry );

  //   this.geometries.delete( geometry );

  //   this.info.memory["geometries"] --;

  //   geometry.removeEventListener( 'dispose', disposeCallback );

 
  //   var index = geometry.index;
  //   var geometryAttributes = geometry.attributes;

  //   if ( index != null ) {

  //     this.attributes.remove( index );

  //   }

  //   for ( var name in geometryAttributes ) {

  //     this.attributes.remove( geometryAttributes[ name ] );

  //   }

  // }


}

