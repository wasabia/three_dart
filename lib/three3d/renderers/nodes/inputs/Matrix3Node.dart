part of renderer_nodes;

class Matrix3Node extends InputNode {

	Matrix3Node( [value] ) : super( 'mat3' ) {
    
		this.value = value ?? new Matrix3();

	}

}
