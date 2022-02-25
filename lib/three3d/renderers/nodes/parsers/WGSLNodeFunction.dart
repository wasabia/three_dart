part of renderer_nodes;

var declarationRegexp = RegExp(r"^fn\s*([a-z_0-9]+)?\s*\(([\s\S]*?)\)\s*\-\>\s*([a-z_0-9]+)?", caseSensitive: false);
var propertiesRegexp = RegExp(r"[a-z_0-9]+", caseSensitive: false);

parse( source ) {

	source = source.trim();

	var declaration = source.match( declarationRegexp );

	if ( declaration != null && declaration.length == 4 ) {

		// tokenizer

		var inputsCode = declaration[ 2 ];
		var propsMatches = [];


    var matches = propertiesRegexp.allMatches(inputsCode);
    for(var match in matches) {
      propsMatches.add( match.group(0) );
    }


		// parser

		var inputs = [];

		var i = 0;

		while ( i < propsMatches.length ) {

			var name = propsMatches[ i ++ ][ 0 ];
			var type = propsMatches[ i ++ ][ 0 ];

			propsMatches[ i ++ ][ 0 ]; // precision

			inputs.add( NodeFunctionInput( type, name ) );

		}

		//

		var blockCode = source.substring( declaration[ 0 ].length );

		var name = declaration[ 1 ] != undefined ? declaration[ 1 ] : '';
		var type = declaration[ 3 ];

		return {
			type,
			inputs,
			name,
			inputsCode,
			blockCode
		};

	} else {

		throw( 'FunctionNode: Function is not a WGSL code.' );

	}

}

class WGSLNodeFunction extends NodeFunction {

  late String inputsCode;
  late String blockCode;

  WGSLNodeFunction.create(type, inputs, name) : super(type, inputs, name) {

  }


	factory WGSLNodeFunction( source ) {
    var data = parse( source );
    var type = data["type"];
    var inputs = data["inputs"];
    var name = data["name"];
    var inputsCode = data["inputsCode"];
    var blockCode = data["blockCode"];
    
    var wnf = WGSLNodeFunction.create(type, inputs, name);

		wnf.inputsCode = inputsCode;
		wnf.blockCode = blockCode;

    return wnf;
	}

	getCode( [name] ) {

    name ??= this.name;

		return """fn ${ name } ( ${ this.inputsCode.trim() } ) -> ${ this.type }""" + this.blockCode;

	}

}

