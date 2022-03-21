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
  late bool floatVertexTextures;
  late int maxVertexUniforms;
  late bool vertexTextures;
  late String precision;

  WebGLPrograms(this.renderer, this.cubemaps, this.cubeuvmaps, this.extensions,
      this.capabilities, this.bindingStates, this.clipping) {
    isWebGL2 = capabilities.isWebGL2;

    logarithmicDepthBuffer = capabilities.logarithmicDepthBuffer;
    floatVertexTextures = capabilities.floatVertexTextures;
    maxVertexUniforms = capabilities.maxVertexUniforms;
    vertexTextures = capabilities.vertexTextures;

    precision = capabilities.precision;
  }

  getMaxBones(object) {
    var skeleton = object.skeleton;
    var bones = skeleton.bones;

    if (floatVertexTextures) {
      return 1024;
    } else {
      // default for when object is not specified
      // ( for example when prebuilding shader to be used with multiple objects )
      //
      //  - leave some extra space for other uniforms
      //  - limit here is ANGLE's 254 max uniform vectors
      //    (up to 54 should be safe)

      var nVertexUniforms = maxVertexUniforms;
      var nVertexMatrices = Math.floor((nVertexUniforms - 20) / 4);

      var maxBones = Math.min<num>(nVertexMatrices, bones.length);

      if (maxBones < bones.length) {
        print(
            'THREE.WebGLRenderer: Skeleton has ${bones.length} bones. This GPU supports $maxBones .');
        return 0;
      }

      return maxBones;
    }
  }

  WebGLParameters getParameters(
      Material material, LightState lights, shadows, scene, object) {
    // print(" WebGLParameters.getParameters material: ${material} map: ${material.map} id: ${material.id}");

    var fog = scene.fog;
    var geometry = object.geometry;
    var environment =
        material is MeshStandardMaterial ? scene.environment : null;

    Texture? envMap;
    if (material is MeshStandardMaterial) {
      envMap = cubeuvmaps.get(material.envMap ?? environment);
    } else {
      envMap = cubemaps.get(material.envMap ?? environment);
    }

    var cubeUVHeight = ( envMap != null ) && ( ( envMap.mapping == CubeUVReflectionMapping ) || ( envMap.mapping == CubeUVRefractionMapping ) ) ? envMap.image.height : null;

    var shaderID = shaderIDs[material.shaderID];

    // heuristics to create shader parameters according to lights in the scene
    // (not to blow over maxLights budget)

    var maxBones = object.isSkinnedMesh ? getMaxBones(object) : 0;

    if (material.precision != null) {
      precision = capabilities.getMaxPrecision(material.precision);

      if (precision != material.precision) {
        print(
            'THREE.WebGLProgram.getParameters: ${material.precision} not supported, using $precision instead.');
      }
    }

    //

		var morphAttribute = geometry.morphAttributes["position"] ?? geometry.morphAttributes["normal"] ?? geometry.morphAttributes["color"];
		var morphTargetsCount = ( morphAttribute != null ) ? morphAttribute.length : 0;

		var morphTextureStride = 0;

		if ( geometry.morphAttributes["position"] != null ) morphTextureStride = 1;
		if ( geometry.morphAttributes["normal"] != null ) morphTextureStride = 2;
		if ( geometry.morphAttributes["color"] != null ) morphTextureStride = 3;

		//

    var vertexShader, fragmentShader;
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

    // print(" WebGLPrograms material : ${material.type} ${material.shaderID} ${material.id} object: ${object.type} ${object.id} shaderID: ${shaderID} ");

    var currentRenderTarget = renderer.getRenderTarget();

    var useAlphaTest = material.alphaTest > 0;
    var useClearcoat = material.clearcoat > 0;

    var parameters = WebGLParameters({
      "isWebGL2": isWebGL2,
      "shaderID": shaderID,
      "shaderName": material.type + " - " + material.name,
      "vertexShader": vertexShader,
      "fragmentShader": fragmentShader,
      "defines": material.defines,
      "customVertexShaderID": customVertexShaderID,
      "customFragmentShaderID": customFragmentShaderID,
      "isRawShaderMaterial": material is RawShaderMaterial,
      "glslVersion": material.glslVersion,
      "precision": precision,
      "instancing": object.isInstancedMesh == true,
      "instancingColor":
          object.isInstancedMesh == true && object.instanceColor != null,
      "supportsVertexTextures": vertexTextures,
      "outputEncoding": (currentRenderTarget == null)
          ? renderer.outputEncoding
          : (currentRenderTarget.isXRRenderTarget == true
              ? currentRenderTarget.texture.encoding
              : LinearEncoding),
      "map": material.map != null,
      "matcap": material.matcap != null,
      "envMap": envMap != null,
      "envMapMode": envMap?.mapping,
      "cubeUVHeight": cubeUVHeight,
      "lightMap": material.lightMap != null,
      "aoMap": material.aoMap != null,
      "emissiveMap": material.emissiveMap != null,
      "bumpMap": material.bumpMap != null,
      "normalMap": material.normalMap != null,
      "objectSpaceNormalMap": material.normalMapType == ObjectSpaceNormalMap,
      "tangentSpaceNormalMap": material.normalMapType == TangentSpaceNormalMap,
      "decodeVideoTexture": material.map != null &&
          (material.map is VideoTexture) &&
          (material.map!.encoding == sRGBEncoding),
      "clearcoat": useClearcoat,
      "clearcoatMap": useClearcoat && material.clearcoatMap != null,
      "clearcoatRoughnessMap":
          useClearcoat && material.clearcoatRoughnessMap != null,
      "clearcoatNormalMap": useClearcoat && material.clearcoatNormalMap != null,
      "displacementMap": material.displacementMap != null,
      "roughnessMap": material.roughnessMap != null,
      "metalnessMap": material.metalnessMap != null,
      "specularMap": material.specularMap != null,
      "specularIntensityMap": material.specularIntensityMap != null,
      "specularColorMap": material.specularColorMap != null,
      "opaque": !material.transparent && material.blending == NormalBlending,
      "alphaMap": material.alphaMap != null,
      "alphaTest": useAlphaTest,
      "gradientMap": material.gradientMap != null,
      "sheen": material.sheen > 0,
      "sheenColorMap": material.sheenColorMap != null,
      "sheenRoughnessMap": material.sheenRoughnessMap != null,
      "transmission": material.transmission > 0,
      "transmissionMap": material.transmissionMap != null,
      "thicknessMap": material.thicknessMap != null,
      "combine": material.combine,
      "vertexTangents": (material.normalMap != null &&
          geometry != null && geometry.attributes["tangent"] != null),
      "vertexColors": material.vertexColors,
      "vertexAlphas": material.vertexColors == true &&
          geometry != null &&
          geometry.attributes["color"] != null &&
          geometry.attributes["color"].itemSize == 4,
      "vertexUvs": material.map != null ||
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
          material.sheenRoughnessMap != null,
      "uvsVertexOnly": !(material.map != null ||
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
          material.displacementMap != null,
      "flipNormalScaleY":
          ((material.normalMap != null && material.normalMap!.flipY == false ||
                  material.clearcoatNormalMap != null &&
                      material.clearcoatNormalMap!.flipY == false) &&
              !(object.geometry != null &&
                  object.geometry.attributes["tangent"] != null)),
      "fog": fog != null,
      "useFog": material.fog,
      "fogExp2": (fog != null && fog.isFogExp2),
      "flatShading": material.flatShading,
      "sizeAttenuation": material.sizeAttenuation,
      "logarithmicDepthBuffer": logarithmicDepthBuffer,
      "skinning": object.isSkinnedMesh == true && maxBones > 0,
      "maxBones": maxBones,
      "useVertexTexture": floatVertexTextures,
      "morphTargets": geometry != null &&
          geometry.morphAttributes["position"] != null,
      "morphNormals": geometry != null &&
          geometry.morphAttributes["normal"] != null,
      "morphColors": geometry != null && geometry.morphAttributes["color"] != null,
      "morphTargetsCount": morphTargetsCount,
			"morphTextureStride": morphTextureStride,
      "numDirLights": lights.directional.length,
      "numPointLights": lights.point.length,
      "numSpotLights": lights.spot.length,
      "numRectAreaLights": lights.rectArea.length,
      "numHemiLights": lights.hemi.length,
      "numDirLightShadows": lights.directionalShadowMap.length,
      "numPointLightShadows": lights.pointShadowMap.length,
      "numSpotLightShadows": lights.spotShadowMap.length,
      "numClippingPlanes": clipping.numPlanes,
      "numClipIntersection": clipping.numIntersection,
      "dithering": material.dithering,
      "shadowMapEnabled": renderer.shadowMap.enabled && shadows.length > 0,
      "shadowMapType": renderer.shadowMap.type,
      "toneMapping": material.toneMapped ? renderer.toneMapping : NoToneMapping,
      "physicallyCorrectLights": renderer.physicallyCorrectLights,
      "premultipliedAlpha": material.premultipliedAlpha,
      "doubleSided": material.side == DoubleSide,
      "flipSided": material.side == BackSide,
      "depthPacking":
          (material.depthPacking != null) ? material.depthPacking : 0,
      "index0AttributeName": material.index0AttributeName,
      "extensionDerivatives": material.extensions != null &&
          material.extensions!["derivatives"] != null,
      "extensionFragDepth": material.extensions != null &&
          material.extensions!["fragDepth"] != null,
      "extensionDrawBuffers": material.extensions != null &&
          material.extensions!["drawBuffers"] != null,
      "extensionShaderTextureLOD": material.extensions != null &&
          material.extensions!["shaderTextureLOD"] != null,
      "rendererExtensionFragDepth":
          isWebGL2 ? isWebGL2 : extensions.has('EXT_frag_depth'),
      "rendererExtensionDrawBuffers":
          isWebGL2 ? isWebGL2 : extensions.has('WEBGL_draw_buffers'),
      "rendererExtensionShaderTextureLod":
          isWebGL2 ? isWebGL2 : extensions.has('EXT_shader_texture_lod'),
      "customProgramCacheKey": material.customProgramCacheKey()
    });

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
    array.add(parameters.maxBones);
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
    if (parameters.useVertexTexture) _programLayers.enable(4);
    if (parameters.morphTargets) _programLayers.enable(5);
    if (parameters.morphNormals) _programLayers.enable(6);
    if ( parameters.morphColors )	_programLayers.enable( 7 );
    if (parameters.premultipliedAlpha) _programLayers.enable(8);
    if (parameters.shadowMapEnabled) _programLayers.enable(9);
    if (parameters.physicallyCorrectLights) _programLayers.enable(10);
    if (parameters.doubleSided) _programLayers.enable(11);
    if (parameters.flipSided) _programLayers.enable(12);
    if (parameters.depthPacking != null && parameters.depthPacking > 0) {
      _programLayers.enable(13);
    }
    if (parameters.dithering) _programLayers.enable(14);
    if (parameters.specularIntensityMap) _programLayers.enable(15);
    if (parameters.specularColorMap) _programLayers.enable(16);
    if (parameters.transmission) _programLayers.enable(17);
    if (parameters.transmissionMap) _programLayers.enable(18);
    if (parameters.thicknessMap) _programLayers.enable(19);
    if (parameters.sheen) _programLayers.enable(20);
    if (parameters.sheenColorMap) _programLayers.enable(21);
    if (parameters.sheenRoughnessMap) _programLayers.enable(22);
    if (parameters.decodeVideoTexture) _programLayers.enable(23);
    if (parameters.opaque) _programLayers.enable(24);

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
