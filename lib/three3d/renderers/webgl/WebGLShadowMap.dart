part of three_webgl;

class WebGLShadowMap {
  Frustum _frustum = Frustum(null, null, null, null, null, null);
  final _shadowMapSize = Vector2(null, null);
  final _viewportSize = Vector2(null, null);
  final _viewport = Vector4.init();

  var shadowSide = {0: BackSide, 1: FrontSide, 2: DoubleSide};

  // HashMap<int, Material> _depthMaterials = HashMap<int, Material>();
  // HashMap<int, Material> _distanceMaterials = HashMap<int, Material>();

  late MeshDepthMaterial _depthMaterial;
  late MeshDistanceMaterial _distanceMaterial;

  final _materialCache = {};

  late ShaderMaterial shadowMaterialVertical;
  late ShaderMaterial shadowMaterialHorizontal;

  BufferGeometry fullScreenTri = BufferGeometry();

  late Mesh fullScreenMesh;

  bool enabled = false;

  bool autoUpdate = true;
  bool needsUpdate = false;

  int type = PCFShadowMap;

  late WebGLShadowMap scope;

  final WebGLRenderer _renderer;
  final WebGLObjects _objects;
  final WebGLCapabilities _capabilities;
  late int _maxTextureSize;

  WebGLShadowMap(this._renderer, this._objects, this._capabilities) {
    _maxTextureSize = _capabilities.maxTextureSize;

    _depthMaterial = MeshDepthMaterial({"depthPacking": RGBADepthPacking});
    _distanceMaterial = MeshDistanceMaterial(null);

    shadowMaterialVertical = ShaderMaterial({
      "defines": {"VSM_SAMPLES": 8},
      "uniforms": {
        "shadow_pass": {"value": null},
        "resolution": {"value": Vector2(null, null)},
        "radius": {"value": 4.0}
      },
      "vertexShader": vsm_vert,
      "fragmentShader": vsm_frag
    });

    var _float32List =
        Float32List.fromList([-1.0, -1.0, 0.5, 3.0, -1.0, 0.5, -1.0, 3.0, 0.5]);

    fullScreenTri.setAttribute(
        'position', Float32BufferAttribute(_float32List, 3, false));

    fullScreenMesh = Mesh(fullScreenTri, shadowMaterialVertical);

    shadowMaterialHorizontal = shadowMaterialVertical.clone();
    shadowMaterialHorizontal.defines!["HORIZONTAL_PASS"] = 1;

    scope = this;
  }

