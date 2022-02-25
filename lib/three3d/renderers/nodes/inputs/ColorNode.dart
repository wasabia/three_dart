part of renderer_nodes;

class ColorNode extends InputNode {

	ColorNode( [value] ) : super('color') {

    generateLength = 2;

		this.value = value ?? Color(1,1,1);

	}

}
