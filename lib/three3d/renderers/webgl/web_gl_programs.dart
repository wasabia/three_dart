part of three_webgl;

class WebGLPrograms {
  var shaderIDs = {
    "MeshDepthMaterial": 'depth',
    "MeshDistanceMaterial": 'distanceRGBA',
    "MeshNormalMaterial": 'normal',
    "MeshBasicMaterial": 'basic',
    "MeshLambertMaterial": 'lambert',
    "MeshPhongMaterial": 'phong',
    "MeshToonMaterial": 'toon',
    "MeshStandardMaterial": 'physical',
    "MeshPhysicalMaterial": 'physical',
    "MeshMatcapMaterial": 'matcap',
    "LineBasicMaterial": 'basic',
    "LineDashedMaterial": 'dashed',
    "PointsMaterial": 'points',
    "ShadowMaterial": 'shadow',
    "SpriteMaterial": 'sprite'
  };

  WebGLRenderer renderer;
  WebGLCubeMaps cubemaps;
  WebGLCubeUVMaps cubeuvmaps;
  WebGLExtensions extensions;
  WebGLCapabilities capabilities;
  WebGLBindingStates bindingStates;
  WebGLClipping clipping;

  final _programLayers = Layers();
  final _customShaders = WebGLShaderCache();
  List<WebGLProgram> programs = [];
  bool isWebGL2 = true;

  late bool logarithmicDepthBuffer;
  late bool vertexTextures;
  late String precision;

  WebGLPrograms(this.renderer, this.cubemaps, this.cubeuvmaps, this.extensions, this.capabilities, this.bindingStates,
      this.clipping) {
    isWebGL2 = capabilities.isWebGL2;

    logarithmicDepthBuffer = capabilities.logarithmicDepthBuffer;
    vertexTextures = capabilities.vertexTextures;

    precision = capabilities.precision;
  }

