part of renderer_nodes;


class UVNode extends AttributeNode {

  late int index;

	UVNode( [index = 0] ) : super( null, 'vec2' ) {

		this.index = index;

	}

	getAttributeName( builder ) {

		var index = this.index;

		return 'uv${( index > 0 ? index + 1 : '' )}';

	}

}

