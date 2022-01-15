part of three_objects;

class Bone extends Object3D {
  String type = 'Bone';

  bool isBone = true;

  Bone() : super() {}

  clone([bool? recursive]) {
    return Bone().copy(this, recursive);
  }
}
