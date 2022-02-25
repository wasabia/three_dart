part of renderer_nodes;


class BufferNode extends InputNode {

  late dynamic bufferType;
  late int bufferCount;

	BufferNode( value, bufferType, [bufferCount = 0] ) : super( 'buffer' ) {

		this.value = value;
		this.bufferType = bufferType;
		this.bufferCount = bufferCount;

	}

	getNodeType( [builder, output] ) {

		return this.bufferType;

	}

}
