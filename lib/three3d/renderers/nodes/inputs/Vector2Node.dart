part of renderer_nodes;

class Vector2Node extends InputNode {

	Vector2Node( [value] ) : super( 'vec2' ) {

		this.value = value ?? Vector2();

	}

}

