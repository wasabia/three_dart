part of three_extra;

/// This class generates a Prefiltered, Mipmapped Radiance Environment Map
/// (PMREM) from a cubeMap environment texture. This allows different levels of
/// blur to be quickly accessed based on material roughness. It is packed into a
/// special CubeUV format that allows us to perform custom interpolation so that
/// we can support nonlinear formats such as RGBE. Unlike a traditional mipmap
/// chain, it only goes down to the LOD_MIN level (above), and then creates extra
/// even more filtered 'mips' at the same LOD_MIN resolution, associated with
/// higher roughness levels. In this way we maintain resolution to smoothly
/// interpolate diffuse lighting while limiting sampling computation.
int LOD_MIN = 4;

// The standard deviations (radians) associated with the extra mips. These are
// chosen to approximate a Trowbridge-Reitz distribution function times the
// geometric shadowing function. These sigma values squared must match the
// variance #defines in cube_uv_reflection_fragment.glsl.js.
var EXTRA_LOD_SIGMA = [0.125, 0.215, 0.35, 0.446, 0.526, 0.582];

class PMREMGenerator {
  late int TOTAL_LODS;

  // The maximum length of the blur for loop. Smaller sigmas will use fewer
  // samples and exit early, but not recompile the shader.
  var MAX_SAMPLES = 20;

  dynamic _lodPlanes;
  dynamic _sizeLods;
  dynamic _sigmas;

  final _flatCamera = /*@__PURE__*/ OrthographicCamera();

  final _clearColor = /*@__PURE__*/ Color(1, 1, 1);
  var _oldTarget;

  dynamic PHI;
  dynamic INV_PHI;
  dynamic _axisDirections;

  late WebGLRenderer _renderer;
  dynamic _pingPongRenderTarget;
  dynamic _blurMaterial;
  dynamic _equirectMaterial;
  dynamic _cubemapMaterial;

  late int _lodMax;
  late num _cubeSize;

  PMREMGenerator(renderer) {
    // Golden Ratio
    PHI = (1 + Math.sqrt(5)) / 2;
    INV_PHI = 1 / PHI;

    // Vertices of a dodecahedron (except the opposites, which represent the
    // same axis), used as axis directions evenly spread on a sphere.
    _axisDirections = [
      /*@__PURE__*/ Vector3(1, 1, 1),
      /*@__PURE__*/ Vector3(-1, 1, 1),
      /*@__PURE__*/ Vector3(1, 1, -1),
      /*@__PURE__*/ Vector3(-1, 1, -1),
      /*@__PURE__*/ Vector3(0, PHI, INV_PHI),
      /*@__PURE__*/ Vector3(0, PHI, -INV_PHI),
      /*@__PURE__*/ Vector3(INV_PHI, 0, PHI),
      /*@__PURE__*/ Vector3(-INV_PHI, 0, PHI),
      /*@__PURE__*/ Vector3(PHI, INV_PHI, 0),
      /*@__PURE__*/ Vector3(-PHI, INV_PHI, 0)
    ];

    _renderer = renderer;
    _pingPongRenderTarget = null;

    _lodMax = 0;
    _cubeSize = 0;
    _lodPlanes = [];
    _sizeLods = [];
    _sigmas = [];

    _blurMaterial = null;

    // this._blurMaterial = _getBlurShader(MAX_SAMPLES);
    _equirectMaterial = null;
    _cubemapMaterial = null;

    _compileMaterial(_blurMaterial);
  }

  /**
	 * Generates a PMREM from a supplied Scene, which can be faster than using an
	 * image if networking bandwidth is low. Optional sigma specifies a blur radius
	 * in radians to be applied to the scene before PMREM generation. Optional near
	 * and far planes ensure the scene is rendered in its entirety (the cubeCamera
	 * is placed at the origin).
	 */
  fromScene(scene, [sigma = 0, near = 0.1, far = 100]) {
    _oldTarget = _renderer.getRenderTarget();

    _setSize(256);
    var cubeUVRenderTarget = _allocateTargets();
    cubeUVRenderTarget.depthBuffer = true;

    _sceneToCubeUV(scene, near, far, cubeUVRenderTarget);
    if (sigma > 0) {
      _blur(cubeUVRenderTarget, 0, 0, sigma, null);
    }

    _applyPMREM(cubeUVRenderTarget);
    _cleanup(cubeUVRenderTarget);

    return cubeUVRenderTarget;
  }

