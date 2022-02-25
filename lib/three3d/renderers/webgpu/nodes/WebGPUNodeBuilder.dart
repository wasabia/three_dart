part of three_webgpu;

var wgslTypeLib = {
	'float': 'f32',
	'int': 'i32',
	'vec2': 'vec2<f32>',
	'vec3': 'vec3<f32>',
	'vec4': 'vec4<f32>',
	'uvec4': 'vec4<u32>',
	'bvec3': 'vec3<bool>',
	'mat3': 'mat3x3<f32>',
	'mat4': 'mat4x4<f32>'
};

var wgslMethods = {
	'dFdx': 'dpdx',
	'dFdy': 'dpdy'
};

var wgslPolyfill = {
	"lessThanEqual": new CodeNode( """
fn lessThanEqual( a : vec3<f32>, b : vec3<f32> ) -> vec3<bool> {

	return vec3<bool>( a.x <= b.x, a.y <= b.y, a.z <= b.z );

}
""" ),
	"mod": new CodeNode( """
fn mod( x : f32, y : f32 ) -> f32 {

	return x - y * floor( x / y );

}
""" ),
	"repeatWrapping": new CodeNode( """
fn repeatWrapping( uv : vec2<f32>, dimension : vec2<i32> ) -> vec2<i32> {

	var uvScaled = vec2<i32>( uv * vec2<f32>( dimension ) );

	return ( ( uvScaled % dimension ) + dimension ) % dimension;

}
""" ),
	"inversesqrt": new CodeNode( """
fn inversesqrt( x : f32 ) -> f32 {

	return 1.0 / sqrt( x );

}
""" )
};

class WebGPUNodeBuilder extends NodeBuilder {

  late Map uniformsGroup;
  late dynamic lightNode;

  late Map bindings;
  late Map bindingsOffset;

	WebGPUNodeBuilder( object, renderer, [lightNode = null] ) : super( object, renderer, null ) {
		this.lightNode = lightNode;

		this.bindings = { "vertex": [], "fragment": [] };
		this.bindingsOffset = { "vertex": 0, "fragment": 0 };

		this.uniformsGroup = {};

		this._parseObject();

	}

