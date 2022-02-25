part of renderer_nodes;

class TempNode extends Node {

	TempNode( [type] ) : super( type ) {

	}

	build( builder, [output] ) {

		var type = builder.getVectorType( this.getNodeType( builder, output ) );

		if ( builder.context["temp"] != false && type != 'void ' && output != 'void' ) {

			Map nodeData = builder.getDataFromNode( this );

			if ( nodeData["snippet"] == undefined ) {

				var snippet = super.build( builder, type );

				var nodeVar = builder.getVarFromNode( this, type );
				var propertyName = builder.getPropertyName( nodeVar );

				builder.addFlowCode( "${propertyName} = ${snippet}" );

				nodeData["snippet"] = snippet;
				nodeData["propertyName"] = propertyName;

			}

			return builder.format( nodeData["propertyName"], type, output );

		}

		return super.build( builder, output );

	}

}

