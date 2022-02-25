part of renderer_nodes;

class ModelViewProjectionNode extends Node {

  late PositionNode position;

	ModelViewProjectionNode( [position] ) : super( 'vec4' ) {
    generateLength = 1;
		this.position = position ?? PositionNode();

	}

	generate( [builder, output] ) {

		var position = this.position;

		var mvpMatrix = new OperatorNode( '*', new CameraNode( CameraNode.PROJECTION_MATRIX ), new ModelNode( ModelNode.VIEW_MATRIX ) );
		var mvpNode = new OperatorNode( '*', mvpMatrix, position );

		var _result = mvpNode.build( builder );

    return _result;
	}

}