	_parseObject() {

		var object = this.object;
		var material = this.material;

		// parse inputs

		if ( material.isMeshStandardMaterial || material.isMeshBasicMaterial || material.isPointsMaterial || material.isLineBasicMaterial ) {

			var lightNode = material.lightNode;

			// VERTEX STAGE

			Node vertex = new PositionNode( PositionNode.GEOMETRY );

			if ( lightNode == null && this.lightNode != null && this.lightNode.hasLights == true ) {

				lightNode = this.lightNode;

			}

			if ( material.positionNode != null && material.positionNode.isNode ) {

				var assignPositionNode = new OperatorNode( '=', new PositionNode( PositionNode.LOCAL ), material.positionNode );

				vertex = new BypassNode( vertex, assignPositionNode );

			}

			if ( object.isSkinnedMesh == true ) {

				vertex = new BypassNode( vertex, new SkinningNode( object ) );

			}

			this.context["vertex"] = vertex;

			this.addFlow( 'vertex', new VarNode( new ModelViewProjectionNode(), 'MVP', 'vec4' ) );

			// COLOR

			var colorNode = null;

			if ( material.colorNode != null && material.colorNode is Node ) {

				colorNode = material.colorNode;

			} else {

				colorNode = new MaterialNode( MaterialNode.COLOR );

			}

			colorNode = this.addFlow( 'fragment', new VarNode( colorNode, 'Color', 'vec4' ) );

			var diffuseColorNode = this.addFlow( 'fragment', new VarNode( colorNode, 'DiffuseColor', 'vec4' ) );

			// OPACITY

			var opacityNode = null;

			if ( material.opacityNode != null && material.opacityNode is Node ) {

				opacityNode = material.opacityNode;

			} else {

				opacityNode = new VarNode( new MaterialNode( MaterialNode.OPACITY ) );

			}

			this.addFlow( 'fragment', new VarNode( opacityNode, 'OPACITY', 'float' ) );

			this.addFlow( 'fragment', new ExpressionNode( 'DiffuseColor.a = DiffuseColor.a * OPACITY;' ) );

			// ALPHA TEST

			var alphaTest = null;

			if ( material.alphaTestNode != null && material.alphaTestNode is Node ) {

				alphaTest = material.alphaTestNode;

			} else if ( material.alphaTest > 0 ) {

				alphaTest = new MaterialNode( MaterialNode.ALPHA_TEST );

			}

			if ( alphaTest != null ) {

				this.addFlow( 'fragment', new VarNode( alphaTest, 'AlphaTest', 'float' ) );

				this.addFlow( 'fragment', new ExpressionNode( 'if ( DiffuseColor.a <= AlphaTest ) { discard; }' ) );

			}

			if ( material.isMeshStandardMaterial ) {

				// METALNESS

				var metalnessNode = null;

				if ( material.metalnessNode && material.metalnessNode.isNode ) {

					metalnessNode = material.metalnessNode;

				} else {

					metalnessNode = new MaterialNode( MaterialNode.METALNESS );

				}

				this.addFlow( 'fragment', new VarNode( metalnessNode, 'Metalness', 'float' ) );

				this.addFlow( 'fragment', new ExpressionNode( 'DiffuseColor = vec4<f32>( DiffuseColor.rgb * ( 1.0 - Metalness ), DiffuseColor.a );' ) );

				// ROUGHNESS

				var roughnessNode = null;

				if ( material.roughnessNode && material.roughnessNode.isNode ) {

					roughnessNode = material.roughnessNode;

				} else {

					roughnessNode = new MaterialNode( MaterialNode.ROUGHNESS );

				}

				roughnessNode = getRoughness( { roughness: roughnessNode } );

				this.addFlow( 'fragment', new VarNode( roughnessNode, 'Roughness', 'float' ) );

				// SPECULAR_TINT

				this.addFlow( 'fragment', new VarNode( new ExpressionNode( 'mix( vec3<f32>( 0.04 ), Color.rgb, Metalness )', 'vec3' ), 'SpecularColor', 'color' ) );

				// NORMAL_VIEW

				var normalNode = null;

				if ( material.normalNode && material.normalNode.isNode ) {

					normalNode = material.normalNode;

				} else {

					normalNode = new NormalNode( NormalNode.VIEW );

				}

				this.addFlow( 'fragment', new VarNode( normalNode, 'TransformedNormalView', 'vec3' ) );

			}

			// LIGHT

			var outputNode = diffuseColorNode;

			if ( lightNode != null && lightNode is Node ) {

				var lightContextNode = new LightContextNode( lightNode );

				outputNode = this.addFlow( 'fragment', new VarNode( lightContextNode, 'Light', 'vec3' ) );

			}

			// RESULT

			var outputNodeObj = nodeObject( outputNode );

			outputNode = join( [outputNodeObj.x, outputNodeObj.y, outputNodeObj.z, nodeObject( diffuseColorNode ).w] );

			//

			var outputEncoding = this.renderer.outputEncoding;

			if ( outputEncoding != LinearEncoding ) {

				outputNode = new ColorSpaceNode( ColorSpaceNode.LINEAR_TO_LINEAR, outputNode );
				outputNode.fromEncoding( outputEncoding );

			}

			this.addFlow( 'fragment', new VarNode( outputNode, 'Output', 'vec4' ) );

		}

	}

	addFlowCode( code ) {

		if ( ! RegExp(r";\s*$").hasMatch( code ) ) {

			code += ';';

		}

		super.addFlowCode( code + '\n\t' );

	}

