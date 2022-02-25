part of renderer_nodes;


class ContextNode extends Node {

  late dynamic node;
  late dynamic context;

	ContextNode( node, [context] ) : super() {

		this.node = node;
		this.context = context ?? {};

	}

	getNodeType( [builder, output] ) {

		return this.node.getNodeType( builder );

	}

	generate( [builder, output] ) {

		var previousContext = builder.getContext();

    Map _context = {};
    _context.addAll( builder.context );
    _context.addAll( this.context );

		builder.setContext( _context );

		var snippet = this.node.build( builder, output );

		builder.setContext( previousContext );

		return snippet;

	}

}