  /**
	 * Generates a PMREM from an equirectangular texture, which can be either LDR
	 * or HDR. The ideal input image size is 1k (1024 x 512),
	 * as this matches best with the 256 x 256 cubemap output.
	 */
  fromEquirectangular(equirectangular, [renderTarget]) {
    return _fromTexture(equirectangular, renderTarget);
  }

  /**
	 * Generates a PMREM from an cubemap texture, which can be either LDR
	 * or HDR. The ideal input cube size is 256 x 256,
	 * as this matches best with the 256 x 256 cubemap output.
	 */
  fromCubemap(cubemap, [renderTarget]) {
    return _fromTexture(cubemap, renderTarget);
  }

  /**
	 * Pre-compiles the cubemap shader. You can get faster start-up by invoking this method during
	 * your texture's network fetch for increased concurrency.
	 */
  compileCubemapShader() {
    if (_cubemapMaterial == null) {
      _cubemapMaterial = _getCubemapShader();
      _compileMaterial(_cubemapMaterial);
    }
  }

  /**
	 * Pre-compiles the equirectangular shader. You can get faster start-up by invoking this method during
	 * your texture's network fetch for increased concurrency.
	 */
  compileEquirectangularShader() {
    if (_equirectMaterial == null) {
      _equirectMaterial = _getEquirectMaterial();
      _compileMaterial(_equirectMaterial);
    }
  }

  /**
	 * Disposes of the PMREMGenerator's internal memory. Note that PMREMGenerator is a static class,
	 * so you should not need more than one PMREMGenerator object. If you do, calling dispose() on
	 * one of them will cause any others to also become unusable.
	 */
  dispose() {
    _dispose();

    if (_cubemapMaterial != null) _cubemapMaterial.dispose();
    if (_equirectMaterial != null) _equirectMaterial.dispose();
  }

  // private interface

  _setSize(cubeSize) {
    _lodMax = Math.floor(Math.log2(cubeSize));
    _cubeSize = Math.pow(2, _lodMax);
  }

  _dispose() {
    _blurMaterial.dispose();

    if (_pingPongRenderTarget != null) _pingPongRenderTarget.dispose();

    for (var i = 0; i < _lodPlanes.length; i++) {
      _lodPlanes[i].dispose();
    }
  }

  _cleanup(outputTarget) {
    _renderer.setRenderTarget(_oldTarget);
    outputTarget.scissorTest = false;
    _setViewport(outputTarget, 0, 0, outputTarget.width, outputTarget.height);
  }

  _fromTexture(texture, [renderTarget]) {
    if (texture.mapping == CubeReflectionMapping ||
        texture.mapping == CubeRefractionMapping) {
      _setSize(texture.image.length == 0
          ? 16
          : (texture.image[0].width ?? texture.image[0].image.width));
    } else {
      // Equirectangular

      _setSize(texture.image.width / 4 ?? 256);
    }

    _oldTarget = _renderer.getRenderTarget();

    var cubeUVRenderTarget = renderTarget ?? _allocateTargets();
    _textureToCubeUV(texture, cubeUVRenderTarget);
    _applyPMREM(cubeUVRenderTarget);
    _cleanup(cubeUVRenderTarget);

    return cubeUVRenderTarget;
  }

  _allocateTargets() {
    var width = 3 * Math.max(_cubeSize, 16 * 7);
    var height = 4 * _cubeSize - 32;

    var params = {
      "magFilter": LinearFilter,
      "minFilter": LinearFilter,
      "generateMipmaps": false,
      "type": HalfFloatType,
      "format": RGBAFormat,
      "encoding": LinearEncoding,
      "depthBuffer": false
    };

    var cubeUVRenderTarget = _createRenderTarget(width, height, params);

    if (_pingPongRenderTarget == null || _pingPongRenderTarget.width != width) {
      if (_pingPongRenderTarget != null) {
        _dispose();
      }

      _pingPongRenderTarget = _createRenderTarget(width, height, params);

      var result = _createPlanes(_lodMax);

      _sizeLods = result["sizeLods"];
      _lodPlanes = result["lodPlanes"];
      _sigmas = result["sigmas"];

      _blurMaterial = _getBlurShader(_lodMax, width, height);
    }

    return cubeUVRenderTarget;
  }

