part of three_objects;

class Bone extends Object3D {
  Bone() : super() {
    type = 'Bone';
  }

  @override
  Bone clone([bool? recursive]) {
    return Bone()..copy(this, recursive);
  }
}
