part of three_webgl;

class WebGLTextures {
  dynamic gl;
  WebGLExtensions extensions;
  WebGLState state;
  WebGLProperties properties;
  WebGLCapabilities capabilities;
  WebGLUtils utils;
  WebGLInfo info;
  bool isWebGL2 = true;

  late int maxTextures;
  late int maxCubemapSize;
  late int maxTextureSize;
  late int maxSamples;

  Map _videoTextures = Map();

  Map<int, int> wrappingToGL = {};
  Map<int, int> filterToGL = {};

  dynamic get _gl => gl;

  WebGLTextures(this.gl, this.extensions, this.state, this.properties,
      this.capabilities, this.utils, this.info) {
    maxTextures = capabilities.maxTextures;
    maxCubemapSize = capabilities.maxCubemapSize;
    maxTextureSize = capabilities.maxTextureSize;
    maxSamples = capabilities.maxSamples;

    wrappingToGL[RepeatWrapping] = gl.REPEAT;
    wrappingToGL[ClampToEdgeWrapping] = gl.CLAMP_TO_EDGE;
    wrappingToGL[MirroredRepeatWrapping] = gl.MIRRORED_REPEAT;

    filterToGL[NearestFilter] = gl.NEAREST;
    filterToGL[NearestMipmapNearestFilter] = gl.NEAREST_MIPMAP_NEAREST;
    filterToGL[NearestMipmapLinearFilter] = gl.NEAREST_MIPMAP_LINEAR;
    filterToGL[LinearFilter] = gl.LINEAR;
    filterToGL[LinearMipmapNearestFilter] = gl.LINEAR_MIPMAP_NEAREST;
    filterToGL[LinearMipmapLinearFilter] = gl.LINEAR_MIPMAP_LINEAR;
  }

  resizeImage(image, needsPowerOfTwo, needsNewCanvas, maxSize) {
    var scale = 1;

    // handle case if texture exceeds max size

    if (image.width > maxSize || image.height > maxSize) {
      scale = maxSize / Math.max(image.width, image.height);
    }

    // only perform resize if necessary

    // if ( scale < 1 || needsPowerOfTwo == true ) {

    // 	// only perform resize for certain image types

    // 	if ( ( typeof HTMLImageElement != 'null' && image instanceof HTMLImageElement ) ||
    // 		( typeof HTMLCanvasElement != 'null' && image instanceof HTMLCanvasElement ) ||
    // 		( typeof ImageBitmap != 'null' && image instanceof ImageBitmap ) ) {

    // 		var floor = needsPowerOfTwo ? MathUtils.floorPowerOfTwo : Math.floor;

    // 		var width = floor( scale * image.width );
    // 		var height = floor( scale * image.height );

    // 		if ( _canvas == null ) _canvas = createCanvas( width, height );

    // 		// cube textures can't reuse the same canvas

    // 		var canvas = needsNewCanvas ? createCanvas( width, height ) : _canvas;

    // 		canvas.width = width;
    // 		canvas.height = height;

    // 		var context = canvas.getContext( '2d' );
    // 		context.drawImage( image, 0, 0, width, height );

    // 		print( 'THREE.WebGLRenderer: Texture has been resized from (' + image.width + 'x' + image.height + ') to (' + width + 'x' + height + ').' );

    // 		return canvas;

    // 	} else {

    // 		if ( 'data' in image ) {

    // 			print( 'THREE.WebGLRenderer: Image in DataTexture is too big (' + image.width + 'x' + image.height + ').' );

    // 		}

    // 		return image;

    // 	}

    // }

    return image;
  }

  isPowerOfTwo(image) {
    return MathUtils.isPowerOfTwo(image.width) &&
        MathUtils.isPowerOfTwo(image.height);
  }

  textureNeedsPowerOfTwo(texture) {
    if (isWebGL2) return false;
  }

  textureNeedsGenerateMipmaps(texture, supportsMips) {
    return texture.generateMipmaps &&
        supportsMips &&
        texture.minFilter != NearestFilter &&
        texture.minFilter != LinearFilter;
  }

  generateMipmap(target) {
    gl.generateMipmap(target);
  }

  getInternalFormat(internalFormatName, glFormat, glType, encoding,
      [bool isVideoTexture = false]) {
    if (isWebGL2 == false) return glFormat;

    if (internalFormatName != null) {
      // if ( gl[ internalFormatName ] != null ) return gl[ internalFormatName ];

      print(
          'THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format ${internalFormatName}');
    }

    var internalFormat = glFormat;

    if (glFormat == gl.RED) {
      if (glType == gl.FLOAT) internalFormat = gl.R32F;
      if (glType == gl.HALF_FLOAT) internalFormat = gl.R16F;
      if (glType == gl.UNSIGNED_BYTE) internalFormat = gl.R8;
    }

    if (glFormat == gl.RGBA) {
      if (glType == gl.FLOAT) internalFormat = gl.RGBA32F;
      if (glType == gl.HALF_FLOAT) internalFormat = gl.RGBA16F;
      if (glType == gl.UNSIGNED_BYTE)
        internalFormat = (encoding == sRGBEncoding && isVideoTexture == false)
            ? gl.SRGB8_ALPHA8
            : gl.RGBA8;
      if ( glType == _gl.UNSIGNED_SHORT_4_4_4_4 ) internalFormat = _gl.RGBA4;
			if ( glType == _gl.UNSIGNED_SHORT_5_5_5_1 ) internalFormat = _gl.RGB5_A1;
    }

    if (internalFormat == gl.R16F ||
        internalFormat == gl.R32F ||
        internalFormat == gl.RGBA16F ||
        internalFormat == gl.RGBA32F) {
      extensions.get('EXT_color_buffer_float');
    }

    return internalFormat;
  }

  int getMipLevels(texture, image, supportsMips) {
    if (textureNeedsGenerateMipmaps(texture, supportsMips) == true ||
        (texture is FramebufferTexture &&
            texture.minFilter != NearestFilter &&
            texture.minFilter != LinearFilter)) {
      return Math.log2(Math.max(image.width, image.height)).toInt() + 1;
    } else if (texture.mipmaps != null && texture.mipmaps.length > 0) {
      // user-defined mipmaps

      return texture.mipmaps.length;
    } else if ( texture.isCompressedTexture && texture.image is List ) {
      // Dart: TODO texture.image is List ??? 
			return image.mipmaps.length;  
    } else {
      // texture without mipmaps (only base level)

      return 1;
    }
  }

  // Fallback filters for non-power-of-2 textures

  filterFallback(int f) {
    if (f == NearestFilter ||
        f == NearestMipmapNearestFilter ||
        f == NearestMipmapLinearFilter) {
      return gl.NEAREST;
    }

    return gl.LINEAR;
  }

  //

  onTextureDispose(Event event) {
    var texture = event.target;

    texture.removeEventListener('dispose', onTextureDispose);

    deallocateTexture(texture);

    if (texture.isVideoTexture) {
      _videoTextures.remove(texture);
    }

    if (texture.isOpenGLTexture) {
      _videoTextures.remove(texture);
    }

    info.memory["textures"] = info.memory["textures"]! - 1;
  }

