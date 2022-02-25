part of renderer_nodes;

class Matrix4Node extends InputNode {

	Matrix4Node( [value] ) : super( 'mat4' ) {
    generateLength = 2;
		this.value = value ?? new Matrix4();

	}

}

