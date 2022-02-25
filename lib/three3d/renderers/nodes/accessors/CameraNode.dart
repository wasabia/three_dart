part of renderer_nodes;

class CameraNode extends Object3DNode {

	static const String PROJECTION_MATRIX = 'projectionMatrix';
  static const String VIEW_MATRIX = 'viewMatrix';
	static const String NORMAL_MATRIX = 'normalMatrix';
	static const String WORLD_MATRIX = 'worldMatrix';
	static const String POSITION = 'position';
	static const String VIEW_POSITION = 'viewPosition';

  late dynamic _inputNode;

	CameraNode( [scope = CameraNode.POSITION] ) : super( scope ) {

    generateLength = 1;
		this._inputNode = null;

	}

	getNodeType( [builder, output] ) {

		var scope = this.scope;

		if ( scope == CameraNode.PROJECTION_MATRIX ) {

			return 'mat4';

		}

		return super.getNodeType( builder );

	}

	update( [frame] ) {

		var camera = frame.camera;
		var inputNode = this._inputNode;
		var scope = this.scope;

		if ( scope == CameraNode.PROJECTION_MATRIX ) {

			inputNode.value = camera.projectionMatrix;

		} else if ( scope == CameraNode.VIEW_MATRIX ) {

			inputNode.value = camera.matrixWorldInverse;

		} else {

			super.update( frame );

		}

	}

	generate( [builder, output] ) {

		var scope = this.scope;

		if ( scope == CameraNode.PROJECTION_MATRIX ) {

			this._inputNode = new Matrix4Node( null );

		}

		return super.generate( builder );

	}

}

