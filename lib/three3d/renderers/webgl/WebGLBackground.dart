part of three_webgl;

class WebGLBackground {
  late Color clearColor;
  late num clearAlpha;
  Mesh? planeMesh;
  Mesh? boxMesh;
  late int currentBackgroundVersion;
  late int currentTonemapping;
  dynamic currentBackground = null;

  WebGLCubeMaps cubemaps;
  WebGLState state;

  WebGLRenderer renderer;
  WebGLObjects objects;
  bool premultipliedAlpha;

  WebGLBackground(this.renderer, this.cubemaps, this.state, this.objects,
      this.premultipliedAlpha) {
    this.clearColor = Color(0, 0, 0);
    this.clearAlpha = 0;
    this.currentBackgroundVersion = 0;
  }

  render(renderList, scene) {
    bool forceClear = false;
    var background = scene.isScene == true ? scene.background : null;

    if (background != null && background.isTexture) {
      background = cubemaps.get(background);
    }

    // Ignore background in AR
    // TODO: Reconsider this.

    // var xr = renderer.xr;
    // var session = xr.getSession && xr.getSession();

    // if ( session != null && session.environmentBlendMode == 'additive' ) {

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
        boxMesh = new Mesh(
            new BoxGeometry(1, 1, 1),
            new ShaderMaterial({
              "name": 'BackgroundCubeMaterial',
              "uniforms": cloneUniforms(ShaderLib["cube"]["uniforms"]),
              "vertexShader": ShaderLib["cube"]["vertexShader"],
              "fragmentShader": ShaderLib["cube"]["fragmentShader"],
              "side": BackSide,
              "depthTest": false,
              "depthWrite": false,
              "fog": false
            }));

        boxMesh!.geometry!.deleteAttribute('normal');
        boxMesh!.geometry!.deleteAttribute('uv');

        boxMesh!.onBeforeRender =
            ({renderer, mesh, scene, camera, geometry, material, group}) {
          mesh.matrixWorld.copyPosition(camera.matrixWorld);
        };

        // TODO see line NO.107 only for dart
        // enable code injection for non-built-in material
        // Object.defineProperty( boxMesh.material, 'envMap', {
        // 	get: function () {
        // 		return this.uniforms.envMap.value;
        // 	}
        // } );

        objects.update(boxMesh);
      }

      if (background is WebGLCubeRenderTarget) {
        // TODO Deprecate

        background = background.texture;
      }

      boxMesh!.material.uniforms["envMap"]["value"] = background;
      boxMesh!.material.uniforms["flipEnvMap"]["value"] =
          ((background is CubeTexture) &&
                  ((background.isRenderTargetTexture) == false))
              ? -1
              : 1;

      // only for dart see line line NO.84 enable code injection for non-built-in material
      // TODO
      boxMesh!.material.envMap = background;

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
          boxMesh, boxMesh!.geometry, boxMesh!.material, 0, 0, null);
    } else if (background != null && background.isTexture) {
      if (planeMesh == null) {
        planeMesh = new Mesh(
            new PlaneGeometry(2, 2),
            new ShaderMaterial({
              "name": 'BackgroundMaterial',
              "uniforms": cloneUniforms(ShaderLib["background"]["uniforms"]),
              "vertexShader": ShaderLib["background"]["vertexShader"],
              "fragmentShader": ShaderLib["background"]["fragmentShader"],
              "side": FrontSide,
              "depthTest": false,
              "depthWrite": false,
              "fog": false
            }));

        planeMesh!.geometry!.deleteAttribute('normal');

        // enable code injection for non-built-in material
        // Object.defineProperty( planeMesh.material, 'map', {
        // 	get: function () {
        // 		return this.uniforms.t2D.value;
        // 	}
        // } );

        objects.update(planeMesh);
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
          planeMesh, planeMesh!.geometry, planeMesh!.material, 0, 0, null);
    }
  }

  setClear(color, alpha) {
    state.buffers["color"]
        .setClear(color.r, color.g, color.b, alpha, premultipliedAlpha);
  }

  getClearColor() {
    return clearColor;
  }

  setClearColor(color, {num alpha = 1}) {
    clearColor.set(color);
    clearAlpha = alpha;
    setClear(clearColor, clearAlpha);
  }

  getClearAlpha() {
    return clearAlpha;
  }

  setClearAlpha(alpha) {
    clearAlpha = alpha;
    setClear(clearColor, clearAlpha);
  }
}
