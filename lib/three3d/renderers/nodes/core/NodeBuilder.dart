part of renderer_nodes;

var shaderStages = [ 'fragment', 'vertex' ];
var vector = [ 'x', 'y', 'z', 'w' ];

class NodeBuilder {

  late dynamic object;
  late dynamic material;
  late dynamic renderer;
  late dynamic parser;

  late List<Node> nodes;
  late List<Node> updateNodes;
  late Map<String, Node> hashNodes;

  late String vertexShader;
  late String fragmentShader;
  late dynamic flowNodes;
  late dynamic flowCode;
  late dynamic uniforms;
  late dynamic codes;
  late dynamic attributes;
  late dynamic varys;

  late dynamic vars;
  late dynamic flow;
  late dynamic stack;

  late WeakMap nodesData;
  late WeakMap flowsData;

  late dynamic context;

  late dynamic shaderStage;
  late dynamic node;

	NodeBuilder( object, renderer, parser ) {

		this.object = object;
		this.material = object.material;
		this.renderer = renderer;
		this.parser = parser ?? new WGSLNodeParser();

		this.nodes = [];
		this.updateNodes = [];
		this.hashNodes = {};

		// this.vertexShader = null;
		// this.fragmentShader = null;

		this.flowNodes = { "vertex": [], "fragment": [] };
		this.flowCode = { "vertex": '', "fragment": '' };
		this.uniforms = { "vertex": [], "fragment": [], "index": 0 };
		this.codes = { "vertex": [], "fragment": [] };
		this.attributes = [];
		this.varys = [];
		this.vars = { "vertex": [], "fragment": [] };
		this.flow = { "code": '' };
		this.stack = [];

		this.context = {
			"keywords": new NodeKeywords(),
			"material": object.material
		};

		this.nodesData = new WeakMap();
		this.flowsData = new WeakMap();

		this.shaderStage = null;
		this.node = null;

	}

	addStack( node ) {

		/*
		if ( this.stack.indexOf( node ) != - 1 ) {

			console.warn( 'Recursive node: ', node );

		}
    */

		this.stack.add( node );

	}

	removeStack( node ) {

		var lastStack = this.stack.removeLast();

		if ( lastStack != node ) {

			throw( 'NodeBuilder: Invalid node stack!' );

		}

	}

	addNode( node ) {

		if ( this.nodes.indexOf( node ) == - 1 ) {

			var updateType = node.getUpdateType( this );

			if ( updateType != NodeUpdateType.None ) {

				this.updateNodes.add( node );

			}

			this.nodes.add( node );


      var _hash = node.getHash( this );

			this.hashNodes[ _hash ] = node;

		}

	}

	getMethod( method ) {

		return method;

	}

	getNodeFromHash( hash ) {

		return this.hashNodes[ hash ];

	}

	addFlow( shaderStage, node ) {

		this.flowNodes[ shaderStage ].add( node );

		return node;

	}

	setContext( context ) {

		this.context = context;

	}

	getContext() {

		return this.context;

	}

	getTexture( textureProperty, uvSnippet, [biasSnippet = null, shaderStage = null] ) {

		console.warn( 'Abstract function.' );

	}

	getCubeTexture( /* textureProperty, uvSnippet, biasSnippet = null */ ) {

		console.warn( 'Abstract function.' );

	}

	// rename to generate
	getConst( type, value ) {

		if ( type == 'float' ) return value + ( value % 1 ? '' : '.0' );
		if ( type == 'vec2' ) return "${ this.getType( 'vec2' ) }( ${value.x}, ${value.y} )";
		if ( type == 'vec3' ) return "${ this.getType( 'vec3' ) }( ${value.x}, ${value.y}, ${value.z} )";
		if ( type == 'vec4' ) return "${ this.getType( 'vec4' ) }( ${value.x}, ${value.y}, ${value.z}, ${value.w} )";
		if ( type == 'color' ) return "${ this.getType( 'vec3' ) }( ${value.r}, ${value.g}, ${value.b} )";

		throw( "NodeBuilder: Type '${type}' not found in generate constant attempt." );

	}

	getType( type ) {

		return type;

	}

	generateMethod( method ) {

		return method;

	}

	getAttribute( name, type ) {

		var attributes = this.attributes;

		// find attribute

		for ( var attribute in attributes ) {

			if ( attribute.name == name ) {

				return attribute;

			}

		}

		// create a new if no exist

		var attribute = new NodeAttribute( name, type );

		attributes.add( attribute );

		return attribute;

	}

	getPropertyName( node/*, shaderStage*/ ) {

		return node.name;

	}

	isVector( type ) {

		return RegExp(r"vec\d").hasMatch( type );

	}

	isMatrix( type ) {

		return RegExp(r"mat\d").hasMatch( type );

	}

	isShaderStage( shaderStage ) {

		return this.shaderStage == shaderStage;

	}

	getTextureEncodingFromMap( map ) {

		var encoding;

		if ( map && map.isTexture ) {

			encoding = map.encoding;

		} else if ( map && map.isWebGLRenderTarget ) {

			encoding = map.texture.encoding;

		} else {

			encoding = LinearEncoding;

		}

		return encoding;

	}

