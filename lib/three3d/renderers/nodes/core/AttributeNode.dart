part of renderer_nodes;

class AttributeNode extends Node {

  late String _attributeName;

	AttributeNode( attributeName, nodeType ) : super( nodeType ) {
    generateLength = 1;
		this._attributeName = attributeName;

	}

	getHash( [builder] ) {

		return this.getAttributeName( builder );

	}

	setAttributeName( attributeName ) {

		this._attributeName = attributeName;

		return this;

	}

	getAttributeName( builder ) {

		return this._attributeName;

	}

	generate( [builder, output] ) {

		var attribute = builder.getAttribute( this.getAttributeName( builder ), this.getNodeType( builder ) );

		if ( builder.isShaderStage( 'vertex' ) ) {

			return attribute.name;

		} else {

			var nodeVary = new VaryNode( this );

			return nodeVary.build( builder, attribute.type );

		}

	}

}
