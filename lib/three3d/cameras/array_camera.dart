
import 'package:three_dart/three3d/cameras/camera.dart';
import 'package:three_dart/three3d/cameras/perspective_camera.dart';

class ArrayCamera extends PerspectiveCamera {
  late List<Camera> cameras;

  ArrayCamera(List<Camera> array) {
    cameras = array;
  }
}
