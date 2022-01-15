part of three_core;

class InstancedBufferAttribute extends BufferAttribute {
  late num meshPerAttribute;
  bool isInstancedBufferAttribute = true;
  String type = "InstancedBufferAttribute";

  InstancedBufferAttribute(array, itemSize,
      [bool normalized = false, num meshPerAttribute = 1])
      : super(array, itemSize, normalized) {
    // if ( normalized is num ) {
    //   meshPerAttribute = normalized;
    //   normalized = false;
    //   print( 'THREE.InstancedBufferAttribute: The constructor now expects normalized as the third argument.' );
    // }

    this.meshPerAttribute = meshPerAttribute;
  }

  copy(source) {
    super.copy(source);

    this.meshPerAttribute = source.meshPerAttribute;

    return this;
  }

  toJSON() {
    var data = super.toJSON();

    data.meshPerAttribute = this.meshPerAttribute;

    data.isInstancedBufferAttribute = true;

    return data;
  }
}
