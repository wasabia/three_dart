part of renderer_nodes;

class TextureNode extends InputNode {

  late dynamic value;
  late UVNode uv;
  late dynamic bias;

	TextureNode( [value = null, uv = null, bias = null] ) : super( 'texture' ) {
		this.value = value;
		this.uv = uv ?? new UVNode();
		this.bias = bias;

	}

	generate( [builder, output] ) {

		var texture = this.value;

		if ( ! texture || texture.isTexture != true ) {

			throw( 'TextureNode: Need a three.js texture.' );

		}

		var type = this.getNodeType( builder );

		var textureProperty = super.generate( builder, type );

		if ( output == 'sampler2D' || output == 'texture2D' ) {

			return textureProperty;

		} else if ( output == 'sampler' ) {

			return textureProperty + '_sampler';

		} else {

			var nodeData = builder.getDataFromNode( this );

			var snippet = nodeData.snippet;

			if ( snippet == undefined ) {

				var uvSnippet = this.uv.build( builder, 'vec2' );
				var bias = this.bias;

				var biasSnippet = null;

				if ( bias != null ) {

					biasSnippet = bias.build( builder, 'float' );

				}

				snippet = builder.getTexture( textureProperty, uvSnippet, biasSnippet );

				nodeData.snippet = snippet;

			}

			return builder.format( snippet, 'vec4', output );

		}

	}

}

