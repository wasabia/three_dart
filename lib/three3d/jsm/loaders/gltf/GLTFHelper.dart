part of gltf_loader;

/*********************************/
/********** INTERNALS ************/
/*********************************/

/* CONSTANTS */

var WEBGL_CONSTANTS = {
  "FLOAT": 5126,
  //FLOAT_MAT2: 35674,
  "FLOAT_MAT3": 35675,
  "FLOAT_MAT4": 35676,
  "FLOAT_VEC2": 35664,
  "FLOAT_VEC3": 35665,
  "FLOAT_VEC4": 35666,
  "LINEAR": 9729,
  "REPEAT": 10497,
  "SAMPLER_2D": 35678,
  "POINTS": 0,
  "LINES": 1,
  "LINE_LOOP": 2,
  "LINE_STRIP": 3,
  "TRIANGLES": 4,
  "TRIANGLE_STRIP": 5,
  "TRIANGLE_FAN": 6,
  "UNSIGNED_BYTE": 5121,
  "UNSIGNED_SHORT": 5123
};

class GLTypeData {

  late int type;

  GLTypeData(int type) {
    this.type = type;
  }

  getBytesPerElement() {
    return WEBGL_COMPONENT_TYPES_BYTES_PER_ELEMENT[type];
  }

  view(buffer, offset, length) {
    if(type == 5120) {
      return Int8List.view(buffer, offset, length);
    } else if(type == 5121) {
      return Uint8List.view(buffer, offset, length);
    } else if(type == 5122) {
      return Int16List.view(buffer, offset, length);
    } else if(type == 5123) {
      return Uint16List.view(buffer, offset, length);
    } else if(type == 5125) {
      return Uint32List.view(buffer, offset, length);
    } else if(type == 5126) {
      return Float32List.view(buffer, offset, length);
    } else {
      throw(" GLTFHelper GLTypeData view type: ${type} is not support ...");
    }
  }

  createList(int len) {
    if(type == 5120) {
      return Int8List(len);
    } else if(type == 5121) {
      return Uint8List(len);
    } else if(type == 5122) {
      return Int16List( len);
    } else if(type == 5123) {
      return Uint16List(len);
    } else if(type == 5125) {
      return Uint32List(len);
    } else if(type == 5126) {
      return Float32List( len);
    } else {
      throw(" GLTFHelper GLTypeData  createList type: ${type} is not support ...");
    }
  }

  static createBufferAttribute(array, itemSize, normalized) {
    if(array.runtimeType == Int8List) {
      return Int8BufferAttribute(array, itemSize, normalized);
    } else if(array.runtimeType == Uint8List) {
      return Uint8BufferAttribute(array, itemSize, normalized);
    } else if(array.runtimeType == Int16List) {
      return Int16BufferAttribute(array, itemSize, normalized);
    } else if(array.runtimeType == Uint16List) {
      return Uint16BufferAttribute(array, itemSize, normalized);
    } else if(array.runtimeType == Uint32List) {
      return Uint32BufferAttribute(array, itemSize, normalized);
    } else if(array.runtimeType == Float32List) {
      return Float32BufferAttribute(array, itemSize, normalized);
    } else {
      throw("GLTFHelper createBufferAttribute  array.runtimeType : ${array.runtimeType} is not support yet");
    }
  }

}

var WEBGL_COMPONENT_TYPES = {
  5120: Int8List,
  5121: Uint8List,
  5122: Int16List,
  5123: Uint16List,
  5125: Uint32List,
  5126: Float32List
};


var WEBGL_COMPONENT_TYPES_BYTES_PER_ELEMENT = {
  5120: Int8List.bytesPerElement,
  5121: Uint8List.bytesPerElement,
  5122: Int16List.bytesPerElement,
  5123: Uint16List.bytesPerElement,
  5125: Uint32List.bytesPerElement,
  5126: Float32List.bytesPerElement
};


