part of three_camera;

class CubeCamera extends Object3D {
  late WebGLCubeRenderTarget renderTarget;

  late PerspectiveCamera cameraPX;
  late PerspectiveCamera cameraNX;
  late PerspectiveCamera cameraPY;
  late PerspectiveCamera cameraNY;
  late PerspectiveCamera cameraPZ;
  late PerspectiveCamera cameraNZ;

  var fov = 90, aspect = 1;

  CubeCamera(num near, num far, this.renderTarget) {
    type = 'CubeCamera';

    if (renderTarget.isWebGLCubeRenderTarget != true) {
      print(
          'THREE.CubeCamera: The constructor now expects an instance of WebGLCubeRenderTarget as third parameter.');
      return;
    }

    cameraPX = PerspectiveCamera(fov, aspect, near, far);
    cameraPX.layers = layers;
    cameraPX.up.set(0, -1, 0);
    cameraPX.lookAt(Vector3(1, 0, 0));
    add(cameraPX);

    cameraNX = PerspectiveCamera(fov, aspect, near, far);
    cameraNX.layers = layers;
    cameraNX.up.set(0, -1, 0);
    cameraNX.lookAt(Vector3(-1, 0, 0));
    add(cameraNX);

    cameraPY = PerspectiveCamera(fov, aspect, near, far);
    cameraPY.layers = layers;
    cameraPY.up.set(0, 0, 1);
    cameraPY.lookAt(Vector3(0, 1, 0));
    add(cameraPY);

    cameraNY = PerspectiveCamera(fov, aspect, near, far);
    cameraNY.layers = layers;
    cameraNY.up.set(0, 0, -1);
    cameraNY.lookAt(Vector3(0, -1, 0));
    add(cameraNY);

    cameraPZ = PerspectiveCamera(fov, aspect, near, far);
    cameraPZ.layers = layers;
    cameraPZ.up.set(0, -1, 0);
    cameraPZ.lookAt(Vector3(0, 0, 1));
    add(cameraPZ);

    cameraNZ = PerspectiveCamera(fov, aspect, near, far);
    cameraNZ.layers = layers;
    cameraNZ.up.set(0, -1, 0);
    cameraNZ.lookAt(Vector3(0, 0, -1));
    add(cameraNZ);
  }

  update(renderer, scene) {
    if (parent == null) updateMatrixWorld(false);

    var currentRenderTarget = renderer.getRenderTarget();
    var currentOutputEncoding = renderer.outputEncoding;
		var currentToneMapping = renderer.toneMapping;
		var currentXrEnabled = renderer.xr.enabled;

		renderer.toneMapping = NoToneMapping;
    renderer.xr.enabled = false;

    var generateMipmaps = renderTarget.texture.generateMipmaps;

    renderTarget.texture.generateMipmaps = false;

    renderer.setRenderTarget(renderTarget, 0);
    renderer.render(scene, cameraPX);

    renderer.setRenderTarget(renderTarget, 1);
    renderer.render(scene, cameraNX);

    renderer.setRenderTarget(renderTarget, 2);
    renderer.render(scene, cameraPY);

    renderer.setRenderTarget(renderTarget, 3);
    renderer.render(scene, cameraNY);

    renderer.setRenderTarget(renderTarget, 4);
    renderer.render(scene, cameraPZ);

    renderTarget.texture.generateMipmaps = generateMipmaps;

    renderer.setRenderTarget(renderTarget, 5);
    renderer.render(scene, cameraNZ);

    renderer.setRenderTarget(currentRenderTarget);
    
    renderer.outputEncoding = currentOutputEncoding;
		renderer.toneMapping = currentToneMapping;
    renderer.xr.enabled = currentXrEnabled;

    renderTarget.texture.needsPMREMUpdate = true;
  }
}
