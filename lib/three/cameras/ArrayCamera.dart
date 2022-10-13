part of three_camera;

class ArrayCamera extends PerspectiveCamera {
  late List<Camera> cameras;

  ArrayCamera(List<Camera> array) {
    cameras = array;
  }
}
