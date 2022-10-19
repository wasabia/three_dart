import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/interleaved_buffer.dart';

abstract class BaseBufferAttribute<TData extends NativeArray> {
  late TData array;
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

  void Function()? onUploadCallback;

  int? buffer;
  int? elementSize;

  BaseBufferAttribute();
}
