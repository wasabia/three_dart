part of renderer_nodes;

class NormalNode extends Node {

	static const String GEOMETRY = 'geometry';
	static const String LOCAL = 'local';
	static const String WORLD = 'world';
	static const String VIEW = 'view';

  late dynamic scope;

	NormalNode( [scope = NormalNode.LOCAL] ) : super( 'vec3' ) {

		

		this.scope = scope;

	}

	getHash( [builder] ) {

		return "normal-${this.scope}";

	}

	generate( [builder, output] ) {

		var scope = this.scope;

		var outputNode = null;

		if ( scope == NormalNode.GEOMETRY ) {

			outputNode = new AttributeNode( 'normal', 'vec3' );

		} else if ( scope == NormalNode.LOCAL ) {

			outputNode = new VaryNode( new NormalNode( NormalNode.GEOMETRY ) );

		} else if ( scope == NormalNode.VIEW ) {

			var vertexNormalNode = new OperatorNode( '*', new ModelNode( ModelNode.NORMAL_MATRIX ), new NormalNode( NormalNode.LOCAL ) );
			outputNode = new MathNode( MathNode.NORMALIZE, new VaryNode( vertexNormalNode ) );

		} else if ( scope == NormalNode.WORLD ) {

			// To use INVERSE_TRANSFORM_DIRECTION only inverse the param order like this: MathNode( ..., Vector, Matrix );
			var vertexNormalNode = new MathNode( MathNode.TRANSFORM_DIRECTION, new NormalNode( NormalNode.VIEW ), new CameraNode( CameraNode.VIEW_MATRIX ) );
			outputNode = new MathNode( MathNode.NORMALIZE, new VaryNode( vertexNormalNode ) );

		}

		return outputNode.build( builder );

	}

}