  _compileMaterial(material) {
    BufferGeometry? geometry;
    if (_lodPlanes.length >= 1) {
      geometry = _lodPlanes[0];
    }

    var tmpMesh = Mesh(geometry, material);
    _renderer.compile(tmpMesh, _flatCamera);
  }

  _sceneToCubeUV(scene, near, far, cubeUVRenderTarget) {
    var fov = 90;
    var aspect = 1;
    var cubeCamera = PerspectiveCamera(fov, aspect, near, far);
    var upSign = [1, -1, 1, 1, 1, 1];
    var forwardSign = [1, 1, 1, -1, -1, -1];
    var renderer = _renderer;

    var originalAutoClear = renderer.autoClear;
    var toneMapping = renderer.toneMapping;
    renderer.getClearColor(_clearColor);

    renderer.toneMapping = NoToneMapping;
    renderer.autoClear = false;
    var backgroundMaterial = MeshBasicMaterial({
      "name": 'PMREM.Background',
      "side": BackSide,
      "depthWrite": false,
      "depthTest": false,
    });
    var backgroundBox = Mesh(BoxGeometry(), backgroundMaterial);
    var useSolidColor = false;
    var background = scene.background;
    if (background != null) {
      if (background is Color) {
        backgroundMaterial.color.copy(background);
        scene.background = null;
        useSolidColor = true;
      }
    } else {
      backgroundMaterial.color.copy(_clearColor);
      useSolidColor = true;
    }
    for (var i = 0; i < 6; i++) {
      var col = i % 3;
      if (col == 0) {
        cubeCamera.up.set(0, upSign[i], 0);
        cubeCamera.lookAt(Vector3(forwardSign[i], 0, 0));
      } else if (col == 1) {
        cubeCamera.up.set(0, 0, upSign[i]);
        cubeCamera.lookAt(Vector3(0, forwardSign[i], 0));
      } else {
        cubeCamera.up.set(0, upSign[i], 0);
        cubeCamera.lookAt(Vector3(0, 0, forwardSign[i]));
      }
      var size = _cubeSize;
      _setViewport(
          cubeUVRenderTarget, col * size, i > 2 ? size : 0, size, size);
      renderer.setRenderTarget(cubeUVRenderTarget);
      if (useSolidColor) {
        renderer.render(backgroundBox, cubeCamera);
      }
      renderer.render(scene, cubeCamera);
    }
    backgroundBox.geometry?.dispose();
    backgroundBox.material?.dispose();

    renderer.toneMapping = toneMapping;
    renderer.autoClear = originalAutoClear;
    scene.background = background;
  }

  _textureToCubeUV(texture, cubeUVRenderTarget) {
    var renderer = _renderer;

    bool isCubeTexture = (texture.mapping == CubeReflectionMapping ||
        texture.mapping == CubeRefractionMapping);

    if (isCubeTexture) {
      _cubemapMaterial ??= _getCubemapShader();

      _cubemapMaterial.uniforms["flipEnvMap"]["value"] =
          (texture.isRenderTargetTexture == false) ? -1 : 1;
    } else {
      _equirectMaterial ??= _getEquirectMaterial();
    }

    var material = isCubeTexture ? _cubemapMaterial : _equirectMaterial;

    BufferGeometry? geometry;
    if (_lodPlanes.length >= 1) {
      geometry = _lodPlanes[0];
    }
    var mesh = Mesh(geometry, material);

    var uniforms = material.uniforms;

    uniforms['envMap']["value"] = texture;

    var size = _cubeSize;
    _setViewport(cubeUVRenderTarget, 0, 0, 3 * size, 2 * size);

    renderer.setRenderTarget(cubeUVRenderTarget);
    renderer.render(mesh, _flatCamera);
  }

  _applyPMREM(cubeUVRenderTarget) {
    var renderer = _renderer;
    var autoClear = renderer.autoClear;
    renderer.autoClear = false;

    for (var i = 1; i < _lodPlanes.length; i++) {
      var sigma =
          Math.sqrt(_sigmas[i] * _sigmas[i] - _sigmas[i - 1] * _sigmas[i - 1]);

      var poleAxis = _axisDirections[(i - 1) % _axisDirections.length];

      _blur(cubeUVRenderTarget, i - 1, i, sigma, poleAxis);
    }

    renderer.autoClear = autoClear;
  }

