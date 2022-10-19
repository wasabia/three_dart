import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/interleaved_buffer.dart';

class InstancedInterleavedBuffer extends InterleavedBuffer {
  late int meshPerAttribute;

  bool isInstancedInterleavedBuffer = true;

  InstancedInterleavedBuffer(NativeArray array, stride, meshPerAttribute) : super(array, stride) {
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
