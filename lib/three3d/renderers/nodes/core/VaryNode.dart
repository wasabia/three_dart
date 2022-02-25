part of renderer_nodes;

class VaryNode extends Node {

  late dynamic node;
  late dynamic name;

	VaryNode( node, [name = null] ) : super() {
    generateLength = 1;
		this.node = node;
		this.name = name;
	}

	getHash( [builder] ) {

		return this.name ?? super.getHash( builder );

	}

	getNodeType( [builder, output] ) {

		// VaryNode is auto type

		return this.node.getNodeType( builder );

	}

	generate( [builder, output] ) {

		var type = this.getNodeType( builder );
		var node = this.node;
		var name = this.name;

		var nodeVary = builder.getVaryFromNode( this, type );

		if ( name != null ) {

			nodeVary.name = name;

		}

		var propertyName = builder.getPropertyName( nodeVary, NodeShaderStage.Vertex );

		// force node run in vertex stage
		builder.flowNodeFromShaderStage( NodeShaderStage.Vertex, node, type, propertyName );

		var _result = builder.getPropertyName( nodeVary );

    return _result;
	}

}

