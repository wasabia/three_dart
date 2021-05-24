import 'dart:typed_data';

class Float32Array {

  late Float32List _list;

  List<num> get data => _list.toList();

  Float32Array(int size) {
    _list = Float32List(size);
  }

  set(List<num> list) {
    _list = Float32List.fromList(list.map((e) => e.toDouble()).toList());
  }

  updateValue(int index, num value) {
    _list[index] = value.toDouble();
  }

}


class Int32Array {

  late Int32List _list;

  Int32Array(int size) {
    _list = Int32List(size);
  }

  set(Int32Array list) {
    _list = list._list;
  }

  setIndex(int i, int value) {
    _list[i] = value;
  }

  getIndex(int i) {
    return _list[i];
  }

  get length => _list.length;

}

class Int16Array {

  late Int16List _list;

  Int16Array(int size) {
    _list = Int16List(size);
  }

  set(Int16Array list) {
    _list = list._list;
  }

}


class Uint32Array {

  late Uint32List _list;

  Uint32Array(int size) {
    _list = Uint32List(size);
  }

  set(Uint32Array list) {
    _list = list._list;
  }

}

class Int8Array {

  late Int8List _list;

  Int8Array(int size) {
    _list = Int8List(size);
  }

  set(Int8Array list) {
    _list = list._list;
  }

}




class Uint8Array {

  late Uint8List _list;

  Uint8Array(int size) {
    _list = Uint8List(size);
  }

  set(Uint8Array list) {
    _list = list._list;
  }

}


class Float64Array {

  late Float64List _list;

  Float64Array(int size) {
    _list = Float64List(size);
  }

  set(Float64Array list) {
    _list = list._list;
  }

}


class Uint16Array {

  late Uint16List _list;

  Uint16Array(int size) {
    _list = Uint16List(size);
  }

  set(Uint16Array list) {
    _list = list._list;
  }

}
