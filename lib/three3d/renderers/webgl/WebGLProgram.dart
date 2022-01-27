part of three_webgl;

int programIdCount = 0;

class DefaultProgram {
  int id = -1;
}

class WebGLProgram extends DefaultProgram with WebGLProgramExtra {
  int id = -1;
  late String name;
  WebGLRenderer renderer;
  String cacheKey;
  WebGLBindingStates bindingStates;
  int usedTimes = 1;
  late dynamic gl;
  WebGLParameters parameters;
  late dynamic program;

  late String vertexShader;
  late String fragmentShader;
  late Map<String, dynamic> diagnostics;

  WebGLUniforms? cachedUniforms;
  Map<String, dynamic>? cachedAttributes;

  WebGLProgram(
      this.renderer, this.cacheKey, this.parameters, this.bindingStates) {
    this.name = parameters.shaderName;
    this.id = programIdCount++;

    this.gl = renderer.getContext();
    this.program = gl.createProgram();
    init();
  }

  init() {
    var defines = parameters.defines;

    vertexShader = parameters.vertexShader;
    fragmentShader = parameters.fragmentShader;

    var shadowMapTypeDefine = generateShadowMapTypeDefine(parameters);
    var envMapTypeDefine = generateEnvMapTypeDefine(parameters);
    var envMapModeDefine = generateEnvMapModeDefine(parameters);
    var envMapBlendingDefine = generateEnvMapBlendingDefine(parameters);

    num gammaFactorDefine =
        (renderer.gammaFactor > 0) ? renderer.gammaFactor : 1.0;

    var customExtensions =
        parameters.isWebGL2 ? '' : generateExtensions(parameters);

    String customDefines = generateDefines(defines);

    String prefixVertex, prefixFragment;

    String defaultVersionString =
        (!kIsWeb && Platform.isMacOS) ? "#version 140\n" : "";

    var versionString = parameters.glslVersion != null
        ? '#version ${parameters.glslVersion}\n'
        : defaultVersionString;

    if (parameters.isRawShaderMaterial) {
      prefixVertex =
          [customDefines].where((s) => filterEmptyLine(s)).join('\n');

      if (prefixVertex.length > 0) {
        prefixVertex = "${prefixVertex}\n";
      }

      prefixFragment = [customExtensions, customDefines]
          .where((s) => filterEmptyLine(s))
          .join('\n');

      if (prefixFragment.length > 0) {
        prefixFragment = "${prefixFragment}\n";
      }
    } else {
      prefixVertex = [
        generatePrecision(parameters),
        '#define SHADER_NAME ' + parameters.shaderName,
        customDefines,
        parameters.instancing ? '#define USE_INSTANCING' : '',
        parameters.instancingColor ? '#define USE_INSTANCING_COLOR' : '',
        parameters.supportsVertexTextures ? '#define VERTEX_TEXTURES' : '',
        '#define GAMMA_FACTOR ${gammaFactorDefine}',
        '#define MAX_BONES ${parameters.maxBones}',
        (parameters.useFog && parameters.fog) ? '#define USE_FOG' : '',
        (parameters.useFog && parameters.fogExp2) ? '#define FOG_EXP2' : '',
        parameters.map ? '#define USE_MAP' : '',
        parameters.envMap ? '#define USE_ENVMAP' : '',
        parameters.envMap ? '#define ' + envMapModeDefine : '',
        parameters.lightMap ? '#define USE_LIGHTMAP' : '',
        parameters.aoMap ? '#define USE_AOMAP' : '',
        parameters.emissiveMap ? '#define USE_EMISSIVEMAP' : '',
        parameters.bumpMap ? '#define USE_BUMPMAP' : '',
        parameters.normalMap ? '#define USE_NORMALMAP' : '',
        (parameters.normalMap && parameters.objectSpaceNormalMap)
            ? '#define OBJECTSPACE_NORMALMAP'
            : '',
        (parameters.normalMap && parameters.tangentSpaceNormalMap)
            ? '#define TANGENTSPACE_NORMALMAP'
            : '',
        parameters.clearcoatMap ? '#define USE_CLEARCOATMAP' : '',
        parameters.clearcoatRoughnessMap
            ? '#define USE_CLEARCOAT_ROUGHNESSMAP'
            : '',
        parameters.clearcoatNormalMap ? '#define USE_CLEARCOAT_NORMALMAP' : '',
        parameters.displacementMap && parameters.supportsVertexTextures
            ? '#define USE_DISPLACEMENTMAP'
            : '',
        parameters.specularMap ? '#define USE_SPECULARMAP' : '',
        parameters.specularIntensityMap
            ? '#define USE_SPECULARINTENSITYMAP'
            : '',
        parameters.specularColorMap ? '#define USE_SPECULARCOLORMAP' : '',
        parameters.roughnessMap ? '#define USE_ROUGHNESSMAP' : '',
        parameters.metalnessMap ? '#define USE_METALNESSMAP' : '',
        parameters.alphaMap ? '#define USE_ALPHAMAP' : '',
        parameters.transmission ? '#define USE_TRANSMISSION' : '',
        parameters.transmissionMap ? '#define USE_TRANSMISSIONMAP' : '',
        parameters.thicknessMap ? '#define USE_THICKNESSMAP' : '',
        parameters.sheenColorMap ? '#define USE_SHEENCOLORMAP' : '',
			  parameters.sheenRoughnessMap ? '#define USE_SHEENROUGHNESSMAP' : '',
        parameters.vertexTangents ? '#define USE_TANGENT' : '',
        parameters.vertexColors ? '#define USE_COLOR' : '',
        parameters.vertexAlphas ? '#define USE_COLOR_ALPHA' : '',
        parameters.vertexUvs ? '#define USE_UV' : '',
        parameters.uvsVertexOnly ? '#define UVS_VERTEX_ONLY' : '',
        parameters.flipNormalScaleY ? '#define FLIP_NORMAL_SCALE_Y' : '',
        parameters.flatShading ? '#define FLAT_SHADED' : '',
        parameters.skinning ? '#define USE_SKINNING' : '',
        parameters.useVertexTexture ? '#define BONE_TEXTURE' : '',
        parameters.morphTargets == true ? '#define USE_MORPHTARGETS' : '',
        parameters.morphNormals == true && parameters.flatShading == false
            ? '#define USE_MORPHNORMALS'
            : '',
        parameters.doubleSided ? '#define DOUBLE_SIDED' : '',
        parameters.flipSided ? '#define FLIP_SIDED' : '',
        parameters.shadowMapEnabled ? '#define USE_SHADOWMAP' : '',
        parameters.shadowMapEnabled ? '#define ' + shadowMapTypeDefine : '',
        parameters.sizeAttenuation ? '#define USE_SIZEATTENUATION' : '',
        parameters.logarithmicDepthBuffer ? '#define USE_LOGDEPTHBUF' : '',
        (parameters.logarithmicDepthBuffer &&
                parameters.rendererExtensionFragDepth)
            ? '#define USE_LOGDEPTHBUF_EXT'
            : '',
        'uniform mat4 modelMatrix;',
        'uniform mat4 modelViewMatrix;',
        'uniform mat4 projectionMatrix;',
        'uniform mat4 viewMatrix;',
        'uniform mat3 normalMatrix;',
        'uniform vec3 cameraPosition;',
        'uniform bool isOrthographic;',
        '#ifdef USE_INSTANCING',
        '	attribute mat4 instanceMatrix;',
        '#endif',
        '#ifdef USE_INSTANCING_COLOR',
        '	attribute vec3 instanceColor;',
        '#endif',
        'attribute vec3 position;',
        'attribute vec3 normal;',
        'attribute vec2 uv;',
        '#ifdef USE_TANGENT',
        '	attribute vec4 tangent;',
        '#endif',
        '#if defined( USE_COLOR_ALPHA )',
        '	attribute vec4 color;',
        '#elif defined( USE_COLOR )',
        '	attribute vec3 color;',
        '#endif',
        '#ifdef USE_MORPHTARGETS',
        '	attribute vec3 morphTarget0;',
        '	attribute vec3 morphTarget1;',
        '	attribute vec3 morphTarget2;',
        '	attribute vec3 morphTarget3;',
        '	#ifdef USE_MORPHNORMALS',
        '		attribute vec3 morphNormal0;',
        '		attribute vec3 morphNormal1;',
        '		attribute vec3 morphNormal2;',
        '		attribute vec3 morphNormal3;',
        '	#else',
        '		attribute vec3 morphTarget4;',
        '		attribute vec3 morphTarget5;',
        '		attribute vec3 morphTarget6;',
        '		attribute vec3 morphTarget7;',
        '	#endif',
        '#endif',
        '#ifdef USE_SKINNING',
        '	attribute vec4 skinIndex;',
        '	attribute vec4 skinWeight;',
        '#endif',
        '\n'
      ].where((s) => filterEmptyLine(s)).join('\n');

      prefixFragment = [
        customExtensions,

        generatePrecision(parameters),

        '#define SHADER_NAME ' + parameters.shaderName,

        customDefines,

        '#define GAMMA_FACTOR ${gammaFactorDefine}',

        (parameters.useFog && parameters.fog) ? '#define USE_FOG' : '',
        (parameters.useFog && parameters.fogExp2) ? '#define FOG_EXP2' : '',

        parameters.map ? '#define USE_MAP' : '',
        parameters.matcap ? '#define USE_MATCAP' : '',
        parameters.envMap ? '#define USE_ENVMAP' : '',
        parameters.envMap ? '#define ' + envMapTypeDefine : '',
        parameters.envMap ? '#define ' + envMapModeDefine : '',
        parameters.envMap ? '#define ' + envMapBlendingDefine : '',
        parameters.lightMap ? '#define USE_LIGHTMAP' : '',
        parameters.aoMap ? '#define USE_AOMAP' : '',
        parameters.emissiveMap ? '#define USE_EMISSIVEMAP' : '',
        parameters.bumpMap ? '#define USE_BUMPMAP' : '',
        parameters.normalMap ? '#define USE_NORMALMAP' : '',
        (parameters.normalMap && parameters.objectSpaceNormalMap)
            ? '#define OBJECTSPACE_NORMALMAP'
            : '',
        (parameters.normalMap && parameters.tangentSpaceNormalMap)
            ? '#define TANGENTSPACE_NORMALMAP'
            : '',
        parameters.clearcoatMap ? '#define USE_CLEARCOATMAP' : '',
        parameters.clearcoatRoughnessMap
            ? '#define USE_CLEARCOAT_ROUGHNESSMAP'
            : '',
        parameters.clearcoatNormalMap ? '#define USE_CLEARCOAT_NORMALMAP' : '',
        parameters.specularMap ? '#define USE_SPECULARMAP' : '',
        parameters.specularIntensityMap
            ? '#define USE_SPECULARINTENSITYMAP'
            : '',
        parameters.specularColorMap ? '#define USE_SPECULARCOLORMAP' : '',
        parameters.roughnessMap ? '#define USE_ROUGHNESSMAP' : '',
        parameters.metalnessMap ? '#define USE_METALNESSMAP' : '',
        parameters.alphaMap ? '#define USE_ALPHAMAP' : '',
        parameters.alphaTest ? '#define USE_ALPHATEST' : '',
        parameters.sheen ? '#define USE_SHEEN' : '',
        parameters.sheenColorMap ? '#define USE_SHEENCOLORMAP' : '',
			  parameters.sheenRoughnessMap ? '#define USE_SHEENROUGHNESSMAP' : '',
        parameters.transmission ? '#define USE_TRANSMISSION' : '',
        parameters.transmissionMap ? '#define USE_TRANSMISSIONMAP' : '',
        parameters.thicknessMap ? '#define USE_THICKNESSMAP' : '',

        parameters.vertexTangents ? '#define USE_TANGENT' : '',
        parameters.vertexColors || parameters.instancingColor
            ? '#define USE_COLOR'
            : '',
        parameters.vertexAlphas ? '#define USE_COLOR_ALPHA' : '',
        parameters.vertexUvs ? '#define USE_UV' : '',
        parameters.uvsVertexOnly ? '#define UVS_VERTEX_ONLY' : '',
        parameters.flipNormalScaleY ? '#define FLIP_NORMAL_SCALE_Y' : '',
        parameters.gradientMap ? '#define USE_GRADIENTMAP' : '',

        parameters.flatShading ? '#define FLAT_SHADED' : '',

        parameters.doubleSided ? '#define DOUBLE_SIDED' : '',
        parameters.flipSided ? '#define FLIP_SIDED' : '',

        parameters.shadowMapEnabled ? '#define USE_SHADOWMAP' : '',
        parameters.shadowMapEnabled ? '#define ' + shadowMapTypeDefine : '',

        parameters.premultipliedAlpha ? '#define PREMULTIPLIED_ALPHA' : '',

        parameters.physicallyCorrectLights
            ? '#define PHYSICALLY_CORRECT_LIGHTS'
            : '',

        parameters.logarithmicDepthBuffer ? '#define USE_LOGDEPTHBUF' : '',
        (parameters.logarithmicDepthBuffer &&
                parameters.rendererExtensionFragDepth)
            ? '#define USE_LOGDEPTHBUF_EXT'
            : '',

        ((parameters.extensionShaderTextureLOD ||
                    parameters.envMap ||
                    parameters.transmission) &&
                parameters.rendererExtensionShaderTextureLod)
            ? '#define TEXTURE_LOD_EXT'
            : '',

        'uniform mat4 viewMatrix;',
        'uniform vec3 cameraPosition;',
        'uniform bool isOrthographic;',

        (parameters.toneMapping != NoToneMapping) ? '#define TONE_MAPPING' : '',
        (parameters.toneMapping != NoToneMapping)
            ? ShaderChunk['tonemapping_pars_fragment']
            : '', // this code is required here because it is used by the toneMapping() defined below
        (parameters.toneMapping != NoToneMapping)
            ? getToneMappingFunction('toneMapping', parameters.toneMapping)
            : '',

        parameters.dithering ? '#define DITHERING' : '',
        parameters.format == RGBFormat ? '#define OPAQUE' : '',

        ShaderChunk[
            'encodings_pars_fragment'], // this code is required here because it is used by the various encoding/decoding defined below
        parameters.map
            ? getTexelDecodingFunction(
                'mapTexelToLinear', parameters.mapEncoding)
            : '',
        parameters.matcap
            ? getTexelDecodingFunction(
                'matcapTexelToLinear', parameters.matcapEncoding)
            : '',
        parameters.envMap
            ? getTexelDecodingFunction(
                'envMapTexelToLinear', parameters.envMapEncoding)
            : '',
        parameters.emissiveMap
            ? getTexelDecodingFunction(
                'emissiveMapTexelToLinear', parameters.emissiveMapEncoding)
            : '',
        parameters.specularColorMap
            ? getTexelDecodingFunction('specularColorMapTexelToLinear',
                parameters.specularColorMapEncoding)
            : '',
        parameters.sheenColorMap ? getTexelDecodingFunction( 'sheenColorMapTexelToLinear', parameters.sheenColorMapEncoding ) : '', 
        parameters.lightMap
            ? getTexelDecodingFunction(
                'lightMapTexelToLinear', parameters.lightMapEncoding)
            : '',
        getTexelEncodingFunction(
            'linearToOutputTexel', parameters.outputEncoding),

        parameters.depthPacking != null
            ? '#define DEPTH_PACKING ${parameters.depthPacking}'
            : '',

        '\n'
      ].where((s) => filterEmptyLine(s)).join('\n');
    }

    vertexShader = resolveIncludes(vertexShader);
    vertexShader = replaceLightNums(vertexShader, parameters);
    vertexShader = replaceClippingPlaneNums(vertexShader, parameters);

    fragmentShader = resolveIncludes(fragmentShader);
    fragmentShader = replaceLightNums(fragmentShader, parameters);
    fragmentShader = replaceClippingPlaneNums(fragmentShader, parameters);

    vertexShader = unrollLoops(vertexShader);
    fragmentShader = unrollLoops(fragmentShader);

    if (parameters.isWebGL2 && parameters.isRawShaderMaterial != true) {
      // GLSL 3.0 conversion for built-in materials and ShaderMaterial
      versionString = (!kIsWeb && Platform.isMacOS)
          ? "#version 140\n"
          : "#version 300 es\n";

      prefixVertex = [
            '#define attribute in',
            '#define varying out',
            '#define texture2D texture'
          ].join('\n') +
          '\n' +
          prefixVertex;

      prefixFragment = [
            '#define varying in',
            (parameters.glslVersion == GLSL3)
                ? ''
                : 'out highp vec4 pc_fragColor;',
            (parameters.glslVersion == GLSL3)
                ? ''
                : '#define gl_FragColor pc_fragColor',
            '#define gl_FragDepthEXT gl_FragDepth',
            '#define texture2D texture',
            '#define textureCube texture',
            '#define texture2DProj textureProj',
            '#define texture2DLodEXT textureLod',
            '#define texture2DProjLodEXT textureProjLod',
            '#define textureCubeLodEXT textureLod',
            '#define texture2DGradEXT textureGrad',
            '#define texture2DProjGradEXT textureProjGrad',
            '#define textureCubeGradEXT textureGrad'
          ].join('\n') +
          '\n' +
          prefixFragment;
    }

    var vertexGlsl = versionString + prefixVertex + vertexShader;
    var fragmentGlsl = versionString + prefixFragment + fragmentShader;

    // developer.log(" alphaTest: ${parameters.alphaTest} ");
    // developer.log(" 111 ================= VERTEX  ");
    // developer.log(vertexGlsl);
    // developer.log("  111 ==================== FRAGMENT ");
    // developer.log(fragmentGlsl);

    var glVertexShader = WebGLShader(gl, gl.VERTEX_SHADER, vertexGlsl);

    var glFragmentShader = WebGLShader(gl, gl.FRAGMENT_SHADER, fragmentGlsl);

    this.vertexShader = glVertexShader.content;
    this.fragmentShader = glFragmentShader.content;

    gl.attachShader(this.program, glVertexShader.shader);
    gl.attachShader(this.program, glFragmentShader.shader);

    // Force a particular attribute to index 0.

    if (parameters.index0AttributeName != null) {
      gl.bindAttribLocation(this.program, 0, parameters.index0AttributeName);
    } else if (parameters.morphTargets == true) {
      // programs with morphTargets displace position out of attribute 0
      gl.bindAttribLocation(this.program, 0, 'position');
    }

    // final _b = gl.isProgram(this.program);

    gl.linkProgram(this.program);

    // check for link errors
    if (renderer.debug["checkShaderErrors"]) {
      var programLog = gl.getProgramInfoLog(program)?.trim();
      var vertexLog = gl.getShaderInfoLog(glVertexShader.shader)?.trim();
      var fragmentLog = gl.getShaderInfoLog(glFragmentShader.shader)?.trim();

      var runnable = true;
      var haveDiagnostics = true;

      if (gl.getProgramParameter(program, gl.LINK_STATUS) == false) {
        runnable = false;

        var vertexErrors = getShaderErrors(gl, glVertexShader, 'vertex');
        var fragmentErrors = getShaderErrors(gl, glFragmentShader, 'fragment');

        print(
            'THREE.WebGLProgram: shader error: ${gl.getError()} gl.VALIDATE_STATUS ${gl.getProgramParameter(program, gl.VALIDATE_STATUS)} gl.getProgramInfoLog ${programLog}  ${vertexErrors} ${fragmentErrors} ');
      } else if (programLog != '') {
        print(
            'THREE.WebGLProgram: gl.getProgramInfoLog() programLog: ${programLog} vertexLog: ${vertexLog} fragmentLog: ${fragmentLog} ');
      } else if (vertexLog == '' || fragmentLog == '') {
        haveDiagnostics = false;
      }

      if (haveDiagnostics) {
        this.diagnostics = {
          "runnable": runnable,
          "programLog": programLog,
          "vertexShader": {"log": vertexLog, "prefix": prefixVertex},
          "fragmentShader": {"log": fragmentLog, "prefix": prefixFragment}
        };
      }
    }

    // Clean up

    // Crashes in iOS9 and iOS10. #18402
    // gl.detachShader( program, glVertexShader );
    // gl.detachShader( program, glFragmentShader );

    gl.deleteShader(glVertexShader.shader);
    gl.deleteShader(glFragmentShader.shader);

    // set up caching for uniform locations
  }
  // set up caching for attribute locations

  WebGLUniforms getUniforms() {
    if (cachedUniforms == null) {
      cachedUniforms = WebGLUniforms(gl, this);
    }

    return cachedUniforms!;
  }

  Map<String, dynamic> getAttributes() {
    if (cachedAttributes == null) {
      cachedAttributes = fetchAttributeLocations(gl, program);
    }

    return cachedAttributes!;
  }

  // free resource

  destroy() {
    bindingStates.releaseStatesOfProgram(this);

    gl.deleteProgram(program);
    this.program = null;
  }

  //

}