  /**
	 * This is a two-pass Gaussian blur for a cubemap. Normally this is done
	 * vertically and horizontally, but this breaks down on a cube. Here we apply
	 * the blur latitudinally (around the poles), and then longitudinally (towards
	 * the poles) to approximate the orthogonally-separable blur. It is least
	 * accurate at the poles, but still does a decent job.
	 */
  _blur(cubeUVRenderTarget, lodIn, lodOut, sigma, poleAxis) {
    var pingPongRenderTarget = _pingPongRenderTarget;

    _halfBlur(cubeUVRenderTarget, pingPongRenderTarget, lodIn, lodOut, sigma,
        'latitudinal', poleAxis);

    _halfBlur(pingPongRenderTarget, cubeUVRenderTarget, lodOut, lodOut, sigma,
        'longitudinal', poleAxis);
  }

  _halfBlur(
      targetIn, targetOut, lodIn, lodOut, sigmaRadians, direction, poleAxis) {
    var renderer = _renderer;
    var blurMaterial = _blurMaterial;

    if (direction != 'latitudinal' && direction != 'longitudinal') {
      print('blur direction must be either latitudinal or longitudinal!');
    }

    // Number of standard deviations at which to cut off the discrete approximation.
    var STANDARDDEVIATIONS = 3;

    BufferGeometry? _geometry;

    if (lodOut < _lodPlanes.length) {
      _geometry = _lodPlanes[lodOut];
    }

    var blurMesh = Mesh(_geometry, blurMaterial);
    var blurUniforms = blurMaterial.uniforms;

    var pixels = _sizeLods[lodIn] - 1;
    var radiansPerPixel = isFinite(sigmaRadians)
        ? Math.PI / (2 * pixels)
        : 2 * Math.PI / (2 * MAX_SAMPLES - 1);
    var sigmaPixels = sigmaRadians / radiansPerPixel;
    var samples = isFinite(sigmaRadians)
        ? 1 + Math.floor(STANDARDDEVIATIONS * sigmaPixels)
        : MAX_SAMPLES;

    if (samples > MAX_SAMPLES) {
      print(
          "sigmaRadians, $sigmaRadians, is too large and will clip, as it requested $samples samples when the maximum is set to $MAX_SAMPLES");
    }

    List<double> weights = [];
    num sum = 0;

    for (var i = 0; i < MAX_SAMPLES; ++i) {
      var x = i / sigmaPixels;
      var weight = Math.exp(-x * x / 2);
      weights.add(weight);

      if (i == 0) {
        sum += weight;
      } else if (i < samples) {
        sum += 2 * weight;
      }
    }

    for (var i = 0; i < weights.length; i++) {
      weights[i] = weights[i] / sum;
    }

    blurUniforms['envMap']["value"] = targetIn.texture;
    blurUniforms['samples']["value"] = samples;
    blurUniforms['weights']["value"] = Float32List.fromList(weights);
    blurUniforms['latitudinal']["value"] = direction == 'latitudinal';

    if (poleAxis != null) {
      blurUniforms['poleAxis']["value"] = poleAxis;
    }

    blurUniforms['dTheta']["value"] = radiansPerPixel;
    blurUniforms['mipInt']["value"] = _lodMax - lodIn;

    var outputSize = _sizeLods[lodOut];
    var x = 3 *
        outputSize *
        (lodOut > _lodMax - LOD_MIN ? lodOut - _lodMax + LOD_MIN : 0);
    var y = 4 * (_cubeSize - outputSize);

    _setViewport(targetOut, x, y, 3 * outputSize, 2 * outputSize);
    renderer.setRenderTarget(targetOut);
    renderer.render(blurMesh, _flatCamera);
  }

  bool isFinite(value) {
    return value == double.infinity;
  }

