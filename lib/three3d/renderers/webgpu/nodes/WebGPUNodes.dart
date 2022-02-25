part of three_webgpu;


class WebGPUNodes {

  late WebGPURenderer renderer;
  late NodeFrame nodeFrame;
  late WeakMap builders;

	WebGPUNodes( renderer ) {

		this.renderer = renderer;

		this.nodeFrame = new NodeFrame();

		this.builders = new WeakMap();

	}

	get( object, [lightNode] ) {

		var nodeBuilder = this.builders.get( object );

		if ( nodeBuilder == undefined ) {

			nodeBuilder = new WebGPUNodeBuilder( object, this.renderer, lightNode ).build();

			this.builders.set( object, nodeBuilder );

		}

		return nodeBuilder;

	}

	remove( object ) {

		this.builders.delete( object );

	}

	updateFrame() {

		// this.nodeFrame.update();

	}

	update( object, camera, [lightNode] ) {

		var renderer = this.renderer;
		var material = object.material;

		var nodeBuilder = this.get( object, lightNode );
		var nodeFrame = this.nodeFrame;

		nodeFrame.material = material;
		nodeFrame.camera = camera;
		nodeFrame.object = object;
		nodeFrame.renderer = renderer;

		for ( var node in nodeBuilder.updateNodes ) {

			nodeFrame.updateNode( node );

		}

	}

	dispose() {

		this.builders = new WeakMap();

	}

}

