part of renderer_nodes;

class Node {
  late String uuid;
  String? nodeType;
  late NodeUpdateType updateType;
  late dynamic inputType;

  late bool constant;

  late int generateLength;

  dynamic value;



	Node( [nodeType = null] ) {

		this.nodeType = nodeType;

		this.updateType = NodeUpdateType.None;

		this.uuid = MathUtils.generateUUID();
	}

	get type {

		return this.runtimeType.toString();

	}

	getHash( [builder] ) {

		return this.uuid;

	}

	getUpdateType( [builder] ) {

		return this.updateType;

	}

	getNodeType( [builder, output] ) {

		return this.nodeType;

	}

	update( [frame] ) {

		console.warn( 'Abstract function.' );

	}

	generate( [builder, output] ) {

		console.warn( 'Abstract function.' );

	}

	build( NodeBuilder builder, [output = null] ) {

		var hash = this.getHash( builder );
		var sharedNode = builder.getNodeFromHash( hash );

		if ( sharedNode != undefined && this != sharedNode ) {

			return sharedNode.build( builder, output );

		}

		builder.addNode( this );
		builder.addStack( this );

    // generate 函数的参数长度？
    // dart不支持 
		var isGenerateOnce = (this.generateLength == 1);


		var snippet = null;

		if ( isGenerateOnce ) {

			var type = this.getNodeType( builder );
			var nodeData = builder.getDataFromNode( this );

			snippet = nodeData["snippet"];

			if ( snippet == undefined ) {

				snippet = this.generate( builder ) ?? '';

				nodeData["snippet"] = snippet;

			}

			snippet = builder.format( snippet, type, output );

		} else {

			snippet = this.generate( builder, output ) ?? '';

		}

		builder.removeStack( this );

		return snippet;

	}

  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    String name = invocation.memberName.toString();
    
    name = name.replaceFirst(RegExp(r'^Symbol\("'), "");
    name = name.replaceFirst(RegExp(r'"\)$'), "");

    String prop = name;

    // handler get
    if ( prop is String && this.getProperty(prop) == undefined ) {

			if ( RegExp(r"^[xyzwrgbastpq]{1,4}$").hasMatch( prop ) == true ) {

				// accessing properties ( swizzle )

				prop = prop..replaceAll( RegExp(r"r|s"), 'x' )
					.replaceAll( RegExp(r"g|t"), 'y' )
					.replaceAll( RegExp(r"b|p"), 'z' )
					.replaceAll( RegExp(r"a|q"), 'w' );

				return ShaderNodeObject( new SplitNode( this, prop ) );

			} else if ( RegExp(r"^\d+$").hasMatch( prop ) == true ) {

				// accessing array

				return ShaderNodeObject( new ArrayElementNode( this, new FloatNode( num.parse( prop ) ).setConst( true ) ) );

			}

		}

		return this.getProperty(prop);
  }


  getProperty(String name) {
    print("Node ${this} getProperty name: ${name} is not support  ");
    return null;
  }

}
