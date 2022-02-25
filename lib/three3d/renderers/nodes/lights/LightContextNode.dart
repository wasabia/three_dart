part of renderer_nodes;

class LightContextNode extends ContextNode {

	LightContextNode( node ) : super( node ) {

	}

	getNodeType( [builder, output] ) {

		return 'vec3';

	}

	generate( [builder, output] ) {

		var material = builder.material;

		var lightingModel = null;

		if ( material.isMeshStandardMaterial == true ) {

			lightingModel = PhysicalLightingModel;

		}

		var directDiffuse = new VarNode( new Vector3Node(), 'DirectDiffuse', 'vec3' );
		var directSpecular = new VarNode( new Vector3Node(), 'DirectSpecular', 'vec3' );

		this.context.directDiffuse = directDiffuse;
		this.context.directSpecular = directSpecular;

		if ( lightingModel != null ) {

			this.context.lightingModel = lightingModel;

		}

		// add code

		var type = this.getNodeType( builder );

		super.generate( builder, type );

		var totalLight = new OperatorNode( '+', directDiffuse, directSpecular );

		return totalLight.build( builder, type );

	}

}

