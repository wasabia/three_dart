part of gltf_loader;

/* GLTF PARSER */
	
class GLTFParser {

  late FileLoader fileLoader;
  late Map<String, dynamic> json;
  late dynamic extensions;
  late Map plugins;
  late dynamic options;
  late GLTFRegistry cache;
  late Map associations;
  late Map primitiveCache;
  late Map meshCache;
  late Map cameraCache;
  late Map lightCache;
  late Map nodeNamesUsed;
  late TextureLoader textureLoader;

  Function? createNodeAttachment;
  Function? extendMaterialParams;
  Function? loadBufferView;

  GLTFParser( json, Map<String, dynamic>? options ) {
    this.json = json ?? {};
    this.extensions = {};
    this.plugins = {};
    this.options = options ?? {};

    // loader object cache
    this.cache = new GLTFRegistry();

    // associations between Three.js objects and glTF elements
    this.associations = new Map();

    // BufferGeometry caching
    this.primitiveCache = {};

    // Object3D instance caches
    this.meshCache = { "refs": {}, "uses": {} };
    this.cameraCache = { "refs": {}, "uses": {} };
    this.lightCache = { "refs": {}, "uses": {} };

    // Track node names, to ensure no duplicates
    this.nodeNamesUsed = {};

    // Use an ImageBitmapLoader if imageBitmaps are supported. Moves much of the
    // expensive work of uploading a texture to the GPU off the main thread.
    // if ( createImageBitmap != null && /Firefox/.test( navigator.userAgent ) == false ) {
    //   this.textureLoader = new ImageBitmapLoader( this.options.manager );
    // } else {
      this.textureLoader = new TextureLoader( this.options["manager"] );
    // }
    
    this.textureLoader.setCrossOrigin( this.options["crossOrigin"] );

    this.fileLoader = new FileLoader( this.options["manager"] );
    this.fileLoader.setResponseType( 'arraybuffer' );

    if ( this.options["crossOrigin"] == 'use-credentials' ) {
      this.fileLoader.setWithCredentials( true );
    }

    this.loadBufferView = loadBufferView2;
  }

  setExtensions( extensions ) {
    this.extensions = extensions;
  }

  setPlugins( plugins ) {
    this.plugins = plugins;
  }

  parse( onLoad, onError ) async {

    var parser = this;
    var json = this.json;
    var extensions = this.extensions;

    // Clear the loader cache
    this.cache.removeAll();

    // Mark the special nodes/meshes in json for efficient parse
    this._invokeAll( ( ext ) {

      return ext._markDefs != null && ext._markDefs() != null;

    } );

    final _scenes = await this.getDependencies( 'scene' );
    final _animations = await this.getDependencies( 'animation' );
    final _cameras = await this.getDependencies( 'camera' );
    
 
    var result = {
      "scene": _scenes[ json["scene"] ?? 0 ],
      "scenes": _scenes,
      "animations": _animations,
      "cameras": _cameras,
      "asset": json["asset"],
      "parser": parser,
      "userData": {}
    };

    addUnknownExtensionsToUserData( extensions, result, json );

    assignExtrasToUserData( result, json );

    onLoad( result );

  }

  /**
   * Marks the special nodes/meshes in json for efficient parse.
   */
  _markDefs() {

    var nodeDefs = this.json["nodes"] ?? [];
    var skinDefs = this.json["skins"] ?? [];
    var meshDefs = this.json["meshes"] ?? [];

    // Nothing in the node definition indicates whether it is a Bone or an
    // Object3D. Use the skins' joint references to mark bones.
    for ( var skinIndex = 0, skinLength = skinDefs.length; skinIndex < skinLength; skinIndex ++ ) {

      var joints = skinDefs[ skinIndex ]["joints"];

      for ( var i = 0, il = joints.length; i < il; i ++ ) {

        nodeDefs[ joints[ i ] ]["isBone"] = true;

      }

    }

    // Iterate over all nodes, marking references to shared resources,
    // as well as skeleton joints.
    for ( var nodeIndex = 0, nodeLength = nodeDefs.length; nodeIndex < nodeLength; nodeIndex ++ ) {

      Map<String, dynamic> nodeDef = nodeDefs[ nodeIndex ];

      if ( nodeDef["mesh"] != null ) {

        this._addNodeRef( this.meshCache, nodeDef["mesh"] );

        // Nothing in the mesh definition indicates whether it is
        // a SkinnedMesh or Mesh. Use the node's mesh reference
        // to mark SkinnedMesh if node has skin.
        if ( nodeDef["skin"] != null ) {
          meshDefs[ nodeDef["mesh"] ]["isSkinnedMesh"] = true;
        }

      }

      if ( nodeDef["camera"] != null ) {

        this._addNodeRef( this.cameraCache, nodeDef["camera"] );

      }

    }

  }

  /**
   * Counts references to shared node / Object3D resources. These resources
   * can be reused, or "instantiated", at multiple nodes in the scene
   * hierarchy. Mesh, Camera, and Light instances are instantiated and must
   * be marked. Non-scenegraph resources (like Materials, Geometries, and
   * Textures) can be reused directly and are not marked here.
   *
   * Example: CesiumMilkTruck sample model reuses "Wheel" meshes.
   */
  _addNodeRef( cache, index ) {

    if ( index == null ) return;

    if ( cache["refs"][ index ] == null ) {

      cache["refs"][ index ] = cache["uses"][ index ] = 0;

    }

    cache["refs"][ index ] ++;

  }

  /** Returns a reference to a shared resource, cloning it if necessary. */
  _getNodeRef( cache, index, object ) {

    if ( cache["refs"][ index ] <= 1 ) return object;

    var ref = object.clone();

    ref.name += '_instance_' + ( cache["uses"][ index ] ++ );

    return ref;

  }

  _invokeOne( Function func ) async {

    var extensions = this.plugins.values.toList();
    extensions.add( this );
  
    for ( var i = 0; i < extensions.length; i ++ ) {
      var result = await func( extensions[ i ] );
      if ( result != null ) return result;
    }

  }

  _invokeAll( Function func ) async {

    var extensions = this.plugins.values.toList();
    unshift(extensions, this );

    var results = [];

    for ( var i = 0; i < extensions.length; i ++ ) {

      var result = await func( extensions[ i ] );

      if ( result != null ) results.add( result );

    }

    return results;

  }


