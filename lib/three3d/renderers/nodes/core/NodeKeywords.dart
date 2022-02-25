part of renderer_nodes;

class NodeKeywords {

  late List keywords;
  late List nodes;
  late Map keywordsCallback;

	NodeKeywords() {

		this.keywords = [];
		this.nodes = [];
		this.keywordsCallback = {};

	}

	getNode( name ) {

		var node = this.nodes[ name ];

		if ( node == undefined && this.keywordsCallback[ name ] != undefined ) {

			node = this.keywordsCallback[ name ]( name );

			this.nodes[ name ] = node;

		}

		return node;

	}

	addKeyword( name, callback ) {

		this.keywords.add( name );
		this.keywordsCallback[ name ] = callback;

		return this;

	}

	parse( code ) {

		var keywordNames = this.keywords;

		var regExp = RegExp( r"\\b${keywordNames.join( '\\b|\\b' )}\\b", caseSensitive: false);

		var codeKeywords = code.match( regExp );

		var keywordNodes = [];

		if ( codeKeywords != null ) {

			for ( var keyword in codeKeywords ) {

				var node = this.getNode( keyword );

				if ( node != undefined && keywordNodes.indexOf( node ) == - 1 ) {

					keywordNodes.add( node );

				}

			}

		}

		return keywordNodes;

	}

	include( builder, code ) {

		var keywordNodes = this.parse( code );

		for ( var keywordNode in keywordNodes ) {

			keywordNode.build( builder );

		}

	}

}