  onRenderTargetDispose(Event event) {
    var renderTarget = event.target;

    renderTarget.removeEventListener('dispose', onRenderTargetDispose);

    deallocateRenderTarget(renderTarget);

    info.memory["textures"] = info.memory["textures"]! - 1;
  }

  //

  deallocateTexture(texture) {
    // print("WebGLTextures.deallocateTexture texture: ${texture} ");

    var textureProperties = properties.get(texture);

    if (textureProperties["__webglInit"] == null) return;

    gl.deleteTexture(textureProperties["__webglTexture"]);

    properties.remove(texture);
  }

  deallocateRenderTarget(renderTarget) {
    var texture = renderTarget.texture;

    var renderTargetProperties = properties.get(renderTarget);
    var textureProperties = properties.get(texture);

    if (renderTarget == null) return;

    if (textureProperties["__webglTexture"] != null) {
      gl.deleteTexture(textureProperties["__webglTexture"]);
      info.memory["textures"] = info.memory["textures"]! - 1;
    }

    if (renderTarget.depthTexture != null) {
      renderTarget.depthTexture.dispose();
    }

    if (renderTarget.isWebGLCubeRenderTarget) {
      for (var i = 0; i < 6; i++) {
        gl.deleteFramebuffer(renderTargetProperties["__webglFramebuffer"][i]);
        if (renderTargetProperties["__webglDepthbuffer"] != null)
          gl.deleteRenderbuffer(
              renderTargetProperties["__webglDepthbuffer"][i]);
      }
    } else {
      gl.deleteFramebuffer(renderTargetProperties["__webglFramebuffer"]);
      if (renderTargetProperties["__webglDepthbuffer"] != null)
        gl.deleteRenderbuffer(renderTargetProperties["__webglDepthbuffer"]);
      if (renderTargetProperties["__webglMultisampledFramebuffer"] != null)
        gl.deleteFramebuffer(
            renderTargetProperties["__webglMultisampledFramebuffer"]);
      if (renderTargetProperties["__webglColorRenderbuffer"] != null)
        gl.deleteRenderbuffer(
            renderTargetProperties["__webglColorRenderbuffer"]);
      if (renderTargetProperties["__webglDepthRenderbuffer"] != null)
        gl.deleteRenderbuffer(
            renderTargetProperties["__webglDepthRenderbuffer"]);
    }

    if (renderTarget.isWebGLMultipleRenderTargets) {
      for (var i = 0, il = texture.length; i < il; i++) {
        var attachmentProperties = properties.get(texture[i]);

        if (attachmentProperties["__webglTexture"] != null) {
          gl.deleteTexture(attachmentProperties["__webglTexture"]);

          info.memory["textures"] = info.memory["textures"]! - 1;
        }

        properties.remove(texture[i]);
      }
    }

    properties.remove(texture);
    properties.remove(renderTarget);
  }

  //

  int textureUnits = 0;

  resetTextureUnits() {
    textureUnits = 0;
  }

  allocateTextureUnit() {
    int textureUnit = textureUnits;

    if (textureUnit >= maxTextures) {
      print(
          'THREE.WebGLTextures: Trying to use ${textureUnit} texture units while this GPU supports only ${maxTextures}');
    }

    textureUnits += 1;

    return textureUnit;
  }

  //

  setTexture2D(texture, int slot) {
    var textureProperties = properties.get(texture);

    if (texture.isVideoTexture) updateVideoTexture(texture);
    if (texture.isOpenGLTexture) {
      uploadOpenGLTexture(textureProperties, texture, slot);
      return;
    }

    // print("WebGLTextures setTexture2D texture: ${texture.runtimeType} ${texture.version} extureProperties: ${textureProperties["__webglTexture"]} ");
    if (texture.version > 0 &&
        textureProperties["__version"] != texture.version) {
      var image = texture.image;

      if (!texture.isOpenGLTexture && image == null) {
        print(
            'THREE.WebGLRenderer: Texture marked for update but image is null');
      } else if (!texture.isOpenGLTexture && image.complete == false) {
        print(
            'THREE.WebGLRenderer: Texture marked for update but image is incomplete');
      } else {
        uploadTexture(textureProperties, texture, slot);
        return;
      }
    }

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(gl.TEXTURE_2D, textureProperties["__webglTexture"]);
  }

  setTexture2DArray(texture, int slot) {
    var textureProperties = properties.get(texture);

    if (texture.version > 0 &&
        textureProperties["__version"] != texture.version) {
      uploadTexture(textureProperties, texture, slot);
      return;
    }

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(gl.TEXTURE_2D_ARRAY, textureProperties["__webglTexture"]);
  }

  setTexture3D(texture, int slot) {
    var textureProperties = properties.get(texture);

    if (texture.version > 0 &&
        textureProperties["__version"] != texture.version) {
      uploadTexture(textureProperties, texture, slot);
      return;
    }

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(gl.TEXTURE_3D, textureProperties["__webglTexture"]);
  }

  setTextureCube(texture, int slot) {
    var textureProperties = properties.get(texture);

    if (texture.version > 0 &&
        textureProperties["__version"] != texture.version) {
      uploadCubeTexture(textureProperties, texture, slot);
      return;
    }

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(gl.TEXTURE_CUBE_MAP, textureProperties["__webglTexture"]);
  }

