part of renderer_nodes;

class ConvertNode extends Node {

  late dynamic node;
  late dynamic convertTo;

	ConvertNode( node, convertTo ) : super() {

		this.node = node;
		this.convertTo = convertTo;

	}

	getNodeType( [builder, output] ) {

		return this.convertTo;

	}

	generate( [builder, output] ) {

		var convertTo = this.convertTo;

		var convertToSnippet = builder.getType( convertTo );
		var nodeSnippet = this.node.build( builder, convertTo );

		return "${ convertToSnippet }( ${ nodeSnippet } )";

	}

}

