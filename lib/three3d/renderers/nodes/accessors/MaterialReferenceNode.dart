part of renderer_nodes;

class MaterialReferenceNode extends ReferenceNode {

  late dynamic material;

	MaterialReferenceNode( property, inputType, [material = null] ) : super( property, inputType, material ) {
    generateLength = 1;
		this.material = material;

	}

	update( [frame] ) {

		this.object = this.material != null ? this.material : frame.material;

		super.update( frame );

	}

}

