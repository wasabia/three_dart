
import 'package:three_dart/three3d/core/base_buffer_attribute.dart';

class GLBufferAttribute extends BaseBufferAttribute {
  GLBufferAttribute(
      int buffer, String type, int itemSize, int elementSize, int count)
      : super() {
    this.buffer = buffer;
    this.type = type;
    this.itemSize = itemSize;
    this.elementSize = elementSize;
    this.count = count;

    version = 0;
  }

  set needsUpdate(bool value) {
    if (value == true) version++;
  }

  GLBufferAttribute setBuffer(int buffer) {
    this.buffer = buffer;

    return this;
  }

  GLBufferAttribute setType(String type, int elementSize) {
    this.type = type;
    this.elementSize = elementSize;

    return this;
  }

  GLBufferAttribute setItemSize(int itemSize) {
    this.itemSize = itemSize;

    return this;
  }

  GLBufferAttribute setCount(int count) {
    this.count = count;

    return this;
  }
}
