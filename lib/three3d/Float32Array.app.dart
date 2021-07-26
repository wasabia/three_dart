
import 'package:ffi/ffi.dart';
import 'dart:ffi';

import 'dart:typed_data';

import 'package:three_dart/three3d/Float32Array.dart';


class ThreeArray {

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

  ThreeArray(int size) {
    _size = size;
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

class Float32Array extends ThreeArray {
  late Pointer<Float> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }

  Float32Array(int size) : super(size) {
    list = calloc<Float>(size);
    oneByteSize = sizeOf<Float>();
  }

  factory Float32Array.from(list) {
    var _array = Float32Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return (data as Pointer<Float>).asTypedList(length);
  }

  set(newList) {
    this.toDartList().setAll( 0, List<double>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Float32Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}



class Uint16Array extends ThreeArray {
  late Pointer<Uint16> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  Uint16Array(int size) : super(size) {
    list = calloc<Uint16>(size);
    oneByteSize = sizeOf<Uint16>();
  }

  factory Uint16Array.from(list) {
    var _array = Uint16Array(list.length).set(list);
    return _array;
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
    return Uint16Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}

class Uint32Array extends ThreeArray {
  late Pointer<Uint32> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }

  Uint32Array(int size) : super(size) {
    list = calloc<Uint32>(size);
    oneByteSize = sizeOf<Uint32>();
  }

  factory Uint32Array.from(list) {
    var _array = Uint32Array(list.length).set(list);
    return _array;
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
    return Uint32Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}



class Int8Array extends ThreeArray {
  late Pointer<Int8> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }

  Int8Array(int size) : super(size) {
    list = calloc<Int8>(size);
    oneByteSize = sizeOf<Int8>();
  }

  factory Int8Array.from(list) {
    var _array = Int8Array(list.length).set(list);
    return _array;
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
    return Int8Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}

class Int16Array extends ThreeArray {

  late Pointer<Int16> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  Int16Array(int size) : super(size) {
    list = calloc<Int16>(size);
    oneByteSize = sizeOf<Int16>();
  }

  factory Int16Array.from(list) {
    var _array = Int16Array(list.length).set(list);
    return _array;
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
    return Int16Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}


class Int32Array extends ThreeArray {
  late Pointer<Int32> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  Int32Array(int size) : super(size) {
    list = calloc<Int32>(size);
    oneByteSize = sizeOf<Int32>();
  }

  factory Int32Array.from(list) {
    var _array = Int32Array(list.length).set(list);
    return _array;
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
    return Int32Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}


class Uint8Array extends ThreeArray {
  late Pointer<Uint8> list;

  get data => list;

  operator [](int index) {
    return this.list[index];
  }

  void operator []=(int index, value) {
    this.list[index] = value;
  }


  Uint8Array(int size) : super(size) {
    list = calloc<Uint8>(size);
    oneByteSize = sizeOf<Uint8>();
  }

  factory Uint8Array.from(list) {
    var _array = Uint8Array(list.length).set(list);
    return _array;
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
    return Uint8Array(_dartList.length).set(_dartList);
  }

  dispose() {
    calloc.free(list);
  }
}
