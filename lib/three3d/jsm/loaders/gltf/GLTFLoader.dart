part of gltf_loader;


class GLTFLoader extends Loader {

  late List<Function> pluginCallbacks;
  late dynamic dracoLoader;
  late dynamic ktx2Loader;
  late dynamic ddsLoader;
  late dynamic meshoptDecoder;

  GLTFLoader( manager ) : super(manager) {

    this.dracoLoader = null;
    this.ddsLoader = null;
    this.ktx2Loader = null;
    this.meshoptDecoder = null;

    this.pluginCallbacks = [];

    
    this.register( ( parser ) {

			return new GLTFMaterialsClearcoatExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFTextureBasisUExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFTextureWebPExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFMaterialsTransmissionExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFMaterialsVolumeExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFMaterialsIorExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFMaterialsSpecularExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFLightsExtension( parser );

		} );

		this.register( ( parser ) {

			return new GLTFMeshoptCompression( parser );

		} );

  }

  load( String url, Function? onLoad, Function? onProgress, Function? onError ) {

    var scope = this;

    var resourcePath;

    if ( this.resourcePath != '' ) {

      resourcePath = this.resourcePath;

    } else if ( this.path != '' ) {

      resourcePath = this.path;

    } else {

      resourcePath = LoaderUtils.extractUrlBase( url );

    }

    // Tells the LoadingManager to track an extra item, which resolves after
    // the model is fully loaded. This means the count of items loaded will
    // be incorrect, but ensures manager.onLoad() does not fire early.
    this.manager.itemStart( url );

    Function _onError = ( e ) {

      if ( onError != null ) {

        onError( e );

      } else {

        print( e );

      }

      scope.manager.itemError( url );
      scope.manager.itemEnd( url );

    };

    var loader = new FileLoader( this.manager );

    loader.setPath( this.path );
    loader.setResponseType( 'arraybuffer' );
    loader.setRequestHeader( this.requestHeader );
    loader.setWithCredentials( this.withCredentials );

    loader.load( url, ( data ) {

      // try {

        scope.parse( data, path: resourcePath, onLoad: ( gltf ) {

          onLoad!( gltf );

          scope.manager.itemEnd( url );

        }, onError: _onError );

      // } catch ( e ) {

      //   _onError( e );

      // }

    }, onProgress, _onError );

  }

  setDRACOLoader( dracoLoader ) {

    this.dracoLoader = dracoLoader;
    return this;

  }

  setDDSLoader ( ddsLoader ) {

    this.ddsLoader = ddsLoader;
    return this;

  }

  setKTX2Loader ( ktx2Loader ) {

    this.ktx2Loader = ktx2Loader;
    return this;

  }

  setMeshoptDecoder ( meshoptDecoder ) {

    this.meshoptDecoder = meshoptDecoder;
    return this;

  }

  register ( Function callback ) {

    if ( this.pluginCallbacks.indexOf( callback ) == - 1 ) {

      this.pluginCallbacks.add( callback );

    }

    return this;

  }

  unregister( callback ) {

    if ( this.pluginCallbacks.indexOf( callback ) != - 1 ) {

      splice(this.pluginCallbacks, this.pluginCallbacks.indexOf( callback ), 1 );

    }

    return this;

  }