var WEBGL_FILTERS = {
  9728: NearestFilter,
  9729: LinearFilter,
  9984: NearestMipmapNearestFilter,
  9985: LinearMipmapNearestFilter,
  9986: NearestMipmapLinearFilter,
  9987: LinearMipmapLinearFilter
};

var WEBGL_WRAPPINGS = {
  33071: ClampToEdgeWrapping,
  33648: MirroredRepeatWrapping,
  10497: RepeatWrapping
};

var WEBGL_TYPE_SIZES = {
  'SCALAR': 1,
  'VEC2': 2,
  'VEC3': 3,
  'VEC4': 4,
  'MAT2': 4,
  'MAT3': 9,
  'MAT4': 16
};

var ATTRIBUTES = {
  "POSITION": 'position',
  "NORMAL": 'normal',
  "TANGENT": 'tangent',
  "TEXCOORD_0": 'uv',
  "TEXCOORD_1": 'uv2',
  "COLOR_0": 'color',
  "WEIGHTS_0": 'skinWeight',
  "JOINTS_0": 'skinIndex',
};

class PATH_PROPERTIES {
  static const String scale = 'scale';
  static const String translation = 'position';
  static const String rotation = 'quaternion';
  static const String weights = 'morphTargetInfluences';
  static const String position = 'position';

  static getValue(String k) {
    if(k == "scale") {
      return scale;
    } else if(k == "translation") {
      return translation;
    } else if(k == "rotation") {
      return rotation;
    } else if(k == "weights") {
      return weights;  
    } else if(k == "position") {
      return position;
    } else {
      throw("GLTFHelper PATH_PROPERTIES getValue k: ${k} is not support ");    
    }
  }
}

var INTERPOLATION = {
  "CUBICSPLINE": null, // We use a custom interpolant (GLTFCubicSplineInterpolation) for CUBICSPLINE tracks. Each
                          // keyframe track will be initialized with a default interpolation type, then modified.
  "LINEAR": InterpolateLinear,
  "STEP": InterpolateDiscrete
};

var ALPHA_MODES = {
  "OPAQUE": 'OPAQUE',
  "MASK": 'MASK',
  "BLEND": 'BLEND'
};

/* UTILITY FUNCTIONS */

Function resolveURL = ( String url, String path ) {

  // Invalid URL
  // if ( typeof url != 'string' || url == '' ) return '';
  if ( url == '' ) return '';

  // Host Relative URL
  final _reg1 = RegExp("^https?:\/\/", caseSensitive: false);
  if ( _reg1.hasMatch( path ) && RegExp("^\/", caseSensitive: false).hasMatch( url ) ) {

    final _reg2 = RegExp("(^https?:\/\/[^\/]+).*", caseSensitive: false);

    final matches = _reg2.allMatches(path);

    matches.forEach((_match) {
      path = path.replaceFirst(_match.group(0)!, _match.group(1)!);
    });

    print("GLTFHelper.resolveURL todo debug  ");
    // path = path.replace( RegExp("(^https?:\/\/[^\/]+).*", caseSensitive: false), '$1' );

  }

  // Absolute URL http://,https://,//
  if ( RegExp("^(https?:)?\/\/", caseSensitive: false).hasMatch( url ) ) return url;

  // Data URI
  if ( RegExp(r"^data:.*,.*$", caseSensitive: false).hasMatch( url ) ) return url;

  // Blob URL
  if ( RegExp(r"^blob:.*$", caseSensitive: false).hasMatch( url ) ) return url;

  // Relative URL
  return path + url;

};

/**
 * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#default-material
 */
Function createDefaultMaterial = ( GLTFRegistry cache ) {

  if ( cache.get( 'DefaultMaterial' ) == null ) {

    cache.add(
      "DefaultMaterial", 
      new MeshStandardMaterial( {
        "color": 0xFFFFFF,
        "emissive": 0x000000,
        "metalness": 1,
        "roughness": 1,
        "transparent": false,
        "depthTest": true,
        "side": FrontSide
      } )
    );

  }

  return cache.get("DefaultMaterial");

};

