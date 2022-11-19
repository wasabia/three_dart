import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/objects/line.dart';

class LineLoop extends Line {
  LineLoop(BufferGeometry? geometry, Material? material) : super(geometry, material) {
    type = 'LineLoop';
  }
}
