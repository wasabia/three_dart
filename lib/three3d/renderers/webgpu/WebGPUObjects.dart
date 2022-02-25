part of three_webgpu;

class WebGPUObjects {

  late WebGPUGeometries geometries;
  late WebGPUInfo info;
  late WeakMap updateMap;


	WebGPUObjects( geometries, info ) {

		this.geometries = geometries;
		this.info = info;

		this.updateMap = new WeakMap();

	}

	update( object ) {

		var geometry = object.geometry;
		var updateMap = this.updateMap;
		var frame = this.info.render["frame"];

		if ( geometry.isBufferGeometry != true ) {

			throw( 'THREE.WebGPURenderer: This renderer only supports THREE.BufferGeometry for geometries.' );

		}

		if ( updateMap.get( geometry ) != frame ) {

			this.geometries.update( geometry );

			updateMap.set( geometry, frame );

		}

	}

	dispose() {

		this.updateMap = new WeakMap();

	}

}
