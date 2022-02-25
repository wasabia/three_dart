part of renderer_nodes;

class VarNode extends Node {

  late dynamic node;
  String? name;

	VarNode( node, [name = null, nodeType = null] ) : super( nodeType ) {
    generateLength = 1;
		this.node = node;
		this.name = name;
	}

	getHash( [builder] ) {

		return this.name ?? super.getHash( builder );

	}

	getNodeType( [builder, output] ) {

		return super.getNodeType( builder ) ?? this.node.getNodeType( builder );

	}

	generate( [builder, output] ) {

		var type = builder.getVectorType( this.getNodeType( builder ) );
		var node = this.node;
		var name = this.name;

		var snippet = node.build( builder, type );

		var nodeVar = builder.getVarFromNode( this, type );

		if ( name != null ) {

			nodeVar.name = name;

		}

		var propertyName = builder.getPropertyName( nodeVar );

		builder.addFlowCode( "${propertyName} = ${snippet}" );

		return propertyName;

	}


  getProperty(String name) {
    return super.getProperty(name);
  }

}