	getVectorType( type ) {

		if ( type == 'color' ) return 'vec3';
		if ( type == 'texture' ) return 'vec4';

		return type;

	}

	getTypeFromLength( type ) {

		if ( type == 1 ) return 'float';
		if ( type == 2 ) return 'vec2';
		if ( type == 3 ) return 'vec3';
		if ( type == 4 ) return 'vec4';

		return 0;

	}

	getTypeLength( type ) {

		var vecType = this.getVectorType( type );
		var vecNum = RegExp(r"vec([2-4])").firstMatch( vecType );

		if ( vecNum != null ) return num.parse( vecNum.group(1)! );
		if ( vecType == 'float' || vecType == 'bool' ) return 1;

		return 0;

	}

	getVectorFromMatrix( String type ) {

		return 'vec${type.substring( 3 )}';

	}

	getDataFromNode( node, [shaderStage] ) {

    shaderStage ??= this.shaderStage;

		var nodeData = this.nodesData.get( node );

		if ( nodeData == undefined ) {

			nodeData = { "vertex": {}, "fragment": {} };

			this.nodesData.set( node, nodeData );

		}

		return shaderStage != null ? nodeData[ shaderStage ] : nodeData;

	}

	getUniformFromNode( node, shaderStage, type ) {

		Map nodeData = this.getDataFromNode( node, shaderStage );

		var nodeUniform = nodeData["uniform"];

		if ( nodeUniform == undefined ) {

			var index = this.uniforms["index"] ++;

			nodeUniform = new NodeUniform( 'nodeUniform${index}', type, node );

			this.uniforms[ shaderStage ].add( nodeUniform );

			nodeData["uniform"] = nodeUniform;

		}

		return nodeUniform;

	}

	getVarFromNode( node, type, [shaderStage] ) {

    shaderStage ??= this.shaderStage;

		Map nodeData = this.getDataFromNode( node, shaderStage );

		var nodeVar = nodeData["variable"];

		if ( nodeVar == undefined ) {

			var vars = this.vars[ shaderStage ];
			var index = vars.length;

			nodeVar = new NodeVar( 'nodeVar${index}', type );

			vars.add( nodeVar );

			nodeData["variable"] = nodeVar;

		}

		return nodeVar;

	}

	getVaryFromNode( node, type ) {

		Map nodeData = this.getDataFromNode( node, null );

		var nodeVary = nodeData["vary"];

		if ( nodeVary == undefined ) {

			var varys = this.varys;
			var index = varys.length;

			nodeVary = new NodeVary( 'nodeVary${index}', type );

			varys.add( nodeVary );

			nodeData["vary"] = nodeVary;

		}

		return nodeVary;

	}

	getCodeFromNode( node, type, [shaderStage] ) {

    shaderStage = shaderStage ?? this.shaderStage;

		var nodeData = this.getDataFromNode( node );

		var nodeCode = nodeData.code;

		if ( nodeCode == undefined ) {

			var codes = this.codes[ shaderStage ];
			var index = codes.length;

			nodeCode = new NodeCode( 'nodeCode' + index, type );

			codes.add( nodeCode );

			nodeData.code = nodeCode;

		}

		return nodeCode;

	}

	addFlowCode( code ) {

		this.flow["code"] += code;

	}

	getFlowData( shaderStage, node ) {

		return this.flowsData.get( node );

	}

	flowNode( node, shaderStage ) {

		this.node = node;

		var output = node.getNodeType( this );

		var flowData = this.flowChildNode( node, output );

		this.flowsData.set( node, flowData );

		this.node = null;

		return flowData;

	}

	flowChildNode( node, [output = null] ) {

		var previousFlow = this.flow;

		var flow = {
			"code": '',
		};

		this.flow = flow;

		flow["result"] = node.build( this, output );

		this.flow = previousFlow;

		return flow;

	}

	flowNodeFromShaderStage( shaderStage, node, [output = null, propertyName = null] ) {

		var previousShaderStage = this.shaderStage;

		this.setShaderStage( shaderStage );

		Map flowData = this.flowChildNode( node, output );

		if ( propertyName != null ) {

			flowData["code"] += "${propertyName} = ${flowData["result"]};\n\t";

		}

		this.flowCode[ shaderStage ] = this.flowCode[ shaderStage ] + flowData["code"];

		this.setShaderStage( previousShaderStage );

		return flowData;

	}

	getAttributes( shaderStage ) {

		var snippet = '';

		if ( shaderStage == 'vertex' ) {

			var attributes = this.attributes;

			for ( var index = 0; index < attributes.length; index ++ ) {

				var attribute = attributes[ index ];

				snippet += "layout(location = ${index}) in ${attribute.type} ${attribute.name}; ";

			}

		}

		return snippet;

	}

	getVarys( shaderStage ) {

		console.warn( 'Abstract function.' );

	}

	getVars( shaderStage ) {

		var snippet = '';

		var vars = this.vars[ shaderStage ];

		for ( var index = 0; index < vars.length; index ++ ) {

			var variable = vars[ index ];

			snippet += "${variable.type} ${variable.name}; ";

		}

		return snippet;

	}

