part of three_webgpu;

class FloatNodeUniform extends FloatUniform {

  late dynamic nodeUniform;

	FloatNodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

class Vector2NodeUniform extends Vector2Uniform {

  late dynamic nodeUniform;

	Vector2NodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

class Vector3NodeUniform extends Vector3Uniform {
  late dynamic nodeUniform;

	Vector3NodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

class Vector4NodeUniform extends Vector4Uniform {
  late dynamic nodeUniform;

	Vector4NodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

class ColorNodeUniform extends ColorUniform {
  late dynamic nodeUniform;

	ColorNodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

class Matrix3NodeUniform extends Matrix3Uniform {

  late dynamic nodeUniform;

	Matrix3NodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

class Matrix4NodeUniform extends Matrix4Uniform {

  late dynamic nodeUniform;

	Matrix4NodeUniform( nodeUniform ) : super( nodeUniform.name, nodeUniform.value ) {

		this.nodeUniform = nodeUniform;

	}

	getValue() {

		return this.nodeUniform.value;

	}

}

