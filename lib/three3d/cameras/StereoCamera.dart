part of three_camera;

var _eyeRight = Matrix4();
var _eyeLeft = Matrix4();
var _projectionMatrix = /*@__PURE__*/ Matrix4();

class StereoCamera {
  String type = 'StereoCamera';

  num aspect = 1;

  num eyeSep = 0.064;

  late PerspectiveCamera cameraL;
  late PerspectiveCamera cameraR;

  final Map<String, dynamic> _cache = {};

  StereoCamera() {
    cameraL = PerspectiveCamera();
    cameraL.layers.enable(1);
    cameraL.matrixAutoUpdate = false;

    cameraR = PerspectiveCamera();
    cameraR.layers.enable(2);
    cameraR.matrixAutoUpdate = false;
  }

  update(camera) {
    var cache = _cache;

    var needsUpdate = cache["focus"] != camera.focus ||
        cache["fov"] != camera.fov ||
        cache["aspect"] != camera.aspect * aspect ||
        cache["near"] != camera.near ||
        cache["far"] != camera.far ||
        cache["zoom"] != camera.zoom ||
        cache["eyeSep"] != eyeSep;

    if (needsUpdate) {
      cache["focus"] = camera.focus;
      cache["fov"] = camera.fov;
      cache["aspect"] = camera.aspect * aspect;
      cache["near"] = camera.near;
      cache["far"] = camera.far;
      cache["zoom"] = camera.zoom;
      cache["eyeSep"] = eyeSep;

      // Off-axis stereoscopic effect based on
      // http://paulbourke.net/stereographics/stereorender/

      _projectionMatrix.copy(camera.projectionMatrix);
      var eyeSepHalf = cache["eyeSep"] / 2;
      var eyeSepOnProjection = eyeSepHalf * cache["near"] / cache["focus"];
      var ymax =
          (cache["near"] * Math.tan(MathUtils.DEG2RAD * cache["fov"] * 0.5)) /
              cache["zoom"];
      var xmin, xmax;

      // translate xOffset

      _eyeLeft.elements[12] = -eyeSepHalf;
      _eyeRight.elements[12] = eyeSepHalf;

      // for left eye

      xmin = -ymax * cache["aspect"] + eyeSepOnProjection;
      xmax = ymax * cache["aspect"] + eyeSepOnProjection;

      _projectionMatrix.elements[0] = 2 * cache["near"] / (xmax - xmin);
      _projectionMatrix.elements[8] = (xmax + xmin) / (xmax - xmin);

      cameraL.projectionMatrix.copy(_projectionMatrix);

      // for right eye

      xmin = -ymax * cache["aspect"] - eyeSepOnProjection;
      xmax = ymax * cache["aspect"] - eyeSepOnProjection;

      _projectionMatrix.elements[0] = 2 * cache["near"] / (xmax - xmin);
      _projectionMatrix.elements[8] = (xmax + xmin) / (xmax - xmin);

      cameraR.projectionMatrix.copy(_projectionMatrix);
    }

    cameraL.matrixWorld.copy(camera.matrixWorld).multiply(_eyeLeft);
    cameraR.matrixWorld.copy(camera.matrixWorld).multiply(_eyeRight);
  }
}