  render(List<Light> lights, scene, Camera camera) {
    if (scope.enabled == false) return;
    if (scope.autoUpdate == false && scope.needsUpdate == false) return;

    if (lights.isEmpty) return;

    var currentRenderTarget = _renderer.getRenderTarget();
    var activeCubeFace = _renderer.getActiveCubeFace();
    var activeMipmapLevel = _renderer.getActiveMipmapLevel();

    var _state = _renderer.state;

    // Set GL state for depth map.
    _state.setBlending(NoBlending, null, null, null, null, null, null, null);
    _state.buffers["color"].setClear(1, 1, 1, 1, false);
    _state.buffers["depth"].setTest(true);
    _state.setScissorTest(false);

    // render depth map

    for (var i = 0, il = lights.length; i < il; i++) {
      var light = lights[i];
      var shadow = light.shadow;

      if (shadow == null) {
        // print( 'THREE.WebGLShadowMap: ${light} has no shadow.' );
        continue;
      }

      if (shadow.autoUpdate == false && shadow.needsUpdate == false) continue;

      _shadowMapSize.copy(shadow.mapSize);

      var shadowFrameExtents = shadow.getFrameExtents();
      _shadowMapSize.multiply(shadowFrameExtents);
      _viewportSize.copy(shadow.mapSize);

      if (_shadowMapSize.x > _maxTextureSize ||
          _shadowMapSize.y > _maxTextureSize) {
        if (_shadowMapSize.x > _maxTextureSize) {
          _viewportSize.x =
              Math.floor(_maxTextureSize / shadowFrameExtents.x).toDouble();
          _shadowMapSize.x = _viewportSize.x * shadowFrameExtents.x;
          shadow.mapSize.x = _viewportSize.x;
        }

        if (_shadowMapSize.y > _maxTextureSize) {
          _viewportSize.y =
              Math.floor(_maxTextureSize / shadowFrameExtents.y).toDouble();
          _shadowMapSize.y = _viewportSize.y * shadowFrameExtents.y;
          shadow.mapSize.y = _viewportSize.y;
        }
      }

      if (shadow.map == null &&
          !shadow.isPointLightShadow &&
          this.type == VSMShadowMap) {
        var pars = WebGLRenderTargetOptions({
          "minFilter": LinearFilter,
          "magFilter": LinearFilter,
          "format": RGBAFormat
        });

        shadow.map = WebGLRenderTarget(
            _shadowMapSize.x.toInt(), _shadowMapSize.y.toInt(), pars);
        shadow.map!.texture.name = light.name + '.shadowMap';

        shadow.mapPass = WebGLRenderTarget(
            _shadowMapSize.x.toInt(), _shadowMapSize.y.toInt(), pars);

        shadow.camera!.updateProjectionMatrix();
      }

      if (shadow.map == null) {
        var pars = WebGLRenderTargetOptions({
          "minFilter": NearestFilter,
          "magFilter": NearestFilter,
          "format": RGBAFormat
        });

        shadow.map = WebGLRenderTarget(
            _shadowMapSize.x.toInt(), _shadowMapSize.y.toInt(), pars);
        shadow.map!.texture.name = light.name + '.shadowMap';

        shadow.camera!.updateProjectionMatrix();
      }

      _renderer.setRenderTarget(shadow.map);
      _renderer.clear();

      var viewportCount = shadow.getViewportCount();

      for (var vp = 0; vp < viewportCount; vp++) {
        var viewport = shadow.getViewport(vp);

        _viewport.set(
            _viewportSize.x * viewport.x,
            _viewportSize.y * viewport.y,
            _viewportSize.x * viewport.z,
            _viewportSize.y * viewport.w);

        _state.viewport(_viewport);

        shadow.updateMatrices(light, viewportIndex: vp);

        _frustum = shadow.getFrustum();

        renderObject(scene, camera, shadow.camera, light, this.type);
      }

      // do blur pass for VSM

      if (!shadow.isPointLightShadow && this.type == VSMShadowMap) {
        VSMPass(shadow, camera);
      }

      shadow.needsUpdate = false;
    }

    scope.needsUpdate = false;

    _renderer.setRenderTarget(
        currentRenderTarget, activeCubeFace, activeMipmapLevel);
  }

  VSMPass(shadow, camera) {
    var geometry = _objects.update(fullScreenMesh);

    if (shadowMaterialVertical.defines!["VSM_SAMPLES"] != shadow.blurSamples) {
      shadowMaterialVertical.defines!["VSM_SAMPLES"] = shadow.blurSamples;
      shadowMaterialHorizontal.defines!["VSM_SAMPLES"] = shadow.blurSamples;

      shadowMaterialVertical.needsUpdate = true;
      shadowMaterialHorizontal.needsUpdate = true;
    }

    // vertical pass

    shadowMaterialVertical.uniforms["shadow_pass"].value = shadow.map.texture;
    shadowMaterialVertical.uniforms["resolution"].value = shadow.mapSize;
    shadowMaterialVertical.uniforms["radius"].value = shadow.radius;

    _renderer.setRenderTarget(shadow.mapPass);
    _renderer.clear();
    _renderer.renderBufferDirect(
        camera, null, geometry, shadowMaterialVertical, fullScreenMesh, null);

    // horizontal pass

    shadowMaterialHorizontal.uniforms["shadow_pass"].value =
        shadow.mapPass.texture;
    shadowMaterialHorizontal.uniforms["resolution"].value = shadow.mapSize;
    shadowMaterialHorizontal.uniforms["radius"].value = shadow.radius;

    _renderer.setRenderTarget(shadow.map);
    _renderer.clear();
    _renderer.renderBufferDirect(
        camera, null, geometry, shadowMaterialHorizontal, fullScreenMesh, null);
  }