  /**
   * Requests the specified dependency asynchronously, with caching.
   * @param {string} type
   * @param {number} index
   * @return {Promise<Object3D|Material|THREE.Texture|AnimationClip|ArrayBuffer|Object>}
   */
  getDependency( type, index ) async {

    var cacheKey = '${type}:${index}';
    var dependency = this.cache.get( cacheKey );

    if ( dependency == null ) {

      switch ( type ) {

        case 'scene':
          dependency = await this.loadScene( index );
          break;

        case 'node':
          dependency = await this.loadNode( index );
          break;

        case 'mesh':
          dependency = await this._invokeOne( ( ext ) async {

            return ext.loadMesh != null ? await ext.loadMesh( index ) : null;

          } );
          break;

        case 'accessor':
          dependency = await this.loadAccessor( index );
          break;

        case 'bufferView':
          dependency = await this._invokeOne( ( ext ) async {

            return ext.loadBufferView != null ? await ext.loadBufferView( index ) : null;

          } );
          break;

        case 'buffer':
          dependency = await this.loadBuffer( index );
          break;

        case 'material':
          dependency = await this._invokeOne( ( ext ) async {

            return ext.loadMaterial != null ? await ext.loadMaterial( index ) : null;

          } );
          break;

        case 'texture':
          dependency = await this._invokeOne( ( ext ) async {

            return ext.loadTexture != null ? await ext.loadTexture( index ) : null;

          } );
          break;

        case 'skin':
          dependency = await this.loadSkin( index );
          break;

        case 'animation':
          dependency = await this.loadAnimation( index );
          break;

        case 'camera':
          dependency = await this.loadCamera( index );
          break;

        default:
          throw( 'GLTFParser getDependency Unknown type: ${type}' );

      }

      this.cache.add( cacheKey, dependency );

    }

    return dependency;

  }

  /**
   * Requests all dependencies of the specified type asynchronously, with caching.
   * @param {string} type
   * @return {Promise<Array<Object>>}
   */
  getDependencies( type ) async {

    var dependencies = this.cache.get( type );

    if(dependencies != null) {
      return dependencies;
    }

    var parser = this;
    var defs = this.json[ type + ( type == 'mesh' ? 'es' : 's' ) ] ?? [];

    List _dependencies = [];

    int l = defs.length;

    for(var i = 0; i < l; i++) {
      var _dep = await parser.getDependency( type, i );
      _dependencies.add(_dep);
    }

    this.cache.add( type, _dependencies );

    return _dependencies;

  }


