part of renderer_nodes;

Proxy( target ) {
  return _Proxy(target);
}


class _Proxy { 
  late dynamic target;
  late dynamic handler;
  _Proxy(this.target) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    String name = invocation.memberName.toString();
    
    name = name.replaceFirst(RegExp(r'^Symbol\("'), "");
    name = name.replaceFirst(RegExp(r'"\)$'), "");

    String prop = name;
    var node = target;

    // handler get
    if ( prop is String && node.getProperty(prop) == undefined ) {

			if ( RegExp(r"^[xyzwrgbastpq]{1,4}$").hasMatch( prop ) == true ) {

				// accessing properties ( swizzle )

				prop = prop..replaceAll( RegExp(r"r|s"), 'x' )
					.replaceAll( RegExp(r"g|t"), 'y' )
					.replaceAll( RegExp(r"b|p"), 'z' )
					.replaceAll( RegExp(r"a|q"), 'w' );

				return ShaderNodeObject( new SplitNode( node, prop ) );

			} else if ( RegExp(r"^\d+$").hasMatch( prop ) == true ) {

				// accessing array

				return ShaderNodeObject( new ArrayElementNode( node, new FloatNode( num.parse( prop ) ).setConst( true ) ) );

			}

		}

		return node.getProperty(prop);
  }




}


// class NodeHandler {

// 	// factory NodeHandler( Function nodeClosure, params ) {
// 	// 	var inputs = params.shift();
// 	// 	return nodeClosure( ShaderNodeObjects( inputs ), params );
// 	// }

// 	get ( node, prop ) {

// 		if ( prop is String && node[ prop ] == undefined ) {

// 			if ( RegExp(r"^[xyzwrgbastpq]{1,4}$").hasMatch( prop ) == true ) {

// 				// accessing properties ( swizzle )

// 				prop = prop..replaceAll( RegExp(r"r|s"), 'x' )
// 					.replaceAll( RegExp(r"g|t"), 'y' )
// 					.replaceAll( RegExp(r"b|p"), 'z' )
// 					.replaceAll( RegExp(r"a|q"), 'w' );

// 				return ShaderNodeObject( new SplitNode( node, prop ) );

// 			} else if ( RegExp(r"^\d+$").hasMatch( prop ) == true ) {

// 				// accessing array

// 				return ShaderNodeObject( new ArrayElementNode( node, new FloatNode( num.parse( prop ) ).setConst( true ) ) );

// 			}

// 		}

// 		return node[ prop ];

// 	}

// }

var nodeObjects = new WeakMap();

ShaderNodeObject( obj ) {

	if ( obj is num ) {

		return ShaderNodeObject( new FloatNode( obj ).setConst( true ) );

	// } else if ( type == 'object' ) {
  } else if ( obj is Object ) {

		if ( obj is Node ) {

			var nodeObject = nodeObjects.get( obj );

			if ( nodeObject == undefined ) {

				// nodeObject = Proxy( obj );
        nodeObject = obj;
				nodeObjects.set( obj, nodeObject );

			}

			return nodeObject;

		}

	}

	return obj;

}

ShaderNodeObjects( objects ) {

	for ( var name in objects ) {

		objects[ name ] = ShaderNodeObject( objects[ name ] );

	}

	return objects;

}

ShaderNodeArray( array ) {

	var len = array.length;

	for ( var i = 0; i < len; i ++ ) {

		array[ i ] = ShaderNodeObject( array[ i ] );

	}

	return array;

}

ShaderNodeProxy( NodeClass, [scope = null, factor = null] ) {

  print(" ShaderNode .ShaderNodeProxy NodeClass: ${NodeClass} ");

  // TODO

	// if ( scope == null ) {

	// 	return ( params ) {

	// 		return ShaderNodeObject( new NodeClass( ShaderNodeArray( params ) ) );

	// 	};

	// } else if ( factor == null ) {

	// 	return ( params ) {

	// 		return ShaderNodeObject( new NodeClass( scope, ShaderNodeArray( params ) ) );

	// 	};

	// } else {

	// 	factor = ShaderNodeObject( factor );

	// 	return ( params ) {

	// 		return ShaderNodeObject( new NodeClass( scope, ShaderNodeArray( params ), factor ) );

	// 	};

	// }

}


