

// web app 平台区分？？ TODO

import 'dart:typed_data';

import 'package:three_dart/three3d/Float32Array.dart';


class ThreeArray {
  late dynamic list;
  late int _size;
  int get length => _size;

  get data => list;

  ThreeArray(int size) {
    _size = size;
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

  Float32Array(int size) : super(size) {
    list = Float32List(size);
  }

  factory Float32Array.from(list) {
    var _array = Float32Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<double>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Float32Array(_dartList.length).set(_dartList);
  }

}



class Uint16Array extends ThreeArray {

  Uint16Array(int size) : super(size) {
    list = Uint16List(size);
  }

  factory Uint16Array.from(list) {
    var _array = Uint16Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Uint16Array(_dartList.length).set(_dartList);
  }
}

class Uint32Array extends ThreeArray {

  Uint32Array(int size) : super(size) {
    list = Uint32List(size);
  }

  factory Uint32Array.from(list) {
    var _array = Uint32Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Uint32Array(_dartList.length).set(_dartList);
  }
}



class Int8Array extends ThreeArray {

  Int8Array(int size) : super(size) {
    list = Int8List(size);
  }

  factory Int8Array.from(list) {
    var _array = Int8Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Int8Array(_dartList.length).set(_dartList);
  }
}

class Int16Array extends ThreeArray {

  Int16Array(int size) : super(size) {
    list = Int16List(size);
  }

  factory Int16Array.from(list) {
    var _array = Int16Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Int16Array(_dartList.length).set(_dartList);
  }
}


class Int32Array extends ThreeArray {

  Int32Array(int size) : super(size) {
    list = Int32List(size);
  }

  factory Int32Array.from(list) {
    var _array = Int32Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Int32Array(_dartList.length).set(_dartList);
  }
}


class Uint8Array extends ThreeArray {

  Uint8Array(int size) : super(size) {
    list = Uint8List(size);
  }

  factory Uint8Array.from(list) {
    var _array = Uint8Array(list.length).set(list);
    return _array;
  }

  toDartList() {
    return data;
  }

  set(newList) {
    this.toDartList().setAll( 0, List<int>.from(newList) );
    return this;
  }

  clone() {
    var _dartList = this.toDartList();
    return Uint8Array(_dartList.length).set(_dartList);
  }
}



// class Float64Array extends ThreeArray {

//   Float64Array(int size) : super(size) {
//     list = ffi.calloc<Float>(size);
//   }

// }