Function addUnknownExtensionsToUserData = ( knownExtensions, object, Map<String, dynamic> objectDef ) {

  // Add unknown glTF extensions to an object's userData.

  if(objectDef["extensions"] != null) {
    objectDef["extensions"].forEach(( name, _value ) {
      if ( knownExtensions[ name ] == null ) {
        object.userData["gltfExtensions"] = object.userData["gltfExtensions"] ?? {};
        object.userData["gltfExtensions"][ name ] = objectDef["extensions"][ name ];
      }
    });
  }
  

};

/**
 * @param {Object3D|Material|BufferGeometry} object
 * @param {GLTF.definition} gltfDef
 */
Function assignExtrasToUserData = ( object, gltfDef ) {


  if ( gltfDef["extras"] != null ) {

    if ( gltfDef["extras"] is Map ) {

      object.userData.addAll(gltfDef["extras"]);

    } else {

      print( 'THREE.GLTFLoader: Ignoring primitive type .extras, ${gltfDef["extras"]}' );

    }

  }

};

/**
 * Specification: https://github.com/KhronosGroup/glTF/blob/master/specification/2.0/README.md#morph-targets
 *
 * @param {BufferGeometry} geometry
 * @param {Array<GLTF.Target>} targets
 * @param {GLTFParser} parser
 * @return {Promise<BufferGeometry>}
 */
Function addMorphTargets = ( geometry, targets, parser ) async {

  var hasMorphPosition = false;
  var hasMorphNormal = false;

  for ( var i = 0, il = targets.length; i < il; i ++ ) {

    var target = targets[ i ];

    if ( target["POSITION"] != null ) hasMorphPosition = true;
    if ( target["NORMAL"] != null ) hasMorphNormal = true;

    if ( hasMorphPosition && hasMorphNormal ) break;

  }

  if ( ! hasMorphPosition && ! hasMorphNormal ) return geometry;


  List<BufferAttribute> morphPositions = [];
  List<BufferAttribute> morphNormals = [];

  for ( var i = 0, il = targets.length; i < il; i ++ ) {

    var target = targets[ i ];

    if ( hasMorphPosition ) {

      var _position = target["POSITION"] != null
        ? await parser.getDependency( 'accessor', target["POSITION"] )
        : geometry.attributes["position"];

      morphPositions.add(_position);  
    }

    if ( hasMorphNormal ) {

      var _normal = target["NORMAL"] != null
        ? await parser.getDependency( 'accessor', target["NORMAL"] )
        : geometry.attributes["normal"];

      morphNormals.add(_normal);

    }

  }


  if ( hasMorphPosition ) geometry.morphAttributes["position"] = morphPositions;
  if ( hasMorphNormal ) geometry.morphAttributes["normal"] = morphNormals;
  geometry.morphTargetsRelative = true;

  return geometry;

};

/**
 * @param {Mesh} mesh
 * @param {GLTF.Mesh} meshDef
 */
Function updateMorphTargets = ( mesh, Map<String, dynamic> meshDef ) {

  mesh.updateMorphTargets();

  if ( meshDef["weights"] != null ) {

    for ( var i = 0, il = meshDef["weights"].length; i < il; i ++ ) {

      mesh.morphTargetInfluences[ i ] = meshDef["weights"][ i ];

    }

  }

  // .extras has user-defined data, so check that .extras.targetNames is an array.
  if ( meshDef["extras"] != null && meshDef["extras"]["targetNames"] is List ) {

    var targetNames = meshDef["extras"]["targetNames"];

    if ( mesh.morphTargetInfluences.length == targetNames.length ) {

      mesh.morphTargetDictionary = Map<String, dynamic>();

      for ( var i = 0, il = targetNames.length; i < il; i ++ ) {

        mesh.morphTargetDictionary[ targetNames[ i ] ] = i;

      }

    } else {

      print( 'THREE.GLTFLoader: Invalid extras.targetNames length. Ignoring names.' );

    }

  }

};

