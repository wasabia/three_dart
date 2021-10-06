import 'dart:typed_data';
import 'index.dart';

class PlatformNativeArray extends NativeArray {
  late dynamic list;
  late int _size;
  late int oneByteSize;
  int get length => _size;

  get data => list;

  get bytesLength => length * oneByteSize;

  get buffer => list.buffer;

  PlatformNativeArray(int size) {
    _size = size;
  }

  PlatformNativeArray.from(listData) {
    _size = listData.length;
  }

  operator [](int index) {
    return this.toDartList()[index];
  }

  void operator []=(int index, value) {
    this.toDartList()[index] = value;
  }

  sublist(int len) {
    return this.toDartList().sublist(len);
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList.map((e) => e.toInt())) );
    return this;
  }

  setAt(newList, int index) {
    this.toDartList().setAll( index, newList);
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return _dartList.sublist(0);
  }


}

class NativeFloat32Array extends PlatformNativeArray {

  NativeFloat32Array(int size) : super(size) {
    list = Float32List(size);
    oneByteSize = Float32List.bytesPerElement;
  }

  NativeFloat32Array.from(List listData) : super.from(listData) {
    list = Float32List.fromList( List<double>.from(listData) );
    
    oneByteSize = Float32List.bytesPerElement;
    this.toDartList().setAll( 0, List<double>.from(listData.map((e) => e.toDouble())) );
  }

  set(newList) {
    this.toDartList().setAll( 0, List<double>.from(newList.map((e) => e.toDouble())) );
    return this;
  }

}


class NativeUint16Array extends PlatformNativeArray {
  NativeUint16Array(int size) : super(size) {
    list = Uint16List(size);
    oneByteSize = Uint16List.bytesPerElement;
  }

  NativeUint16Array.from(List listData) : super.from(listData) {
    list = Uint16List.fromList( List<int>.from(listData) );
    oneByteSize = Uint16List.bytesPerElement;
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toDouble())) );
  }
}

class NativeUint32Array extends PlatformNativeArray {
  NativeUint32Array(int size) : super(size) {
    list = Uint32List(size);
    oneByteSize = Uint32List.bytesPerElement;
  }

  NativeUint32Array.from(List listData) : super.from(listData) {
    list = Uint32List.fromList( List<int>.from(listData) );
    oneByteSize = Uint32List.bytesPerElement;
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toDouble())) );
  }
}

class NativeInt8Array extends PlatformNativeArray {
  NativeInt8Array(int size) : super(size) {
    list = Int8List(size);
    oneByteSize = Int8List.bytesPerElement;
  }

  NativeInt8Array.from(List listData) : super.from(listData) {
    list = Int8List.fromList( List<int>.from(listData) );
    oneByteSize = Int8List.bytesPerElement;
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toDouble())) );
  }
}

class NativeInt16Array extends PlatformNativeArray {
  NativeInt16Array(int size) : super(size) {
    list = Int16List(size);
    oneByteSize = Int16List.bytesPerElement;
  }

  NativeInt16Array.from(List listData) : super.from(listData) {
    list = Int16List.fromList( List<int>.from(listData) );
    oneByteSize = Int16List.bytesPerElement;
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toDouble())) );
  }
}

class NativeInt32Array extends PlatformNativeArray {
  NativeInt32Array(int size) : super(size) {
    list = Int32List(size);
    oneByteSize = Int32List.bytesPerElement;
  }

  NativeInt32Array.from(List listData) : super.from(listData) {
    list = Int32List.fromList( List<int>.from(listData) );
    oneByteSize = Int32List.bytesPerElement;
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toDouble())) );
  }
}

class NativeUint8Array extends PlatformNativeArray {
  NativeUint8Array(int size) : super(size) {
    list = Uint8List(size);
    oneByteSize = Uint8List.bytesPerElement;
  }

  NativeUint8Array.from(List listData) : super.from(listData) {
    list = Uint8List.fromList( List<int>.from(listData) );
    oneByteSize = Uint8List.bytesPerElement;
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toDouble())) );
  }
}


class NativeFloat64Array extends PlatformNativeArray {
  NativeFloat64Array(int size) : super(size) {
    list = Float64List(size);
    oneByteSize = Float64List.bytesPerElement;
  }

  NativeFloat64Array.from(List listData) : super.from(listData) {
    list = Float64List.fromList( List<double>.from(listData) );
    oneByteSize = Float64List.bytesPerElement;
    this.toDartList().setAll( 0, List<double>.from(listData.map((e) => e.toDouble())) );
  }

  set(newList) {
    this.toDartList().setAll( 0, List<double>.from(newList.map((e) => e.toDouble())) );
    return this;
  }
}



