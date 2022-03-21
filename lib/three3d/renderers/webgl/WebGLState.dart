part of three_webgl;

class WebGLState {
  bool isWebGL2 = true;
  dynamic gl;
  WebGLExtensions extensions;
  WebGLCapabilities capabilities;

  late ColorBuffer colorBuffer;
  late DepthBuffer depthBuffer;
  late StencilBuffer stencilBuffer;

  late int maxTextures;

  var emptyTextures = <int, dynamic>{};
  late Map<int, int> equationToGL;
  late Map<int, int> factorToGL;

  Map<String, dynamic> get buffers =>
      {"color": colorBuffer, "depth": depthBuffer, "stencil": stencilBuffer};

  //

  Map<int, bool> enabledCapabilities = <int, bool>{};

  dynamic xrFramebuffer;
  Map currentBoundFramebuffers = {};
  WeakMap currentDrawbuffers = WeakMap();
  var defaultDrawbuffers = [];

  dynamic currentProgram;

  bool currentBlendingEnabled = false;

  int? currentBlending;
  int? currentBlendEquation;
  int? currentBlendSrc;
  int? currentBlendDst;
  int? currentBlendEquationAlpha;
  int? currentBlendSrcAlpha;
  int? currentBlendDstAlpha;
  bool? currentPremultipledAlpha;

  bool? currentFlipSided = false;
  int? currentCullFace;

  num? currentLineWidth;

  num? currentPolygonOffsetFactor;
  num? currentPolygonOffsetUnits;

  bool lineWidthAvailable = true;

  int? currentTextureSlot;
  var currentBoundTextures = <int, BoundTexture>{};

  late Vector4 currentScissor;
  late Vector4 currentViewport;

  dynamic scissorParam;
  dynamic viewportParam;

  WebGLState(this.gl, this.extensions, this.capabilities) {
    this.isWebGL2 = capabilities.isWebGL2;

    this.colorBuffer = ColorBuffer(this.gl);
    this.depthBuffer = DepthBuffer(this.gl);
    this.stencilBuffer = StencilBuffer(this.gl);

    this.colorBuffer.enable = enable;
    this.colorBuffer.disable = disable;

    this.depthBuffer.enable = enable;
    this.depthBuffer.disable = disable;

    this.stencilBuffer.enable = enable;
    this.stencilBuffer.disable = disable;

    this.maxTextures = gl.getParameter(gl.MAX_COMBINED_TEXTURE_IMAGE_UNITS);
    this.emptyTextures[gl.TEXTURE_2D] =
        createTexture(gl.TEXTURE_2D, gl.TEXTURE_2D, 1);
    this.emptyTextures[gl.TEXTURE_CUBE_MAP] =
        createTexture(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_CUBE_MAP_POSITIVE_X, 6);

    // init

    this.colorBuffer.setClear(0, 0, 0, 1, false);
    this.depthBuffer.setClear(1);
    this.stencilBuffer.setClear(0);

    enable(gl.DEPTH_TEST);
    this.depthBuffer.setFunc(LessEqualDepth);

    setFlipSided(false);
    setCullFace(CullFaceBack);
    enable(gl.CULL_FACE);

    setBlending(NoBlending, null, null, null, null, null, null, false);

    equationToGL = {
      AddEquation: gl.FUNC_ADD,
      SubtractEquation: gl.FUNC_SUBTRACT,
      ReverseSubtractEquation: gl.FUNC_REVERSE_SUBTRACT
    };

    equationToGL[MinEquation] = gl.MIN;
    equationToGL[MaxEquation] = gl.MAX;

    factorToGL = {
      ZeroFactor: gl.ZERO,
      OneFactor: gl.ONE,
      SrcColorFactor: gl.SRC_COLOR,
      SrcAlphaFactor: gl.SRC_ALPHA,
      SrcAlphaSaturateFactor: gl.SRC_ALPHA_SATURATE,
      DstColorFactor: gl.DST_COLOR,
      DstAlphaFactor: gl.DST_ALPHA,
      OneMinusSrcColorFactor: gl.ONE_MINUS_SRC_COLOR,
      OneMinusSrcAlphaFactor: gl.ONE_MINUS_SRC_ALPHA,
      OneMinusDstColorFactor: gl.ONE_MINUS_DST_COLOR,
      OneMinusDstAlphaFactor: gl.ONE_MINUS_DST_ALPHA
    };

    scissorParam = gl.getParameter(gl.SCISSOR_BOX);
    viewportParam = gl.getParameter(gl.VIEWPORT);

    // currentScissor = new Vector4.init().fromArray( scissorParam );
    // currentViewport = new Vector4.init().fromArray( viewportParam );

    currentScissor = Vector4.init();
    currentViewport = Vector4.init();
  }

