part of renderer_nodes;

class MaterialNode extends Node {

	static const String ALPHA_TEST = 'alphaTest';
	static const String COLOR = 'color';
	static const String OPACITY = 'opacity';
	static const String SPECULAR = 'specular';
	static const String ROUGHNESS = 'roughness';
	static const String METALNESS = 'metalness';

  late String scope;

	MaterialNode( [scope = MaterialNode.COLOR] ) : super() {
    generateLength = 2;
		this.scope = scope;

	}

	getNodeType( [builder, output] ) {

		var scope = this.scope;
		var material = builder.context["material"];

		if ( scope == MaterialNode.COLOR ) {

			return material.map != null ? 'vec4' : 'vec3';

		} else if ( scope == MaterialNode.OPACITY ) {

			return 'float';

		} else if ( scope == MaterialNode.SPECULAR ) {

			return 'vec3';

		} else if ( scope == MaterialNode.ROUGHNESS || scope == MaterialNode.METALNESS ) {

			return 'float';

		}

	}

	generate( [builder, output] ) {

		var material = builder.context["material"];
		var scope = this.scope;

		var node = null;

    print(" ============ this ${this} generate scope: ${scope}  ");

		if ( scope == MaterialNode.ALPHA_TEST ) {

			node = new MaterialReferenceNode( 'alphaTest', 'float' );

		} else if ( scope == MaterialNode.COLOR ) {

			var colorNode = new MaterialReferenceNode( 'color', 'color' );

			if ( material.map != null && material.map != undefined && material.map.isTexture == true ) {

				node = new OperatorNode( '*', colorNode, new MaterialReferenceNode( 'map', 'texture' ) );

			} else {

				node = colorNode;

			}

		} else if ( scope == MaterialNode.OPACITY ) {

			var opacityNode = new MaterialReferenceNode( 'opacity', 'float' );

			if ( material.alphaMap != null && material.alphaMap != undefined && material.alphaMap.isTexture == true ) {

				node = new OperatorNode( '*', opacityNode, new MaterialReferenceNode( 'alphaMap', 'texture' ) );

			} else {

				node = opacityNode;

			}

		} else if ( scope == MaterialNode.SPECULAR ) {

			var specularColorNode = new MaterialReferenceNode( 'specularColor', 'color' );

			if ( material.specularColorMap != null && material.specularColorMap != undefined && material.specularColorMap.isTexture == true ) {

				node = new OperatorNode( '*', specularColorNode, new MaterialReferenceNode( 'specularColorMap', 'texture' ) );

			} else {

				node = specularColorNode;

			}

		} else {

			var outputType = this.getNodeType( builder );

			node = new MaterialReferenceNode( scope, outputType );

		}

		return node.build( builder, output );

	}

}