Function createPrimitiveKey = ( Map<String, dynamic> primitiveDef ) {

  var dracoExtension = primitiveDef["extensions"] != null ? primitiveDef["extensions"][ EXTENSIONS["KHR_DRACO_MESH_COMPRESSION"]! ] : null;
  var geometryKey;

  if ( dracoExtension != null ) {

    geometryKey = 'draco:${dracoExtension["bufferView"]}:${dracoExtension["indices"]}:${createAttributesKey( dracoExtension["attributes"] )}';

  } else {
    geometryKey = '${primitiveDef["indices"]}:${createAttributesKey( primitiveDef["attributes"] )}:${primitiveDef["mode"]}';

  }

  return geometryKey;

};

Function createAttributesKey = ( Map<String, dynamic> attributes ) {

  var attributesKey = '';

  var keys = attributes.keys.toList();
  keys.sort();

  for ( var i = 0, il = keys.length; i < il; i ++ ) {

    attributesKey += '${keys[ i ]}:${attributes[ keys[ i ] ]};';

  }

  return attributesKey;

};







/**
 * @param {BufferGeometry} geometry
 * @param {GLTF.Primitive} primitiveDef
 * @param {GLTFParser} parser
 */
Function computeBounds = ( geometry, Map<String, dynamic> primitiveDef, GLTFParser parser ) {

  Map<String, dynamic> attributes = primitiveDef["attributes"];

  var box = new Box3(null, null);

  if ( attributes["POSITION"] != null ) {

    var accessor = parser.json["accessors"][ attributes["POSITION"] ];

    var min = accessor["min"];
    var max = accessor["max"];

    // glTF requires 'min' and 'max', but VRM (which extends glTF) currently ignores that requirement.

    if ( min != null && max != null ) {

      box.set(
        new Vector3( min[ 0 ], min[ 1 ], min[ 2 ] ),
        new Vector3( max[ 0 ], max[ 1 ], max[ 2 ] ) );

    } else {

      print( 'THREE.GLTFLoader: Missing min/max properties for accessor POSITION.' );

      return;

    }

  } else {

    return;

  }

  var targets = primitiveDef["targets"];

  if ( targets != null ) {

    var maxDisplacement = new Vector3.init();
    var vector = new Vector3.init();

    for ( var i = 0, il = targets.length; i < il; i ++ ) {

      var target = targets[ i ];

      if ( target["POSITION"] != null ) {

        var accessor = parser.json["accessors"][ target["POSITION"] ];
        var min = accessor["min"];
        var max = accessor["max"];

        // glTF requires 'min' and 'max', but VRM (which extends glTF) currently ignores that requirement.

        if ( min != null && max != null ) {

          // we need to get max of absolute components because target weight is [-1,1]
          vector.setX( Math.max( Math.abs( min[ 0 ] ), Math.abs( max[ 0 ] ) ) );
          vector.setY( Math.max( Math.abs( min[ 1 ] ), Math.abs( max[ 1 ] ) ) );
          vector.setZ( Math.max( Math.abs( min[ 2 ] ), Math.abs( max[ 2 ] ) ) );

          // Note: this assumes that the sum of all weights is at most 1. This isn't quite correct - it's more conservative
          // to assume that each target can have a max weight of 1. However, for some use cases - notably, when morph targets
          // are used to implement key-frame animations and as such only two are active at a time - this results in very large
          // boxes. So for now we make a box that's sometimes a touch too small but is hopefully mostly of reasonable size.
          maxDisplacement.max( vector );

        } else {

          print( 'THREE.GLTFLoader: Missing min/max properties for accessor POSITION.' );

        }

      }

    }

    // As per comment above this box isn't conservative, but has a reasonable size for a very large number of morph targets.
    box.expandByVector( maxDisplacement );

  }

  geometry.boundingBox = box;

  var sphere = new Sphere(null, null);

  box.getCenter( sphere.center );
  sphere.radius = box.min.distanceTo( box.max ) / 2;

  geometry.boundingSphere = sphere;

};

