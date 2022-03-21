part of three_core;

abstract class BufferAttribute<TData extends NativeArray>
    extends BaseBufferAttribute<TData> {
  final _vector = Vector3.init();
  final _vector2 = Vector2(null, null);

  bool isBufferAttribute = true;

  BufferAttribute(TData arrayList, int itemSize, [bool normalized = false]) {
    type = "BufferAttribute";
    array = arrayList;
    this.itemSize = itemSize;
    count = array.length ~/ itemSize;
    this.normalized = normalized == true;

    usage = StaticDrawUsage;
    updateRange = {"offset": 0, "count": -1};

    version = 0;
  }

  int get length => count;

  set needsUpdate(bool value) {
    if (value == true) version++;
  }

  BufferAttribute setUsage(int value) {
    usage = value;

    return this;
  }

  BufferAttribute copy(BufferAttribute source) {
    name = source.name;
    itemSize = source.itemSize;
    count = source.count;
    normalized = source.normalized;
    type = source.type;
    usage = source.usage;
    array = source.array.clone() as TData;
    return this;
  }

  BufferAttribute copyAt(int index1, BufferAttribute attribute, int index2) {
    index1 *= itemSize;
    index2 *= attribute.itemSize;

    for (var i = 0, l = itemSize; i < l; i++) {
      array[index1 + i] = attribute.array[index2 + i];
    }

    return this;
  }

  BufferAttribute copyArray(TData array) {
    this.array = array;
    return this;
  }

  BufferAttribute copyColorsArray(List<Color> colors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = colors.length; i < l; i++) {
      var color = colors[i];
      array[offset++] = color.r;
      array[offset++] = color.g;
      array[offset++] = color.b;
    }

    return this;
  }

  BufferAttribute copyVector2sArray(List<Vector2> vectors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = vectors.length; i < l; i++) {
      var vector = vectors[i];
      array[offset++] = vector.x;
      array[offset++] = vector.y;
    }

    return this;
  }

  BufferAttribute copyVector3sArray(List<Vector3> vectors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = vectors.length; i < l; i++) {
      var vector = vectors[i];
      array[offset++] = vector.x;
      array[offset++] = vector.y;
      array[offset++] = vector.z;
    }

    return this;
  }

  BufferAttribute copyVector4sArray(List<Vector4> vectors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = vectors.length; i < l; i++) {
      var vector = vectors[i];
      array[offset++] = vector.x;
      array[offset++] = vector.y;
      array[offset++] = vector.z;
      array[offset++] = vector.w;
    }

    return this;
  }

  BufferAttribute applyMatrix3(Matrix3 m) {
    if (itemSize == 2) {
      for (var i = 0, l = count; i < l; i++) {
        _vector2.fromBufferAttribute(this, i);
        _vector2.applyMatrix3(m);

        setXY(i, _vector2.x, _vector2.y);
      }
    } else if (itemSize == 3) {
      for (var i = 0, l = count; i < l; i++) {
        _vector.fromBufferAttribute(this, i);
        _vector.applyMatrix3(m);

        setXYZ(i, _vector.x, _vector.y, _vector.z);
      }
    }

    return this;
  }

  void applyMatrix4(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i)!;
      _vector.y = getY(i)!;
      _vector.z = getZ(i)!;

      _vector.applyMatrix4(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }
  }

  BufferAttribute applyNormalMatrix(m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i)!;
      _vector.y = getY(i)!;
      _vector.z = getZ(i)!;

      _vector.applyNormalMatrix(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  BufferAttribute transformDirection(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i)!;
      _vector.y = getY(i)!;
      _vector.z = getZ(i)!;

      _vector.transformDirection(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  BufferAttribute set(value, {int offset = 0}) {
    array[offset] = value;

    return this;
  }

  num? getX(int index) {
    return getAt(index * itemSize);
  }

  BufferAttribute setX(int index, x) {
    array[index * itemSize] = x;

    return this;
  }

  num? getY(int index) {
    return getAt(index * itemSize + 1);
  }

  BufferAttribute setY(int index, y) {
    array[index * itemSize + 1] = y;

    return this;
  }

  num? getZ(int index) {
    return getAt(index * itemSize + 2);
  }

  BufferAttribute setZ(int index, z) {
    array[index * itemSize + 2] = z;

    return this;
  }

  num? getW(int index) {
    return getAt(index * itemSize + 3);
  }

  num? getAt(int index) {
    if (index < array.length) {
      return array[index];
    } else {
      return null;
    }
  }

  BufferAttribute setW(int index, w) {
    array[index * itemSize + 3] = w;

    return this;
  }

  BufferAttribute setXY(int index, x, y) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;

    return this;
  }

  void setXYZ(int index, num x, num y, num z) {
    int _idx = index * itemSize;

    array[_idx + 0] = x.toDouble();
    array[_idx + 1] = y.toDouble();
    array[_idx + 2] = z.toDouble();
  }

  BufferAttribute setXYZW(int index, x, y, z, w) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;
    array[index + 2] = z;
    array[index + 3] = w;

    return this;
  }

  BufferAttribute onUpload(callback) {
    onUploadCallback = callback;

    return this;
  }

  BufferAttribute clone() {
    // if (type == "BufferAttribute") {
    //   return BufferAttribute(array, itemSize, false).copy(this);
    // } else
    if (type == "Float32BufferAttribute") {
      final typed = array as Float32Array;
      return Float32BufferAttribute(typed, itemSize, false).copy(this);
    } else if (type == "Uint8BufferAttribute") {
      final typed = array as Uint8Array;
      return Uint8BufferAttribute(typed, itemSize, false).copy(this);
    } else if (type == "Uint16BufferAttribute") {
      final typed = array as Uint16Array;
      return Uint16BufferAttribute(typed, itemSize, false).copy(this);
    } else {
      throw ("BufferAttribute type: $type clone need support ....  ");
    }
  }

  toJSON([data]) {
    // print(" BufferAttribute to JSON todo  ${this.array.runtimeType} ");

    // return {
    // 	"itemSize": this.itemSize,
    // 	"type": this.array.runtimeType.toString(),
    // 	"array": this.array.sublist(0),
    // 	"normalized": this.normalized
    // };
    Map<String, dynamic> result = {
      "itemSize": itemSize,
      "type": array.runtimeType.toString(), //.replaceAll('List', 'Array'),
      "array": array.sublist(0),
      "normalized": normalized
    };

    if (name != null) result["name"] = name;
    if (usage != StaticDrawUsage) result["usage"] = usage;
    if (updateRange?["offset"] != 0 || updateRange?["count"] != -1) {
      result["updateRange"] = updateRange;
    }

    return result;
  }
}

