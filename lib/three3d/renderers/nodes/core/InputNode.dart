part of renderer_nodes;

class InputNode extends Node {

	InputNode( [inputType] ) : super(inputType) {
		this.inputType = inputType;

		this.constant = false;

	}

	setConst( value ) {

		this.constant = value;

		return this;

	}

	getConst() {

		return this.constant;

	}

	getInputType( builder ) {

		return this.inputType;

	}

	generateConst( builder ) {

		return builder.getConst( this.getNodeType( builder ), this.value );

	}

	@override
  generate( [builder, output] ) {

		var type = this.getNodeType( builder );

		if ( this.constant == true ) {

			return builder.format( this.generateConst( builder ), type, output );

		} else {

			var inputType = this.getInputType( builder );

			var nodeUniform = builder.getUniformFromNode( this, builder.shaderStage, inputType );
			var propertyName = builder.getPropertyName( nodeUniform );

			return builder.format( propertyName, type, output );

		}

	}

}
