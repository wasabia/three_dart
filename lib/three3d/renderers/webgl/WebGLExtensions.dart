part of three_webgl;

class WebGLExtensions {

  Map<String, dynamic>? extensions;
  dynamic gl;

  WebGLExtensions(this.gl) {
  }


  has( name ) {
    if(kIsWeb) {
      return hasForWeb(name);
    } else {
      return hasForApp(name);
    }
  }

  hasForWeb(name) {
    extensions = extensions ?? {};
    if ( extensions![ name ] != null ) {
      return extensions![ name ] != null;
    }
    
    var extension;

    switch ( name ) {

      case 'WEBGL_depth_texture':
        extension = gl.getExtension( 'WEBGL_depth_texture' ) ?? gl.getExtension( 'MOZ_WEBGL_depth_texture' ) ?? gl.getExtension( 'WEBKIT_WEBGL_depth_texture' );
        break;

      case 'EXT_texture_filter_anisotropic':
        extension = gl.getExtension( 'EXT_texture_filter_anisotropic' ) ?? gl.getExtension( 'MOZ_EXT_texture_filter_anisotropic' ) ?? gl.getExtension( 'WEBKIT_EXT_texture_filter_anisotropic' );
        break;

      case 'WEBGL_compressed_texture_s3tc':
        extension = gl.getExtension( 'WEBGL_compressed_texture_s3tc' ) ?? gl.getExtension( 'MOZ_WEBGL_compressed_texture_s3tc' ) ?? gl.getExtension( 'WEBKIT_WEBGL_compressed_texture_s3tc' );
        break;

      case 'WEBGL_compressed_texture_pvrtc':
        extension = gl.getExtension( 'WEBGL_compressed_texture_pvrtc' ) ?? gl.getExtension( 'WEBKIT_WEBGL_compressed_texture_pvrtc' );
        break;

      default:
        extension = gl.getExtension( name );

    }

    extensions![ name ] = extension;

    return extension != null;
  }

  hasForApp(name) {
    if(extensions == null) {
      List<String> _extensions = gl.getExtension(name);

      extensions = {};
      _extensions.forEach((element) {
        extensions![element] = element;
      });
    }

    Map<String, dynamic> _names = {
      "EXT_texture_filter_anisotropic": "GL_EXT_texture_filter_anisotropic",
      "GL_OES_texture_compression_astc": "GL_OES_texture_compression_astc",
      "GL_KHR_texture_compression_astc_ldr": "GL_KHR_texture_compression_astc_ldr",
      "GL_KHR_texture_compression_astc_hdr": "GL_KHR_texture_compression_astc_hdr",
      "GL_KHR_texture_compression_astc_sliced_3d": "GL_KHR_texture_compression_astc_sliced_3d",
      "GL_EXT_texture_compression_astc_decode_mode": "GL_EXT_texture_compression_astc_decode_mode",
      "GL_EXT_texture_compression_astc_decode_mode_rgb9e5": "GL_EXT_texture_compression_astc_decode_mode_rgb9e5"
    };

    var _name = _names[name] ?? name;

    if ( extensions!.containsKey( _name ) ) {
      return extensions!.containsKey( _name );
    } else {
      return false;
    }
  }

  get( String name ) {

    // print(" WebGLExtensions get name: ${name} ");

    if ( ! this.has( name ) ) {
      // extensions?.keys.forEach((element) {
      //   print(element);
      // });
      print( 'ERROR: ------ THREE.WebGLRenderer: ' + name + ' extension not supported.-------------' );
      return false;
    }

    return extensions![ name ];

  }

}