part of renderer_nodes;

class JoinNode extends Node {

  late List nodes;

	JoinNode( [nodes] ) : super() {

		generateLength = 1;

		this.nodes = nodes ?? [];

	}

	getNodeType( [builder, output] ) {

		return builder.getTypeFromLength( this.nodes.length );

	}

	generate( [builder, output] ) {

		var type = this.getNodeType( builder );
		var nodes = this.nodes;

		var snippetValues = [];

		for ( var i = 0; i < nodes.length; i ++ ) {

			var input = nodes[ i ];

			var inputSnippet = input.build( builder, 'float' );

			snippetValues.add( inputSnippet );

		}

		return "${ builder.getType( type ) }( ${ snippetValues.join( ', ' ) } )";

	}

}

