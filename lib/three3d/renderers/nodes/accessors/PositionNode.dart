part of renderer_nodes;


class PositionNode extends Node {

	static const String GEOMETRY = 'geometry';
	static const String LOCAL = 'local';
	static const String WORLD = 'world';
	static const String VIEW = 'view';
	static const String VIEW_DIRECTION = 'viewDirection';

  late String scope;

	PositionNode( [scope = PositionNode.LOCAL] ) : super( 'vec3' ) {
    generateLength = 1;
		this.scope = scope;

	}

	@override
  getHash( [builder] ) {

		return "position-${this.scope}";

	}

	@override
  generate( [builder, output] ) {

		var scope = this.scope;

		var outputNode = null;

		if ( scope == PositionNode.GEOMETRY ) {

			outputNode = new AttributeNode( 'position', 'vec3' );

		} else if ( scope == PositionNode.LOCAL ) {

			outputNode = new VaryNode( new PositionNode( PositionNode.GEOMETRY ) );

		} else if ( scope == PositionNode.WORLD ) {

			var vertexPositionNode = new MathNode( MathNode.TRANSFORM_DIRECTION, new ModelNode( ModelNode.WORLD_MATRIX ), new PositionNode( PositionNode.LOCAL ) );
			outputNode = new VaryNode( vertexPositionNode );

		} else if ( scope == PositionNode.VIEW ) {

			var vertexPositionNode = new OperatorNode( '*', new ModelNode( ModelNode.VIEW_MATRIX ), new PositionNode( PositionNode.LOCAL ) );
			outputNode = new VaryNode( vertexPositionNode );

		} else if ( scope == PositionNode.VIEW_DIRECTION ) {

			var vertexPositionNode = new MathNode( MathNode.NEGATE, new PositionNode( PositionNode.VIEW ) );
			outputNode = new MathNode( MathNode.NORMALIZE, new VaryNode( vertexPositionNode ) );

		}

		return outputNode.build( builder, this.getNodeType( builder ) );

	}

}