  parse(  data, {String? path, Function? onLoad, Function? onError} ) {

    var content;
    var extensions = {};
    var plugins = {};

    if ( data is String ) {

      content = data;

    } else {

      var magic = LoaderUtils.decodeText( Uint8List.view( data.buffer, 0, 4 ) );


      if ( magic == BINARY_EXTENSION_HEADER_MAGIC ) {

        // try {

          extensions[ EXTENSIONS["KHR_BINARY_GLTF"] ] = new GLTFBinaryExtension( data.buffer );


        // } catch ( error ) {

        //   if ( onError != null ) onError( error );
        //   return;

        // }

        content = extensions[ EXTENSIONS["KHR_BINARY_GLTF"] ].content;

      } else {

        content = LoaderUtils.decodeText( data );

      }

    }

    Map<String, dynamic> json = convert.jsonDecode( content );


    if ( json["asset"] == null || num.parse(json["asset"]["version"]) < 2.0 ) {

      if ( onError != null ) onError( 'THREE.GLTFLoader: Unsupported asset. glTF versions >= 2.0 are supported.' );
      return;

    }

    var parser = new GLTFParser( json, {

      "path": path != null ? path : this.resourcePath != null ? this.resourcePath : '',
      "crossOrigin": this.crossOrigin,
      "requestHeader": this.requestHeader,
      "manager": this.manager,
      "ktx2Loader": this.ktx2Loader,
      "meshoptDecoder": this.meshoptDecoder

    } );

    parser.fileLoader.setRequestHeader( this.requestHeader );

    for ( var i = 0; i < this.pluginCallbacks.length; i ++ ) {

      var plugin = this.pluginCallbacks[ i ]( parser );
      plugins[ plugin.name ] = plugin;

      // Workaround to avoid determining as unknown extension
      // in addUnknownExtensionsToUserData().
      // Remove this workaround if we move all the existing
      // extension handlers to plugin system
      extensions[ plugin.name ] = true;

    }

    if ( json["extensionsUsed"] != null ) {

      for ( var i = 0; i < json["extensionsUsed"].length; ++ i ) {

        var extensionName = json["extensionsUsed"][ i ];
        var extensionsRequired = json["extensionsRequired"] ?? [];

        if( extensionName == EXTENSIONS["KHR_MATERIALS_UNLIT"] ) {
          extensions[ extensionName ] = new GLTFMaterialsUnlitExtension();
        } else if(extensionName == EXTENSIONS["KHR_MATERIALS_PBR_SPECULAR_GLOSSINESS"]) {
            extensions[ extensionName ] = new GLTFMaterialsPbrSpecularGlossinessExtension();
        } else if(extensionName == EXTENSIONS["KHR_DRACO_MESH_COMPRESSION"]) {
            extensions[ extensionName ] = new GLTFDracoMeshCompressionExtension( json, this.dracoLoader );
        } else if(extensionName == EXTENSIONS["MSFT_TEXTURE_DDS"]) {
            extensions[ extensionName ] = new GLTFTextureDDSExtension( this.ddsLoader );
        } else if(extensionName == EXTENSIONS["KHR_TEXTURE_TRANSFORM"]) {
            extensions[ extensionName ] = new GLTFTextureTransformExtension();
        } else if(extensionName == EXTENSIONS["KHR_MESH_QUANTIZATION"]){
            extensions[ extensionName ] = new GLTFMeshQuantizationExtension();
        } else {
          if ( extensionsRequired.indexOf( extensionName ) >= 0 && plugins[ extensionName ] == null ) {
            print( 'THREE.GLTFLoader: Unknown extension ${extensionName}.' );
          }
        }

        // switch ( extensionName ) {
        //   case EXTENSIONS["KHR_MATERIALS_UNLIT"]:
        //     extensions[ extensionName ] = new GLTFMaterialsUnlitExtension();
        //     break;
        //   case EXTENSIONS.KHR_MATERIALS_PBR_SPECULAR_GLOSSINESS:
        //     extensions[ extensionName ] = new GLTFMaterialsPbrSpecularGlossinessExtension();
        //     break;
        //   case EXTENSIONS.KHR_DRACO_MESH_COMPRESSION:
        //     extensions[ extensionName ] = new GLTFDracoMeshCompressionExtension( json, this.dracoLoader );
        //     break;
        //   case EXTENSIONS.MSFT_TEXTURE_DDS:
        //     extensions[ extensionName ] = new GLTFTextureDDSExtension( this.ddsLoader );
        //     break;
        //   case EXTENSIONS.KHR_TEXTURE_TRANSFORM:
        //     extensions[ extensionName ] = new GLTFTextureTransformExtension();
        //     break;
        //   case EXTENSIONS.KHR_MESH_QUANTIZATION:
        //     extensions[ extensionName ] = new GLTFMeshQuantizationExtension();
        //     break;
        //   default:
        //     if ( extensionsRequired.indexOf( extensionName ) >= 0 && plugins[ extensionName ] == null ) {
        //       print( 'THREE.GLTFLoader: Unknown extension ${extensionName}.' );
        //     }
        // }

      }

    }

    parser.setExtensions( extensions );
    parser.setPlugins( plugins );
    parser.parse( onLoad, onError );

  }


}