class Int8BufferAttribute extends BufferAttribute<Int8Array> {
  Int8BufferAttribute(Int8Array array, int itemSize, [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Int8BufferAttribute";
  }
}

class Uint8BufferAttribute extends BufferAttribute<Uint8Array> {
  Uint8BufferAttribute(Uint8Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Uint8BufferAttribute";
  }
}

class Uint8ClampedBufferAttribute extends BufferAttribute<Uint8Array> {
  Uint8ClampedBufferAttribute(Uint8Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Uint8ClampedBufferAttribute";
  }
}

class Int16BufferAttribute extends BufferAttribute<Int16Array> {
  Int16BufferAttribute(Int16Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Int16BufferAttribute";
  }
}

// Int16BufferAttribute.prototype = Object.create( BufferAttribute.prototype );
// Int16BufferAttribute.prototype.constructor = Int16BufferAttribute;

class Uint16BufferAttribute extends BufferAttribute<Uint16Array> {
  Uint16BufferAttribute(Uint16Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Uint16BufferAttribute";
  }
}

class Int32BufferAttribute extends BufferAttribute<Int32Array> {
  Int32BufferAttribute(Int32Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Int32BufferAttribute";
  }
}

class Uint32BufferAttribute extends BufferAttribute<Uint32Array> {
  Uint32BufferAttribute(Uint32Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Uint32BufferAttribute";
  }
}

// class Float16BufferAttribute extends BufferAttribute {
//   Float16BufferAttribute(array, int itemSize, [bool normalized = false])
//       : super(array, itemSize, normalized) {
//     type = "Float16BufferAttribute";
//   }
// }

class Float32BufferAttribute extends BufferAttribute<Float32Array> {
  Float32BufferAttribute(Float32Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Float32BufferAttribute";
  }
}

class Float64BufferAttribute extends BufferAttribute<Float64Array> {
  Float64BufferAttribute(Float64Array array, int itemSize,
      [bool normalized = false])
      : super(array, itemSize, normalized) {
    type = "Float64BufferAttribute";
  }
}