  WebGLParameters getParameters(Material material, LightState lights, shadows, scene, object) {
    var fog = scene.fog;
    var geometry = object.geometry;
    var environment = material is MeshStandardMaterial ? scene.environment : null;

    Texture? envMap;
    if (material is MeshStandardMaterial) {
      envMap = cubeuvmaps.get(material.envMap ?? environment);
    } else {
      envMap = cubemaps.get(material.envMap ?? environment);
    }

    var cubeUVHeight = (envMap != null) && (envMap.mapping == CubeUVReflectionMapping) ? envMap.image.height : null;

    var shaderID = shaderIDs[material.shaderID];

    // heuristics to create shader parameters according to lights in the scene
    // (not to blow over maxLights budget)

    if (material.precision != null) {
      precision = capabilities.getMaxPrecision(material.precision);

      if (precision != material.precision) {
        print('three.WebGLProgram.getParameters: ${material.precision} not supported, using $precision instead.');
      }
    }

    var morphAttribute =
        geometry.morphAttributes["position"] ?? geometry.morphAttributes["normal"] ?? geometry.morphAttributes["color"];
    var morphTargetsCount = (morphAttribute != null) ? morphAttribute.length : 0;

    var morphTextureStride = 0;

    if (geometry.morphAttributes["position"] != null) morphTextureStride = 1;
    if (geometry.morphAttributes["normal"] != null) morphTextureStride = 2;
    if (geometry.morphAttributes["color"] != null) morphTextureStride = 3;

    //

    String? vertexShader, fragmentShader;
    var customVertexShaderID, customFragmentShaderID;

    if (shaderID != null) {
      var shader = ShaderLib[shaderID];
      vertexShader = shader["vertexShader"];
      fragmentShader = shader["fragmentShader"];
    } else {
      vertexShader = material.vertexShader;
      fragmentShader = material.fragmentShader;

      _customShaders.update(material);

      customVertexShaderID = _customShaders.getVertexShaderID(material);
      customFragmentShaderID = _customShaders.getFragmentShaderID(material);
    }

    // print(" WebGLPrograms material : ${material.type} ${material.shaderID} ${material.id} object: ${object.type} ${object.id} shaderID: ${shaderID} vertexColors: ${material.vertexColors} ");

    var currentRenderTarget = renderer.getRenderTarget();

    var useAlphaTest = material.alphaTest > 0;
    var useClearcoat = material.clearcoat > 0;

    var parameters = WebGLParameters.create();

    parameters.isWebGL2 = isWebGL2;
    parameters.shaderID = shaderID;
    parameters.shaderName = material.type + " - " + material.name;
    parameters.vertexShader = vertexShader!;
    parameters.fragmentShader = fragmentShader!;
    parameters.defines = material.defines;
    parameters.customVertexShaderID = customVertexShaderID;
    parameters.customFragmentShaderID = customFragmentShaderID;
    parameters.isRawShaderMaterial = material is RawShaderMaterial;
    parameters.glslVersion = material.glslVersion;
    parameters.precision = precision;
    parameters.instancing = object is InstancedMesh;
    parameters.instancingColor = object is InstancedMesh && object.instanceColor != null;
    parameters.supportsVertexTextures = vertexTextures;
    parameters.outputEncoding = (currentRenderTarget == null)
        ? renderer.outputEncoding
        : (currentRenderTarget.isXRRenderTarget == true ? currentRenderTarget.texture.encoding : LinearEncoding);
    parameters.map = material.map != null;
    parameters.matcap = material.matcap != null;
    parameters.envMap = envMap != null;
    parameters.envMapMode = envMap?.mapping;
    parameters.cubeUVHeight = cubeUVHeight;
    parameters.lightMap = material.lightMap != null;
    parameters.aoMap = material.aoMap != null;
    parameters.emissiveMap = material.emissiveMap != null;
    parameters.bumpMap = material.bumpMap != null;
    parameters.normalMap = material.normalMap != null;
    parameters.objectSpaceNormalMap = material.normalMapType == ObjectSpaceNormalMap;
    parameters.tangentSpaceNormalMap = material.normalMapType == TangentSpaceNormalMap;
    parameters.decodeVideoTexture =
        material.map != null && (material.map is VideoTexture) && (material.map!.encoding == sRGBEncoding);
    parameters.clearcoat = useClearcoat;
    parameters.clearcoatMap = useClearcoat && material.clearcoatMap != null;
    parameters.clearcoatRoughnessMap = useClearcoat && material.clearcoatRoughnessMap != null;
    parameters.clearcoatNormalMap = useClearcoat && material.clearcoatNormalMap != null;
    parameters.displacementMap = material.displacementMap != null;
    parameters.roughnessMap = material.roughnessMap != null;
    parameters.metalnessMap = material.metalnessMap != null;
    parameters.specularMap = material.specularMap != null;
    parameters.specularIntensityMap = material.specularIntensityMap != null;
    parameters.specularColorMap = material.specularColorMap != null;
    parameters.opaque = material.transparent == false && material.blending == NormalBlending;
    parameters.alphaMap = material.alphaMap != null;
    parameters.alphaTest = useAlphaTest;
    parameters.gradientMap = material.gradientMap != null;
    parameters.sheen = material.sheen > 0;
    parameters.sheenColorMap = material.sheenColorMap != null;
    parameters.sheenRoughnessMap = material.sheenRoughnessMap != null;
    parameters.transmission = material.transmission > 0;
    parameters.transmissionMap = material.transmissionMap != null;
    parameters.thicknessMap = material.thicknessMap != null;
    parameters.combine = material.combine;
    parameters.vertexTangents =
        (material.normalMap != null && geometry != null && geometry.attributes["tangent"] != null);
    parameters.vertexColors = material.vertexColors;
    parameters.vertexAlphas = material.vertexColors == true &&
        geometry != null &&
        geometry.attributes["color"] != null &&
        geometry.attributes["color"].itemSize == 4;
    parameters.vertexUvs = material.map != null ||
        material.bumpMap != null ||
        material.normalMap != null ||
        material.specularMap != null ||
        material.alphaMap != null ||
        material.emissiveMap != null ||
        material.roughnessMap != null ||
        material.metalnessMap != null ||
        material.clearcoatMap != null ||
        material.clearcoatRoughnessMap != null ||
        material.clearcoatNormalMap != null ||
        material.displacementMap != null ||
        material.transmissionMap != null ||
        material.thicknessMap != null ||
        material.specularIntensityMap != null ||
        material.specularColorMap != null ||
        material.sheenColorMap != null ||
        material.sheenRoughnessMap != null;
    parameters.uvsVertexOnly = !(material.map != null ||
            material.bumpMap != null ||
            material.normalMap != null ||
            material.specularMap != null ||
            material.alphaMap != null ||
            material.emissiveMap != null ||
            material.roughnessMap != null ||
            material.metalnessMap != null ||
            material.clearcoatNormalMap != null ||
            material.transmission != null ||
            material.transmissionMap != null ||
            material.thicknessMap != null ||
            material.sheen > 0 ||
            material.sheenColorMap != null ||
            material.sheenRoughnessMap != null) &&
        material.displacementMap != null;
    parameters.fog = fog != null;
    parameters.useFog = material.fog;
    parameters.fogExp2 = (fog != null && fog.isFogExp2);
    parameters.flatShading = material.flatShading;
    parameters.sizeAttenuation = material.sizeAttenuation;
    parameters.logarithmicDepthBuffer = logarithmicDepthBuffer;
    parameters.skinning = object is SkinnedMesh;
    parameters.morphTargets = geometry != null && geometry.morphAttributes["position"] != null;
    parameters.morphNormals = geometry != null && geometry.morphAttributes["normal"] != null;
    parameters.morphColors = geometry != null && geometry.morphAttributes["color"] != null;
    parameters.morphTargetsCount = morphTargetsCount;
    parameters.morphTextureStride = morphTextureStride;
    parameters.numDirLights = lights.directional.length;
    parameters.numPointLights = lights.point.length;
    parameters.numSpotLights = lights.spot.length;
    parameters.numRectAreaLights = lights.rectArea.length;
    parameters.numHemiLights = lights.hemi.length;
    parameters.numDirLightShadows = lights.directionalShadowMap.length;
    parameters.numPointLightShadows = lights.pointShadowMap.length;
    parameters.numSpotLightShadows = lights.spotShadowMap.length;
    parameters.numClippingPlanes = clipping.numPlanes;
    parameters.numClipIntersection = clipping.numIntersection;
    parameters.dithering = material.dithering;
    parameters.shadowMapEnabled = renderer.shadowMap.enabled && shadows.length > 0;
    parameters.shadowMapType = renderer.shadowMap.type;
    parameters.toneMapping = material.toneMapped ? renderer.toneMapping : NoToneMapping;
    parameters.physicallyCorrectLights = renderer.physicallyCorrectLights;
    parameters.premultipliedAlpha = material.premultipliedAlpha;
    parameters.doubleSided = material.side == DoubleSide;
    parameters.flipSided = material.side == BackSide;
    parameters.useDepthPacking = material.depthPacking != null;
    parameters.depthPacking = material.depthPacking ?? 0;
    parameters.index0AttributeName = material.index0AttributeName;
    parameters.extensionDerivatives = material.extensions != null && material.extensions!["derivatives"] != null;
    parameters.extensionFragDepth = material.extensions != null && material.extensions!["fragDepth"] != null;
    parameters.extensionDrawBuffers = material.extensions != null && material.extensions!["drawBuffers"] != null;
    parameters.extensionShaderTextureLOD =
        material.extensions != null && material.extensions!["shaderTextureLOD"] != null;
    parameters.rendererExtensionFragDepth = isWebGL2 ? isWebGL2 : extensions.has('EXT_frag_depth');
    parameters.rendererExtensionDrawBuffers = isWebGL2 ? isWebGL2 : extensions.has('WEBGL_draw_buffers');
    parameters.rendererExtensionShaderTextureLod = isWebGL2 ? isWebGL2 : extensions.has('EXT_shader_texture_lod');
    parameters.customProgramCacheKey = material.customProgramCacheKey() ?? "";

    return parameters;
  }