  createTexture(int type, int target, int count) {
    var data = Uint8Array(4);
    // 4 is required to match default unpack alignment of 4.
    //
    var texture = gl.createTexture();

    gl.bindTexture(type, texture);
    gl.texParameteri(type, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(type, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    for (var i = 0; i < count; i++) {
      gl.texImage2D(
          target + i, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
    }

    return texture;
  }

  enable(id) {
    if (enabledCapabilities[id] != true) {
      gl.enable(id);
      enabledCapabilities[id] = true;
    }
  }

  disable(id) {
    if (enabledCapabilities[id] != false) {
      gl.disable(id);
      enabledCapabilities[id] = false;
    }
  }

  bindXRFramebuffer(framebuffer) {
    if (framebuffer != xrFramebuffer) {
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);

      xrFramebuffer = framebuffer;
    }
  }

  bindFramebuffer(target, framebuffer) {
    if (framebuffer == null && xrFramebuffer != null)
      framebuffer = xrFramebuffer; // use active XR framebuffer if available

    if (currentBoundFramebuffers[target] != framebuffer) {
      gl.bindFramebuffer(target, framebuffer);

      currentBoundFramebuffers[target] = framebuffer;

      if (isWebGL2) {
        // gl.DRAW_FRAMEBUFFER is equivalent to gl.FRAMEBUFFER

        if (target == gl.DRAW_FRAMEBUFFER) {
          currentBoundFramebuffers[gl.FRAMEBUFFER] = framebuffer;
        }

        if (target == gl.FRAMEBUFFER) {
          currentBoundFramebuffers[gl.DRAW_FRAMEBUFFER] = framebuffer;
        }
      }

      return true;
    }

    return false;
  }

  drawBuffers(renderTarget, framebuffer) {
    dynamic drawBuffers = defaultDrawbuffers;

    var needsUpdate = false;

    if (renderTarget != null) {
      drawBuffers = currentDrawbuffers.get(framebuffer);

      if (drawBuffers == null) {
        drawBuffers = [];
        currentDrawbuffers.set(framebuffer, drawBuffers);
      }

      if (renderTarget.isWebGLMultipleRenderTargets) {
        var textures = renderTarget.texture;

        if (drawBuffers.length != textures.length ||
            drawBuffers[0] != gl.COLOR_ATTACHMENT0) {
          for (var i = 0, il = textures.length; i < il; i++) {
            drawBuffers[i] = gl.COLOR_ATTACHMENT0 + i;
          }

          drawBuffers.length = textures.length;

          needsUpdate = true;
        }
      } else {
        if (drawBuffers.length == 0 || drawBuffers[0] != gl.COLOR_ATTACHMENT0) {
          if (drawBuffers.length == 0) {
            drawBuffers.add(gl.COLOR_ATTACHMENT0);
          } else {
            drawBuffers[0] = gl.COLOR_ATTACHMENT0;
          }

          drawBuffers.length = 1;

          needsUpdate = true;
        }
      }
    } else {
      if (drawBuffers.length == 0 || drawBuffers[0] != gl.BACK) {
        if (drawBuffers.length == 0) {
          drawBuffers.add(gl.BACK);
        } else {
          drawBuffers[0] = gl.BACK;
        }

        drawBuffers.length = 1;

        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      if (capabilities.isWebGL2) {
        gl.drawBuffers(List<int>.from(drawBuffers));
      } else {
        extensions
            .get('WEBGL_draw_buffers')
            .drawBuffersWEBGL(List<int>.from(drawBuffers));
      }
    }
  }

  useProgram(program) {
    if (currentProgram != program) {
      gl.useProgram(program);
      currentProgram = program;
      return true;
    }

    return false;
  }

  setBlending(
      int blending,
      int? blendEquation,
      int? blendSrc,
      int? blendDst,
      int? blendEquationAlpha,
      int? blendSrcAlpha,
      int? blendDstAlpha,
      bool? premultipliedAlpha) {
    if (blending == NoBlending) {
      if (currentBlendingEnabled) {
        disable(gl.BLEND);
        currentBlendingEnabled = false;
      }

      return;
    }

    if (!currentBlendingEnabled) {
      enable(gl.BLEND);
      currentBlendingEnabled = true;
    }

    if (blending != CustomBlending) {
      if (blending != currentBlending ||
          premultipliedAlpha != currentPremultipledAlpha) {
        if (currentBlendEquation != AddEquation ||
            currentBlendEquationAlpha != AddEquation) {
          gl.blendEquation(gl.FUNC_ADD);

          currentBlendEquation = AddEquation;
          currentBlendEquationAlpha = AddEquation;
        }

        if (premultipliedAlpha != null && premultipliedAlpha) {
          switch (blending) {
            case NormalBlending:
              gl.blendFuncSeparate(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, gl.ONE,
                  gl.ONE_MINUS_SRC_ALPHA);
              break;

            case AdditiveBlending:
              gl.blendFunc(gl.ONE, gl.ONE);
              break;

            case SubtractiveBlending:
              gl.blendFuncSeparate(
                  gl.ZERO, gl.ONE_MINUS_SRC_COLOR, gl.ZERO, gl.ONE);
              break;

            case MultiplyBlending:
              gl.blendFuncSeparate(
                  gl.ZERO, gl.SRC_COLOR, gl.ZERO, gl.SRC_ALPHA);
              break;

            default:
              print('THREE.WebGLState: Invalid blending: ${blending}');
              break;
          }
        } else {
          switch (blending) {
            case NormalBlending:
              gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE,
                  gl.ONE_MINUS_SRC_ALPHA);
              break;

            case AdditiveBlending:
              gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
              break;

            case SubtractiveBlending:
              gl.blendFuncSeparate(
                  gl.ZERO, gl.ONE_MINUS_SRC_COLOR, gl.ZERO, gl.ONE);
              break;

            case MultiplyBlending:
              gl.blendFunc(gl.ZERO, gl.SRC_COLOR);
              break;

            default:
              print('THREE.WebGLState: Invalid blending: ${blending}');
              break;
          }
        }

        currentBlendSrc = null;
        currentBlendDst = null;
        currentBlendSrcAlpha = null;
        currentBlendDstAlpha = null;

        currentBlending = blending;
        currentPremultipledAlpha = premultipliedAlpha;
      }

      return;
    }

    // custom blending

    blendEquationAlpha = blendEquationAlpha ?? blendEquation;
    blendSrcAlpha = blendSrcAlpha ?? blendSrc;
    blendDstAlpha = blendDstAlpha ?? blendDst;

    if (blendEquation != currentBlendEquation ||
        blendEquationAlpha != currentBlendEquationAlpha) {
      gl.blendEquationSeparate(
          equationToGL[blendEquation]!, equationToGL[blendEquationAlpha]!);

      currentBlendEquation = blendEquation;
      currentBlendEquationAlpha = blendEquationAlpha;
    }

    if (blendSrc != currentBlendSrc ||
        blendDst != currentBlendDst ||
        blendSrcAlpha != currentBlendSrcAlpha ||
        blendDstAlpha != currentBlendDstAlpha) {
      gl.blendFuncSeparate(factorToGL[blendSrc], factorToGL[blendDst],
          factorToGL[blendSrcAlpha], factorToGL[blendDstAlpha]);

      currentBlendSrc = blendSrc;
      currentBlendDst = blendDst;
      currentBlendSrcAlpha = blendSrcAlpha;
      currentBlendDstAlpha = blendDstAlpha;
    }

    currentBlending = blending;
    currentPremultipledAlpha = null;
  }

  void setMaterial(Material material, bool frontFaceCW) {
    material.side == DoubleSide ? disable(gl.CULL_FACE) : enable(gl.CULL_FACE);

    var flipSided = (material.side == BackSide);
    if (frontFaceCW) flipSided = !flipSided;

    setFlipSided(flipSided);

    (material.blending == NormalBlending && material.transparent == false)
        ? setBlending(NoBlending, null, null, null, null, null, null, false)
        : setBlending(
            material.blending,
            material.blendEquation,
            material.blendSrc,
            material.blendDst,
            material.blendEquationAlpha,
            material.blendSrcAlpha,
            material.blendDstAlpha,
            material.premultipliedAlpha);

    depthBuffer.setFunc(material.depthFunc);
    depthBuffer.setTest(material.depthTest);
    depthBuffer.setMask(material.depthWrite);
    colorBuffer.setMask(material.colorWrite);

    var stencilWrite = material.stencilWrite;
    stencilBuffer.setTest(stencilWrite);
    if (stencilWrite) {
      stencilBuffer.setMask(material.stencilWriteMask);
      stencilBuffer.setFunc(
          material.stencilFunc, material.stencilRef, material.stencilFuncMask);
      stencilBuffer.setOp(
          material.stencilFail, material.stencilZFail, material.stencilZPass);
    }

    setPolygonOffset(material.polygonOffset, material.polygonOffsetFactor,
        material.polygonOffsetUnits);

    material.alphaToCoverage == true
        ? enable(gl.SAMPLE_ALPHA_TO_COVERAGE)
        : disable(gl.SAMPLE_ALPHA_TO_COVERAGE);
  }

  //

  setFlipSided(bool flipSided) {
    if (currentFlipSided != flipSided) {
      if (flipSided) {
        gl.frontFace(gl.CW);
      } else {
        gl.frontFace(gl.CCW);
      }

      currentFlipSided = flipSided;
    }
  }

  setCullFace(int cullFace) {
    if (cullFace != CullFaceNone) {
      enable(gl.CULL_FACE);

      if (cullFace != currentCullFace) {
        if (cullFace == CullFaceBack) {
          gl.cullFace(gl.BACK);
        } else if (cullFace == CullFaceFront) {
          gl.cullFace(gl.FRONT);
        } else {
          gl.cullFace(gl.FRONT_AND_BACK);
        }
      }
    } else {
      disable(gl.CULL_FACE);
    }

    currentCullFace = cullFace;
  }

  setLineWidth(width) {
    if (width != currentLineWidth) {
      if (lineWidthAvailable) gl.lineWidth(width);

      currentLineWidth = width;
    }
  }

  setPolygonOffset(bool polygonOffset, num? factor, num? units) {
    if (polygonOffset) {
      enable(gl.POLYGON_OFFSET_FILL);

      if (currentPolygonOffsetFactor != factor ||
          currentPolygonOffsetUnits != units) {
        gl.polygonOffset(factor, units);

        currentPolygonOffsetFactor = factor;
        currentPolygonOffsetUnits = units;
      }
    } else {
      disable(gl.POLYGON_OFFSET_FILL);
    }
  }

  setScissorTest(bool scissorTest) {
    if (scissorTest) {
      enable(gl.SCISSOR_TEST);
    } else {
      disable(gl.SCISSOR_TEST);
    }
  }

  // texture

  activeTexture(int? webglSlot) {
    if (webglSlot == null) webglSlot = gl.TEXTURE0 + maxTextures - 1;

    if (currentTextureSlot != webglSlot) {
      gl.activeTexture(webglSlot);

      currentTextureSlot = webglSlot;
    }
  }

  bindTexture(webglType, webglTexture) {
    if (currentTextureSlot == null) {
      activeTexture(null);
    }

    var boundTexture = currentBoundTextures[currentTextureSlot];

    // print("WebGLState.boundTexture boundTexture: ${boundTexture} currentTextureSlot: ${currentTextureSlot} ");

    if (boundTexture == null) {
      boundTexture = BoundTexture(null, null);
      currentBoundTextures[currentTextureSlot!] = boundTexture;
    }

    // print(" boundTexture.type != webglType: ${boundTexture.type != webglType} ");
    // print("boundTexture.texture != webglTexture: ${boundTexture.texture != webglTexture} ");

    // todo debug
    // 当注释掉下面的if条件前 在web下工作正常 手机app端 不正常 例如：阴影渲染 第一次正确 第二次失败
    // 当然绑定纹理失效？
    // 灵异bug
    // 暂时先注释掉if条件  原因不明
    // if (boundTexture.type != webglType || boundTexture.texture != webglTexture) {

    gl.bindTexture(webglType, webglTexture ?? emptyTextures[webglType]);

    boundTexture.type = webglType;
    boundTexture.texture = webglTexture;
    // }
  }

  unbindTexture() {
    var boundTexture = currentBoundTextures[currentTextureSlot];

    if (boundTexture != null && boundTexture.type != null) {
      gl.bindTexture(boundTexture.type!, null);

      boundTexture.type = null;
      boundTexture.texture = null;
    }
  }

  compressedTexImage2D(
      target, level, internalformat, width, height, border, pixels) {
    gl.compressedTexImage2D(
        target, level, internalformat, width, height, border, pixels);
  }

  texSubImage2D(target, level, x, y, width, height, glFormat, glType, data) {
    // try {

    gl.texSubImage2D(
        target, level, x, y, width, height, glFormat, glType, data);

    // } catch ( error ) {

    // 	print( 'THREE.WebGLState: ${error}' );

    // }
  }


  void texSubImage2D_IF(target, level, x, y, glFormat, glType, image) {
    if (kIsWeb) {
      texSubImage2D_NOSIZE(gl.TEXTURE_2D, 0, 0, 0, glFormat, glType, image.data);
    } else {
      texSubImage2D(gl.TEXTURE_2D, 0, 0, 0, image.width, image.height, glFormat, glType, image.data);
    }
  }

  void texSubImage2D_NOSIZE(target, level, x, y, glFormat, glType, data) {
    // try {

    gl.texSubImage2D_NOSIZE(target, level, x, y, glFormat, glType, data);

    // } catch ( error ) {

    // 	print( 'THREE.WebGLState: ${error}' );

    // }
  }

  void texSubImage3D(target, level, xoffset, yoffset, zoffset, width, height,
      depth,
      format, type, pixels) {
    // try {

    gl.texSubImage3D(target, level, xoffset, yoffset, zoffset, width, height,
        depth, format, type, pixels);

    // } catch ( error ) {

    // 	console.error( 'THREE.WebGLState:', error );

    // }
  }

  void compressedTexSubImage2D(
      target, level, xoffset, yoffset, width, height, format, pixels) {
    // try {

    gl.compressedTexSubImage2D(
        target, level, xoffset, yoffset, width, height, format, pixels);

    // } catch ( error ) {

    // 	console.error( 'THREE.WebGLState:', error );

    // }
  }

  void texStorage2D(int type, int levels, int glInternalFormat, width, height) {
    // try {

    gl.texStorage2D(
        type, levels, glInternalFormat, width.toInt(), height.toInt());

    // } catch ( error ) {

    // 	print( 'THREE.WebGLState: ${error}' );

    // }
  }

  void texStorage3D(target, levels, internalformat, width, height, depth) {
    // try {

    gl.texStorage3D(target, levels, internalformat, width, height, depth);

    // } catch ( error ) {

    // 	console.error( 'THREE.WebGLState:', error );

    // }
  }

  void texImage2D_IF(
      int target, int level, int internalformat, int format, int type, image) {
    if(kIsWeb) {
      texImage2D_NOSIZE(target, level, internalformat, format, type, image.data);
    } else {
      texImage2D(target, level, internalformat, image.width, image.height, 0, format,
        type, image.data);
    }
  }

  void texImage2D(int target, int level, int internalformat, width, height,
      border,
      int format, int type, data) {
    gl.texImage2D(target, level, internalformat, width, height, border, format,
        type, data);
  }

  void texImage2D_NOSIZE(
      int target, int level, int internalformat, int format, int type, data) {
    gl.texImage2D_NOSIZE(target, level, internalformat, format, type, data);
  }

  void texImage3D(int target, int level, int internalformat, int width,
      int height,
      int depth, int border, int format, int type, offset) {
    gl.texImage3D(target, level, internalformat, width, height, depth, border,
        format, type, offset);
  }

  //

  void scissor(Vector4 scissor) {
    if (currentScissor.equals(scissor) == false) {
      gl.scissor(scissor.x, scissor.y, scissor.z, scissor.w);
      currentScissor.copy(scissor);
    }
  }

  void viewport(Vector4 viewport) {
    if (currentViewport.equals(viewport) == false) {
      gl.viewport(viewport.x, viewport.y, viewport.z, viewport.w);
      currentViewport.copy(viewport);
    }
  }

  //

  void reset() {
    // reset state

    gl.disable(gl.BLEND);
    gl.disable(gl.CULL_FACE);
    gl.disable(gl.DEPTH_TEST);
    gl.disable(gl.POLYGON_OFFSET_FILL);
    gl.disable(gl.SCISSOR_TEST);
    gl.disable(gl.STENCIL_TEST);
    gl.disable(gl.SAMPLE_ALPHA_TO_COVERAGE);

    gl.blendEquation(gl.FUNC_ADD);
    gl.blendFunc(gl.ONE, gl.ZERO);
    gl.blendFuncSeparate(gl.ONE, gl.ZERO, gl.ONE, gl.ZERO);

    gl.colorMask(true, true, true, true);
    gl.clearColor(0, 0, 0, 0);

    gl.depthMask(true);
    gl.depthFunc(gl.LESS);
    gl.clearDepth(1);

    gl.stencilMask(0xffffffff);
    gl.stencilFunc(gl.ALWAYS, 0, 0xffffffff);
    gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    gl.clearStencil(0);

    gl.cullFace(gl.BACK);
    gl.frontFace(gl.CCW);

    gl.polygonOffset(0, 0);

    gl.activeTexture(gl.TEXTURE0);

    if (isWebGL2 == true) {
      gl.bindFramebuffer(
          gl.DRAW_FRAMEBUFFER, null); // Equivalent to gl.FRAMEBUFFER
      gl.bindFramebuffer(gl.READ_FRAMEBUFFER, null);
    } else {
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    }

    gl.useProgram(null);

    gl.lineWidth(1);

    // TODO app gl no canvas ???
    // gl.scissor( 0, 0, gl.canvas.width, gl.canvas.height );
    // gl.viewport( 0, 0, gl.canvas.width, gl.canvas.height );
    gl.scissor(0, 0, 0, 0);
    gl.viewport(0, 0, 0, 0);

    // reset internals

    enabledCapabilities = {};

    currentTextureSlot = null;
    currentBoundTextures = {};

    xrFramebuffer = null;
    currentBoundFramebuffers = {};
    currentDrawbuffers = WeakMap();
    defaultDrawbuffers = [];

    currentProgram = null;

    currentBlendingEnabled = false;
    currentBlending = null;
    currentBlendEquation = null;
    currentBlendSrc = null;
    currentBlendDst = null;
    currentBlendEquationAlpha = null;
    currentBlendSrcAlpha = null;
    currentBlendDstAlpha = null;
    currentPremultipledAlpha = false;

    currentFlipSided = null;
    currentCullFace = null;

    currentLineWidth = null;

    currentPolygonOffsetFactor = null;
    currentPolygonOffsetUnits = null;

    colorBuffer.reset();
    depthBuffer.reset();
    stencilBuffer.reset();
  }
}

class ColorBuffer {
  dynamic gl;

  bool locked = false;

  late Function enable;
  late Function disable;

  Vector4 color = Vector4.init();
  bool? currentColorMask = null;
  Vector4 currentColorClear = Vector4(0, 0, 0, 0);

  ColorBuffer(this.gl) {}

  setMask(bool colorMask) {
    if (currentColorMask != colorMask && !locked) {
      gl.colorMask(colorMask, colorMask, colorMask, colorMask);
      currentColorMask = colorMask;
    }
  }

  setLocked(lock) {
    locked = lock;
  }

  setClear(double r, double g, double b, double a, bool premultipliedAlpha) {
    if (premultipliedAlpha == true) {
      r *= a;
      g *= a;
      b *= a;
    }

    color.set(r, g, b, a);

    if (currentColorClear.equals(color) == false) {
      gl.clearColor(r, g, b, a);
      currentColorClear.copy(color);
    }
  }

  reset() {
    locked = false;

    currentColorMask = null;
    currentColorClear.set(-1, 0, 0, 0); // set to invalid state
  }
}

class DepthBuffer {
  dynamic gl;

  bool locked = false;

  late Function enable;
  late Function disable;

  bool? currentDepthMask = null;

  int? currentDepthFunc;
  int? currentDepthClear;

  DepthBuffer(this.gl) {}

  setTest(depthTest) {
    if (depthTest) {
      enable(gl.DEPTH_TEST);
    } else {
      disable(gl.DEPTH_TEST);
    }
  }

  setMask(bool depthMask) {
    if (currentDepthMask != depthMask && !locked) {
      gl.depthMask(depthMask);
      currentDepthMask = depthMask;
    }
  }

  setFunc(int depthFunc) {
    if (currentDepthFunc != depthFunc) {
      if (depthFunc != null) {
        switch (depthFunc) {
          case NeverDepth:
            gl.depthFunc(gl.NEVER);
            break;

          case AlwaysDepth:
            gl.depthFunc(gl.ALWAYS);
            break;

          case LessDepth:
            gl.depthFunc(gl.LESS);
            break;

          case LessEqualDepth:
            gl.depthFunc(gl.LEQUAL);
            break;

          case EqualDepth:
            gl.depthFunc(gl.EQUAL);
            break;

          case GreaterEqualDepth:
            gl.depthFunc(gl.GEQUAL);
            break;

          case GreaterDepth:
            gl.depthFunc(gl.GREATER);
            break;

          case NotEqualDepth:
            gl.depthFunc(gl.NOTEQUAL);
            break;

          default:
            gl.depthFunc(gl.LEQUAL);
        }
      } else {
        gl.depthFunc(gl.LEQUAL);
      }

      currentDepthFunc = depthFunc;
    }
  }

  setLocked(lock) {
    locked = lock;
  }

  setClear(int depth) {
    if (currentDepthClear != depth) {
      gl.clearDepth(depth);
      currentDepthClear = depth;
    }
  }

  reset() {
    locked = false;

    currentDepthMask = null;
    currentDepthFunc = null;
    currentDepthClear = null;
  }
}

class StencilBuffer {
  dynamic gl;

  bool locked = false;

  late Function enable;
  late Function disable;

  int? currentStencilMask;
  int? currentStencilFunc;
  int? currentStencilRef;
  int? currentStencilFuncMask;
  int? currentStencilFail;
  int? currentStencilZFail;
  int? currentStencilZPass;
  int? currentStencilClear;

  StencilBuffer(this.gl) {}

  setTest(bool stencilTest) {
    if (!locked) {
      if (stencilTest) {
        enable(gl.STENCIL_TEST);
      } else {
        disable(gl.STENCIL_TEST);
      }
    }
  }

  setMask(int stencilMask) {
    if (currentStencilMask != stencilMask && !locked) {
      gl.stencilMask(stencilMask);
      currentStencilMask = stencilMask;
    }
  }

  setFunc(int stencilFunc, int stencilRef, int stencilMask) {
    if (currentStencilFunc != stencilFunc ||
        currentStencilRef != stencilRef ||
        currentStencilFuncMask != stencilMask) {
      gl.stencilFunc(stencilFunc, stencilRef, stencilMask);

      currentStencilFunc = stencilFunc;
      currentStencilRef = stencilRef;
      currentStencilFuncMask = stencilMask;
    }
  }

  setOp(int stencilFail, int stencilZFail, int stencilZPass) {
    if (currentStencilFail != stencilFail ||
        currentStencilZFail != stencilZFail ||
        currentStencilZPass != stencilZPass) {
      gl.stencilOp(stencilFail, stencilZFail, stencilZPass);

      currentStencilFail = stencilFail;
      currentStencilZFail = stencilZFail;
      currentStencilZPass = stencilZPass;
    }
  }

  setLocked(bool lock) {
    locked = lock;
  }

  setClear(int stencil) {
    if (currentStencilClear != stencil) {
      gl.clearStencil(stencil);
      currentStencilClear = stencil;
    }
  }

  reset() {
    locked = false;

    currentStencilMask = null;
    currentStencilFunc = null;
    currentStencilRef = null;
    currentStencilFuncMask = null;
    currentStencilFail = null;
    currentStencilZFail = null;
    currentStencilZPass = null;
    currentStencilClear = null;
  }
}

class BoundTexture {
  int? type;
  dynamic texture;

  BoundTexture(type, texture) {
    type = type;
    texture = texture;
  }
}
