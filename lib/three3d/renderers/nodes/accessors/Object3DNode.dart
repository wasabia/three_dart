part of renderer_nodes;

class Object3DNode extends Node {

	static const String VIEW_MATRIX = 'viewMatrix';
	static const String NORMAL_MATRIX = 'normalMatrix';
	static const String WORLD_MATRIX = 'worldMatrix';
	static const String POSITION = 'position';
	static const String VIEW_POSITION = 'viewPosition';


  late String scope;
  late dynamic object3d;
  late dynamic _inputNode;

	Object3DNode( [scope = Object3DNode.VIEW_MATRIX, object3d = null] ) : super() {

		this.scope = scope;
		this.object3d = object3d;

		this.updateType = NodeUpdateType.Object;

		this._inputNode = null;

	}

	getNodeType( [builder, output] ) {

		var scope = this.scope;

		if ( scope == Object3DNode.WORLD_MATRIX || scope == Object3DNode.VIEW_MATRIX ) {

			return 'mat4';

		} else if ( scope == Object3DNode.NORMAL_MATRIX ) {

			return 'mat3';

		} else if ( scope == Object3DNode.POSITION || scope == Object3DNode.VIEW_POSITION ) {

			return 'vec3';

		}

	}

	update( [frame] ) {

		var object = this.object3d != null ? this.object3d : frame.object;
		var inputNode = this._inputNode;
		var camera = frame.camera;
		var scope = this.scope;

		if ( scope == Object3DNode.VIEW_MATRIX ) {

			inputNode.value = object.modelViewMatrix;

		} else if ( scope == Object3DNode.NORMAL_MATRIX ) {

			inputNode.value = object.normalMatrix;

		} else if ( scope == Object3DNode.WORLD_MATRIX ) {

			inputNode.value = object.matrixWorld;

		} else if ( scope == Object3DNode.POSITION ) {

			inputNode.value.setFromMatrixPosition( object.matrixWorld );

		} else if ( scope == Object3DNode.VIEW_POSITION ) {

			inputNode.value.setFromMatrixPosition( object.matrixWorld );

			inputNode.value.applyMatrix4( camera.matrixWorldInverse );

		}

	}

	generate( [builder, output] ) {

		var scope = this.scope;

		if ( scope == Object3DNode.WORLD_MATRIX || scope == Object3DNode.VIEW_MATRIX ) {

			this._inputNode = new Matrix4Node(  );

		} else if ( scope == Object3DNode.NORMAL_MATRIX ) {

			this._inputNode = new Matrix3Node( );

		} else if ( scope == Object3DNode.POSITION || scope == Object3DNode.VIEW_POSITION ) {

			this._inputNode = new Vector3Node();

		}

		return this._inputNode.build( builder );

	}

}
