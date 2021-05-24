import 'dart:ffi';
import 'dart:io';

import 'package:three_dart/three3d/jsm/loaders/darco/index.dart';
import 'package:three_dart/three3d/loaders/index.dart';

class DRACOLoaderPlatform extends Loader with DRACOLoader {
  
  final DynamicLibrary libEGL = Platform.isAndroid
    ? DynamicLibrary.open("libdraco.a")
    : DynamicLibrary.process();


  DRACOLoaderPlatform ( manager ) : super( manager ) {
  }


}