ShaderNodeScript( jsFunc ) {

	return ( inputs, builder ) {

		ShaderNodeObjects( inputs );

		return ShaderNodeObject( jsFunc( inputs, builder ) );

	};

}


// var ShaderNode = Proxy( ShaderNodeScript, NodeHandler );
var ShaderNode = ShaderNodeScript;


//
// Node Material Shader Syntax
//

var uniform = ShaderNode( ( inputNode ) {

	inputNode.setConst( false );

	return inputNode;

} );

var nodeObject = ( val ) {

	return ShaderNodeObject( val );

};

var float = ( val ) {

	return nodeObject( new FloatNode( val ).setConst( true ) );

};

var color = ( params ) {

	return nodeObject( new ColorNode( new Color( params ) ).setConst( true ) );

};

var join = ( params ) {

	return nodeObject( new JoinNode( ShaderNodeArray( params ) ) );

};

var cond = ( params ) {

	return nodeObject( new CondNode( ShaderNodeArray( params ) ) );

};

var vec2 = ( params ) {

	if ( params[ 0 ]?.isNode == true ) {

		return nodeObject( new ConvertNode( params[ 0 ], 'vec2' ) );

	} else {

		// Providing one scalar value: This value is used for all components

		if ( params.length == 1 ) {

			params[ 1 ] = params[ 0 ];

		}

		return nodeObject( new Vector2Node( new Vector2( params ) ).setConst( true ) );

	}

};

var vec3 = ( params ) {

	if ( params[ 0 ]?.isNode == true ) {

		return nodeObject( new ConvertNode( params[ 0 ], 'vec3' ) );

	} else {

		// Providing one scalar value: This value is used for all components

		if ( params.length == 1 ) {

			params[ 1 ] = params[ 2 ] = params[ 0 ];

		}

		return nodeObject( new Vector3Node( new Vector3( params ) ).setConst( true ) );

	}

};

var vec4 = ( params ) {

	if ( params[ 0 ]?.isNode == true ) {

		return nodeObject( new ConvertNode( params[ 0 ], 'vec4' ) );

	} else {

		// Providing one scalar value: This value is used for all components

		if ( params.length == 1 ) {

			params[ 1 ] = params[ 2 ] = params[ 3 ] = params[ 0 ];

		}

		return nodeObject( new Vector4Node( new Vector4( params ) ).setConst( true ) );

	}

};

var addTo = ( varNode, params ) {

	varNode.node = add( varNode.node, ShaderNodeArray( params ) );

	return nodeObject( varNode );

};

var add = ShaderNodeProxy( OperatorNode, '+' );
var sub = ShaderNodeProxy( OperatorNode, '-' );
var mul = ShaderNodeProxy( OperatorNode, '*' );
var div = ShaderNodeProxy( OperatorNode, '/' );
var equal = ShaderNodeProxy( OperatorNode, '==' );
var assign = ShaderNodeProxy( OperatorNode, '=' );
var greaterThan = ShaderNodeProxy( OperatorNode, '>' );
var lessThanEqual = ShaderNodeProxy( OperatorNode, '<=' );
var and = ShaderNodeProxy( OperatorNode, '&&' );

var element = ShaderNodeProxy( ArrayElementNode );

var normalGeometry = new NormalNode( NormalNode.GEOMETRY );
var normalLocal = new NormalNode( NormalNode.LOCAL );
var normalWorld = new NormalNode( NormalNode.WORLD );
var normalView = new NormalNode( NormalNode.VIEW );
var transformedNormalView = new VarNode( new NormalNode( NormalNode.VIEW ), 'TransformedNormalView', 'vec3' );

var positionLocal = new PositionNode( PositionNode.LOCAL );
var positionWorld = new PositionNode( PositionNode.WORLD );
var positionView = new PositionNode( PositionNode.VIEW );
var positionViewDirection = new PositionNode( PositionNode.VIEW_DIRECTION );

