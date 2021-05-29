part of three_core;


class InstancedBufferGeometry extends BufferGeometry {

	String type = 'InstancedBufferGeometry';
	int? instanceCount = Math.Infinity.toInt();
  bool isInstancedBufferGeometry = true;

  InstancedBufferGeometry() : super() {

  }



	copy ( source ) {

		super.copy( source );

		this.instanceCount = source.instanceCount;

		return this;

	}

	clone () {

		return InstancedBufferGeometry().copy( this );

	}

	toJSON ({Object3dMeta? meta}) {

		var data = super.toJSON(meta: meta);

		data.instanceCount = this.instanceCount;

		data.isInstancedBufferGeometry = true;

		return data;

	}

}