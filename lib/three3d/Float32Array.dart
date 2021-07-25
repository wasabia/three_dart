import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';


// web app 平台区分？？ TODO

class ThreeArray {
  late dynamic _list;
  late int _size;
  int get length => _size;
  
  ThreeArray(int size) {
    _size = size;
  }

  operator [](int index) {
    return _list.asTypedList(length)[index];
  }

  void operator []=(int index, value) {
    _list.asTypedList(length)[index] = value;
  }

  sublist(int len) {
    return _list.asTypedList(length).sublist(len);
  }

  set(newList) {
    return _list.asTypedList(length).setAll(0, newList);
  }

}

class Float32Array extends ThreeArray {

  List<num> get data => _list.toList();

  Float32Array(int size) : super(size) {
    _list = calloc<Float>(size);
  }

}


class Int32Array extends ThreeArray {

  Int32Array(int size) : super(size) {
    _list = Int32List(size);
  }

}

// class Int16Array extends ThreeArray {

//   Int16Array(int size) : super(size) {
//     _list = Int16List(size);
//   }

// }


// class Uint32Array extends ThreeArray {

//   Uint32Array(int size) : super(size) {
//     _list = Uint32List(size);
//   }

// }

// class Int8Array extends ThreeArray {

//   Int8Array(int size) : super(size) {
//     _list = Int8List(size);
//   }

// }

// class Uint8Array extends ThreeArray {

//   Uint8Array(int size) : super(size) {
//     _list = Uint8List(size);
//   }

// }


// class Float64Array extends ThreeArray {

//   Float64Array(int size) : super(size) {
//     _list = Float64List(size);
//   }

// }


// class Uint16Array extends ThreeArray {

//   Uint16Array(int size) : super(size) {
//     _list = Uint16List(size);
//   }

// }
