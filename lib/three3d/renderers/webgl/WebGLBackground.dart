part of three_webgl;

class WebGLBackground {
  WebGLCubeMaps cubemaps;
  WebGLState state;

  WebGLRenderer renderer;
  WebGLObjects objects;
  bool alpha;
  bool premultipliedAlpha;

  Color clearColor = Color(0x000000);
  double clearAlpha = 0;

  Mesh? planeMesh;
  Mesh? boxMesh;

  var currentBackground;
  int currentBackgroundVersion = 0;
  var currentTonemapping;

  WebGLBackground(this.renderer, this.cubemaps, this.state, this.objects,
      this.alpha, this.premultipliedAlpha) {
    clearAlpha = alpha == true ? 0.0 : 1.0;
  }

  void render(WebGLRenderList renderList, Object3D scene) {
    var forceClear = false;
    var background = scene is Scene ? scene.background : null;

    if (background != null && background is Texture) {
      background = cubemaps.get(background);
    }

    // Ignore background in AR
    // TODO: Reconsider this.

    var xr = renderer.xr;
    // var session = xr.getSession && xr.getSession();

    // if ( session && session.environmentBlendMode == 'additive' ) {

    // 	background = null;

    // }

    if (background == null) {
      setClear(clearColor, clearAlpha);
    } else if (background != null && background is Color) {
      setClear(background, 1);
      forceClear = true;
    }

    if (renderer.autoClear || forceClear) {
      renderer.clear(renderer.autoClearColor, renderer.autoClearDepth,
          renderer.autoClearStencil);
    }

    if (background != null &&
        (background is CubeTexture ||
            (background is Texture &&
                background.mapping == CubeUVReflectionMapping))) {
      if (boxMesh == null) {
        boxMesh = Mesh(
            BoxGeometry(1, 1, 1),
            ShaderMaterial({
              "name": 'BackgroundCubeMaterial',
              "uniforms": cloneUniforms(ShaderLib["cube"]["uniforms"]),
              "vertexShader": ShaderLib["cube"]["vertexShader"],
              "fragmentShader": ShaderLib["cube"]["fragmentShader"],
              "side": BackSide,
              "depthTest": false,
              "depthWrite": false,
              "fog": false
            }));

        boxMesh!.geometry?.deleteAttribute('normal');
        boxMesh!.geometry?.deleteAttribute('uv');

        boxMesh!.onBeforeRender = (
            {renderer,
            scene,
            camera,
            renderTarget,
            mesh,
            geometry,
            material,
            group}) {
          boxMesh!.matrixWorld.copyPosition(camera.matrixWorld);
        };

        // enable code injection for non-built-in material
        // Object.defineProperty( boxMesh.material, 'envMap', {

        // 	get: function () {

        // 		return this.uniforms.envMap.value;

        // 	}

        // } );

        objects.update(boxMesh!);
      }

      boxMesh!.material.uniforms["envMap"]["value"] = background;
      boxMesh!.material.uniforms["flipEnvMap"]["value"] =
          (background is CubeTexture && background is WebGL3DRenderTarget)
              ? -1
              : 1;

      if (currentBackground != background ||
          currentBackgroundVersion != background.version ||
          currentTonemapping != renderer.toneMapping) {
        boxMesh!.material.needsUpdate = true;

        currentBackground = background;
        currentBackgroundVersion = background.version;
        currentTonemapping = renderer.toneMapping;
      }

      // push to the pre-sorted opaque render list
      renderList.unshift(
          boxMesh!, boxMesh!.geometry, boxMesh!.material, 0, 0, null);
    } else if (background != null && background is Texture) {
      if (planeMesh == undefined) {
        planeMesh = Mesh(
            PlaneGeometry(2, 2),
            ShaderMaterial({
              "name": 'BackgroundMaterial',
              "uniforms": cloneUniforms(ShaderLib["background"]["uniforms"]),
              "vertexShader": ShaderLib["background"]["vertexShader"],
              "fragmentShader": ShaderLib["background"]["fragmentShader"],
              "side": FrontSide,
              "depthTest": false,
              "depthWrite": false,
              "fog": false
            }));

        planeMesh!.geometry?.deleteAttribute('normal');

        // enable code injection for non-built-in material
        // Object.defineProperty( planeMesh.material, 'map', {

        // 	get: function () {

        // 		return this.uniforms.t2D.value;

        // 	}

        // } );

        objects.update(planeMesh!);
      }

      planeMesh!.material.uniforms["t2D"]["value"] = background;

      if (background.matrixAutoUpdate == true) {
        background.updateMatrix();
      }

      planeMesh!.material.uniforms["uvTransform"]["value"]
          .copy(background.matrix);

      if (currentBackground != background ||
          currentBackgroundVersion != background.version ||
          currentTonemapping != renderer.toneMapping) {
        planeMesh!.material.needsUpdate = true;

        currentBackground = background;
        currentBackgroundVersion = background.version;
        currentTonemapping = renderer.toneMapping;
      }

      // push to the pre-sorted opaque render list
      renderList.unshift(
          planeMesh!, planeMesh!.geometry, planeMesh!.material, 0, 0, null);
    }
  }

  void setClear(Color color, double alpha) {
    state.buffers["color"]
        .setClear(color.r, color.g, color.b, alpha, premultipliedAlpha);
  }

  Color getClearColor() {
    return clearColor;
  }

  void setClearColor(Color color, [double alpha = 1.0]) {
    clearColor.set(color);
    clearAlpha = alpha;
    setClear(clearColor, clearAlpha);
  }

  double getClearAlpha() {
    return clearAlpha;
  }

  void setClearAlpha(double alpha) {
    clearAlpha = alpha;
    setClear(clearColor, clearAlpha);
  }
}
