part of renderer_nodes;

class MeshBasicNodeMaterial extends MeshBasicMaterial {

  bool isNodeMaterial = true;

  dynamic colorNode;
  dynamic opacityNode;
  dynamic alphaTestNode;
  dynamic lightNode;
  dynamic positionNode;

	MeshBasicNodeMaterial( parameters ) : super(parameters) {
		this.colorNode = null;
		this.opacityNode = null;

		this.alphaTestNode = null;

		this.lightNode = null;

		this.positionNode = null;

	}

	copy( source ) {

		this.colorNode = source.colorNode;
		this.opacityNode = source.opacityNode;

		this.alphaTestNode = source.alphaTestNode;

		this.lightNode = source.lightNode;

		this.positionNode = source.positionNode;

		return super.copy( source );

	}

}
