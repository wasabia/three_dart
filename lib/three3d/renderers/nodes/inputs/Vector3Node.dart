part of renderer_nodes;


class Vector3Node extends InputNode {

	Vector3Node( [value] ) : super( 'vec3' ) {

		this.value = value ?? new Vector3();

	}

}
