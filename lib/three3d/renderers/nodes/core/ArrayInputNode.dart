part of renderer_nodes;

class ArrayInputNode extends InputNode {

  late List nodes;

	ArrayInputNode( [nodes] ) : super() {

		this.nodes = nodes ?? [];

	}

	getNodeType( [builder, output] ) {

		return this.nodes[ 0 ].getNodeType( builder );

	}

}