/**
 * @param {BufferGeometry} geometry
 * @param {GLTF.Primitive} primitiveDef
 * @param {GLTFParser} parser
 * @return {Promise<BufferGeometry>}
 */
Function addPrimitiveAttributes = ( geometry, Map<String, dynamic> primitiveDef, GLTFParser parser ) async {

  var attributes = primitiveDef["attributes"];

  List<Future> pending = [];

  Function assignAttributeAccessor = ( accessorIndex, attributeName ) async {
    final accessor = await parser.getDependency( 'accessor', accessorIndex );
    return geometry.setAttribute( attributeName, accessor );
  };

  List<String> attKeys = geometry.attributes.keys.toList();

  attributes.forEach((gltfAttributeName, value) {
    var threeAttributeName = ATTRIBUTES[ gltfAttributeName ] ?? gltfAttributeName.toLowerCase();
    // Skip attributes already provided by e.g. Draco extension.
    if ( attKeys.indexOf(threeAttributeName) >= 0 ) {
      // skip
    } else {
      pending.add( assignAttributeAccessor( attributes[ gltfAttributeName ], threeAttributeName ) );
    }
  });

  if ( primitiveDef["indices"] != null && geometry.index == null ) {
    var accessor = await parser.getDependency( 'accessor', primitiveDef["indices"] );
    geometry.setIndex( accessor );
  }

  assignExtrasToUserData( geometry, primitiveDef );

  computeBounds( geometry, primitiveDef, parser );

  Future.wait( pending );

  return primitiveDef["targets"] != null
      ? addMorphTargets( geometry, primitiveDef["targets"], parser )
      : geometry;

};

/**
 * @param {BufferGeometry} geometry
 * @param {Number} drawMode
 * @return {BufferGeometry}
 */
Function toTrianglesDrawMode = ( geometry, drawMode ) {

  var index = geometry.getIndex();

  // generate index if not present

  if ( index == null ) {

    var indices = [];

    var position = geometry.getAttribute( 'position' );

    if ( position != null ) {

      for ( var i = 0; i < position.count; i ++ ) {

        indices.add( i );

      }

      geometry.setIndex( indices );
      index = geometry.getIndex();

    } else {

      print( 'THREE.GLTFLoader.toTrianglesDrawMode(): Undefined position attribute. Processing not possible.' );
      return geometry;

    }

  }

  //

  var numberOfTriangles = index.count - 2;
  var newIndices = [];

  if ( drawMode == TriangleFanDrawMode ) {

    // gl.TRIANGLE_FAN

    for ( var i = 1; i <= numberOfTriangles; i ++ ) {

      newIndices.add( index.getX( 0 ) );
      newIndices.add( index.getX( i ) );
      newIndices.add( index.getX( i + 1 ) );

    }

  } else {

    // gl.TRIANGLE_STRIP

    for ( var i = 0; i < numberOfTriangles; i ++ ) {

      if ( i % 2 == 0 ) {

        newIndices.add( index.getX( i ) );
        newIndices.add( index.getX( i + 1 ) );
        newIndices.add( index.getX( i + 2 ) );


      } else {

        newIndices.add( index.getX( i + 2 ) );
        newIndices.add( index.getX( i + 1 ) );
        newIndices.add( index.getX( i ) );

      }

    }

  }

  if ( ( newIndices.length / 3 ) != numberOfTriangles ) {

    print( 'THREE.GLTFLoader.toTrianglesDrawMode(): Unable to generate correct amount of triangles.' );

  }

  // build final geometry

  var newGeometry = geometry.clone();
  newGeometry.setIndex( newIndices );

  return newGeometry;

};

