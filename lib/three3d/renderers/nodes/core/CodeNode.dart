part of renderer_nodes;

class CodeNode extends Node {

  late String code;
  late bool useKeywords;
  late List _includes;


	CodeNode( [code = '', nodeType = 'code'] ) : super( nodeType ) {

		this.code = code;

		this.useKeywords = false;

		this._includes = [];

	}

	setIncludes( includes ) {

		this._includes = includes;

		return this;

	}

	getIncludes( builder ) {

		return this._includes;

	}

	@override
  generate( [builder, output] ) {

		if ( this.useKeywords == true ) {

			var contextKeywords = builder.context.keywords;

			if ( contextKeywords != undefined ) {

				var nodeData = builder.getDataFromNode( this, builder.shaderStage );

				if ( nodeData.keywords == undefined ) {

					nodeData.keywords = [];

				}

				if ( nodeData.keywords.indexOf( contextKeywords ) == - 1 ) {

					contextKeywords.include( builder, this.code );

					nodeData.keywords.push( contextKeywords );

				}

			}

		}

		var includes = this.getIncludes( builder );

		for ( var include in includes ) {

			include.build( builder );

		}

		var nodeCode = builder.getCodeFromNode( this, this.getNodeType( builder ) );
		nodeCode.code = this.code;

		return nodeCode.code;

	}

}