  setTextureParameters(textureType, Texture texture, supportsMips) {
    if (supportsMips) {
      gl.texParameteri(
          textureType, gl.TEXTURE_WRAP_S, wrappingToGL[texture.wrapS]!);
      gl.texParameteri(
          textureType, gl.TEXTURE_WRAP_T, wrappingToGL[texture.wrapT]!);

      if (textureType == gl.TEXTURE_3D || textureType == gl.TEXTURE_2D_ARRAY) {
        gl.texParameteri(
            textureType, gl.TEXTURE_WRAP_R, wrappingToGL[texture.wrapR]!);
      }

      gl.texParameteri(
          textureType, gl.TEXTURE_MAG_FILTER, filterToGL[texture.magFilter]!);
      gl.texParameteri(
          textureType, gl.TEXTURE_MIN_FILTER, filterToGL[texture.minFilter]!);
    } else {
      gl.texParameteri(textureType, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(textureType, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

      if (textureType == gl.TEXTURE_3D || textureType == gl.TEXTURE_2D_ARRAY) {
        gl.texParameteri(textureType, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE);
      }

      if (texture.wrapS != ClampToEdgeWrapping ||
          texture.wrapT != ClampToEdgeWrapping) {
        print(
            'THREE.WebGLRenderer: Texture is not power of two. Texture.wrapS and Texture.wrapT should be set to THREE.ClampToEdgeWrapping.');
      }

      gl.texParameteri(textureType, gl.TEXTURE_MAG_FILTER,
          filterFallback(texture.magFilter));
      gl.texParameteri(textureType, gl.TEXTURE_MIN_FILTER,
          filterFallback(texture.minFilter));

      if (texture.minFilter != NearestFilter &&
          texture.minFilter != LinearFilter) {
        print(
            'THREE.WebGLRenderer: Texture is not power of two. Texture.minFilter should be set to THREE.NearestFilter or THREE.LinearFilter.');
      }
    }

    var extension = extensions.get('EXT_texture_filter_anisotropic');

    if (extension != null) {
      if (texture.type == FloatType &&
          extensions.get('OES_texture_float_linear') == null) return;
      if (texture.type == HalfFloatType &&
          (isWebGL2 || extensions.get('OES_texture_half_float_linear')) == null)
        return;

      if (texture.anisotropy > 1 ||
          properties.get(texture)["__currentAnisotropy"] != null) {
        // print("extension: ${extension} ... extension.TEXTURE_MAX_ANISOTROPY_EXT: ${extension.TEXTURE_MAX_ANISOTROPY_EXT} ");

        if(kIsWeb) {
          gl.texParameterf(textureType, extension.TEXTURE_MAX_ANISOTROPY_EXT,
            Math.min(texture.anisotropy, capabilities.getMaxAnisotropy()));
        } else {
          gl.texParameterf(textureType, gl.TEXTURE_MAX_ANISOTROPY_EXT,
            Math.min(texture.anisotropy, capabilities.getMaxAnisotropy()).toDouble());
        }
        
        properties.get(texture)["__currentAnisotropy"] = texture.anisotropy;
      }
    }
  }

  initTexture(Map<String, dynamic> textureProperties, Texture texture) {
    if (textureProperties["__webglInit"] != true) {
      textureProperties["__webglInit"] = true;

      texture.addEventListener('dispose', onTextureDispose);

      if (texture.isOpenGLTexture) {
        final _texture = texture as OpenGLTexture;
        textureProperties["__webglTexture"] = _texture.openGLTexture;
      } else {
        textureProperties["__webglTexture"] = gl.createTexture();
      }

      info.memory["textures"] = info.memory["textures"]! + 1;
    }
  }

  uploadTexture(textureProperties, Texture texture, int slot) {
    var textureType = gl.TEXTURE_2D;

    // print(" WebGLTextures.uploadTexture ");
    // print(texture.toJSON(null));

    if (texture.isDataTexture2DArray) textureType = gl.TEXTURE_2D_ARRAY;
    if (texture.isDataTexture3D) textureType = gl.TEXTURE_3D;

    initTexture(textureProperties, texture);

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(textureType, textureProperties["__webglTexture"]);

    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, texture.flipY ? 1 : 0);

    gl.pixelStorei(
        gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, texture.premultiplyAlpha ? 1 : 0);
    gl.pixelStorei(gl.UNPACK_ALIGNMENT, texture.unpackAlignment);

    if (kIsWeb) {
      gl.pixelStorei(gl.UNPACK_COLORSPACE_CONVERSION_WEBGL, gl.NONE);
    }

    var needsPowerOfTwo =
        textureNeedsPowerOfTwo(texture) && isPowerOfTwo(texture.image) == false;

    var image =
        resizeImage(texture.image, needsPowerOfTwo, false, maxTextureSize);
    image = verifyColorSpace(texture, image);

    var supportsMips = isPowerOfTwo(image) || isWebGL2;
    var glFormat = utils.convert(texture.format);
    var glType = utils.convert(texture.type);

    var glInternalFormat = getInternalFormat(texture.internalFormat, glFormat,
        glType, texture.encoding, texture.isVideoTexture);

    setTextureParameters(textureType, texture, supportsMips);

    var mipmap;
    var mipmaps = texture.mipmaps;

    var levels = getMipLevels(texture, image, supportsMips);
    var useTexStorage = (isWebGL2 && texture.isVideoTexture != true);
    var allocateMemory = (textureProperties["__version"] == null);

    if (texture.isDepthTexture) {
      // populate depth texture with dummy data

      glInternalFormat = gl.DEPTH_COMPONENT;

      if (isWebGL2) {
        if (texture.type == FloatType) {
          glInternalFormat = gl.DEPTH_COMPONENT32F;
        } else if (texture.type == UnsignedIntType) {
          glInternalFormat = gl.DEPTH_COMPONENT24;
        } else if (texture.type == UnsignedInt248Type) {
          glInternalFormat = gl.DEPTH24_STENCIL8;
        } else {
          glInternalFormat = gl
              .DEPTH_COMPONENT16; // WebGL2 requires sized internalformat for glTexImage2D

        }
      } else {
        if (texture.type == FloatType) {
          print('WebGLRenderer: Floating point depth texture requires WebGL2.');
        }
      }

      // validation checks for WebGL 1

      if (texture.format == DepthFormat &&
          glInternalFormat == gl.DEPTH_COMPONENT) {
        // The error INVALID_OPERATION is generated by texImage2D if format and internalformat are
        // DEPTH_COMPONENT and type is not UNSIGNED_SHORT or UNSIGNED_INT
        // (https://www.khronos.org/registry/webgl/extensions/WEBGL_depth_texture/)
        if (texture.type != UnsignedShortType &&
            texture.type != UnsignedIntType) {
          print(
              'THREE.WebGLRenderer: Use UnsignedShortType or UnsignedIntType for DepthFormat DepthTexture.');

          texture.type = UnsignedShortType;
          glType = utils.convert(texture.type);
        }
      }

      if (texture.format == DepthStencilFormat &&
          glInternalFormat == gl.DEPTH_COMPONENT) {
        // Depth stencil textures need the DEPTH_STENCIL internal format
        // (https://www.khronos.org/registry/webgl/extensions/WEBGL_depth_texture/)
        glInternalFormat = gl.DEPTH_STENCIL;

        // The error INVALID_OPERATION is generated by texImage2D if format and internalformat are
        // DEPTH_STENCIL and type is not UNSIGNED_INT_24_8_WEBGL.
        // (https://www.khronos.org/registry/webgl/extensions/WEBGL_depth_texture/)
        if (texture.type != UnsignedInt248Type) {
          print(
              'THREE.WebGLRenderer: Use UnsignedInt248Type for DepthStencilFormat DepthTexture.');

          texture.type = UnsignedInt248Type;
          glType = utils.convert(texture.type);
        }
      }

      // state.texImage2D(gl.TEXTURE_2D, 0, glInternalFormat, image.width,
      //     image.height, 0, glFormat, glType, null);

      if ( useTexStorage && allocateMemory ) {
				state.texStorage2D( gl.TEXTURE_2D, 1, glInternalFormat, image.width, image.height );
			} else {
				state.texImage2D( gl.TEXTURE_2D, 0, glInternalFormat, image.width, image.height, 0, glFormat, glType, null );
			}
    } else if (texture.isDataTexture) {
      // print("uploadTexture texture isDataTexture image.width: ${image.width}, image.height: ${image.height} supportsMips: ${supportsMips}  -mipmaps.length: ${mipmaps.length}---------------- ");
      // print(image.data.toDartList().length);
      // print(image.data.toDartList() );
      // use manually created mipmaps if available
      // if there are no manual mipmaps
      // set 0 level mipmap and then use GL to generate other mipmap levels

      if (mipmaps.length > 0 && supportsMips) {

        if ( useTexStorage && allocateMemory ) {
					state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, mipmaps[ 0 ].width, mipmaps[ 0 ].height );
				}

        for (var i = 0, il = mipmaps.length; i < il; i++) {
          mipmap = mipmaps[i];
          // state.texImage2D(gl.TEXTURE_2D, i, glInternalFormat, mipmap.width,
          //     mipmap.height, 0, glFormat, glType, mipmap.data);

          if ( useTexStorage ) {
						state.texSubImage2D( _gl.TEXTURE_2D, 0, 0, 0, mipmap.width, mipmap.height, glFormat, glType, mipmap.data );
					} else {
						state.texImage2D( _gl.TEXTURE_2D, i, glInternalFormat, mipmap.width, mipmap.height, 0, glFormat, glType, mipmap.data );
					}
        }

        texture.generateMipmaps = false;
      } else {
        // state.texImage2D(gl.TEXTURE_2D, 0, glInternalFormat, image.width,
        //     image.height, 0, glFormat, glType, image.data);

        if ( useTexStorage ) {
					if ( allocateMemory ) {
						state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, image.width, image.height );
					}
					state.texSubImage2D( _gl.TEXTURE_2D, 0, 0, 0, image.width, image.height, glFormat, glType, image.data );
				} else {
					state.texImage2D( _gl.TEXTURE_2D, 0, glInternalFormat, image.width, image.height, 0, glFormat, glType, image.data );
				}
      }
    } else if (texture.isCompressedTexture) {
      if ( useTexStorage && allocateMemory ) {
				state.texStorage2D( _gl.TEXTURE_2D, levels, glInternalFormat, mipmaps[ 0 ].width, mipmaps[ 0 ].height );
			}

      for (var i = 0, il = mipmaps.length; i < il; i++) {
        mipmap = mipmaps[i];

        if (texture.format != RGBAFormat) {
          if (glFormat != null) {
            // state.compressedTexImage2D(gl.TEXTURE_2D, i, glInternalFormat,
            //     mipmap.width, mipmap.height, 0, null, mipmap.data);
            if ( useTexStorage ) {
							state.compressedTexSubImage2D( _gl.TEXTURE_2D, i, 0, 0, mipmap.width, mipmap.height, glFormat, mipmap.data );
						} else {
							state.compressedTexImage2D( _gl.TEXTURE_2D, i, glInternalFormat, mipmap.width, mipmap.height, 0, mipmap.data );
						}
          } else {
            print(
                'THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()');
          }
        } else {
          // state.texImage2D(gl.TEXTURE_2D, i, glInternalFormat, mipmap.width,
          //     mipmap.height, 0, glFormat, glType, mipmap.data);

          if ( useTexStorage ) {
						state.texSubImage2D( _gl.TEXTURE_2D, i, 0, 0, mipmap.width, mipmap.height, glFormat, glType, mipmap.data );
					} else {
						state.texImage2D( _gl.TEXTURE_2D, i, glInternalFormat, mipmap.width, mipmap.height, 0, glFormat, glType, mipmap.data );
					}
        }
      }
    } else if (texture.isDataTexture2DArray) {
      // state.texImage3D(gl.TEXTURE_2D_ARRAY, 0, glInternalFormat, image.width,
      //     image.height, image.depth, 0, glFormat, glType, image.data);
      if ( useTexStorage ) {
				if ( allocateMemory ) {
					state.texStorage3D( _gl.TEXTURE_2D_ARRAY, levels, glInternalFormat, image.width, image.height, image.depth );
				}
				state.texSubImage3D( _gl.TEXTURE_2D_ARRAY, 0, 0, 0, 0, image.width, image.height, image.depth, glFormat, glType, image.data );
			} else {
				state.texImage3D( _gl.TEXTURE_2D_ARRAY, 0, glInternalFormat, image.width, image.height, image.depth, 0, glFormat, glType, image.data );
			}
    } else if (texture.isDataTexture3D) {
      // state.texImage3D(gl.TEXTURE_3D, 0, glInternalFormat, image.width,
      //     image.height, image.depth, 0, glFormat, glType, image.data);
      if ( useTexStorage ) {
				if ( allocateMemory ) {
					state.texStorage3D( _gl.TEXTURE_3D, levels, glInternalFormat, image.width, image.height, image.depth );
				}
				state.texSubImage3D( _gl.TEXTURE_3D, 0, 0, 0, 0, image.width, image.height, image.depth, glFormat, glType, image.data );
			} else {
				state.texImage3D( _gl.TEXTURE_3D, 0, glInternalFormat, image.width, image.height, image.depth, 0, glFormat, glType, image.data );
			}
    } else if (texture is FramebufferTexture) {
      
      if ( useTexStorage && allocateMemory ) {

				state.texStorage2D( gl.TEXTURE_2D, levels, glInternalFormat, image.width, image.height );

			} else {

				state.texImage2D( gl.TEXTURE_2D, 0, glInternalFormat, image.width, image.height, 0, glFormat, glType, null );

			}

    } else {
      // regular Texture (image, video, canvas)

      // use manually created mipmaps if available
      // if there are no manual mipmaps
      // set 0 level mipmap and then use GL to generate other mipmap levels

      

      if (mipmaps.length > 0 && supportsMips) {
        if (useTexStorage && allocateMemory) {
          state.texStorage2D(gl.TEXTURE_2D, levels, glInternalFormat,
              mipmaps[0].width, mipmaps[0].height);
        }

        for (var i = 0, il = mipmaps.length; i < il; i++) {
          mipmap = mipmaps[i];

          // TODO texImage2D

          // state.texImage2D(gl.TEXTURE_2D, i, glInternalFormat, image.width,
          //     image.height, 0, glFormat, glType, mipmap);

          if (useTexStorage) {
            state.texSubImage2D(gl.TEXTURE_2D, i, 0, 0, mipmap.width,
                mipmap.height, glFormat, glType, mipmap.data);
          } else {
            state.texImage2D(gl.TEXTURE_2D, i, glInternalFormat, image.width,
                image.height, 0, glFormat, glType, mipmap.data);
          }
        }

        texture.generateMipmaps = false;
      } else {
        // print(" WebGLTextures.uploadTexture..... ");

        // TODO
        // if (kIsWeb) {
        // state.texImage2D_NOSIZE(
        //     gl.TEXTURE_2D, 0, glInternalFormat, glFormat, glType, image.data);
        // } else {
        //   state.texImage2D(gl.TEXTURE_2D, 0, glInternalFormat, image.width,
        //       image.height, 0, glFormat, glType, image.data);
        // }

        if (useTexStorage) {
          if (allocateMemory) {
            state.texStorage2D(gl.TEXTURE_2D, levels, glInternalFormat,
                image.width, image.height);
          }

          if (kIsWeb) {
            state.texSubImage2D_NOSIZE(
                gl.TEXTURE_2D, 0, 0, 0, glFormat, glType, image.data);
          } else {
            state.texSubImage2D(gl.TEXTURE_2D, 0, 0, 0, image.width,
                image.height, glFormat, glType, image.data);
          }
        } else {
          // state.texImage2D( gl.TEXTURE_2D, 0, glInternalFormat, glFormat, glType, image );

          if (kIsWeb) {
            state.texImage2D_NOSIZE(gl.TEXTURE_2D, 0, glInternalFormat,
                glFormat, glType, image.data);
          } else {
            state.texImage2D(gl.TEXTURE_2D, 0, glInternalFormat, image.width,
                image.height, 0, glFormat, glType, image.data);
          }
        }
      }
    }