	@override
  getTexture( textureProperty, uvSnippet, [biasSnippet, shaderStage] ) {

    shaderStage ??= this.shaderStage;

		if ( shaderStage == 'fragment' ) {

			return """textureSample( ${textureProperty}, ${textureProperty}_sampler, ${uvSnippet} )""";

		} else {

			this._include( 'repeatWrapping' );

			var dimension = """textureDimensions( ${textureProperty}, 0 )""";

			return """textureLoad( ${textureProperty}, repeatWrapping( ${uvSnippet}, ${dimension} ), 0 )""";

		}

	}

	getPropertyName( node, [shaderStage] ) {

    shaderStage = shaderStage ?? this.shaderStage;

		if ( node is NodeVary ) {

			if ( shaderStage == 'vertex' ) {

				return "NodeVarys.${ node.name }";

			}

		} else if ( node is NodeUniform ) {

			var name = node.name;
			var type = node.type;

			if ( type == 'texture' ) {

				return name;

			} else if ( type == 'buffer' ) {

				return "NodeBuffer.${name}";

			} else {

				return "NodeUniforms.${name}";

			}

		}

		return super.getPropertyName( node );

	}

	getBindings() {

		var bindings = this.bindings;

		return [ ...bindings["vertex"], ...bindings["fragment"] ];

	}

	getUniformFromNode( node, shaderStage, type ) {

		var uniformNode = super.getUniformFromNode( node, shaderStage, type );
		Map nodeData = this.getDataFromNode( node, shaderStage );

		if ( nodeData["uniformGPU"] == undefined ) {

			var uniformGPU;

			var bindings = this.bindings[ shaderStage ];

			if ( type == 'texture' ) {

				var sampler = new WebGPUNodeSampler( "${uniformNode.name}_sampler", uniformNode.node );
				var texture = new WebGPUNodeSampledTexture( uniformNode.name, uniformNode.node );

				// add first textures in sequence and group for last
				var lastBinding = bindings[ bindings.length - 1 ];
				var index = lastBinding && lastBinding.isUniformsGroup ? bindings.length - 1 : bindings.length;

				if ( shaderStage == 'fragment' ) {

					bindings.splice( index, 0, sampler, texture );

					uniformGPU = [ sampler, texture ];

				} else {

					bindings.splice( index, 0, texture );

					uniformGPU = [ texture ];


				}


			} else if ( type == 'buffer' ) {

				var buffer = new WebGPUUniformBuffer( 'NodeBuffer', node.value );

				// add first textures in sequence and group for last
				var lastBinding = bindings[ bindings.length - 1 ];
				var index = lastBinding && lastBinding.isUniformsGroup ? bindings.length - 1 : bindings.length;

				bindings.splice( index, 0, buffer );

				uniformGPU = buffer;

			} else {

				var uniformsGroup = this.uniformsGroup[ shaderStage ];

				if ( uniformsGroup == undefined ) {

					uniformsGroup = WebGPUNodeUniformsGroup( shaderStage );

					this.uniformsGroup[ shaderStage ] = uniformsGroup;

					bindings.add( uniformsGroup );

				}

				if ( node is ArrayInputNode ) {

					uniformGPU = [];

					for ( var inputNode in node.nodes ) {

						var uniformNodeGPU = this._getNodeUniform( inputNode, type );

						// fit bounds to buffer
						uniformNodeGPU.boundary = getVectorLength( uniformNodeGPU.itemSize );
						uniformNodeGPU.itemSize = getStrideLength( uniformNodeGPU.itemSize );

						uniformsGroup.addUniform( uniformNodeGPU );

						uniformGPU.add( uniformNodeGPU );

					}

				} else {

					uniformGPU = this._getNodeUniform( uniformNode, type );

					uniformsGroup.addUniform( uniformGPU );

				}

			}

			nodeData["uniformGPU"] = uniformGPU;

			if ( shaderStage == 'vertex' ) {

				this.bindingsOffset[ 'fragment' ] = bindings.length;

			}

		}

		return uniformNode;

	}

