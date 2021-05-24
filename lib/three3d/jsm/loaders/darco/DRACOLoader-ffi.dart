import 'dart:ffi';




class DecoderBuffer extends Struct {
  @Double()
  external double latitude;

  @Int32()
  external int size;
}



class DRACOLoaderFFI {

  final Pointer<T> Function<T extends NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  DRACOLoaderFFI(DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  DRACOLoaderFFI.fromLookup( 
    Pointer<T> Function<T extends NativeType>(String symbolName) lookup)
      : _lookup = lookup;


  late final _getEncodedGeometryType_ptr = _lookup<NativeFunction<_c_getEncodedGeometryType>>('GetEncodedGeometryType');
  late final _dart_getEncodedGeometryType _getEncodedGeometryType = _getEncodedGeometryType_ptr.asFunction<_dart_getEncodedGeometryType>();

  void getEncodedGeometryType(
    Pointer<Int32> buffer,
  ) {
    return _getEncodedGeometryType(
      buffer,
    );
  }    


}




typedef _c_getEncodedGeometryType = Void Function(
  Pointer<Int32> buffer,
);

typedef _dart_getEncodedGeometryType = void Function(
  Pointer<Int32> buffer,
);
