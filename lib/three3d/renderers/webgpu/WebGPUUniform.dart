part of three_webgpu;


class WebGPUUniform {

  late String name;
  late dynamic value;

  late int boundary;
  late int itemSize;
  late int offset;

	WebGPUUniform( name, [value = null] ) {

		this.name = name;
		this.value = value;

		this.boundary = 0; // used to build the uniform buffer according to the STD140 layout
		this.itemSize = 0;

		this.offset = 0; // this property is set by WebGPUUniformsGroup and marks the start position in the uniform buffer

	}

	setValue( value ) {

		this.value = value;

	}

	getValue() {

		return this.value;

	}

}

class FloatUniform extends WebGPUUniform {

	FloatUniform( name, [value = 0] ) : super( name, value ) {

		this.boundary = 4;
		this.itemSize = 1;

	}

}


class Vector2Uniform extends WebGPUUniform {

	Vector2Uniform( name, [ value ]) : super( name, value ) {
		this.value ??= Vector2();
		this.boundary = 8;
		this.itemSize = 2;

	}

}


class Vector3Uniform extends WebGPUUniform {

	Vector3Uniform( name, [value] ) : super( name, value ) {

    this.value ??= Vector3();

		this.boundary = 16;
		this.itemSize = 3;

	}

}


class Vector4Uniform extends WebGPUUniform {

	Vector4Uniform( name, [value] ) : super( name, value ) {

    this.value ??= new Vector4(0,0,0,0);

		this.boundary = 16;
		this.itemSize = 4;

	}

}


class ColorUniform extends WebGPUUniform {

	ColorUniform( name, [value] ) : super( name, value ) {

    this.value ??= new Color();

		this.boundary = 16;
		this.itemSize = 3;

	}

}

class Matrix3Uniform extends WebGPUUniform {

	Matrix3Uniform( name, [value] ) : super( name, value ) {

    this.value = new Matrix3();

		this.boundary = 48;
		this.itemSize = 12;

	}

}


class Matrix4Uniform extends WebGPUUniform {

	Matrix4Uniform( name, value ) : super( name, value ) {
    this.value ??= new Matrix4();

		this.boundary = 64;
		this.itemSize = 16;

	}

}
