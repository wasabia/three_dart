part of three_core;


class InstancedInterleavedBuffer extends InterleavedBuffer {

  late int meshPerAttribute;

  bool isInstancedInterleavedBuffer = true;

  String type = "InstancedInterleavedBuffer";

  InstancedInterleavedBuffer( array, stride, meshPerAttribute ) : super( array, stride ) {
    this.meshPerAttribute = meshPerAttribute ?? 1;
  }


  copy ( source ) {

		super.copy( source );

    var source1 = source as InstancedInterleavedBuffer;

		this.meshPerAttribute = source1.meshPerAttribute;

		return this;

	}

	clone ( data ) {

		var ib = super.clone( data );

		ib.meshPerAttribute = this.meshPerAttribute;

		return ib;

	}

	toJSON ( data ) {

		var json = super.toJSON( data );

		json["isInstancedInterleavedBuffer"] = true;
		json["meshPerAttributes"] = this.meshPerAttribute;

		return json;

	}

}
