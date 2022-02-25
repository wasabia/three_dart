part of renderer_nodes;

class BypassNode extends Node {

  late dynamic outputNode;
  late dynamic callNode;

	BypassNode( returnNode, callNode ) : super() {

		this.outputNode = returnNode;
		this.callNode = callNode;

	}

	getNodeType( [builder, output] ) {

		return this.outputNode.getNodeType( builder );

	}

	generate( [builder, output] ) {

		var snippet = this.callNode.build( builder, 'void' );

		if ( snippet != '' ) {

			builder.addFlowCode( snippet );

		}

		return this.outputNode.build( builder, output );

	}

}
