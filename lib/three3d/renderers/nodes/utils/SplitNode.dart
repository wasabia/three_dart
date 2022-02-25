part of renderer_nodes;


class SplitNode extends Node {

  late dynamic node;
  late String components;

	SplitNode( node, [components = 'x'] ) : super() {
    generateLength = 1;

		this.node = node;
		this.components = components;

	}

	getVectorLength() {

		var vectorLength = this.components.length;

		for ( var c in this.components.split('') ) {

			vectorLength = Math.max( vector.indexOf( c ) + 1, vectorLength );

		}

		return vectorLength;

	}

	getNodeType( [builder, output] ) {

		return builder.getTypeFromLength( this.components.length );

	}

	generate( [builder, output] ) {

		var node = this.node;
		var nodeTypeLength = builder.getTypeLength( node.getNodeType( builder ) );

		if ( nodeTypeLength > 1 ) {

			var type = null;

			var componentsLength = this.getVectorLength();

			if ( componentsLength >= nodeTypeLength ) {

				// need expand the input node

				type = builder.getTypeFromLength( this.getVectorLength() );

			}

			var nodeSnippet = node.build( builder, type );

			return "${nodeSnippet}.${this.components}";

		} else {

			// ignore components if node is a float

			return node.build( builder );

		}

	}

}