  /**
   * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#buffers-and-buffer-views
   * @param {number} bufferIndex
   * @return {Promise<ArrayBuffer>}
   */
  loadBuffer( bufferIndex ) async {

    Map<String, dynamic> bufferDef = this.json["buffers"][ bufferIndex ];
    var loader = this.fileLoader;

    if ( bufferDef["type"] != null && bufferDef["type"] != 'arraybuffer' ) {

      throw( 'THREE.GLTFLoader: ${bufferDef["type"]} buffer type is not supported.' );

    }

    // If present, GLB container is required to be the first buffer.
    if ( bufferDef["uri"] == null && bufferIndex == 0 ) {

      return this.extensions[ EXTENSIONS["KHR_BINARY_GLTF"] ].body;

    }

    var options = this.options;

    
    final res = await loader.loadAsync( resolveURL( bufferDef["uri"], options["path"] ), null);


    return res;
  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#buffers-and-buffer-views
   * @param {number} bufferViewIndex
   * @return {Promise<ArrayBuffer>}
   */
  loadBufferView2( bufferViewIndex ) async {
    var bufferViewDef = this.json["bufferViews"][ bufferViewIndex ];
    var buffer = await this.getDependency( 'buffer', bufferViewDef["buffer"] );

    var byteLength = bufferViewDef["byteLength"] ?? 0;
    var byteOffset = bufferViewDef["byteOffset"] ?? 0;
  
    if(buffer is Uint8List) {
      return buffer.sublist(byteOffset, byteOffset + byteLength).buffer;
    } else {
      return Uint8List.view(buffer).sublist(byteOffset, byteOffset + byteLength).buffer;
    }
  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#accessors
   * @param {number} accessorIndex
   * @return {Promise<BufferAttribute|InterleavedBufferAttribute>}
   */
  loadAccessor( accessorIndex ) async {

    var parser = this;
    var json = this.json;

    Map<String, dynamic> accessorDef = this.json["accessors"][ accessorIndex ];

    if ( accessorDef["bufferView"] == null && accessorDef["sparse"] == null ) {

      // Ignore empty accessors, which may be used to declare runtime
      // information about attributes coming from another source (e.g. Draco
      // compression extension).
      return null;

    }


    var bufferView;
    if ( accessorDef["bufferView"] != null ) {
      bufferView = await this.getDependency( 'bufferView', accessorDef["bufferView"] );
    } else {
      bufferView = null;
    }


    var sparseIndicesBufferView;
    var sparseValuesBufferView;

    if ( accessorDef["sparse"] != null ) {
      final _sparse = accessorDef["sparse"];
      sparseIndicesBufferView = await this.getDependency( 'bufferView', _sparse["indices"]["bufferView"] );
      sparseValuesBufferView = await this.getDependency( 'bufferView', _sparse["values"]["bufferView"] );
    }



    int itemSize = WEBGL_TYPE_SIZES[ accessorDef["type"] ]!;
    var typedArray = GLTypeData(accessorDef["componentType"]);

    // For VEC3: itemSize is 3, elementBytes is 4, itemBytes is 12.
    var elementBytes = typedArray.getBytesPerElement();
    var itemBytes = elementBytes * itemSize;
    var byteOffset = accessorDef["byteOffset"] ?? 0;
    var byteStride = accessorDef["bufferView"] != null ? json["bufferViews"][ accessorDef["bufferView"] ]["byteStride"] : null;
    var normalized = accessorDef["normalized"] == true;
    var array;
    var bufferAttribute;

    // The buffer is not interleaved if the stride is the item size in bytes.
    if ( byteStride != null && byteStride != itemBytes ) {

      // Each "slice" of the buffer, as defined by 'count' elements of 'byteStride' bytes, gets its own InterleavedBuffer
      // This makes sure that IBA.count reflects accessor.count properly
      var ibSlice = Math.floor( byteOffset / byteStride );
      var ibCacheKey = 'InterleavedBuffer:${accessorDef["bufferView"]}:${accessorDef["componentType"]}:${ibSlice}:${accessorDef["count"]}';
      var ib = parser.cache.get( ibCacheKey );

      if ( ib == null ) {

        // array = TypedArray.view( bufferView, ibSlice * byteStride, accessorDef.count * byteStride / elementBytes );
        array = typedArray.view(bufferView, ibSlice * byteStride, accessorDef["count"] * byteStride / elementBytes);

        // Integer parameters to IB/IBA are in array elements, not bytes.
        ib = new InterleavedBuffer( array, byteStride / elementBytes );

        parser.cache.add( ibCacheKey, ib );

      }

      bufferAttribute = new InterleavedBufferAttribute( ib, itemSize, ( byteOffset % byteStride ) / elementBytes, normalized );

    } else {

      if ( bufferView == null ) {

        array = typedArray.createList( accessorDef["count"] * itemSize );

      } else {

        array = typedArray.view( bufferView, byteOffset, accessorDef["count"] * itemSize );

      }

      // bufferAttribute = BufferAttribute( array, itemSize, normalized );
      // 
      bufferAttribute = GLTypeData.createBufferAttribute(array, itemSize, normalized);

    }

    // https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#sparse-accessors
    if ( accessorDef["sparse"] != null ) {

      var itemSizeIndices = WEBGL_TYPE_SIZES["SCALAR"]!;
      var typedArrayIndices = GLTypeData( accessorDef["sparse"]["indices"]["componentType"] );

      var byteOffsetIndices = accessorDef["sparse"]["indices"]["byteOffset"] ?? 0;
      var byteOffsetValues = accessorDef["sparse"]["values"]["byteOffset"] ?? 0;

      var sparseIndices = typedArrayIndices.view( sparseIndicesBufferView, byteOffsetIndices, accessorDef["sparse"]["count"] * itemSizeIndices );
      var sparseValues = typedArray.view( sparseValuesBufferView, byteOffsetValues, accessorDef["sparse"]["count"] * itemSize );

      if ( bufferView != null ) {

        // Avoid modifying the original ArrayBuffer, if the bufferView wasn't initialized with zeroes.
        bufferAttribute = BufferAttribute( slice(bufferAttribute.array, 0).cast(), bufferAttribute.itemSize, bufferAttribute.normalized );

      }

      for ( var i = 0, il = sparseIndices.length; i < il; i ++ ) {

        var index = sparseIndices[ i ];

        bufferAttribute.setX( index, sparseValues[ i * itemSize ] );
        if ( itemSize >= 2 ) bufferAttribute.setY( index, sparseValues[ i * itemSize + 1 ] );
        if ( itemSize >= 3 ) bufferAttribute.setZ( index, sparseValues[ i * itemSize + 2 ] );
        if ( itemSize >= 4 ) bufferAttribute.setW( index, sparseValues[ i * itemSize + 3 ] );
        if ( itemSize >= 5 ) throw( 'THREE.GLTFLoader: Unsupported itemSize in sparse BufferAttribute.' );

      }

    }

    return bufferAttribute;

  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#textures
   * @param {number} textureIndex
   * @return {Promise<THREE.Texture>}
   */
  loadTexture( textureIndex ) {

    var parser = this;
    Map<String, dynamic> json = this.json;
    var options = this.options;

    Map<String, dynamic> textureDef = json["textures"][ textureIndex ];

    var textureExtensions = textureDef["extensions"] ?? {};

    var source;

    if ( textureExtensions[ EXTENSIONS["MSFT_TEXTURE_DDS"] ] != null ) {

      source = json["images"][ textureExtensions[ EXTENSIONS["MSFT_TEXTURE_DDS"] ]["source"] ];

    } else {

      source = json["images"][ textureDef["source"] ];

    }

    var loader;

    if ( source["uri"] != null ) {

      loader = options.manager.getHandler( source["uri"] );

    }

    if ( loader == null ) {

      loader = textureExtensions[ EXTENSIONS["MSFT_TEXTURE_DDS"] ] != null 
        ? parser.extensions[ EXTENSIONS["MSFT_TEXTURE_DDS"] ]["ddsLoader"]
        : this.textureLoader;

    }

    return this.loadTextureImage( textureIndex, source, loader );

  }


  loadTextureImage( textureIndex, Map<String, dynamic> source, loader ) async {

    print("GLTFParser.loadTextureImage todo debug implement ");

    var parser = this;
    var json = this.json;
    var options = this.options;

    var textureDef = json["textures"][ textureIndex ];

    // var URL = self.URL || self.webkitURL;

    var sourceURI = source["uri"];
    var isObjectURL = false;
    var hasAlpha = true;

    if ( source["mimeType"] == 'image/jpeg' ) hasAlpha = false;

    if ( source["bufferView"] != null ) {

      // Load binary image data from bufferView, if provided.
      
      var bufferView = await parser.getDependency( 'bufferView', source["bufferView"] );

      if ( source["mimeType"] == 'image/png' ) {

        // Inspect the PNG 'IHDR' chunk to determine whether the image could have an
        // alpha channel. This check is conservative — the image could have an alpha
        // channel with all values == 1, and the indexed type (colorType == 3) only
        // sometimes contains alpha.
        //
        // https://en.wikipedia.org/wiki/Portable_Network_Graphics#File_header
        var colorType = new ByteData.view( bufferView, 25, 1 ).getUint8( 0 );
        hasAlpha = colorType == 6 || colorType == 4 || colorType == 3;

      }

      isObjectURL = true;
      // var blob = new Blob( [ bufferView ], { type: source.mimeType } );
      // sourceURI = URL.createObjectURL( blob );

    }

    // return Promise.resolve( sourceURI ).then( function ( sourceURI ) {

    //   return new Promise( function ( resolve, reject ) {

    //     var onLoad = resolve;

    //     if ( loader.isImageBitmapLoader == true ) {

    //       onLoad = function ( imageBitmap ) {

    //         resolve( new CanvasTexture( imageBitmap ) );

    //       };

    //     }

    //     loader.load( resolveURL( sourceURI, options.path ), onLoad, null, reject );

    //   } );

    // } ).then( function ( texture ) {

    //   // Clean up resources and configure Texture.

    //   if ( isObjectURL == true ) {
    //     URL.revokeObjectURL( sourceURI );
    //   }

    //   texture.flipY = false;

    //   if ( textureDef.name ) texture.name = textureDef.name;

    //   // When there is definitely no alpha channel in the texture, set RGBFormat to save space.
    //   if ( ! hasAlpha ) texture.format = RGBFormat;

    //   var samplers = json.samplers ?? {};
    //   var sampler = samplers[ textureDef.sampler ] ?? {};

    //   texture.magFilter = WEBGL_FILTERS[ sampler.magFilter ] ?? LinearFilter;
    //   texture.minFilter = WEBGL_FILTERS[ sampler.minFilter ] ?? LinearMipmapLinearFilter;
    //   texture.wrapS = WEBGL_WRAPPINGS[ sampler.wrapS ] ?? RepeatWrapping;
    //   texture.wrapT = WEBGL_WRAPPINGS[ sampler.wrapT ] ?? RepeatWrapping;

    //   parser.associations[texture] = {
    //     "type": 'textures',
    //     "index": textureIndex
    //   };

    //   return texture;

    // } );
    // 
    
    return null;

  }

  /**
   * Asynchronously assigns a texture to the given material parameters.
   * @param {Object} materialParams
   * @param {string} mapName
   * @param {Object} mapDef
   * @return {Promise}
   */
  assignTexture( materialParams, mapName, Map<String, dynamic> mapDef ) async {

    var parser = this;

    var texture = await this.getDependency( 'texture', mapDef["index"] );

    
    // Materials sample aoMap from UV set 1 and other maps from UV set 0 - this can't be configured
    // However, we will copy UV set 0 to UV set 1 on demand for aoMap
    if ( mapDef["texCoord"] != null && mapDef["texCoord"] != 0 && ! ( mapName == 'aoMap' && mapDef["texCoord"] == 1 ) ) {

      print( 'THREE.GLTFLoader: Custom UV set ${mapDef["texCoord"]} for texture ${mapName} not yet supported.' );

    }

    if ( parser.extensions[ EXTENSIONS["KHR_TEXTURE_TRANSFORM"] ] != null ) {

      var transform = mapDef["extensions"] != null ? mapDef["extensions"][ EXTENSIONS["KHR_TEXTURE_TRANSFORM"] ] : null;

      if ( transform != null ) {

        var gltfReference = parser.associations[texture];
        texture = parser.extensions[ EXTENSIONS["KHR_TEXTURE_TRANSFORM"] ].extendTexture( texture, transform );
        parser.associations[texture] = gltfReference;

      }

    }

    materialParams[ mapName ] = texture;

  }

  /**
   * Assigns final material to a Mesh, Line, or Points instance. The instance
   * already has a material (generated from the glTF material options alone)
   * but reuse of the same glTF material may require multiple threejs materials
   * to accomodate different primitive types, defines, etc. New materials will
   * be created if necessary, and reused from a cache.
   * @param  {Object3D} mesh Mesh, Line, or Points instance.
   */
  assignFinalMaterial( mesh ) {

    var geometry = mesh.geometry;
    var material = mesh.material;

    bool useVertexTangents = geometry.attributes["tangent"] != null;
    bool useVertexColors = geometry.attributes["color"] != null;
    bool useFlatShading = geometry.attributes["normal"] == null;
    bool useSkinning = mesh.isSkinnedMesh == true;
    bool useMorphTargets = geometry.morphAttributes.keys.length > 0;
    bool useMorphNormals = useMorphTargets && geometry.morphAttributes["normal"] != null;

    if ( mesh.isPoints ) {

      var cacheKey = 'PointsMaterial:' + material.uuid;

      var pointsMaterial = this.cache.get( cacheKey );

      if ( pointsMaterial == null ) {

        pointsMaterial = new PointsMaterial({});
        pointsMaterial.copy( material );
        pointsMaterial.color.copy( material.color );
        pointsMaterial.map = material.map;
        pointsMaterial.sizeAttenuation = false; // glTF spec says points should be 1px

        this.cache.add( cacheKey, pointsMaterial );

      }

      material = pointsMaterial;

    } else if ( mesh.isLine ) {

      var cacheKey = 'LineBasicMaterial:' + material.uuid;

      var lineMaterial = this.cache.get( cacheKey );

      if ( lineMaterial == null ) {

        lineMaterial = new LineBasicMaterial({});
        lineMaterial.copy( material );
        lineMaterial.color.copy( material.color );

        this.cache.add( cacheKey, lineMaterial );

      }

      material = lineMaterial;

    }

    // Clone the material if it will be modified
    if ( useVertexTangents || useVertexColors || useFlatShading || useSkinning || useMorphTargets ) {

      var cacheKey = 'ClonedMaterial:' + material.uuid + ':';

      if ( material.type == "GLTFSpecularGlossinessMaterial" ) cacheKey += 'specular-glossiness:';
      if ( useSkinning ) cacheKey += 'skinning:';
      if ( useVertexTangents ) cacheKey += 'vertex-tangents:';
      if ( useVertexColors ) cacheKey += 'vertex-colors:';
      if ( useFlatShading ) cacheKey += 'flat-shading:';
      if ( useMorphTargets ) cacheKey += 'morph-targets:';
      if ( useMorphNormals ) cacheKey += 'morph-normals:';

      var cachedMaterial = this.cache.get( cacheKey );

      if ( cachedMaterial == null ) {

        cachedMaterial = material.clone();

        if ( useSkinning ) cachedMaterial.skinning = true;
        if ( useVertexTangents ) cachedMaterial.vertexTangents = true;
        if ( useVertexColors ) cachedMaterial.vertexColors = true;
        if ( useFlatShading ) cachedMaterial.flatShading = true;
        if ( useMorphTargets ) cachedMaterial.morphTargets = true;
        if ( useMorphNormals ) cachedMaterial.morphNormals = true;

        this.cache.add( cacheKey, cachedMaterial );

        this.associations[cachedMaterial] = this.associations[material];

      }

      material = cachedMaterial;

    }


    // workarounds for mesh and geometry

    if ( material.aoMap != null && geometry.attributes.uv2 == null && geometry.attributes.uv != null ) {

      geometry.setAttribute( 'uv2', geometry.attributes.uv );

    }

    // https://github.com/mrdoob/three.js/issues/11438#issuecomment-507003995
    if ( material.normalScale != null && ! useVertexTangents ) {

      material.normalScale.y = - material.normalScale.y;

    }

    if ( material.clearcoatNormalScale != null && ! useVertexTangents ) {

      material.clearcoatNormalScale.y = - material.clearcoatNormalScale.y;

    }

    mesh.material = material;

  }


  getMaterialType ( materialIndex ) {

    return MeshStandardMaterial;

  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#materials
   * @param {number} materialIndex
   * @return {Promise<Material>}
   */
  loadMaterial( materialIndex ) async {

    var parser = this;
    var json = this.json;
    var extensions = this.extensions;
    Map<String, dynamic> materialDef = json["materials"][ materialIndex ];

    var materialType;
    Map<String, dynamic> materialParams = {};
    Map<String, dynamic> materialExtensions = materialDef["extensions"] ?? {};

    List<Future> pending = [];

    if ( materialExtensions[ EXTENSIONS["KHR_MATERIALS_PBR_SPECULAR_GLOSSINESS"] ] != null ) {

      var sgExtension = extensions[ EXTENSIONS["KHR_MATERIALS_PBR_SPECULAR_GLOSSINESS"] ];
      materialType = sgExtension.getMaterialType(materialIndex);
      pending.add( sgExtension.extendParams( materialParams, materialDef, parser ) );

    } else if ( materialExtensions[ EXTENSIONS["KHR_MATERIALS_UNLIT"] ] != null ) {

      var kmuExtension = extensions[ EXTENSIONS["KHR_MATERIALS_UNLIT"] ];
      materialType = kmuExtension.getMaterialType(materialIndex);
      pending.add( kmuExtension.extendParams( materialParams, materialDef, parser ) );

    } else {

      // Specification:
      // https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#metallic-roughness-material

      Map<String, dynamic> metallicRoughness = materialDef["pbrMetallicRoughness"] ?? {};

      materialParams["color"] = new Color( 1.0, 1.0, 1.0 );
      materialParams["opacity"] = 1.0;

      if ( metallicRoughness["baseColorFactor"] is List ) {

        var array = metallicRoughness["baseColorFactor"];

        materialParams["color"].fromArray( array );
        materialParams["opacity"] = array[ 3 ];

      }

      if ( metallicRoughness["baseColorTexture"] != null ) {

        pending.add( parser.assignTexture( materialParams, 'map', metallicRoughness["baseColorTexture"] ) );

      }

      materialParams["metalness"] = metallicRoughness["metallicFactor"] != null ? metallicRoughness["metallicFactor"] : 1.0;
      materialParams["roughness"] = metallicRoughness["roughnessFactor"] != null ? metallicRoughness["roughnessFactor"] : 1.0;

      if ( metallicRoughness["metallicRoughnessTexture"] != null ) {

        pending.add( parser.assignTexture( materialParams, 'metalnessMap', metallicRoughness["metallicRoughnessTexture"] ) );
        pending.add( parser.assignTexture( materialParams, 'roughnessMap', metallicRoughness["metallicRoughnessTexture"] ) );

      }

      materialType =await this._invokeOne( ( ext ) async {

        return ext.getMaterialType != null ? await ext.getMaterialType( materialIndex ) : null;

      } );

      final _v = this._invokeAll( ( ext ) {
          return ext.extendMaterialParams != null && ext.extendMaterialParams( materialIndex, materialParams ) != null;
        } );

      pending.add(
        Future.sync(() => _v)
      );

    }

    if ( materialDef["doubleSided"] == true ) {

      materialParams["side"] = DoubleSide;

    }

    var alphaMode = materialDef["alphaMode"] ?? ALPHA_MODES["OPAQUE"];

    if ( alphaMode == ALPHA_MODES["BLEND"] ) {

      materialParams["transparent"] = true;

      // See: https://github.com/mrdoob/three.js/issues/17706
      materialParams["depthWrite"] = false;

    } else {

      materialParams["transparent"] = false;

      if ( alphaMode == ALPHA_MODES["MASK"] ) {

        materialParams["alphaTest"] = materialDef["alphaCutoff"] != null ? materialDef["alphaCutoff"] : 0.5;

      }

    }

    if ( materialDef["normalTexture"] != null && materialType != MeshBasicMaterial ) {

      pending.add( parser.assignTexture( materialParams, 'normalMap', materialDef["normalTexture"] ) );

      materialParams["normalScale"] = new Vector2( 1, 1 );

      if ( materialDef["normalTexture"]["scale"] != null ) {

        // materialParams["normalScale"].set( materialDef["normalTexture"]["scale"], materialDef["normalTexture"]["scale"] );
        materialParams["normalScale"][ materialDef["normalTexture"]["scale"] ] = materialDef["normalTexture"]["scale"];

      }

    }

    if ( materialDef["occlusionTexture"] != null && materialType != MeshBasicMaterial ) {

      pending.add( parser.assignTexture( materialParams, 'aoMap', materialDef["occlusionTexture"] ) );

      if ( materialDef["occlusionTexture"]["strength"] != null ) {

        materialParams["aoMapIntensity"] = materialDef["occlusionTexture"]["strength"];

      }

    }

    if ( materialDef["emissiveFactor"] != null && materialType != MeshBasicMaterial ) {

      materialParams["emissive"] = new Color(1,1,1).fromArray( materialDef["emissiveFactor"] );

    }

    if ( materialDef["emissiveTexture"] != null && materialType != MeshBasicMaterial ) {

      pending.add( parser.assignTexture( materialParams, 'emissiveMap', materialDef["emissiveTexture"] ) );

    }

    await Future.wait(pending);

    var material;

    if ( materialType == GLTFMeshStandardSGMaterial ) {

      material = extensions[ EXTENSIONS["KHR_MATERIALS_PBR_SPECULAR_GLOSSINESS"] ].createMaterial( materialParams );

    } else {
      material = createMaterialType( materialType, materialParams );
    }

    if ( materialDef["name"] != null ) material.name = materialDef["name"];

    // baseColorTexture, emissiveTexture, and specularGlossinessTexture use sRGB encoding.
    if ( material.map != null ) material.map.encoding = sRGBEncoding;
    if ( material.emissiveMap != null ) material.emissiveMap.encoding = sRGBEncoding;

    assignExtrasToUserData( material, materialDef );

    parser.associations[material] = { "type": 'materials', "index": materialIndex };

    if ( materialDef["extensions"] != null ) addUnknownExtensionsToUserData( extensions, material, materialDef );

    return material;
  }

  createMaterialType(materialType, Map<String, dynamic> materialParams) {


    if(materialType == GLTFMeshStandardSGMaterial){
      return GLTFMeshStandardSGMaterial(materialParams);
    } else if(materialType == MeshBasicMaterial) {
      return MeshBasicMaterial(materialParams);
    } else if(materialType == MeshPhysicalMaterial) {
      return MeshPhysicalMaterial(materialParams);
    } else if(materialType == MeshStandardMaterial) {
      return MeshStandardMaterial(materialParams);
    } else {
      throw("GLTFParser createMaterialType materialType: ${materialType.runtimeType.toString()} is not support ");
    }
  }

  /** When Object3D instances are targeted by animation, they need unique names. */
  createUniqueName( originalName ) {

    var sanitizedName = PropertyBinding.sanitizeNodeName( originalName ?? '' );

    var name = sanitizedName;

    for ( var i = 1; this.nodeNamesUsed[ name ] != null; ++ i ) {

      name = '${sanitizedName}_${i}';

    }

    this.nodeNamesUsed[ name ] = true;

    return name;

  }


  /**
   * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#geometry
   *
   * Creates BufferGeometries from primitives.
   *
   * @param {Array<GLTF.Primitive>} primitives
   * @return {Promise<Array<BufferGeometry>>}
   */
  loadGeometries( primitives ) {

    var parser = this;
    var extensions = this.extensions;
    var cache = this.primitiveCache;

    Function createDracoPrimitive = ( primitive ) async {
      var geometry = await extensions[ EXTENSIONS["KHR_DRACO_MESH_COMPRESSION"] ].decodePrimitive( primitive, parser );
      return addPrimitiveAttributes( geometry, primitive, parser );
    };

    List<Future> pending = [];

    for ( var i = 0, il = primitives.length; i < il; i ++ ) {

      Map<String, dynamic> primitive = primitives[ i ];
      var cacheKey = createPrimitiveKey( primitive );

      // See if we've already created this geometry
      var cached = cache[ cacheKey ];

      if ( cached != null ) {

        // Use the cached geometry if it exists
        pending.add( cached.promise );

      } else {

        var geometryPromise;

        if ( primitive["extensions"] != null && primitive["extensions"][ EXTENSIONS["KHR_DRACO_MESH_COMPRESSION"] ] != null ) {

          // Use DRACO geometry if available
          geometryPromise = createDracoPrimitive( primitive );

        } else {

          // Otherwise create a new geometry
          geometryPromise = addPrimitiveAttributes( new BufferGeometry(), primitive, parser );

        }

        // Cache this geometry
        cache[ cacheKey ] = { "primitive": primitive, "promise": geometryPromise };

        pending.add( geometryPromise );

      }

    }

    return Future.wait( pending );

  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#meshes
   * @param {number} meshIndex
   * @return {Promise<Group|Mesh|SkinnedMesh>}
   */
  loadMesh( meshIndex ) async {

    var parser = this;
    var json = this.json;
    var extensions = this.extensions;

    Map<String, dynamic> meshDef = json["meshes"][ meshIndex ];
    var primitives = meshDef["primitives"];

    List<Future> pending = [];

    for ( var i = 0, il = primitives.length; i < il; i ++ ) {

      var material = primitives[ i ]["material"] == null
        ? createDefaultMaterial( this.cache )
        : this.getDependency( 'material', primitives[ i ]["material"] );

      pending.add( Future.sync(() => material) );

    }

    pending.add( parser.loadGeometries( primitives ) );

    final results = await Future.wait(pending);

    var materials = slice(results, 0, results.length - 1 );
    var geometries = results[ results.length - 1 ];


    var meshes = [];

    for ( var i = 0, il = geometries.length; i < il; i ++ ) {

      var geometry = geometries[ i ];
      Map<String, dynamic> primitive = primitives[ i ];

      // 1. create Mesh

      var mesh;

      var material = materials[ i ];

      if ( primitive["mode"] == WEBGL_CONSTANTS["TRIANGLES"] ||
        primitive["mode"] == WEBGL_CONSTANTS["TRIANGLE_STRIP"] ||
        primitive["mode"] == WEBGL_CONSTANTS["TRIANGLE_FAN"] ||
        primitive["mode"] == null ) {

        // .isSkinnedMesh isn't in glTF spec. See ._markDefs()
        mesh = meshDef["isSkinnedMesh"] == true
          ? new SkinnedMesh( geometry, material )
          : new Mesh( geometry, material );

        if ( mesh.isSkinnedMesh == true && ! mesh.geometry.attributes["skinWeight"].normalized ) {

          // we normalize floating point skin weight array to fix malformed assets (see #15319)
          // it's important to skip this for non-float32 data since normalizeSkinWeights assumes non-normalized inputs
          mesh.normalizeSkinWeights();

        }

        if ( primitive["mode"] == WEBGL_CONSTANTS["TRIANGLE_STRIP"] ) {

          mesh.geometry = toTrianglesDrawMode( mesh.geometry, TriangleStripDrawMode );

        } else if ( primitive["mode"] == WEBGL_CONSTANTS["TRIANGLE_FAN"] ) {

          mesh.geometry = toTrianglesDrawMode( mesh.geometry, TriangleFanDrawMode );

        }

      } else if ( primitive["mode"] == WEBGL_CONSTANTS["LINES"] ) {

        mesh = new LineSegments( geometry, material );

      } else if ( primitive["mode"] == WEBGL_CONSTANTS["LINE_STRIP"] ) {

        mesh = new Line( geometry, material );

      } else if ( primitive["mode"] == WEBGL_CONSTANTS["LINE_LOOP"] ) {

        mesh = new LineLoop( geometry, material );

      } else if ( primitive["mode"] == WEBGL_CONSTANTS["POINTS"] ) {

        mesh = new Points( geometry, material );

      } else {

        throw( 'THREE.GLTFLoader: Primitive mode unsupported: ${primitive["mode"]}' );

      }

      if ( mesh.geometry.morphAttributes.keys.length > 0 ) {

        updateMorphTargets( mesh, meshDef );

      }

      mesh.name = parser.createUniqueName( meshDef["name"] ?? ( 'mesh_${meshIndex}' ) );

      assignExtrasToUserData( mesh, meshDef );

      if ( primitive["extensions"] != null ) addUnknownExtensionsToUserData( extensions, mesh, primitive );

      parser.assignFinalMaterial( mesh );

      meshes.add( mesh );

    }

    if ( meshes.length == 1 ) {

      return meshes[ 0 ];

    }

    var group = new Group();

    for ( var i = 0, il = meshes.length; i < il; i ++ ) {

      group.add( meshes[ i ] );

    }

    return group;

  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#cameras
   * @param {number} cameraIndex
   * @return {Promise<THREE.Camera>}
   */
  loadCamera( cameraIndex ) {

    var camera;
    Map<String, dynamic> cameraDef = this.json["cameras"][ cameraIndex ];
    var params = cameraDef[ cameraDef["type"] ];

    if ( params == null ) {

      print( 'THREE.GLTFLoader: Missing camera parameters.' );
      return;

    }

    if ( cameraDef["type"] == 'perspective' ) {

      camera = new PerspectiveCamera( fov: MathUtils.radToDeg( params.yfov ), aspect: params.aspectRatio ?? 1, near: params.znear ?? 1, far: params.zfar ?? 2e6 );

    } else if ( cameraDef["type"] == 'orthographic' ) {

      camera = new OrthographicCamera( left: - params.xmag, right: params.xmag, top: params.ymag, bottom: - params.ymag, near: params.znear, far: params.zfar );

    }

    if ( cameraDef["name"] != null ) camera.name = this.createUniqueName( cameraDef["name"] );

    assignExtrasToUserData( camera, cameraDef );

    return camera;

  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#skins
   * @param {number} skinIndex
   * @return {Promise<Object>}
   */
  loadSkin( skinIndex ) async {

    var skinDef = this.json["skins"][ skinIndex ];

    var skinEntry = { "joints": skinDef["joints"] };

    if ( skinDef["inverseBindMatrices"] == null ) {

      return skinEntry;

    }

    var accessor = await this.getDependency( 'accessor', skinDef["inverseBindMatrices"] );

    skinEntry["inverseBindMatrices"] = accessor;
    return skinEntry;
  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#animations
   * @param {number} animationIndex
   * @return {Promise<AnimationClip>}
   */
  loadAnimation( animationIndex ) async {

    var json = this.json;

    Map<String, dynamic> animationDef = json["animations"][ animationIndex ];

    List<Future> pendingNodes = [];
    List<Future> pendingInputAccessors = [];
    List<Future> pendingOutputAccessors = [];
    List<Future> pendingSamplers = [];
    List<Future> pendingTargets = [];

    for ( var i = 0, il = animationDef["channels"].length; i < il; i ++ ) {

      Map<String, dynamic> channel = animationDef["channels"][ i ];
      Map<String, dynamic> sampler = animationDef["samplers"][ channel["sampler"] ];
      Map<String, dynamic> target = channel["target"];
      var name = target["node"] != null ? target["node"] : target["id"]; // NOTE: target.id is deprecated.
      var input = animationDef["parameters"] != null ? animationDef["parameters"][ sampler["input"] ] : sampler["input"];
      var output = animationDef["parameters"] != null ? animationDef["parameters"][ sampler["output"] ] : sampler["output"];

      pendingNodes.add( this.getDependency( 'node', name ) );
      pendingInputAccessors.add( this.getDependency( 'accessor', input ) );
      pendingOutputAccessors.add( this.getDependency( 'accessor', output ) );
      pendingSamplers.add( Future.sync(() => sampler) );
      pendingTargets.add( Future.sync(() => target) );

    }

    final dependencies = await Future.wait(
      [
        Future.wait(pendingNodes),
        Future.wait(pendingInputAccessors),
        Future.wait(pendingOutputAccessors),
        Future.wait(pendingSamplers),
        Future.wait(pendingTargets)
      ]
    );

    var nodes = dependencies[ 0 ];
    var inputAccessors = dependencies[ 1 ];
    var outputAccessors = dependencies[ 2 ];
    var samplers = dependencies[ 3 ];
    var targets = dependencies[ 4 ];

    List<KeyframeTrack> tracks = [];

    for ( var i = 0, il = nodes.length; i < il; i ++ ) {

      var node = nodes[ i ];
      var inputAccessor = inputAccessors[ i ];
      var outputAccessor = outputAccessors[ i ];
      Map<String, dynamic> sampler = samplers[ i ];
      Map<String, dynamic> target = targets[ i ];

      if ( node == null ) continue;

      node.updateMatrix();
      node.matrixAutoUpdate = true;

      var typedKeyframeTrack = TypedKeyframeTrack( PATH_PROPERTIES.getValue( target["path"] ) );

      

      var targetName = node.name != null ? node.name : node.uuid;

      var interpolation = sampler["interpolation"] != null ? INTERPOLATION[ sampler["interpolation"] ] : InterpolateLinear;

      var targetNames = [];

      if ( PATH_PROPERTIES.getValue( target["path"] ) == PATH_PROPERTIES.weights ) {

        // Node may be a Group (glTF mesh with several primitives) or a Mesh.
        node.traverse( ( object ) {

          if ( object.isMesh == true && object.morphTargetInfluences != null ) {

            targetNames.add( object.name != null ? object.name : object.uuid );

          }

        } );

      } else {

        targetNames.add( targetName );

      }

      var outputArray = outputAccessor.array;

      if ( outputAccessor.normalized ) {

        var scale;

        if ( outputArray.runtimeType == Int8List ) {

          scale = 1 / 127;

        } else if ( outputArray.runtimeType == Uint8List ) {

          scale = 1 / 255;

        } else if ( outputArray.runtimeType == Int16List ) {

          scale = 1 / 32767;

        } else if ( outputArray.runtimeType == Uint16List ) {

          scale = 1 / 65535;

        } else {

          throw( 'THREE.GLTFLoader: Unsupported output accessor component type.' );

        }

        var scaled = Float32List( outputArray.length );

        for ( var j = 0, jl = outputArray.length; j < jl; j ++ ) {

          scaled[ j ] = outputArray[ j ] * scale;

        }

        outputArray = scaled;

      }

      for ( var j = 0, jl = targetNames.length; j < jl; j ++ ) {

        var track = typedKeyframeTrack.createTrack(
          targetNames[ j ] + '.' + PATH_PROPERTIES.getValue( target["path"] ),
          inputAccessor.array,
          outputArray,
          interpolation
        );

        // Override interpolation with custom factory method.
        if ( sampler["interpolation"] == 'CUBICSPLINE' ) {

          // track.createInterpolant = ( result ) {
          //   // A CUBICSPLINE keyframe in glTF has three output values for each input value,
          //   // representing inTangent, splineVertex, and outTangent. As a result, track.getValueSize()
          //   // must be divided by three to get the interpolant's sampleSize argument.
          //   return new GLTFCubicSplineInterpolant( this.times, this.values, this.getValueSize() / 3, result );
          // };

          track.setCreateInterpolant();

          // Mark as CUBICSPLINE. `track.getInterpolation()` doesn't support custom interpolants.
          track.createInterpolant.isInterpolantFactoryMethodGLTFCubicSpline = true;

        }

        tracks.add( track );

      }

    }

    var name = animationDef["name"] != null ? animationDef["name"] : 'animation_${animationIndex}';

    return new AnimationClip( name, duration: -1, tracks: tracks );

  }

  /**
   * Specification: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#nodes-and-hierarchy
   * @param {number} nodeIndex
   * @return {Promise<Object3D>}
   */
  loadNode( nodeIndex ) async {

    var json = this.json;
    var extensions = this.extensions;
    var parser = this;

    Map<String, dynamic> nodeDef = json["nodes"][ nodeIndex ];

    // reserve node's name before its dependencies, so the root has the intended name.
    var nodeName = nodeDef["name"] != null ? parser.createUniqueName( nodeDef["name"] ) : '';


    var pending = [];

    if ( nodeDef["mesh"] != null ) {

      var mesh = await parser.getDependency( 'mesh', nodeDef["mesh"] );

      var node = await parser._getNodeRef( parser.meshCache, nodeDef["mesh"], mesh );

      // if weights are provided on the node, override weights on the mesh.
      if ( nodeDef["weights"] != null ) {

        node.traverse( ( o ) {

          if ( ! o.isMesh ) return;

          for ( var i = 0, il = nodeDef["weights"].length; i < il; i ++ ) {

            o.morphTargetInfluences[ i ] = nodeDef["weights"][ i ];

          }

        } );

      }

      pending.add(node);

    }

    if ( nodeDef["camera"] != null ) {

      var camera = await parser.getDependency( 'camera', nodeDef["camera"] );

      pending.add( await parser._getNodeRef( parser.cameraCache, nodeDef["camera"], camera ) );

    }

    // parser._invokeAll( ( ext ) async {
    //   return ext.createNodeAttachment != null ? await ext.createNodeAttachment( nodeIndex ) : null;
    // } ).forEach( ( promise ) {
    //   pending.add( promise );
    // } );
    
    List _results = await parser._invokeAll( ( ext ) async {
        return ext.createNodeAttachment != null ? await ext.createNodeAttachment( nodeIndex ) : null;
      } );

    var objects = [];

    pending.forEach((element) {
      objects.add(element);
    });

    _results.forEach((element) {
      objects.add(element);
    });

    var node;

    // .isBone isn't in glTF spec. See ._markDefs
    if ( nodeDef["isBone"] == true ) {

      node = new Bone();

    } else if ( objects.length > 1 ) {

      node = new Group();

    } else if ( objects.length == 1 ) {

      node = objects[ 0 ];

    } else {

      node = new Object3D();

    }


    if ( objects.length == 0 || node != objects[ 0 ] ) {

      for ( var i = 0, il = objects.length; i < il; i ++ ) {

        node.add( objects[ i ] );

      }

    }

    if ( nodeDef["name"] != null ) {

      node.userData["name"] = nodeDef["name"];
      node.name = nodeName;

    }

    assignExtrasToUserData( node, nodeDef );

    if ( nodeDef["extensions"] != null ) addUnknownExtensionsToUserData( extensions, node, nodeDef );

    if ( nodeDef["matrix"] != null ) {

      var matrix = new Matrix4();
      matrix.fromArray( List<num?>.from(nodeDef["matrix"]) );
      node.applyMatrix4( matrix );
    } else {
      if ( nodeDef["translation"] != null ) {
        node.position.fromArray( List<num?>.from(nodeDef["translation"]) );
      }

      if ( nodeDef["rotation"] != null ) {
        node.quaternion.fromArray( List<num?>.from(nodeDef["rotation"]) );
      }

      if ( nodeDef["scale"] != null ) {
        node.scale.fromArray( List<num?>.from(nodeDef["scale"]) );
      }


  
    }

    parser.associations[node] = { "type": 'nodes', "index": nodeIndex };

    return node;
  }


  /**
   * Specification: https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#scenes
   * @param {number} sceneIndex
   * @return {Promise<Group>}
   */
  
  buildNodeHierachy( nodeId, parentObject, json, parser ) async {

    Map<String, dynamic> nodeDef = json["nodes"][ nodeId ];

    var node = await parser.getDependency( 'node', nodeId );


    if ( nodeDef["skin"] != null ) {
      
      // build skeleton here as well

      var skinEntry;

      var skin = await parser.getDependency( 'skin', nodeDef["skin"] );
      skinEntry = skin;


      var jointNodes = [];

      for ( var i = 0, il = skinEntry["joints"].length; i < il; i ++ ) {

        var _node = await parser.getDependency( 'node', skinEntry["joints"][ i ] );

        jointNodes.add( _node );

      }


      node.traverse( ( mesh ) {

        if ( ! mesh.isMesh ) return;

        List<Bone> bones = [];
        List<Matrix4> boneInverses = [];

        for ( var j = 0, jl = jointNodes.length; j < jl; j ++ ) {

          var jointNode = jointNodes[ j ];

          if ( jointNode != null ) {

            bones.add( jointNode );

     
            var mat = new Matrix4();

            if ( skinEntry["inverseBindMatrices"] != null ) {

              mat.fromArray( skinEntry["inverseBindMatrices"].array, offset: j * 16 );

            }

           
            boneInverses.add( mat );

          } else {

            print( 'THREE.GLTFLoader: Joint "%s" could not be found. ${skinEntry["joints"][ j ]}' );

          }

        }

        mesh.bind( new Skeleton( bones: bones, boneInverses: boneInverses ), mesh.matrixWorld );

      } );
    } 


  

    // build node hierachy

    parentObject.add( node );


 
    if ( nodeDef["children"] != null ) {

      var children = nodeDef["children"];

      for ( var i = 0, il = children.length; i < il; i ++ ) {

        var child = children[ i ];
        await buildNodeHierachy( child, node, json, parser );

      }

    }


  }

  loadScene( sceneIndex ) async {

    var json = this.json;
    var extensions = this.extensions;
    Map<String, dynamic> sceneDef = this.json["scenes"][ sceneIndex ];
    var parser = this;

    // Loader returns Group, not Scene.
    // See: https://github.com/mrdoob/three.js/issues/18342#issuecomment-578981172
    var scene = new Group();
    if ( sceneDef["name"] != null ) scene.name = parser.createUniqueName( sceneDef["name"] );

    assignExtrasToUserData( scene, sceneDef );

    if ( sceneDef["extensions"] != null ) addUnknownExtensionsToUserData( extensions, scene, sceneDef );

    var nodeIds = sceneDef["nodes"] ?? [];


    for ( var i = 0, il = nodeIds.length; i < il; i ++ ) {
      await buildNodeHierachy( nodeIds[ i ], scene, json, parser );
    }


    return scene;

  }




}
//class GLTFParser end...


class TypedKeyframeTrack {
  late String path;

  TypedKeyframeTrack(String path) {
    this.path = path;
  }


  createTrack(v0, v1, v2, v3) {
    switch ( this.path ) {

      case PATH_PROPERTIES.weights:

        return NumberKeyframeTrack(v0, v1, v2, v3);
        break;
      case PATH_PROPERTIES.rotation:

        return QuaternionKeyframeTrack(v0, v1, v2, v3);
        break;

      case PATH_PROPERTIES.position:
      case PATH_PROPERTIES.scale:
      default:

        return VectorKeyframeTrack(v0, v1, v2, v3);
        break;

    }
  }


}