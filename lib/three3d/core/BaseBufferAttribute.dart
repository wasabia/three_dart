part of three_core;

class BaseBufferAttribute {
  dynamic array;
  late int itemSize;

  InterleavedBuffer? data;

  late String type;

  // 保持可空
  // 在 Mesh.updateMorphTargets 里当name是null时使用index替换
  String? name;

  int count = 0;
  bool normalized = false;
  int usage = StaticDrawUsage;
  int version = 0;
  Map<String, int>? updateRange;

  Function? onUploadCallback;

  int? buffer;
  int? elementSize;

  bool isGLBufferAttribute = false;
  bool isInterleavedBufferAttribute = false;
  bool isInstancedBufferAttribute = false;
  bool isFloat16BufferAttribute = false;

  BaseBufferAttribute() {}
}