	getAttributes( shaderStage ) {

		var snippet = '';

		if ( shaderStage == 'vertex' ) {

			var attributes = this.attributes;
			var length = attributes.length;

			snippet += '\n';

			for ( var index = 0; index < length; index ++ ) {

				var attribute = attributes[ index ];
				var name = attribute.name;
				var type = this.getType( attribute.type );

				snippet += "\t[[ location( ${index} ) ]] ${ name } : ${ type }";

				if ( index + 1 < length ) {

					snippet += ',\n';

				}

			}

			snippet += '\n';

		}

		return snippet;

	}

	getVars( shaderStage ) {

		var snippet = '';

		var vars = this.vars[ shaderStage ];

		for ( var index = 0; index < vars.length; index ++ ) {

			var variable = vars[ index ];

			var name = variable.name;
			var type = this.getType( variable.type );

			snippet += "var ${name} : ${type}; ";

		}

		return snippet;

	}

	@override
  getVarys( shaderStage ) {

		var snippet = '';

		if ( shaderStage == 'vertex' ) {

			snippet += '\t[[ builtin( position ) ]] Vertex: vec4<f32>;\n';

			var varys = this.varys;

			for ( var index = 0; index < varys.length; index ++ ) {

				var vary = varys[ index ];

				snippet += "\t[[ location( ${index} ) ]] ${ vary.name } : ${ this.getType( vary.type ) };\n";

			}

			snippet = this._getWGSLStruct( 'NodeVarysStruct', snippet );

		} else if ( shaderStage == 'fragment' ) {

			var varys = this.varys;

			snippet += '\n';

			for ( var index = 0; index < varys.length; index ++ ) {

				var vary = varys[ index ];

				snippet += "\t[[ location( ${index} ) ]] ${ vary.name } : ${ this.getType( vary.type ) }";

				if ( index + 1 < varys.length ) {

					snippet += ',\n';

				}

			}

			snippet += '\n';

		}

		return snippet;

	}

	@override
  getUniforms( shaderStage ) {

		var uniforms = this.uniforms[ shaderStage ];

		var snippet = '';
		var groupSnippet = '';

		var index = this.bindingsOffset[ shaderStage ];

		for ( var uniform in uniforms ) {

			if ( uniform.type == 'texture' ) {

				if ( shaderStage == 'fragment' ) {

					snippet += "[[ group( 0 ), binding( ${index ++} ) ]] var ${uniform.name}_sampler : sampler; ";

				}

				snippet += "[[ group( 0 ), binding( ${index ++} ) ]] var ${uniform.name} : texture_2d<f32>; ";

			} else if ( uniform.type == 'buffer' ) {

				var bufferNode = uniform.node;
				var bufferType = this.getType( bufferNode.bufferType );
				var bufferCount = bufferNode.bufferCount;

				var bufferSnippet = "\t${uniform.name} : array< ${bufferType}, ${bufferCount} >;\n";

				snippet += this._getWGSLUniforms( 'NodeBuffer', bufferSnippet, index ++ ) + '\n\n';

			} else {

				var vectorType = this.getType( this.getVectorType( uniform.type ) );

				if ( uniform.value is List ) {

					var length = uniform.value.length;

					groupSnippet += "uniform ${vectorType}[ ${length} ] ${uniform.name}; ";

				} else {

					groupSnippet += "\t${uniform.name} : ${ vectorType};\n";

				}

			}

		}

		if ( groupSnippet != null ) {

			snippet += this._getWGSLUniforms( 'NodeUniforms', groupSnippet, index ++ );

		}

		return snippet;

	}

