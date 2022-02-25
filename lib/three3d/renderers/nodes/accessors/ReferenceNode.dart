part of renderer_nodes;


class ReferenceNode extends Node {

  late dynamic property;
  late dynamic object;
  late dynamic node;

	ReferenceNode( property, inputType, [object = null] ) : super() {

		this.property = property;
		this.inputType = inputType;

		this.object = object;

		this.node = null;

		this.updateType = NodeUpdateType.Object;

		this.setNodeType( inputType );

	}

	setNodeType( inputType ) {

		var node = null;
		var nodeType = inputType;

		if ( nodeType == 'float' ) {

			node = new FloatNode();

		} else if ( nodeType == 'vec2' ) {

			node = new Vector2Node( null );

		} else if ( nodeType == 'vec3' ) {

			node = new Vector3Node( null );

		} else if ( nodeType == 'vec4' ) {

			node = new Vector4Node( null );

		} else if ( nodeType == 'color' ) {

			node = new ColorNode( null );
			nodeType = 'vec3';

		} else if ( nodeType == 'texture' ) {

			node = new TextureNode();
			nodeType = 'vec4';

		}

		this.node = node;
		this.nodeType = nodeType;
		this.inputType = inputType;

	}

	getNodeType([builder, output]) {

		return this.inputType;

	}

	update( [frame] ) {

		var object = this.object != null ? this.object : frame.object;
		var value = object.getProperty(this.property);

		this.node.value = value;

	}

	generate( [builder, output] ) {

		return this.node.build( builder, this.getNodeType( builder ) );

	}

}

