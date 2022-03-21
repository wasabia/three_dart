part of three_camera;

class ArrayCamera extends PerspectiveCamera {
  late List<Camera> cameras;
  @override
  bool isArrayCamera = true;

  ArrayCamera(List<Camera> array) {
    cameras = array;
  }
}
