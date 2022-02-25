part of renderer_nodes;


class NodeFrame {

  late num time;
  late num deltaTime;
  late int frameId;
  num? startTime;
  late WeakMap updateMap;
  late dynamic renderer;
  late dynamic material;
  late dynamic camera;
  late dynamic object;
  late dynamic lastTime;

	NodeFrame() {

		this.time = 0;
		this.deltaTime = 0;

		this.frameId = 0;

		this.startTime = null;

		this.updateMap = new WeakMap();

		this.renderer = null;
		this.material = null;
		this.camera = null;
		this.object = null;

	}

	updateNode( node ) {

		if ( node.updateType == NodeUpdateType.Frame ) {

			if ( this.updateMap.get( node ) != this.frameId ) {

				this.updateMap.set( node, this.frameId );

				node.update( this );

			}

		} else if ( node.updateType == NodeUpdateType.Object ) {

			node.update( this );

		}

	}

	update() {

		this.frameId ++;

		if ( this.lastTime == undefined ) this.lastTime = performance.now();

		this.deltaTime = ( performance.now() - this.lastTime ) / 1000;

		this.lastTime = performance.now();

		this.time += this.deltaTime;

	}

}