    if (textureNeedsGenerateMipmaps(texture, supportsMips)) {
      generateMipmap(textureType);
    }

    textureProperties["__version"] = texture.version;

    if (texture.onUpdate != null) texture.onUpdate!(texture);
  }

  uploadCubeTexture(textureProperties, texture, int slot) {
    if (texture.image.length != 6) return;

    initTexture(textureProperties, texture);

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(gl.TEXTURE_CUBE_MAP, textureProperties.__webglTexture);

    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, texture.flipY ? 1 : 0);
    gl.pixelStorei(
        gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, texture.premultiplyAlpha ? 1 : 0);
    gl.pixelStorei(gl.UNPACK_ALIGNMENT, texture.unpackAlignment);

    if (kIsWeb) {
      gl.pixelStorei(gl.UNPACK_COLORSPACE_CONVERSION_WEBGL, gl.NONE);
    }

    var isCompressed = (texture &&
        (texture.isCompressedTexture || texture.image[0].isCompressedTexture));
    var isDataTexture = (texture.image[0] && texture.image[0].isDataTexture);
    if (texture.image[0])
      gl.pixelStorei(gl.UNPACK_ALIGNMENT, texture.image[0].unpackAlignment);

    var cubeImage = [];

    for (var i = 0; i < 6; i++) {
      if (!isCompressed && !isDataTexture) {
        cubeImage[i] =
            resizeImage(texture.image[i], false, true, maxCubemapSize);
      } else {
        cubeImage[i] =
            isDataTexture ? texture.image[i].image : texture.image[i];
      }

      cubeImage[i] = verifyColorSpace(texture, cubeImage[i]);
    }

    var image = cubeImage[0],
        supportsMips = isPowerOfTwo(image) || isWebGL2,
        glFormat = utils.convert(texture.format),
        glType = utils.convert(texture.type),
        glInternalFormat = getInternalFormat(
            texture.internalFormat, glFormat, glType, texture.encoding);

    var useTexStorage = ( isWebGL2 && texture.isVideoTexture != true );
		var allocateMemory = ( textureProperties["__version"] == null );
		var levels = getMipLevels( texture, image, supportsMips );

    setTextureParameters(gl.TEXTURE_CUBE_MAP, texture, supportsMips);

    var mipmaps;

    if (isCompressed) {

      if ( useTexStorage && allocateMemory ) {

				state.texStorage2D( _gl.TEXTURE_CUBE_MAP, levels, glInternalFormat, image.width, image.height );

			}


      for (var i = 0; i < 6; i++) {
        mipmaps = cubeImage[i].mipmaps;

        for (var j = 0; j < mipmaps.length; j++) {
          var mipmap = mipmaps[j];

          if (texture.format != RGBAFormat) {
            if (glFormat != null) {
              // state.compressedTexImage2D(
              //     gl.TEXTURE_CUBE_MAP_POSITIVE_X + i,
              //     j,
              //     glInternalFormat,
              //     mipmap.width,
              //     mipmap.height,
              //     0,
              //     0,
              //     mipmap.data);
              if ( useTexStorage ) {

								state.compressedTexSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, 0, 0, mipmap.width, mipmap.height, glFormat, mipmap.data );

							} else {

								state.compressedTexImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, glInternalFormat, mipmap.width, mipmap.height, 0, mipmap.data );

							}
            } else {
              print(
                  'THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()');
            }
          } else {
            // state.texImage2D(
            //     gl.TEXTURE_CUBE_MAP_POSITIVE_X + i,
            //     j,
            //     glInternalFormat,
            //     mipmap.width,
            //     mipmap.height,
            //     0,
            //     glFormat,
            //     glType,
            //     mipmap.data);
            if ( useTexStorage ) {

							state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, 0, 0, mipmap.width, mipmap.height, glFormat, glType, mipmap.data );

						} else {

							state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j, glInternalFormat, mipmap.width, mipmap.height, 0, glFormat, glType, mipmap.data );

						}
          }
        }
      }
    } else {
      mipmaps = texture.mipmaps;

      if ( useTexStorage && allocateMemory ) {

				// TODO: Uniformly handle mipmap definitions
				// Normal textures and compressed cube textures define base level + mips with their mipmap array
				// Uncompressed cube textures use their mipmap array only for mips (no base level)

				if ( mipmaps.length > 0 ) levels ++;

				state.texStorage2D( _gl.TEXTURE_CUBE_MAP, levels, glInternalFormat, cubeImage[ 0 ].width, cubeImage[ 0 ].height );

			}

      for (var i = 0; i < 6; i++) {
        if (isDataTexture) {
          // state.texImage2D(
          //     gl.TEXTURE_CUBE_MAP_POSITIVE_X + i,
          //     0,
          //     glInternalFormat,
          //     cubeImage[i].width,
          //     cubeImage[i].height,
          //     0,
          //     glFormat,
          //     glType,
          //     cubeImage[i].data);

          if ( useTexStorage ) {

						state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, 0, 0, cubeImage[ i ].width, cubeImage[ i ].height, glFormat, glType, cubeImage[ i ].data );

					} else {

						state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, cubeImage[ i ].width, cubeImage[ i ].height, 0, glFormat, glType, cubeImage[ i ].data );

					}

          for (var j = 0; j < mipmaps.length; j++) {
            var mipmap = mipmaps[j];
            var mipmapImage = mipmap.image[i].image;

            // state.texImage2D(
            //     gl.TEXTURE_CUBE_MAP_POSITIVE_X + i,
            //     j + 1,
            //     glInternalFormat,
            //     mipmapImage.width,
            //     mipmapImage.height,
            //     0,
            //     glFormat,
            //     glType,
            //     mipmapImage.data);

            if ( useTexStorage ) {

							state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, 0, 0, mipmapImage.width, mipmapImage.height, glFormat, glType, mipmapImage.data );

						} else {

							state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, glInternalFormat, mipmapImage.width, mipmapImage.height, 0, glFormat, glType, mipmapImage.data );

						}
          }
        } else {
          // state.texImage2D(
          //     gl.TEXTURE_CUBE_MAP_POSITIVE_X + i,
          //     0,
          //     glInternalFormat,
          //     null,
          //     null,
          //     null,
          //     glFormat,
          //     glType,
          //     cubeImage[i]);

          if ( useTexStorage ) {

						state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, 0, 0, cubeImage[ i ].width, cubeImage[ i ].height, glFormat, glType, cubeImage[ i ] );

					} else {

						state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, cubeImage[ i ].width, cubeImage[ i ].height, 0, glFormat, glType, cubeImage[ i ] );

					}

          for (var j = 0; j < mipmaps.length; j++) {
            var mipmap = mipmaps[j];

            // state.texImage2D(
            //     gl.TEXTURE_CUBE_MAP_POSITIVE_X + i,
            //     j + 1,
            //     glInternalFormat,
            //     null,
            //     null,
            //     null,
            //     glFormat,
            //     glType,
            //     mipmap.image[i]);
            if ( useTexStorage ) {

							state.texSubImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, 0, 0, mipmap.image[ i ].width, mipmap.image[ i ].height, glFormat, glType, mipmap.image[ i ] );

						} else {

							state.texImage2D( _gl.TEXTURE_CUBE_MAP_POSITIVE_X + i, j + 1, glInternalFormat, mipmap.image[ i ].width, mipmap.image[ i ].height, 0, glFormat, glType, mipmap.image[ i ] );

						}
          }
        }
      }
    }

    if (textureNeedsGenerateMipmaps(texture, supportsMips)) {
      // We assume images for cube map have the same size.
      generateMipmap(gl.TEXTURE_CUBE_MAP);
    }

    textureProperties.__version = texture.version;

    if (texture.onUpdate) texture.onUpdate(texture);
  }

  // Render targets

  // Setup storage for target texture and bind it to correct framebuffer
  setupFrameBufferTexture(
      framebuffer, renderTarget, texture, attachment, textureTarget) {
    var glFormat = utils.convert(texture.format);
    var glType = utils.convert(texture.type);
    var glInternalFormat = getInternalFormat(
        texture.internalFormat, glFormat, glType, texture.encoding);

    if (textureTarget == gl.TEXTURE_3D ||
        textureTarget == gl.TEXTURE_2D_ARRAY) {
      state.texImage3D(textureTarget, 0, glInternalFormat, renderTarget.width,
          renderTarget.height, renderTarget.depth, 0, glFormat, glType, null);
    } else {
      state.texImage2D(textureTarget, 0, glInternalFormat, renderTarget.width,
          renderTarget.height, 0, glFormat, glType, null);
    }

    state.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, attachment, textureTarget,
        properties.get(texture)["__webglTexture"], 0);
    state.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  // Setup storage for internal depth/stencil buffers and bind to correct framebuffer
  setupRenderBufferStorage(renderbuffer, renderTarget, isMultisample) {
    gl.bindRenderbuffer(gl.RENDERBUFFER, renderbuffer);

    if (renderTarget.depthBuffer && !renderTarget.stencilBuffer) {
      var glInternalFormat = gl.DEPTH_COMPONENT16;

      if (isMultisample) {
        var depthTexture = renderTarget.depthTexture;

        if (depthTexture != null && depthTexture.isDepthTexture) {
          if (depthTexture.type == FloatType) {
            glInternalFormat = gl.DEPTH_COMPONENT32F;
          } else if (depthTexture.type == UnsignedIntType) {
            glInternalFormat = gl.DEPTH_COMPONENT24;
          }
        }

        var samples = getRenderTargetSamples(renderTarget);

        gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples,
            glInternalFormat, renderTarget.width, renderTarget.height);
      } else {
        gl.renderbufferStorage(gl.RENDERBUFFER, glInternalFormat,
            renderTarget.width, renderTarget.height);
      }

      gl.framebufferRenderbuffer(
          gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, renderbuffer);
    } else if (renderTarget.depthBuffer && renderTarget.stencilBuffer) {
      if (isMultisample) {
        var samples = getRenderTargetSamples(renderTarget);

        gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples,
            gl.DEPTH24_STENCIL8, renderTarget.width, renderTarget.height);
      } else {
        gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_STENCIL,
            renderTarget.width, renderTarget.height);
      }

      gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT,
          gl.RENDERBUFFER, renderbuffer);
    } else {
      // Use the first texture for MRT so far
      var texture = renderTarget.isWebGLMultipleRenderTargets == true
          ? renderTarget.texture[0]
          : renderTarget.texture;

      var glFormat = utils.convert(texture.format);
      var glType = utils.convert(texture.type);
      var glInternalFormat = getInternalFormat(
          texture.internalFormat, glFormat, glType, texture.encoding);

      if (isMultisample) {
        var samples = getRenderTargetSamples(renderTarget);

        gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples,
            glInternalFormat, renderTarget.width, renderTarget.height);
      } else {
        gl.renderbufferStorage(gl.RENDERBUFFER, glInternalFormat,
            renderTarget.width, renderTarget.height);
      }
    }

    gl.bindRenderbuffer(gl.RENDERBUFFER, null);
  }

  // Setup resources for a Depth Texture for a FBO (needs an extension)
  setupDepthTexture(framebuffer, renderTarget) {
    var isCube = (renderTarget && renderTarget.isWebGLCubeRenderTarget);
    if (isCube)
      throw ('Depth Texture with cube render targets is not supported');

    state.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);

    if (!(renderTarget.depthTexture != null &&
        renderTarget.depthTexture.isDepthTexture)) {
      throw ('renderTarget.depthTexture must be an instance of THREE.DepthTexture');
    }

    // upload an empty depth texture with framebuffer size
    if (properties.get(renderTarget.depthTexture)["__webglTexture"] == null ||
        renderTarget.depthTexture.image.width != renderTarget.width ||
        renderTarget.depthTexture.image.height != renderTarget.height) {
      renderTarget.depthTexture.image.width = renderTarget.width;
      renderTarget.depthTexture.image.height = renderTarget.height;
      renderTarget.depthTexture.needsUpdate = true;
    }

    setTexture2D(renderTarget.depthTexture, 0);

    var webglDepthTexture =
        properties.get(renderTarget.depthTexture)["__webglTexture"];

    if (renderTarget.depthTexture.format == DepthFormat) {
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT,
          gl.TEXTURE_2D, webglDepthTexture, 0);
    } else if (renderTarget.depthTexture.format == DepthStencilFormat) {
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT,
          gl.TEXTURE_2D, webglDepthTexture, 0);
    } else {
      throw ('Unknown depthTexture format');
    }
  }

  // Setup GL resources for a non-texture depth buffer
  setupDepthRenderbuffer(renderTarget) {
    var renderTargetProperties = properties.get(renderTarget);

    var isCube = (renderTarget.isWebGLCubeRenderTarget == true);

    if (renderTarget.depthTexture != null) {
      if (isCube)
        throw ('target.depthTexture not supported in Cube render targets');

      setupDepthTexture(
          renderTargetProperties["__webglFramebuffer"], renderTarget);
    } else {
      if (isCube) {
        renderTargetProperties["__webglDepthbuffer"] = [];

        for (var i = 0; i < 6; i++) {
          state.bindFramebuffer(
              gl.FRAMEBUFFER, renderTargetProperties["__webglFramebuffer"][i]);

          // renderTargetProperties["__webglDepthbuffer"][ i ] = gl.createRenderbuffer();
          renderTargetProperties["__webglDepthbuffer"]
              .add(gl.createRenderbuffer());

          setupRenderBufferStorage(
              renderTargetProperties["__webglDepthbuffer"][i],
              renderTarget,
              false);
        }
      } else {
        state.bindFramebuffer(
            gl.FRAMEBUFFER, renderTargetProperties["__webglFramebuffer"]);

        renderTargetProperties["__webglDepthbuffer"] = gl.createRenderbuffer();
        setupRenderBufferStorage(
            renderTargetProperties["__webglDepthbuffer"], renderTarget, false);
      }
    }

    state.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  // rebind framebuffer with external textures
	rebindTextures( renderTarget, colorTexture, depthTexture ) {

		var renderTargetProperties = properties.get( renderTarget );

		if ( colorTexture != null ) {

			setupFrameBufferTexture( renderTargetProperties["__webglFramebuffer"], renderTarget, renderTarget.texture, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D );

		}

		if ( depthTexture != undefined ) {

			setupDepthRenderbuffer( renderTarget );

		}

	}

  // Set up GL resources for the render target
  setupRenderTarget(RenderTarget renderTarget) {
    var texture = renderTarget.texture;

    var renderTargetProperties = properties.get(renderTarget);
    var textureProperties = properties.get(renderTarget.texture);

    renderTarget.addEventListener('dispose', onRenderTargetDispose);

    if (renderTarget.isWebGLMultipleRenderTargets != true) {
      textureProperties["__webglTexture"] = gl.createTexture();
      textureProperties["__version"] = texture.version;
      info.memory["textures"] = info.memory["textures"]! + 1;
    }

    var isCube = (renderTarget.isWebGLCubeRenderTarget == true);
    var isMultipleRenderTargets =
        (renderTarget.isWebGLMultipleRenderTargets == true);
    var isMultisample = (renderTarget.isWebGLMultisampleRenderTarget == true);
    var isRenderTarget3D =
        texture.isDataTexture3D || texture.isDataTexture2DArray;
    var supportsMips = isPowerOfTwo(renderTarget) || isWebGL2;

    // Setup framebuffer

    if (isCube) {
      renderTargetProperties["__webglFramebuffer"] = [];

      for (var i = 0; i < 6; i++) {
        // renderTargetProperties["__webglFramebuffer"][ i ] = gl.createFramebuffer();

        renderTargetProperties["__webglFramebuffer"]
            .add(gl.createFramebuffer());
      }
    } else {
      renderTargetProperties["__webglFramebuffer"] = gl.createFramebuffer();

      if (isMultipleRenderTargets) {
        if (capabilities.drawBuffers) {
          var textures = renderTarget.texture;

          for (var i = 0, il = textures.length; i < il; i++) {
            var attachmentProperties = properties.get(textures[i]);

            if (attachmentProperties["__webglTexture"] == null) {
              attachmentProperties["__webglTexture"] = gl.createTexture();

              info.memory["textures"] = info.memory["textures"]! + 1;
            }
          }
        } else {
          print(
              'THREE.WebGLRenderer: WebGLMultipleRenderTargets can only be used with WebGL2 or WEBGL_draw_buffers extension.');
        }
      } else if (isMultisample) {
        if (isWebGL2) {
          renderTargetProperties["__webglMultisampledFramebuffer"] =
              gl.createFramebuffer();
          renderTargetProperties["__webglColorRenderbuffer"] =
              gl.createRenderbuffer();

          gl.bindRenderbuffer(gl.RENDERBUFFER,
              renderTargetProperties["__webglColorRenderbuffer"]);

          var glFormat = utils.convert(texture.format);
          var glType = utils.convert(texture.type);
          var glInternalFormat = getInternalFormat(
              texture.internalFormat, glFormat, glType, texture.encoding);
          var samples = getRenderTargetSamples(renderTarget);
          gl.renderbufferStorageMultisample(gl.RENDERBUFFER, samples,
              glInternalFormat, renderTarget.width, renderTarget.height);

          state.bindFramebuffer(gl.FRAMEBUFFER,
              renderTargetProperties["__webglMultisampledFramebuffer"]);
          gl.framebufferRenderbuffer(
              gl.FRAMEBUFFER,
              gl.COLOR_ATTACHMENT0,
              gl.RENDERBUFFER,
              renderTargetProperties["__webglColorRenderbuffer"]);
          gl.bindRenderbuffer(gl.RENDERBUFFER, null);

          if (renderTarget.depthBuffer) {
            renderTargetProperties["__webglDepthRenderbuffer"] =
                gl.createRenderbuffer();
            setupRenderBufferStorage(
                renderTargetProperties["__webglDepthRenderbuffer"],
                renderTarget,
                true);
          }

          state.bindFramebuffer(gl.FRAMEBUFFER, null);
        } else {
          print(
              'THREE.WebGLRenderer: WebGLMultisampleRenderTarget can only be used with WebGL2.');
        }
      }
    }

    // Setup color buffer

    if (isCube) {
      state.bindTexture(
          gl.TEXTURE_CUBE_MAP, textureProperties["__webglTexture"]);
      setTextureParameters(gl.TEXTURE_CUBE_MAP, texture, supportsMips);

      for (var i = 0; i < 6; i++) {
        setupFrameBufferTexture(
            renderTargetProperties["__webglFramebuffer"][i],
            renderTarget,
            texture,
            gl.COLOR_ATTACHMENT0,
            gl.TEXTURE_CUBE_MAP_POSITIVE_X + i);
      }

      if (textureNeedsGenerateMipmaps(texture, supportsMips)) {
        generateMipmap(gl.TEXTURE_CUBE_MAP);
      }

      state.bindTexture(gl.TEXTURE_CUBE_MAP, null);
    } else if (isMultipleRenderTargets) {
      var textures = renderTarget.texture;

      for (var i = 0, il = textures.length; i < il; i++) {
        var attachment = textures[i];
        var attachmentProperties = properties.get(attachment);

        state.bindTexture(
            gl.TEXTURE_2D, attachmentProperties["__webglTexture"]);
        setTextureParameters(gl.TEXTURE_2D, attachment, supportsMips);
        setupFrameBufferTexture(renderTargetProperties["__webglFramebuffer"],
            renderTarget, attachment, gl.COLOR_ATTACHMENT0 + i, gl.TEXTURE_2D);

        if (textureNeedsGenerateMipmaps(attachment, supportsMips)) {
          generateMipmap(gl.TEXTURE_2D);
        }
      }

      state.bindTexture(gl.TEXTURE_2D, null);
    } else {
      var glTextureType = gl.TEXTURE_2D;

      if (isRenderTarget3D) {
        // Render targets containing layers, i.e: Texture 3D and 2d arrays

        if (isWebGL2) {
          var isTexture3D = texture.isDataTexture3D;
          glTextureType = isTexture3D ? gl.TEXTURE_3D : gl.TEXTURE_2D_ARRAY;
        } else {
          print(
              'THREE.DataTexture3D and THREE.DataTexture2DArray only supported with WebGL2.');
        }
      }

      state.bindTexture(glTextureType, textureProperties["__webglTexture"]);
      setTextureParameters(glTextureType, texture, supportsMips);
      setupFrameBufferTexture(renderTargetProperties["__webglFramebuffer"],
          renderTarget, texture, gl.COLOR_ATTACHMENT0, glTextureType);

      if (textureNeedsGenerateMipmaps(texture, supportsMips)) {
        generateMipmap(glTextureType);
      }

      state.bindTexture(glTextureType, null);
    }

    // Setup depth and stencil buffers

    if (renderTarget.depthBuffer) {
      setupDepthRenderbuffer(renderTarget);
    }
  }

  updateRenderTargetMipmap(renderTarget) {
    var supportsMips = isPowerOfTwo(renderTarget) || isWebGL2;

    var textures = renderTarget.isWebGLMultipleRenderTargets == true
        ? renderTarget.texture
        : [renderTarget.texture];

    for (var i = 0, il = textures.length; i < il; i++) {
      var texture = textures[i];

      if (textureNeedsGenerateMipmaps(texture, supportsMips)) {
        var target = renderTarget.isWebGLCubeRenderTarget
            ? gl.TEXTURE_CUBE_MAP
            : gl.TEXTURE_2D;
        var webglTexture = properties.get(texture)["__webglTexture"];

        state.bindTexture(target, webglTexture);
        generateMipmap(target);
        state.bindTexture(target, null);
      }
    }
  }

  updateMultisampleRenderTarget(renderTarget) {
    if (renderTarget.isWebGLMultisampleRenderTarget) {
      if (isWebGL2) {
        var width = renderTarget.width;
        var height = renderTarget.height;
        var mask = gl.COLOR_BUFFER_BIT;

        if (renderTarget.depthBuffer) mask |= gl.DEPTH_BUFFER_BIT;
        if (renderTarget.stencilBuffer) mask |= gl.STENCIL_BUFFER_BIT;

        var renderTargetProperties = properties.get(renderTarget);

        state.bindFramebuffer(gl.READ_FRAMEBUFFER,
            renderTargetProperties["__webglMultisampledFramebuffer"]);
        state.bindFramebuffer(
            gl.DRAW_FRAMEBUFFER, renderTargetProperties["__webglFramebuffer"]);

        gl.blitFramebuffer(
            0, 0, width, height, 0, 0, width, height, mask, gl.NEAREST);

        state.bindFramebuffer(gl.READ_FRAMEBUFFER, null);
        state.bindFramebuffer(gl.DRAW_FRAMEBUFFER,
            renderTargetProperties["__webglMultisampledFramebuffer"]);
      } else {
        print(
            'THREE.WebGLRenderer: WebGLMultisampleRenderTarget can only be used with WebGL2.');
      }
    }
  }

  getRenderTargetSamples(renderTarget) {
    return (isWebGL2 && renderTarget.isWebGLMultisampleRenderTarget)
        ? Math.min(maxSamples, renderTarget.samples)
        : 0;
  }

  updateVideoTexture(VideoTexture texture) {
    var frame = info.render["frame"];

    // Check the last frame we updated the VideoTexture

    if (_videoTextures[texture] != frame) {
      _videoTextures[texture] = frame;
      texture.update();
    }
  }

  uploadOpenGLTexture(textureProperties, OpenGLTexture texture, int slot) {
    var frame = info.render["frame"];
    if (_videoTextures[texture] != frame) {
      _videoTextures[texture] = frame;
      texture.update();
    }

    var textureType = gl.TEXTURE_2D;

    initTexture(textureProperties, texture);

    state.activeTexture(gl.TEXTURE0 + slot);
    state.bindTexture(textureType, textureProperties["__webglTexture"]);

    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, texture.flipY ? 1 : 0);
    gl.pixelStorei(
        gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, texture.premultiplyAlpha ? 1 : 0);
    gl.pixelStorei(gl.UNPACK_ALIGNMENT, texture.unpackAlignment);
  }

  verifyColorSpace(texture, image) {
    var encoding = texture.encoding;
    var format = texture.format;
    var type = texture.type;

    if (texture.isCompressedTexture == true ||
        texture.isVideoTexture == true || texture.format == SRGBAFormat) return image;

    if (encoding != LinearEncoding) {
      // sRGB

      if (encoding == sRGBEncoding) {
        if (isWebGL2 == false) {
          // in WebGL 1, try to use EXT_sRGB extension and unsized formats

          if (extensions.has('EXT_sRGB') == true && format == RGBAFormat) {
      
            texture.format = SRGBAFormat;

            // it's not possible to generate mips in WebGL 1 with this extension

            texture.minFilter = LinearFilter;
            texture.generateMipmaps = false;
          } else {
            // slow fallback (CPU decode)

            image = ImageUtils.sRGBToLinear(image);
          }
        } else {
          // in WebGL 2 uncompressed textures can only be sRGB encoded if they have the RGBA8 format

          if (format != RGBAFormat || type != UnsignedByteType) {
            print(
                'THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType.');
          }
        }
      } else {
        print('THREE.WebGLTextures: Unsupported texture encoding: ${encoding}');
      }
    }

    return image;
  }

  // backwards compatibility

  bool warnedTexture2D = false;
  bool warnedTextureCube = false;

  safeSetTexture2D(texture, slot) {
    // print(" WebGLTextures.safeSetTexture2D  texture: ${texture}  isOpenGLTexture: ${texture.isOpenGLTexture} " );

    if (texture != null && texture.isWebGLRenderTarget) {
      if (warnedTexture2D == false) {
        print(
            'THREE.WebGLTextures.safeSetTexture2D: don\'t use render targets as textures. Use their .texture property instead.');
        warnedTexture2D = true;
      }

      texture = texture.texture;
    }

    setTexture2D(texture, slot);
  }

  safeSetTextureCube(texture, slot) {
    if (texture != null && texture is WebGLCubeRenderTarget) {
      if (warnedTextureCube == false) {
        print(
            'THREE.WebGLTextures.safeSetTextureCube: don\'t use cube render targets as textures. Use their .texture property instead.');
        warnedTextureCube = true;
      }

      texture = texture.texture;
    }

    setTextureCube(texture, slot);
  }

  dispose() {}
}
