part of renderer_nodes;

class PropertyNode extends Node {

  late String? name;

	PropertyNode( [name = null, nodeType = 'vec4'] ) : super( nodeType ) {

		this.name = name;

	}

	getHash( [builder] ) {

		return this.name ?? super.getHash( builder );

	}

	generate( [builder, output] ) {

		var nodeVary = builder.getVarFromNode( this, this.getNodeType( builder ) );
		var name = this.name;

		if ( name != null ) {

			nodeVary.name = name;

		}

		return builder.getPropertyName( nodeVary );

	}

}