  String getProgramCacheKey(WebGLParameters parameters) {
    List<dynamic> array = [];

    if (parameters.shaderID != null) {
      array.add(parameters.shaderID!);
    } else {
      array.add(parameters.customVertexShaderID);
      array.add(parameters.customFragmentShaderID);
    }

    if (parameters.defines != null) {
      for (var name in parameters.defines!.keys) {
        array.add(name);
        array.add(parameters.defines![name].toString());
      }
    }

    if (parameters.isRawShaderMaterial == false) {
      getProgramCacheKeyParameters(array, parameters);
      getProgramCacheKeyBooleans(array, parameters);

      array.add(renderer.outputEncoding.toString());
    }

    array.add(parameters.customProgramCacheKey);

    String _key = array.join();

    return _key;
  }

  getProgramCacheKeyParameters(array, parameters) {
    array.add(parameters.precision);
    array.add(parameters.outputEncoding);
    array.add(parameters.envMapMode);
    array.add(parameters.combine);
    array.add(parameters.vertexUvs);
    array.add(parameters.fogExp2);
    array.add(parameters.sizeAttenuation);
    array.add(parameters.morphTargetsCount);
    array.add(parameters.numDirLights);
    array.add(parameters.numPointLights);
    array.add(parameters.numSpotLights);
    array.add(parameters.numHemiLights);
    array.add(parameters.numRectAreaLights);
    array.add(parameters.numDirLightShadows);
    array.add(parameters.numPointLightShadows);
    array.add(parameters.numSpotLightShadows);
    array.add(parameters.shadowMapType);
    array.add(parameters.toneMapping);
    array.add(parameters.numClippingPlanes);
    array.add(parameters.numClipIntersection);
    array.add(parameters.depthPacking);
  }