  getDepthMaterial(
      object, material, light, shadowCameraNear, shadowCameraFar, type) {
    Material? result;

    var customMaterial = light.isPointLight
        ? object.customDistanceMaterial
        : object.customDepthMaterial;

    if (customMaterial != null) {
      result = customMaterial;
    } else {
      result = light.isPointLight ? _distanceMaterial : _depthMaterial;
    }

    if (_renderer.localClippingEnabled &&
        material.clipShadows == true &&
        material.clippingPlanes.length != 0) {
      // in this case we need a unique material instance reflecting the
      // appropriate state

      var keyA = result!.uuid;
      var keyB = material.uuid;

      var materialsForVariant = _materialCache[keyA];

      if (materialsForVariant == null) {
        materialsForVariant = {};
        _materialCache[keyA] = materialsForVariant;
      }

      var cachedMaterial = materialsForVariant[keyB];

      if (cachedMaterial == null) {
        cachedMaterial = result.clone();
        materialsForVariant[keyB] = cachedMaterial;
      }

      result = cachedMaterial;
    }

    result!.visible = material.visible;
    result.wireframe = material.wireframe;

    if (type == VSMShadowMap) {
      result.side =
          (material.shadowSide != null) ? material.shadowSide : material.side;
    } else {
      result.side = (material.shadowSide != null)
          ? material.shadowSide
          : shadowSide[material.side];
    }

    result.clipShadows = material.clipShadows;
    result.clippingPlanes = material.clippingPlanes;
    result.clipIntersection = material.clipIntersection;

    result.wireframeLinewidth = material.wireframeLinewidth;
    result.linewidth = material.linewidth;

    if (light.isPointLight == true && result.isMeshDistanceMaterial) {
      MeshDistanceMaterial result2 = result as MeshDistanceMaterial;

      result2.referencePosition.setFromMatrixPosition(light.matrixWorld);
      result2.nearDistance = shadowCameraNear;
      result2.farDistance = shadowCameraFar;

      return result2;
    } else {
      return result;
    }
  }

  renderObject(object, camera, shadowCamera, light, type) {
    if (object.visible == false) return;

    var visible = object.layers.test(camera.layers);

    if (visible && (object.isMesh || object.isLine || object.isPoints)) {
      if ((object.castShadow ||
              (object.receiveShadow && type == VSMShadowMap)) &&
          (!object.frustumCulled || _frustum.intersectsObject(object))) {
        object.modelViewMatrix.multiplyMatrices(
            shadowCamera.matrixWorldInverse, object.matrixWorld);

        var geometry = _objects.update(object);
        var material = object.material;

        if (material is List) {
          var groups = geometry.groups;

          for (var k = 0, kl = groups.length; k < kl; k++) {
            var group = groups[k];
            var groupMaterial = material[group["materialIndex"]];

            if (groupMaterial != null && groupMaterial.visible) {
              var depthMaterial = getDepthMaterial(object, groupMaterial, light,
                  shadowCamera.near, shadowCamera.far, type);

              _renderer.renderBufferDirect(
                  shadowCamera, null, geometry, depthMaterial, object, group);
            }
          }
        } else if (material.visible) {
          var depthMaterial = getDepthMaterial(object, material, light,
              shadowCamera.near, shadowCamera.far, type);

          // print("WebGLShadowMap object: ${object} light: ${light} depthMaterial: ${depthMaterial} ");

          _renderer.renderBufferDirect(
              shadowCamera, null, geometry, depthMaterial, object, null);
        }
      }
    }

    var children = object.children;

    for (var i = 0, l = children.length; i < l; i++) {
      renderObject(children[i], camera, shadowCamera, light, type);
    }
  }
}
