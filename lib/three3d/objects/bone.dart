

import 'package:three_dart/three3d/core/object_3d.dart';

class Bone extends Object3D {
  Bone() : super() {
    type = 'Bone';
  }

  @override
  Bone clone([bool? recursive]) {
    return Bone()..copy(this, recursive);
  }
}
