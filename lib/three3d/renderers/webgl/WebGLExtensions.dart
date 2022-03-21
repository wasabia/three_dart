part of three_webgl;

class WebGLExtensions {
  Map<String, dynamic> extensions = {};
  dynamic gl;

  WebGLExtensions(this.gl);

  getExtension(name) {
    return has(name);
  }

  init(capabilities) {
    if (capabilities.isWebGL2) {
      getExtension('EXT_color_buffer_float');
    } else {
      getExtension('WEBGL_depth_texture');
      getExtension('OES_texture_float');
      getExtension('OES_texture_half_float');
      getExtension('OES_texture_half_float_linear');
      getExtension('OES_standard_derivatives');
      getExtension('OES_element_index_uint');
      getExtension('OES_vertex_array_object');
      getExtension('ANGLE_instanced_arrays');
    }

    getExtension('OES_texture_float_linear');
    getExtension('EXT_color_buffer_half_float');
  }

  has(String name) {
    if (kIsWeb) {
      return hasForWeb(name);
    } else {
      return hasForApp(name);
    }
  }

  hasForWeb(String name) {
    if (extensions[name] != null) {
      return extensions[name];
    }

    var extension;

    switch (name) {
      case 'WEBGL_depth_texture':
        extension = gl.getExtension('WEBGL_depth_texture') ??
            gl.getExtension('MOZ_WEBGL_depth_texture') ??
            gl.getExtension('WEBKIT_WEBGL_depth_texture');
        break;

      case 'EXT_texture_filter_anisotropic':
        extension = gl.getExtension('EXT_texture_filter_anisotropic') ??
            gl.getExtension('MOZ_EXT_texture_filter_anisotropic') ??
            gl.getExtension('WEBKIT_EXT_texture_filter_anisotropic');
        break;

      case 'WEBGL_compressed_texture_s3tc':
        extension = gl.getExtension('WEBGL_compressed_texture_s3tc') ??
            gl.getExtension('MOZ_WEBGL_compressed_texture_s3tc') ??
            gl.getExtension('WEBKIT_WEBGL_compressed_texture_s3tc');
        break;

      case 'WEBGL_compressed_texture_pvrtc':
        extension = gl.getExtension('WEBGL_compressed_texture_pvrtc') ??
            gl.getExtension('WEBKIT_WEBGL_compressed_texture_pvrtc');
        break;

      default:
        extension = gl.getExtension(name);
    }

    extensions[name] = extension;

    return extension;
  }

  bool hasForApp(name) {
    if (extensions.keys.isEmpty) {
      List<String> _extensions = gl.getExtension(name);

      extensions = {};
      for (var element in _extensions) {
        extensions[element] = element;
      }
    }

    Map<String, dynamic> _names = {
      "EXT_color_buffer_float": "GL_EXT_color_buffer_float",
      "EXT_texture_filter_anisotropic": "GL_EXT_texture_filter_anisotropic",
      "EXT_color_buffer_half_float": "GL_EXT_color_buffer_half_float",
      "GL_OES_texture_compression_astc": "GL_OES_texture_compression_astc",
      "GL_KHR_texture_compression_astc_ldr":
          "GL_KHR_texture_compression_astc_ldr",
      "GL_KHR_texture_compression_astc_hdr":
          "GL_KHR_texture_compression_astc_hdr",
      "GL_KHR_texture_compression_astc_sliced_3d":
          "GL_KHR_texture_compression_astc_sliced_3d",
      "GL_EXT_texture_compression_astc_decode_mode":
          "GL_EXT_texture_compression_astc_decode_mode",
      "GL_EXT_texture_compression_astc_decode_mode_rgb9e5":
          "GL_EXT_texture_compression_astc_decode_mode_rgb9e5"
    };

    var _name = _names[name] ?? name;

    // print(" has for app : ${name} ");
    // developer.log( extensions.keys.toList().toString() );

    if (extensions.containsKey(_name)) {
      return extensions.containsKey(_name);
    } else {
      return false;
    }
  }

  get(String name) {
    var extension = getExtension(name);

    if (extension == null) {
      print('THREE.WebGLExtensions.get: $name extension not supported.');
    }

    return extension;
  }
}