	buildCode() {

		var shadersData = { "fragment": {}, "vertex": {} };

		for ( var shaderStage in shadersData.keys ) {

			var flow = '// code\n';
			flow += "\t${ this.flowCode[ shaderStage ] }";
			flow += '\n';

			var flowNodes = this.flowNodes[ shaderStage ];

      var mainNode = null;
      if(flowNodes.length >= 1) {
        mainNode = flowNodes[ flowNodes.length - 1 ];
      }

			for ( var node in flowNodes ) {

				Map flowSlotData = this.getFlowData( shaderStage, node );
				var slotName = node.name;

				if ( slotName != null ) {

					if ( flow.length > 0 ) flow += '\n';

					flow += "\t// FLOW -> ${ slotName }\n\t";

				}

				flow += "${ flowSlotData["code"] }\n\t";

				if ( node == mainNode ) {

					flow += '// FLOW RESULT\n\t';

					if ( shaderStage == 'vertex' ) {

						flow += 'NodeVarys.Vertex = ';

					} else if ( shaderStage == 'fragment' ) {

						flow += 'return ';

					}

					flow += "${ flowSlotData["result"] };";

				}

			}

			var stageData = shadersData[ shaderStage ]!;

			stageData["uniforms"] = this.getUniforms( shaderStage );
			stageData["attributes"] = this.getAttributes( shaderStage );
			stageData["varys"] = this.getVarys( shaderStage );
			stageData["vars"] = this.getVars( shaderStage );
			stageData["codes"] = this.getCodes( shaderStage );
			stageData["flow"] = flow;

		}

		this.vertexShader = this._getWGSLVertexCode( shadersData["vertex"] );
		this.fragmentShader = this._getWGSLFragmentCode( shadersData["fragment"] );

	}

	getMethod( method ) {

		if ( wgslPolyfill[ method ] != undefined ) {

			this._include( method );

		}

		return wgslMethods[ method ] ?? method;

	}

	getType( type ) {

		return wgslTypeLib[ type ] ?? type;

	}

	_include( name ) {

		wgslPolyfill[ name ]!.build( this );

	}

	_getNodeUniform( uniformNode, type ) {

		if ( type == 'float' ) return new FloatNodeUniform( uniformNode );
		if ( type == 'vec2' ) return new Vector2NodeUniform( uniformNode );
		if ( type == 'vec3' ) return new Vector3NodeUniform( uniformNode );
		if ( type == 'vec4' ) return new Vector4NodeUniform( uniformNode );
		if ( type == 'color' ) return new ColorNodeUniform( uniformNode );
		if ( type == 'mat3' ) return new Matrix3NodeUniform( uniformNode );
		if ( type == 'mat4' ) return new Matrix4NodeUniform( uniformNode );

		throw( "Uniform ${type} not declared." );

	}

	_getWGSLVertexCode( shaderData ) {

		return """${ this.getSignature() }

// uniforms
${shaderData["uniforms"]}

// varys
${shaderData["varys"]}

// codes
${shaderData["codes"]}

[[ stage( vertex ) ]]
fn main( ${shaderData["attributes"]} ) -> NodeVarysStruct {

	// system
	var NodeVarys: NodeVarysStruct;

	// vars
	${shaderData["vars"]}

	// flow
	${shaderData["flow"]}

	return NodeVarys;

}
""";

	}

	_getWGSLFragmentCode( shaderData ) {

		return """${ this.getSignature() }

// uniforms
${shaderData["uniforms"]}

// codes
${shaderData["codes"]}

[[ stage( fragment ) ]]
fn main( ${shaderData["varys"]} ) -> [[ location( 0 ) ]] vec4<f32> {

	// vars
	${shaderData["vars"]}

	// flow
	${shaderData["flow"]}

}
""";

	}

	_getWGSLStruct( name, vars ) {

		return """
struct ${name} {
\n${vars}
};""";

	}

	_getWGSLUniforms( name, vars, [binding = 0, group = 0] ) {

		var structName = name + 'Struct';
		var structSnippet = this._getWGSLStruct( structName, vars );

		return """${structSnippet}
[[ binding( ${binding} ), group( ${group} ) ]]
var<uniform> ${name} : ${structName};""";

	}

}
