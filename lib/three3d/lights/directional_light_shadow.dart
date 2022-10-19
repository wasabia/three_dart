import 'package:three_dart/three3d/cameras/orthographic_camera.dart';
import 'package:three_dart/three3d/lights/light_shadow.dart';

class DirectionalLightShadow extends LightShadow {
  bool isDirectionalLightShadow = true;

  DirectionalLightShadow() : super(OrthographicCamera(-5, 5, 5, -5, 0.5, 500));
}