	getUniforms( shaderStage ) {

		console.warn( 'Abstract function.' );

	}

	getCodes( shaderStage ) {

		var codes = this.codes[ shaderStage ];

		var code = '';

		for ( var nodeCode in codes ) {

			code += nodeCode.code + '\n';

		}

		return code;

	}

	getHash() {

		return this.vertexShader + this.fragmentShader;

	}

	getShaderStage() {

		return this.shaderStage;

	}

	setShaderStage( shaderStage ) {

		this.shaderStage = shaderStage;

	}

	buildCode() {

		console.warn( 'Abstract function.' );

	}

	build() {

		if ( this.context["vertex"] != null && this.context["vertex"] is Node ) {

			this.flowNodeFromShaderStage( 'vertex', this.context["vertex"] );

		}

		for ( var shaderStage in shaderStages ) {

			this.setShaderStage( shaderStage );

			var flowNodes = this.flowNodes[ shaderStage ];

			for ( var node in flowNodes ) {

				this.flowNode( node, shaderStage );

			}

		}

		this.setShaderStage( null );

		this.buildCode();

		return this;

	}

	format( snippet, fromType, toType ) {

		fromType = this.getVectorType( fromType );
		toType = this.getVectorType( toType );

		var typeToType = "${fromType} to ${toType}";

		switch ( typeToType ) {

			case 'int to float' : return "${ this.getType( 'float' ) }( ${ snippet } )";
			case 'int to vec2' : return "${ this.getType( 'vec2' ) }( ${ this.getType( 'float' ) }( ${ snippet } ) )";
			case 'int to vec3' : return "${ this.getType( 'vec3' ) }( ${ this.getType( 'float' ) }( ${ snippet } ) )";
			case 'int to vec4' : return "${ this.getType( 'vec4' ) }( ${ this.getType( 'vec3' ) }( ${ this.getType( 'float' ) }( ${ snippet } ) ), 1.0 )";

			case 'float to int' : return "${ this.getType( 'int' ) }( ${ snippet } )";
			case 'float to vec2' : return "${ this.getType( 'vec2' ) }( ${ snippet } )";
			case 'float to vec3' : return "${ this.getType( 'vec3' ) }( ${ snippet } )";
			case 'float to vec4' : return "${ this.getType( 'vec4' ) }( ${ this.getType( 'vec3' ) }( ${ snippet } ), 1.0 )";

			case 'vec2 to int' : return "${ this.getType( 'int' ) }( ${ snippet }.x )";
			case 'vec2 to float' : return "${ snippet }.x";
			case 'vec2 to vec3' : return "${ this.getType( 'vec3' ) }( ${ snippet }, 0.0 )";
			case 'vec2 to vec4' : return "${ this.getType( 'vec4' ) }( ${ snippet }.xy, 0.0, 1.0 )";

			case 'vec3 to int' : return "${ this.getType( 'int' ) }( ${ snippet }.x )";
			case 'vec3 to float' : return "${ snippet }.x";
			case 'vec3 to vec2' : return "${ snippet }.xy";
			case 'vec3 to vec4' : return "${ this.getType( 'vec4' ) }( ${ snippet }, 1.0 )";

			case 'vec4 to int' : return "${ this.getType( 'int' ) }( ${ snippet }.x )";
			case 'vec4 to float' : return "${ snippet }.x";
			case 'vec4 to vec2' : return "${ snippet }.xy";
			case 'vec4 to vec3' : return "${ snippet }.xyz";

			case 'mat3 to int' : return "${ this.getType( 'int' ) }( ${ snippet } * ${ this.getType( 'vec3' ) }( 1.0 ) ).x";
			case 'mat3 to float' : return "( ${ snippet } * ${ this.getType( 'vec3' ) }( 1.0 ) ).x";
			case 'mat3 to vec2' : return "( ${ snippet } * ${ this.getType( 'vec3' ) }( 1.0 ) ).xy";
			case 'mat3 to vec3' : return "( ${ snippet } * ${ this.getType( 'vec3' ) }( 1.0 ) ).xyz";
			case 'mat3 to vec4' : return "${ this.getType( 'vec4' ) }( ${ snippet } * ${ this.getType( 'vec3' ) }( 1.0 ), 1.0 )";

			case 'mat4 to int' : return "${ this.getType( 'int' ) }( ${ snippet } * ${ this.getType( 'vec4' ) }( 1.0 ) ).x";
			case 'mat4 to float' : return "( ${ snippet } * ${ this.getType( 'vec4' ) }( 1.0 ) ).x";
			case 'mat4 to vec2' : return "( ${ snippet } * ${ this.getType( 'vec4' ) }( 1.0 ) ).xy";
			case 'mat4 to vec3' : return "( ${ snippet } * ${ this.getType( 'vec4' ) }( 1.0 ) ).xyz";
			case 'mat4 to vec4' : return "( ${ snippet } * ${ this.getType( 'vec4' ) }( 1.0 ) )";

		}

		return snippet;

	}

	getSignature() {

		return """// Three.js r${ REVISION } - NodeMaterial System\n""";

	}

}