var PI = float( 3.141592653589793 );
var PI2 = float( 6.283185307179586 );
var PI_HALF = float( 1.5707963267948966 );
var RECIPROCAL_PI = float( 0.3183098861837907 );
var RECIPROCAL_PI2 = float( 0.15915494309189535 );
var EPSILON = float( 1e-6 );

var diffuseColor = new PropertyNode( 'DiffuseColor', 'vec4' );
var roughness = new PropertyNode( 'Roughness', 'float' );
var metalness = new PropertyNode( 'Metalness', 'float' );
var alphaTest = new PropertyNode( 'AlphaTest', 'float' );
var specularColor = new PropertyNode( 'SpecularColor', 'color' );

var abs = ShaderNodeProxy( MathNode, 'abs' );
var acos = ShaderNodeProxy( MathNode, 'acos' );
var asin = ShaderNodeProxy( MathNode, 'asin' );
var atan = ShaderNodeProxy( MathNode, 'atan' );
var ceil = ShaderNodeProxy( MathNode, 'ceil' );
var clamp = ShaderNodeProxy( MathNode, 'clamp' );
var cos = ShaderNodeProxy( MathNode, 'cos' );
var cross = ShaderNodeProxy( MathNode, 'cross' );
var degrees = ShaderNodeProxy( MathNode, 'degrees' );
var dFdx = ShaderNodeProxy( MathNode, 'dFdx' );
var dFdy = ShaderNodeProxy( MathNode, 'dFdy' );
var distance = ShaderNodeProxy( MathNode, 'distance' );
var dot = ShaderNodeProxy( MathNode, 'dot' );
var exp = ShaderNodeProxy( MathNode, 'exp' );
var exp2 = ShaderNodeProxy( MathNode, 'exp2' );
var faceforward = ShaderNodeProxy( MathNode, 'faceforward' );
var floor = ShaderNodeProxy( MathNode, 'floor' );
var fract = ShaderNodeProxy( MathNode, 'fract' );
var invert = ShaderNodeProxy( MathNode, 'invert' );
var inversesqrt = ShaderNodeProxy( MathNode, 'inversesqrt' );
var length = ShaderNodeProxy( MathNode, 'length' );
var log = ShaderNodeProxy( MathNode, 'log' );
var log2 = ShaderNodeProxy( MathNode, 'log2' );
var max = ShaderNodeProxy( MathNode, 'max' );
var min = ShaderNodeProxy( MathNode, 'min' );
var mix = ShaderNodeProxy( MathNode, 'mix' );
var mod = ShaderNodeProxy( MathNode, 'mod' );
var negate = ShaderNodeProxy( MathNode, 'negate' );
var normalize = ShaderNodeProxy( MathNode, 'normalize' );
var pow = ShaderNodeProxy( MathNode, 'pow' );
var pow2 = ShaderNodeProxy( MathNode, 'pow', 2 );
var pow3 = ShaderNodeProxy( MathNode, 'pow', 3 );
var pow4 = ShaderNodeProxy( MathNode, 'pow', 4 );
var radians = ShaderNodeProxy( MathNode, 'radians' );
var reflect = ShaderNodeProxy( MathNode, 'reflect' );
var refract = ShaderNodeProxy( MathNode, 'refract' );
var round = ShaderNodeProxy( MathNode, 'round' );
var saturate = ShaderNodeProxy( MathNode, 'saturate' );
var sign = ShaderNodeProxy( MathNode, 'sign' );
var sin = ShaderNodeProxy( MathNode, 'sin' );
var smoothstep = ShaderNodeProxy( MathNode, 'smoothstep' );
var sqrt = ShaderNodeProxy( MathNode, 'sqrt' );
var step = ShaderNodeProxy( MathNode, 'step' );
var tan = ShaderNodeProxy( MathNode, 'tan' );
var transformDirection = ShaderNodeProxy( MathNode, 'transformDirection' );
