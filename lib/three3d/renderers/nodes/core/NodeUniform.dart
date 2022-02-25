part of renderer_nodes;

class NodeUniform {

  late String name;
  late String type;
  late dynamic node;
  late dynamic needsUpdate;

	NodeUniform( name, type, node, [needsUpdate] ) {

		this.name = name;
		this.type = type;
		this.node = node;
		this.needsUpdate = needsUpdate;

	}

	get value {

		return this.node.value;

	}

	set value( val ) {

		this.node.value = val;

	}

}

