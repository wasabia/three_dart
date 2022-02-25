part of renderer_nodes;

class Vector4Node extends InputNode {

	Vector4Node( [value] ) : super( 'vec4' ) {

		this.value = value ?? Vector4();

	}

}