  _createPlanes(int lodMax) {
    var lodPlanes = [];
    var sizeLods = [];
    var sigmas = [];

    var lod = lodMax;

    var totalLods = lodMax - LOD_MIN + 1 + EXTRA_LOD_SIGMA.length;

    for (var i = 0; i < totalLods; i++) {
      var sizeLod = Math.pow(2, lod);
      sizeLods.add(sizeLod);
      var sigma = 1.0 / sizeLod;

      if (i > lodMax - LOD_MIN) {
        sigma = EXTRA_LOD_SIGMA[i - lodMax + LOD_MIN - 1];
      } else if (i == 0) {
        sigma = 0;
      }

      sigmas.add(sigma);

      var texelSize = 1.0 / (sizeLod - 1);
      var min = -texelSize / 2;
      var max = 1 + texelSize / 2;
      var uv1 = [min, min, max, min, max, max, min, min, max, max, min, max];

      var cubeFaces = 6;
      var vertices = 6;
      var positionSize = 3;
      var uvSize = 2;
      var faceIndexSize = 1;

      var position = Float32Array(positionSize * vertices * cubeFaces);
      var uv = Float32Array(uvSize * vertices * cubeFaces);
      var faceIndex = Int32Array(faceIndexSize * vertices * cubeFaces);

      for (var face = 0; face < cubeFaces; face++) {
        double x = (face % 3) * 2 / 3 - 1;
        double y = face > 2 ? 0 : -1;
        List<double> coordinates = [
          x,
          y,
          0,
          x + 2 / 3,
          y,
          0,
          x + 2 / 3,
          y + 1,
          0,
          x,
          y,
          0,
          x + 2 / 3,
          y + 1,
          0,
          x,
          y + 1,
          0
        ];
        position.set(coordinates, positionSize * vertices * face);
        uv.set(uv1, uvSize * vertices * face);
        final faces = [face, face, face, face, face, face];
        faceIndex.set(faces, faceIndexSize * vertices * face);
      }

      var planes = BufferGeometry();
      planes.setAttribute(
          'position', Float32BufferAttribute(position, positionSize, false));
      planes.setAttribute('uv', Float32BufferAttribute(uv, uvSize, false));
      planes.setAttribute(
          'faceIndex', Int32BufferAttribute(faceIndex, faceIndexSize, false));
      lodPlanes.add(planes);

      if (lod > LOD_MIN) {
        lod--;
      }
    }

    return {"lodPlanes": lodPlanes, "sizeLods": sizeLods, "sigmas": sigmas};
  }

  _createRenderTarget(width, height, params) {
    var cubeUVRenderTarget =
        WebGLRenderTarget(width, height, WebGLRenderTargetOptions(params));
    cubeUVRenderTarget.texture.mapping = CubeUVReflectionMapping;
    cubeUVRenderTarget.texture.name = 'PMREM.cubeUv';
    cubeUVRenderTarget.scissorTest = true;
    return cubeUVRenderTarget;
  }

  _setViewport(target, x, y, width, height) {
    target.viewport.set(x, y, width, height);
    target.scissor.set(x, y, width, height);
  }

  _getPlatformHelper() {
    if (kIsWeb) {
      return "";
    }

    if (Platform.isMacOS) {
      return """
        #define varying in
        out highp vec4 pc_fragColor;
        #define gl_FragColor pc_fragColor
        #define gl_FragDepthEXT gl_FragDepth
        #define texture2D texture
        #define textureCube texture
        #define texture2DProj textureProj
        #define texture2DLodEXT textureLod
        #define texture2DProjLodEXT textureProjLod
        #define textureCubeLodEXT textureLod
        #define texture2DGradEXT textureGrad
        #define texture2DProjGradEXT textureProjGrad
        #define textureCubeGradEXT textureGrad
      """;
    }
    return """
      
    """;
  }

