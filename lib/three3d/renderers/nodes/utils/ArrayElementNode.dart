part of renderer_nodes;

class ArrayElementNode extends Node {

  late dynamic node;
  late dynamic indexNode;

	ArrayElementNode( node, indexNode ) : super() {

		this.node = node;
		this.indexNode = indexNode;

	}

	getNodeType( [builder, output] ) {

		return this.node.getNodeType( builder );

	}

	generate( [builder, output] ) {

		var nodeSnippet = this.node.build( builder );
		var indexSnippet = this.indexNode.build( builder, 'int' );

		return "${nodeSnippet}[ ${indexSnippet} ]";

	}

}
