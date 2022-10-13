part of three_core;

class InstancedBufferAttribute extends BufferAttribute {
  late int meshPerAttribute;

  InstancedBufferAttribute(NativeArray array, int itemSize,
      [bool normalized = false, this.meshPerAttribute = 1])
      : super(array, itemSize, normalized) {
    type = "InstancedBufferAttribute";
    // if ( normalized is num ) {
    //   meshPerAttribute = normalized;
    //   normalized = false;
    //   print( 'THREE.InstancedBufferAttribute: The constructor now expects normalized as the third argument.' );
    // }
  }

  @override
  BufferAttribute copy(BufferAttribute source) {
    super.copy(source);
    if (source is InstancedBufferAttribute) {
      meshPerAttribute = source.meshPerAttribute;
    }
    return this;
  }

  @override
  Map<String, dynamic> toJSON([data]) {
    var result = super.toJSON();
    result['meshPerAttribute'] = meshPerAttribute;
    result['isInstancedBufferAttribute'] = true;
    return result;
  }
}
