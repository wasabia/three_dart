part of renderer_nodes;

class FloatNode extends InputNode {

	FloatNode( [value = 0] ) : super( 'float' ) {
    generateLength = 2;

		this.value = value;

	}

}