  _getBlurShader(lodMax, width, height) {
    var weights = Float32List(MAX_SAMPLES);
    var poleAxis = Vector3(0, 1, 0);
    var shaderMaterial = ShaderMaterial({
      "name": 'SphericalGaussianBlur',
      "defines": {
        'n': MAX_SAMPLES,
        'CUBEUV_TEXEL_WIDTH': 1.0 / width,
        'CUBEUV_TEXEL_HEIGHT': 1.0 / height,
        'CUBEUV_MAX_MIP': "$lodMax.0",
      },
      "uniforms": {
        'envMap': {},
        'samples': {"value": 1},
        'weights': {"value": weights},
        'latitudinal': {"value": false},
        'dTheta': {"value": 0.0},
        'mipInt': {"value": 0},
        'poleAxis': {"value": poleAxis}
      },
      "vertexShader": _getCommonVertexShader(),
      "fragmentShader": """
        ${_getPlatformHelper()}

        precision mediump float;
        precision mediump int;

        varying vec3 vOutputDirection;

        uniform sampler2D envMap;
        uniform int samples;
        uniform float weights[ n ];
        uniform bool latitudinal;
        uniform float dTheta;
        uniform float mipInt;
        uniform vec3 poleAxis;

        #define ENVMAP_TYPE_CUBE_UV
        #include <cube_uv_reflection_fragment>

        vec3 getSample( float theta, vec3 axis ) {

          float cosTheta = cos( theta );
          // Rodrigues' axis-angle rotation
          vec3 sampleDirection = vOutputDirection * cosTheta
            + cross( axis, vOutputDirection ) * sin( theta )
            + axis * dot( axis, vOutputDirection ) * ( 1.0 - cosTheta );

          return bilinearCubeUV( envMap, sampleDirection, mipInt );

        }

        void main() {

          vec3 axis = latitudinal ? poleAxis : cross( poleAxis, vOutputDirection );

          if ( all( equal( axis, vec3( 0.0 ) ) ) ) {

            axis = vec3( vOutputDirection.z, 0.0, - vOutputDirection.x );

          }

          axis = normalize( axis );

          gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
          gl_FragColor.rgb += weights[ 0 ] * getSample( 0.0, axis );

          for ( int i = 1; i < n; i++ ) {

            if ( i >= samples ) {

              break;

            }

            float theta = dTheta * float( i );
            gl_FragColor.rgb += weights[ i ] * getSample( -1.0 * theta, axis );
            gl_FragColor.rgb += weights[ i ] * getSample( theta, axis );

          }

        }
      """,
      "blending": NoBlending,
      "depthTest": false,
      "depthWrite": false
    });

    return shaderMaterial;
  }

  _getEquirectMaterial() {
    var shaderMaterial = ShaderMaterial({
      "name": 'EquirectangularToCubeUV',
      "uniforms": {'envMap': {}},
      "vertexShader": _getCommonVertexShader(),
      "fragmentShader": """
        ${_getPlatformHelper()}

        precision mediump float;
        precision mediump int;

        varying vec3 vOutputDirection;

        uniform sampler2D envMap;

        #include <common>

        void main() {
          vec3 outputDirection = normalize( vOutputDirection );
          vec2 uv = equirectUv( outputDirection );
          gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );
        }
      """,
      "blending": NoBlending,
      "depthTest": false,
      "depthWrite": false
    });

    return shaderMaterial;
  }

  _getCubemapShader() {
    var shaderMaterial = ShaderMaterial({
      "name": 'CubemapToCubeUV',
      "uniforms": {
        'envMap': {},
        'flipEnvMap': {"value": -1}
      },
      "vertexShader": _getCommonVertexShader(),
      "fragmentShader": """
        ${_getPlatformHelper()}
        
        precision mediump float;
        precision mediump int;

        uniform float flipEnvMap;

        varying vec3 vOutputDirection;

        uniform samplerCube envMap;

        void main() {

          gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

        }
      """,
      "blending": NoBlending,
      "depthTest": false,
      "depthWrite": false
    });

    return shaderMaterial;
  }

  _getPlatformVertexHelper() {
    if (kIsWeb) {
      return "";
    }

    if (Platform.isMacOS) {
      return """
        #define attribute in
        #define varying out
        #define texture2D texture
      """;
    }

    return """
    """;
  }

  _getCommonVertexShader() {
    return """

      ${_getPlatformVertexHelper()}

      precision mediump float;
      precision mediump int;

      attribute float faceIndex;

      varying vec3 vOutputDirection;

      // RH coordinate system; PMREM face-indexing convention
      vec3 getDirection( vec2 uv, float face ) {

        uv = 2.0 * uv - 1.0;

        vec3 direction = vec3( uv, 1.0 );

        if ( face == 0.0 ) {

          direction = direction.zyx; // ( 1, v, u ) pos x

        } else if ( face == 1.0 ) {

          direction = direction.xzy;
          direction.xz *= -1.0; // ( -u, 1, -v ) pos y

        } else if ( face == 2.0 ) {

          direction.x *= -1.0; // ( -u, v, 1 ) pos z

        } else if ( face == 3.0 ) {

          direction = direction.zyx;
          direction.xz *= -1.0; // ( -1, v, -u ) neg x

        } else if ( face == 4.0 ) {

          direction = direction.xzy;
          direction.xy *= -1.0; // ( -u, -1, v ) neg y

        } else if ( face == 5.0 ) {

          direction.z *= -1.0; // ( u, v, -1 ) neg z

        }

        return direction;

      }

      void main() {

        vOutputDirection = getDirection( uv, faceIndex );
        gl_Position = vec4( position, 1.0 );

      }
    """;
  }
}
