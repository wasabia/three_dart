part of three_core;

class InstancedBufferGeometry extends BufferGeometry {
  InstancedBufferGeometry() : super() {
    type = 'InstancedBufferGeometry';
    instanceCount = Math.Infinity.toInt();
    isInstancedBufferGeometry = true;
  }

  @override
  InstancedBufferGeometry copy(BufferGeometry source) {
    super.copy(source);
    instanceCount = source.instanceCount;
    return this;
  }

  @override
  BufferGeometry clone() {
    return InstancedBufferGeometry().copy(this);
  }

  @override
  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    var data = super.toJSON(meta: meta);
    data['instanceCount'] = instanceCount;
    data['isInstancedBufferGeometry'] = true;
    return data;
  }
}
