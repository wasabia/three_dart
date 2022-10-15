
import 'package:three_dart/three3d/cameras/perspective_camera.dart';
import 'package:three_dart/three3d/lights/light.dart';
import 'package:three_dart/three3d/lights/light_shadow.dart';
import 'package:three_dart/three3d/math/math_utils.dart';

class SpotLightShadow extends LightShadow {
  SpotLightShadow() : super(PerspectiveCamera(50, 1, 0.5, 500)) {
    focus = 1;
  }

  @override
  void updateMatrices(Light light, {int viewportIndex = 0}) {
    PerspectiveCamera camera = this.camera as PerspectiveCamera;

    var fov = MathUtils.RAD2DEG * 2 * light.angle! * focus;
    var aspect = mapSize.width / mapSize.height;
    var far = light.distance ?? camera.far;

    if (fov != camera.fov || aspect != camera.aspect || far != camera.far) {
      camera.fov = fov;
      camera.aspect = aspect;
      camera.far = far;
      camera.updateProjectionMatrix();
    }

    super.updateMatrices(light, viewportIndex: viewportIndex);
  }

  @override
  SpotLightShadow copy(LightShadow source) {
    super.copy(source);

    focus = source.focus;

    return this;
  }
}