  getProgramCacheKeyBooleans(array, parameters) {
    _programLayers.disableAll();

    if (parameters.isWebGL2) _programLayers.enable(0);
    if (parameters.supportsVertexTextures) _programLayers.enable(1);
    if (parameters.instancing) _programLayers.enable(2);
    if (parameters.instancingColor) _programLayers.enable(3);
    if (parameters.map) _programLayers.enable(4);
    if (parameters.matcap) _programLayers.enable(5);
    if (parameters.envMap) _programLayers.enable(6);
    if (parameters.lightMap) _programLayers.enable(7);
    if (parameters.aoMap) _programLayers.enable(8);
    if (parameters.emissiveMap) _programLayers.enable(9);
    if (parameters.bumpMap) _programLayers.enable(10);
    if (parameters.normalMap) _programLayers.enable(11);
    if (parameters.objectSpaceNormalMap) _programLayers.enable(12);
    if (parameters.tangentSpaceNormalMap) _programLayers.enable(13);
    if (parameters.clearcoat) _programLayers.enable(14);
    if (parameters.clearcoatMap) _programLayers.enable(15);
    if (parameters.clearcoatRoughnessMap) _programLayers.enable(16);
    if (parameters.clearcoatNormalMap) _programLayers.enable(17);
    if (parameters.displacementMap) _programLayers.enable(18);
    if (parameters.specularMap) _programLayers.enable(19);
    if (parameters.roughnessMap) _programLayers.enable(20);
    if (parameters.metalnessMap) _programLayers.enable(21);
    if (parameters.gradientMap) _programLayers.enable(22);
    if (parameters.alphaMap) _programLayers.enable(23);
    if (parameters.alphaTest) _programLayers.enable(24);
    if (parameters.vertexColors) _programLayers.enable(25);
    if (parameters.vertexAlphas) _programLayers.enable(26);
    if (parameters.vertexUvs) _programLayers.enable(27);
    if (parameters.vertexTangents) _programLayers.enable(28);
    if (parameters.uvsVertexOnly) _programLayers.enable(29);
    if (parameters.fog) _programLayers.enable(30);

    array.add(_programLayers.mask);
    _programLayers.disableAll();

    if (parameters.useFog) _programLayers.enable(0);
    if (parameters.flatShading) _programLayers.enable(1);
    if (parameters.logarithmicDepthBuffer) _programLayers.enable(2);
    if (parameters.skinning) _programLayers.enable(3);
    if (parameters.morphTargets) _programLayers.enable(4);
    if (parameters.morphNormals) _programLayers.enable(5);
    if (parameters.morphColors) _programLayers.enable(6);
    if (parameters.premultipliedAlpha) _programLayers.enable(7);
    if (parameters.shadowMapEnabled) _programLayers.enable(8);
    if (parameters.physicallyCorrectLights) _programLayers.enable(9);
    if (parameters.doubleSided) _programLayers.enable(10);
    if (parameters.flipSided) _programLayers.enable(11);
    if (parameters.useDepthPacking) {
      _programLayers.enable(12);
    }
    if (parameters.dithering) _programLayers.enable(13);
    if (parameters.specularIntensityMap) _programLayers.enable(14);
    if (parameters.specularColorMap) _programLayers.enable(15);
    if (parameters.transmission) _programLayers.enable(16);
    if (parameters.transmissionMap) _programLayers.enable(17);
    if (parameters.thicknessMap) _programLayers.enable(18);
    if (parameters.sheen) _programLayers.enable(19);
    if (parameters.sheenColorMap) _programLayers.enable(20);
    if (parameters.sheenRoughnessMap) _programLayers.enable(21);
    if (parameters.decodeVideoTexture) _programLayers.enable(22);
    if (parameters.opaque) _programLayers.enable(23);

    array.add(_programLayers.mask);
  }

  Map<String, dynamic> getUniforms(Material material) {
    String? shaderID = shaderIDs[material.shaderID];
    Map<String, dynamic> uniforms;

    if (shaderID != null) {
      var shader = ShaderLib[shaderID];
      uniforms = cloneUniforms(shader["uniforms"]);
    } else {
      uniforms = material.uniforms;
    }

    return uniforms;
  }

  acquireProgram(WebGLParameters parameters, String cacheKey) {
    WebGLProgram? program;

    // Check if code has been already compiled
    for (var p = 0, pl = programs.length; p < pl; p++) {
      var preexistingProgram = programs[p];

      if (preexistingProgram.cacheKey == cacheKey) {
        program = preexistingProgram;
        ++program.usedTimes;

        break;
      }
    }

    if (program == null) {
      program = WebGLProgram(renderer, cacheKey, parameters, bindingStates);
      programs.add(program);
    }

    return program;
  }

  releaseProgram(program) {
    if (--program.usedTimes == 0) {
      // Remove from unordered set
      var i = programs.indexOf(program);
      programs[i] = programs[programs.length - 1];
      programs.removeLast();

      // Free WebGL resources
      program.destroy();
    }
  }

  releaseShaderCache(material) {
    _customShaders.remove(material);
  }

  dispose() {
    _customShaders.dispose();
  }
}
