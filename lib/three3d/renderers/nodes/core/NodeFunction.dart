part of renderer_nodes;

class NodeFunction {

  late dynamic type;
  late dynamic inputs;
  late String name;
  late String presicion;

	NodeFunction( type, inputs, [name = '', presicion = ''] ) {

		this.type = type;
		this.inputs = inputs;
		this.name = name;
		this.presicion = presicion;

	}

	getCode( /*name = this.name*/ ) {

		console.warn( 'Abstract function.' );

	}

}
