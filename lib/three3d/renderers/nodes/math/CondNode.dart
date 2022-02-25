part of renderer_nodes;

class CondNode extends Node {

  late dynamic node;
  late dynamic ifNode;
  late dynamic elseNode;

	CondNode( node, [ifNode, elseNode]) : super() {
		this.node = node;

		this.ifNode = ifNode;
		this.elseNode = elseNode;

	}

	getNodeType( [builder, output] ) {

		var ifType = this.ifNode.getNodeType( builder );
		var elseType = this.elseNode.getNodeType( builder );

		if ( builder.getTypeLength( elseType ) > builder.getTypeLength( ifType ) ) {

			return elseType;

		}

		return ifType;

	}

	generate( [builder, output] ) {

		var type = this.getNodeType( builder );

		var context = { "temp": false };
		var nodeProperty = new PropertyNode( null, type ).build( builder );

		var nodeSnippet = new ContextNode( this.node/*, context*/ ).build( builder, 'bool' ),
			ifSnippet = new ContextNode( this.ifNode, context ).build( builder, type ),
			elseSnippet = new ContextNode( this.elseNode, context ).build( builder, type );

		builder.addFlowCode( """if ( ${nodeSnippet} ) {

\t\t${nodeProperty} = ${ifSnippet};

\t} else {

\t\t${nodeProperty} = ${elseSnippet};

\t}""" );

		return nodeProperty;

	}

}

