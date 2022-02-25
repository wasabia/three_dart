part of renderer_nodes;

class OperatorNode extends TempNode {

  late dynamic op;
  late Node aNode;
  late Node bNode;

  

	OperatorNode( op, aNode, bNode, [List? params] ) : super() {
    generateLength = 2;
    
		this.op = op;

		if ( params != null && params.length > 0 ) {

			var finalBNode = bNode;

			for ( var i = 0; i < params.length; i ++ ) {

				finalBNode = new OperatorNode( op, finalBNode, params[ i ] );

			}

			bNode = finalBNode;

		}

		this.aNode = aNode;
		this.bNode = bNode;

	}

	getNodeType( [builder, output] ) {

		var op = this.op;

		var aNode = this.aNode;
		var bNode = this.bNode;

		var typeA = aNode.getNodeType( builder );
		var typeB = bNode.getNodeType( builder );

		if ( typeA == 'void' || typeB == 'void' ) {

			return 'void';

		} else if ( op == '=' ) {

			return typeA;

		} else if ( op == '==' || op == '&&' ) {

			return 'bool';

		} else if ( op == '<=' || op == '>' ) {

			var length = builder.getTypeLength( output );

			return length > 1 ? "bvec${ length }" : 'bool';

		} else {

			if ( typeA == 'float' && builder.isMatrix( typeB ) ) {

				return typeB;

			} else if ( builder.isMatrix( typeA ) && builder.isVector( typeB ) ) {

				// matrix x vector

				return builder.getVectorFromMatrix( typeA );

			} else if ( builder.isVector( typeA ) && builder.isMatrix( typeB ) ) {

				// vector x matrix

				return builder.getVectorFromMatrix( typeB );

			} else if ( builder.getTypeLength( typeB ) > builder.getTypeLength( typeA ) ) {

				// anytype x anytype: use the greater length vector

				return typeB;

			}

			return typeA;

		}

	}

	generate( [builder, output] ) {

		var op = this.op;

		var aNode = this.aNode;
		var bNode = this.bNode;

		var type = this.getNodeType( builder, output );

		var typeA = null;
		var typeB = null;

		if ( type != 'void' ) {

			typeA = aNode.getNodeType( builder );
			typeB = bNode.getNodeType( builder );

			if ( op == '=' ) {

				typeB = typeA;

			} else if ( builder.isMatrix( typeA ) && builder.isVector( typeB ) ) {

				// matrix x vector

				typeB = builder.getVectorFromMatrix( typeA );

			} else if ( builder.isVector( typeA ) && builder.isMatrix( typeB ) ) {

				// vector x matrix

				typeA = builder.getVectorFromMatrix( typeB );

			} else {

				// anytype x anytype

				typeA = typeB = type;

			}

		} else {

			typeA = typeB = type;

		}

		var a = aNode.build( builder, typeA );
		var b = bNode.build( builder, typeB );

		var outputLength = builder.getTypeLength( output );

		if ( output != 'void' ) {

			if ( op == '=' ) {

				builder.addFlowCode( "${a} ${this.op} ${b}" );

				return a;

			} else if ( op == '>' && outputLength > 1 ) {

				return "${ builder.getMethod( 'greaterThan' ) }( ${a}, ${b} )";

			} else if ( op == '<=' && outputLength > 1 ) {

				return "${ builder.getMethod( 'lessThanEqual' ) }( ${a}, ${b} )";

			} else {

				return "( ${a} ${this.op} ${b} )";

			}

		} else if ( typeA != 'void' ) {

			return "${a} ${this.op} ${b}";

		}

	}

}

