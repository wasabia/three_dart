part of three_webgl;

int programIdCount = 0;

class DefaultProgram {
  int id = -1;
}

class WebGLProgram extends DefaultProgram with WebGLProgramExtra {
  @override
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
    name = parameters.shaderName;
    id = programIdCount++;

    gl = renderer.getContext();
    program = gl.createProgram();
    init();
  }

  void init() {
    var defines = parameters.defines;

    vertexShader = parameters.vertexShader;
    fragmentShader = parameters.fragmentShader;

    var shadowMapTypeDefine = generateShadowMapTypeDefine(parameters);
    var envMapTypeDefine = generateEnvMapTypeDefine(parameters);
    var envMapModeDefine = generateEnvMapModeDefine(parameters);
    var envMapBlendingDefine = generateEnvMapBlendingDefine(parameters);
    var cubeUVSize = generateCubeUVSize(parameters);

    var customExtensions =
        parameters.isWebGL2 ? '' : generateExtensions(parameters);

    String customDefines = generateDefines(defines);

    String prefixVertex, prefixFragment;

    String defaultVersionString =
        (!kIsWeb && (Platform.isMacOS || Platform.isWindows))
            ? "#version 410\n"
            : "";

    var versionString = parameters.glslVersion != null
        ? '#version ${parameters.glslVersion}\n'
        : defaultVersionString;

    if (parameters.isRawShaderMaterial) {
      prefixVertex =
          [customDefines].where((s) => filterEmptyLine(s)).join('\n');

      if (prefixVertex.isNotEmpty) {
        prefixVertex = "$prefixVertex\n";
      }

      prefixFragment = [customExtensions, customDefines]
          .where((s) => filterEmptyLine(s))
          .join('\n');

      if (prefixFragment.isNotEmpty) {
        prefixFragment = "$prefixFragment\n";
      }
    } else {
      prefixVertex = [
        generatePrecision(parameters),
        '#define SHADER_NAME ' + parameters.shaderName,
        customDefines,
        parameters.instancing ? '#define USE_INSTANCING' : '',
        parameters.instancingColor ? '#define USE_INSTANCING_COLOR' : '',
        parameters.supportsVertexTextures ? '#define VERTEX_TEXTURES' : '',
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
        parameters.morphTargets ? '#define USE_MORPHTARGETS' : '',
        (parameters.morphTargets && parameters.isWebGL2)
            ? '#define MORPHTARGETS_TEXTURE'
            : '',
        (parameters.morphTargets && parameters.isWebGL2)
            ? '#define MORPHTARGETS_COUNT ${parameters.morphTargetsCount}'
            : '',
        parameters.morphNormals && parameters.flatShading == false
            ? '#define USE_MORPHNORMALS'
            : '',
        (parameters.morphColors && parameters.isWebGL2)
            ? '#define USE_MORPHCOLORS'
            : '',
        (parameters.morphTargetsCount > 0 && parameters.isWebGL2)
            ? '#define MORPHTARGETS_TEXTURE'
            : '',
        (parameters.morphTargetsCount > 0 && parameters.isWebGL2)
            ? '#define MORPHTARGETS_TEXTURE_STRIDE ${parameters.morphTextureStride}'
            : '',
        (parameters.morphTargetsCount > 0 && parameters.isWebGL2)
            ? '#define MORPHTARGETS_COUNT ${parameters.morphTargetsCount}'
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
        'layout (location = 0) in vec3 position;',
        '#ifdef USE_INSTANCING',
        '	attribute mat4 instanceMatrix;',
        '#endif',
        '#ifdef USE_INSTANCING_COLOR',
        '	attribute vec3 instanceColor;',
        '#endif',
        // 'attribute vec3 position;',
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
        '#if ( defined( USE_MORPHTARGETS ) && ! defined( MORPHTARGETS_TEXTURE ) )',
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
        (parameters.useFog && parameters.fog) ? '#define USE_FOG' : '',
        (parameters.useFog && parameters.fogExp2) ? '#define FOG_EXP2' : '',

        parameters.map ? '#define USE_MAP' : '',
        parameters.matcap ? '#define USE_MATCAP' : '',
        parameters.envMap ? '#define USE_ENVMAP' : '',
        parameters.envMap ? '#define ' + envMapTypeDefine : '',
        parameters.envMap ? '#define ' + envMapModeDefine : '',
        parameters.envMap ? '#define ' + envMapBlendingDefine : '',
        cubeUVSize != null
            ? '#define CUBEUV_TEXEL_WIDTH ${cubeUVSize["texelWidth"]}'
            : '',
        cubeUVSize != null
            ? '#define CUBEUV_TEXEL_HEIGHT ${cubeUVSize["texelHeight"]}'
            : '',
        cubeUVSize != null
            ? '#define CUBEUV_MAX_MIP ' + cubeUVSize["maxMip"].toString() + '.0'
            : '',

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
        parameters.decodeVideoTexture ? '#define DECODE_VIDEO_TEXTURE' : '',
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
        parameters.opaque ? '' : '#define OPAQUE',

        ShaderChunk[
            'encodings_pars_fragment'], // this code is required here because it is used by the various encoding/decoding defined below

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
      versionString = (!kIsWeb && (Platform.isMacOS || Platform.isWindows))
          ? "#version 410\n"
          : "#version 300 es\n";

      prefixVertex = [
            'precision mediump sampler2DArray;',
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
                : 'layout(location = 0) out highp vec4 pc_fragColor;',
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
    // // developer.log(vertexGlsl);
    // print(vertexGlsl);
    // developer.log("  111 ==================== FRAGMENT ");
    // // developer.log(fragmentGlsl);
    // print( fragmentGlsl );

    var glVertexShader = WebGLShader(gl, gl.VERTEX_SHADER, vertexGlsl);

    var glFragmentShader = WebGLShader(gl, gl.FRAGMENT_SHADER, fragmentGlsl);

    vertexShader = glVertexShader.content;
    fragmentShader = glFragmentShader.content;

    gl.attachShader(program, glVertexShader.shader);
    gl.attachShader(program, glFragmentShader.shader);

    // Force a particular attribute to index 0.

    if (parameters.index0AttributeName != null) {
      gl.bindAttribLocation(program, 0, parameters.index0AttributeName);
    } else if (parameters.morphTargets == true) {
      // programs with morphTargets displace position out of attribute 0
      gl.bindAttribLocation(program, 0, 'position');
    }

    // final _b = gl.isProgram(this.program);

    gl.linkProgram(program);

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
            'THREE.WebGLProgram: shader error: ${gl.getError()} gl.VALIDATE_STATUS ${gl.getProgramParameter(program, gl.VALIDATE_STATUS)} gl.getProgramInfoLog $programLog  $vertexErrors $fragmentErrors ');
      } else if (programLog != '' && programLog != null) {
        print(
            'THREE.WebGLProgram: gl.getProgramInfoLog() programLog: $programLog vertexLog: $vertexLog fragmentLog: $fragmentLog ');
      } else if (vertexLog == '' || fragmentLog == '') {
        haveDiagnostics = false;
      }

      if (haveDiagnostics) {
        diagnostics = {
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
    cachedUniforms ??= WebGLUniforms(gl, this);

    return cachedUniforms!;
  }

  Map<String, dynamic> getAttributes() {
    cachedAttributes ??= fetchAttributeLocations(gl, program);

    return cachedAttributes!;
  }

  // free resource

  void destroy() {
    bindingStates.releaseStatesOfProgram(this);

    gl.deleteProgram(program);
    program = null;
  }

  //

}
