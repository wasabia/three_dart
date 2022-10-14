part of three_core;

class InstancedInterleavedBuffer extends InterleavedBuffer {
  late int meshPerAttribute;

  bool isInstancedInterleavedBuffer = true;
  
  InstancedInterleavedBuffer(NativeArray array, stride, meshPerAttribute)
      : super(array, stride) {
    this.meshPerAttribute = meshPerAttribute ?? 1;
    type = "InstancedInterleavedBuffer";
  }

  @override
  InstancedInterleavedBuffer copy(InterleavedBuffer source) {
    super.copy(source);
    if (source is InstancedInterleavedBuffer) {
      meshPerAttribute = source.meshPerAttribute;
    }
    return this;
  }

  @override
  clone(data) {
    var ib = super.clone(data);

    ib.meshPerAttribute = meshPerAttribute;

    return ib;
  }

  @override
  toJSON(data) {
    var json = super.toJSON(data);

    json["isInstancedInterleavedBuffer"] = true;
    json["meshPerAttributes"] = meshPerAttribute;

    return json;
  }
}
