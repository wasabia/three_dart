import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'index.dart';


class PlatformNativeArray extends NativeArray {

  late int _size;
  late int oneByteSize;
  int get length => _size;
  int get bytesLength => length * oneByteSize;

  get data {

  }

  operator [](int index) {
    
  }

  void operator []=(int index, value) {
    
  }

  PlatformNativeArray(int size) {
    _size = size;
  }

  PlatformNativeArray.from(List listData) {
    _size = listData.length;
  }

  sublist(int len) {
    return this.toDartList().sublist(len);
  }

  toDartList() {
    return data.asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll(0, newList);
    return this;
  }

  clone() {
    print(" ThreeArray clone need implement ");
  }

}

class NativeFloat32Array extends PlatformNativeArray {
  late Pointer<Float> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value.toDouble();
  }

  NativeFloat32Array(int size) : super(size) {
    list = calloc<Float>(size);
    oneByteSize = sizeOf<Float>();
  }

  NativeFloat32Array.from(List listData) : super.from(listData) {
    list = calloc<Float>(listData.length);
    oneByteSize = sizeOf<Float>();
    this.toDartList().setAll( 0, List<double>.from(listData.map((e) => e.toDouble())) );
  }

  toDartList() {
    return (data as Pointer<Float>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<double>.from(newList.map((e) => e.toDouble())) );
    return this;
  }

  setAt(newList, int index) {
    this.toDartList().setAll( index, List<double>.from(newList.map((e) => e.toDouble())) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeFloat32Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}



class NativeUint16Array extends PlatformNativeArray {
  late Pointer<Uint16> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  NativeUint16Array(int size) : super(size) {
    list = calloc<Uint16>(size);
    oneByteSize = sizeOf<Uint16>();
  }

  NativeUint16Array.from(List listData) : super.from(listData) {
    list = calloc<Uint16>(listData.length);
    oneByteSize = sizeOf<Uint16>();
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toInt())) );
  }

  toDartList() {
    return (data as Pointer<Uint16>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeUint16Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}

class NativeUint32Array extends PlatformNativeArray {
  late Pointer<Uint32> list;

  get data => list;

  get buffer => data;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }

  NativeUint32Array(int size) : super(size) {
    list = calloc<Uint32>(size);
    oneByteSize = sizeOf<Uint32>();
  }

  NativeUint32Array.from(List listData) : super.from(listData) {
    list = calloc<Uint32>(listData.length);
    oneByteSize = sizeOf<Uint32>();
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toInt())) );
  }

  toDartList() {
    return (data as Pointer<Uint32>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeUint32Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}



class NativeInt8Array extends PlatformNativeArray {
  late Pointer<Int8> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }

  NativeInt8Array(int size) : super(size) {
    list = calloc<Int8>(size);
    oneByteSize = sizeOf<Int8>();
  }

  NativeInt8Array.from(List listData) : super.from(listData) {
    list = calloc<Int8>(listData.length);
    oneByteSize = sizeOf<Int8>();
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toInt())) );
  }

  toDartList() {
    return (data as Pointer<Int8>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeInt8Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}

class NativeInt16Array extends PlatformNativeArray {

  late Pointer<Int16> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  NativeInt16Array(int size) : super(size) {
    list = calloc<Int16>(size);
    oneByteSize = sizeOf<Int16>();
  }

  NativeInt16Array.from(List listData) : super.from(listData) {
    list = calloc<Int16>(listData.length);
    oneByteSize = sizeOf<Int16>();
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toInt())) );
  }

  toDartList() {
    return (data as Pointer<Int16>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeInt16Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}


class NativeInt32Array extends PlatformNativeArray {
  late Pointer<Int32> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  NativeInt32Array(int size) : super(size) {
    list = calloc<Int32>(size);
    oneByteSize = sizeOf<Int32>();
  }

  NativeInt32Array.from(List listData) : super.from(listData) {
    list = calloc<Int32>(listData.length);
    oneByteSize = sizeOf<Int32>();
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toInt())) );
  }

  toDartList() {
    return (data as Pointer<Int32>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeInt32Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}


class NativeUint8Array extends PlatformNativeArray {
  late Pointer<Uint8> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  NativeUint8Array(int size) : super(size) {
    list = calloc<Uint8>(size);
    oneByteSize = sizeOf<Uint8>();
  }

  NativeUint8Array.from(List listData) : super.from(listData) {
    list = calloc<Uint8>(listData.length);
    oneByteSize = sizeOf<Uint8>();
    this.toDartList().setAll( 0, List<int>.from(listData.map((e) => e.toInt())) );
  }

  toDartList() {
    return (data as Pointer<Uint8>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return NativeUint8Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}
