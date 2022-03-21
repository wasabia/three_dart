part of three_materials;

int materialId = 0;

class Material with EventDispatcher {
  int id = materialId++;
  String uuid = MathUtils.generateUUID();
  String name = "";
  String type = "Material";
  bool fog = true;
  int blending = NormalBlending;
  int side = FrontSide;
  bool vertexColors = false;

  bool sizeAttenuation = false;

  Vector2? normalScale;
  Vector2? clearcoatNormalScale;

  num opacity = 1;
  bool transparent = false;
  int blendSrc = SrcAlphaFactor;
  int blendDst = OneMinusSrcAlphaFactor;
  int blendEquation = AddEquation;
  int? blendSrcAlpha;
  int? blendDstAlpha;
  int? blendEquationAlpha;
  int depthFunc = LessEqualDepth;
  bool depthTest = true;
  bool depthWrite = true;
  int stencilWriteMask = 0xff;
  int stencilFunc = AlwaysStencilFunc;
  int stencilRef = 0;
  int stencilFuncMask = 0xff;
  int stencilFail = KeepStencilOp;
  int stencilZFail = KeepStencilOp;
  int stencilZPass = KeepStencilOp;

  bool stencilWrite = false;
  List<Plane>? clippingPlanes;
  bool clipIntersection = false;
  bool clipShadows = false;

  int? shadowSide;
  bool colorWrite = true;

  num? shininess;

  String? precision;
  bool polygonOffset = false;
  num polygonOffsetFactor = 0;
  num polygonOffsetUnits = 0;

  bool dithering = false;
  num _alphaTest = 0;
  num get alphaTest => _alphaTest;
  set alphaTest(num value) {
    if ((_alphaTest > 0) != (value > 0)) {
      version++;
    }

    _alphaTest = value;
  }

  num _clearcoat = 0;
  num get clearcoat => _clearcoat;
  set clearcoat(num value) {
    if ((_clearcoat > 0) != (value > 0)) {
      version++;
    }
    _clearcoat = value;
  }

  bool alphaToCoverage = false;
  num rotation = 0;

  bool premultipliedAlpha = false;
  bool visible = true;

  bool toneMapped = true;

  Map<String, dynamic> userData = {};

  int version = 0;

  bool isMaterial = true;
  bool flatShading = false;
  Color color = Color(1,1,1);

  Color? specular;
  num? specularIntensity;
  Color? specularColor;
  num? clearcoatRoughness;
  num? bumpScale;
  num? envMapIntensity;

  num metalness = 0.0;
  num roughness = 1.0;

  Texture? matcap;
  Texture? clearcoatMap;
  Texture? clearcoatRoughnessMap;
  Texture? clearcoatNormalMap;
  Texture? displacementMap;
  Texture? roughnessMap;
  Texture? metalnessMap;
  Texture? specularMap;
  Texture? specularIntensityMap;
  Texture? specularColorMap;
  Texture? sheenColorMap;

  Texture? gradientMap;
  num sheen = 0.0;
  Color? sheenColor;
  Texture? sheenTintMap;

  num sheenRoughness = 1.0;
  Texture? sheenRoughnessMap;

  num _transmission = 0.0;
  num get transmission => _transmission;
  set transmission(num value) {
    if ((_transmission > 0) != (value > 0)) {
      version++;
    }

    _transmission = value;
  }

  Texture? transmissionMap;

  num? thickness;
  Texture? thicknessMap;

  Color? attenuationColor;
  num? attenuationDistance;

  bool vertexTangents = false;

  Texture? map;
  Texture? lightMap;
  num? lightMapIntensity;
  Texture? aoMap;
  num? aoMapIntensity;

  Texture? alphaMap;
  num? displacementScale;
  num? displacementBias;

  int? normalMapType;

  Texture? normalMap;
  Texture? bumpMap;
  Texture? get envMap => (uniforms["envMap"] == null ? null : uniforms["envMap"]["value"]);
  set envMap(value) {
    uniforms["envMap"] = {"value": value};
  }

  int? combine;

  num? refractionRatio;
  bool wireframe = false;
  num? wireframeLinewidth;
  String? wireframeLinejoin;
  String? wireframeLinecap;

  num? linewidth;
  String? linecap;
  String? linejoin;

  num? dashSize;
  num? gapSize;
  num? scale;

  Color? emissive;
  num emissiveIntensity = 1.0;
  Texture? emissiveMap;

  bool isMeshStandardMaterial = false;
  bool isRawShaderMaterial = false;
  bool isShaderMaterial = false;
  bool isMeshLambertMaterial = false;
  bool isMeshPhongMaterial = false;
  bool isMeshToonMaterial = false;
  bool isMeshBasicMaterial = false;
  bool isShadowMaterial = false;
  bool isSpriteMaterial = false;
  bool isMeshMatcapMaterial = false;
  bool isMeshDepthMaterial = false;
  bool isMeshDistanceMaterial = false;
  bool isMeshNormalMaterial = false;
  bool isLineDashedMaterial = false;
  bool isLineBasicMaterial = false;
  bool isPointsMaterial = false;
  bool isMeshPhysicalMaterial = false;
  bool instanced = false;

  Map<String, dynamic>? defines;
  Map<String, dynamic> uniforms = {};

  String? vertexShader;
  String? fragmentShader;

  String? glslVersion;
  int? depthPacking;
  String? index0AttributeName;
  Map<String, dynamic>? extensions;
  Map<String, dynamic>? defaultAttributeValues;

  bool? lights;
  bool? clipping;

  num? ior;

  num? size;

  num? _reflectivity;
  num? get reflectivity => _reflectivity;
  set reflectivity(value) {
    _reflectivity = value;
  }

  bool? uniformsNeedUpdate;

  Function? onBeforeCompile;
  late Function customProgramCacheKey;

  Map<String, dynamic> extra = {};

  String? shaderid;

  String get shaderID => shaderid ?? type;
  set shaderID(value) {
    shaderid = value;
  }

  // ( /* renderer, scene, camera, geometry, object, group */ ) {}
  Function? onBeforeRender;

  Material() {
    customProgramCacheKey = () {
      return onBeforeCompile?.toString();
    };
  }

  Material.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    uuid = json["uuid"];
    type = json["type"];
    color.setHex(json["color"]);
  }

  void onBuild(shaderobject, renderer) {}

  // onBeforeCompile(shaderobject, renderer) {}

  void setValues(Map<String, dynamic>? values) {
    if (values == null) return;

    for (var key in values.keys) {
      var newValue = values[key];

      if (newValue == null) {
        print('THREE.Material setValues: $key parameter is null.');
        continue;
      }

      setValue(key, newValue);
    }
  }

  void setValue(String key, dynamic newValue) {
    if (key == "alphaTest") {
      alphaTest = newValue;
    } else if (key == "alphaMap") {
      alphaMap = newValue;
    } else if (key == "aoMap") {
      aoMap = newValue;
    } else if (key == "blendDst") {
      blendDst = newValue;
    } else if (key == "blendDstAlpha") {
      blendDstAlpha = newValue;
    } else if (key == "blendSrcAlpha") {
      blendSrcAlpha = newValue;
    } else if (key == "blendEquation") {
      blendEquation = newValue;
    } else if (key == "blending") {
      blending = newValue;
    } else if (key == "blendSrc") {
      blendSrc = newValue;
    } else if (key == "blendSrcAlpha") {
      blendSrcAlpha = newValue;
    } else if (key == "clearcoat") {
      clearcoat = newValue;
    } else if (key == "clearcoatRoughness") {
      clearcoatRoughness = newValue;
    } else if (key == "clipIntersection") {
      clipIntersection = newValue;
    } else if (key == "clipping") {
      clipping = newValue;
    } else if (key == "clippingPlanes") {
      clippingPlanes = newValue;
    } else if (key == "clipShadows") {
      clipShadows = newValue;
    } else if (key == "color") {
      if (newValue.runtimeType == Color) {
        color = newValue;
      } else {
        color = Color(0, 0, 0).setHex(newValue);
      }
    } else if (key == "colorWrite") {
      colorWrite = newValue;
    } else if (key == "defines") {
      defines = newValue;
    } else if (key == "depthPacking") {
      depthPacking = newValue;
    } else if (key == "depthTest") {
      depthTest = newValue;
    } else if (key == "depthWrite") {
      depthWrite = newValue;
    } else if (key == "dithering") {
      dithering = newValue;
    } else if (key == "emissive") {
      if (newValue.runtimeType == Color) {
        emissive = newValue;
      } else {
        emissive = Color(0, 0, 0).setHex(newValue);
      }
    } else if (key == "emissiveMap") {
      emissiveMap = newValue;
    } else if (key == "flatShading") {
      flatShading = newValue;
    } else if (key == "fog") {
      fog = newValue;
    } else if (key == "fragmentShader") {
      fragmentShader = newValue;
    } else if (key == "instanced") {
      instanced = newValue;
    } else if (key == "lights") {
      lights = newValue;
    } else if (key == "linecap") {
      linecap = newValue;
    } else if (key == "linejoin") {
      linejoin = newValue;
    } else if (key == "linewidth") {
      linewidth = newValue;
    } else if (key == "matcap") {
      matcap = newValue;
    } else if (key == "map") {
      map = newValue;
    } else if (key == "metalness") {
      metalness = newValue;
    } else if (key == "metalnessMap") {
      metalnessMap = newValue;
    } else if (key == "name") {
      name = newValue;
    } else if (key == "normalMap") {
      normalMap = newValue;
    } else if (key == "normalScale") {
      normalScale = newValue;
    } else if (key == "opacity") {
      opacity = newValue;
    } else if (key == "polygonOffset") {
      polygonOffset = newValue;
    } else if (key == "polygonOffsetFactor") {
      polygonOffsetFactor = newValue;
    } else if (key == "polygonOffsetUnits") {
      polygonOffsetUnits = newValue;
    } else if (key == "premultipliedAlpha") {
      premultipliedAlpha = newValue;
    } else if (key == "reflectivity") {
      reflectivity = newValue;
    } else if (key == "roughness") {
      roughness = newValue;
    } else if (key == "roughnessMap") {
      roughnessMap = newValue;
    } else if (key == "shading") {
      //   // for backward compatability if shading is set in the constructor
      throw ('THREE.' +
          type +
          ': .shading has been removed. Use the boolean .flatShading instead.');
      //   this.flatShading = ( newValue == FlatShading ) ? true : false;

    } else if (key == "shininess") {
      shininess = newValue;
    } else if (key == "side") {
      side = newValue;
    } else if (key == "size") {
      size = newValue;
    } else if (key == "sizeAttenuation") {
      sizeAttenuation = newValue;
    } else if (key == "stencilZFail") {
      stencilZFail = newValue;
    } else if (key == "stencilZPass") {
      stencilZPass = newValue;
    } else if (key == "stencilFail") {
      stencilFail = newValue;
    } else if (key == "stencilFunc") {
      stencilFunc = newValue;
    } else if (key == "stencilRef") {
      stencilRef = newValue;
    } else if (key == "stencilWrite") {
      stencilWrite = newValue;
    } else if (key == "toneMapped") {
      toneMapped = newValue;
    } else if (key == "transparent") {
      transparent = newValue;
    } else if (key == "uniforms") {
      uniforms = newValue;
    } else if (key == "vertexShader") {
      vertexShader = newValue;
    } else if (key == "visible") {
      visible = newValue;
    } else if (key == "vertexColors") {
      vertexColors = newValue;
    } else if (key == "wireframe") {
      wireframe = newValue;
    } else if (key == "wireframeLinewidth") {
      wireframeLinewidth = newValue;
    } else if (key == "shadowSide") {
      shadowSide = newValue;
    } else if (key == "specular") {
      if (newValue.runtimeType == Color) {
        specular = newValue;
      } else {
        specular = Color(0, 0, 0).setHex(newValue);
      }
    } else {
      throw ("Material.setValues key: $key newValue: $newValue is not support");
    }
  }

  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    var isRoot = (meta == null || meta is String);

    if (isRoot) {
      meta = Object3dMeta();
    }

    Map<String, dynamic> data = {
      "metadata": {
        "version": 4.5,
        "type": 'Material',
        "generator": 'Material.toJSON'
      }
    };

    // standard Material serialization
    data["uuid"] = uuid;
    data["type"] = type;

    if (name != '') data["name"] = name;

    if (color.isColor) {
      data["color"] = color.getHex();
    }

    data["roughness"] = roughness;
    data["metalness"] = metalness;

    data["sheen"] = sheen;
    if (sheenColor != null && sheenColor is Color) {
      data["sheenColor"] = sheenColor!.getHex();
    }
    data["sheenRoughness"] = sheenRoughness;

    if (emissive != null && emissive!.isColor) {
      data["emissive"] = emissive!.getHex();
    }
    if (emissiveIntensity != 1) {
      data["emissiveIntensity"] = emissiveIntensity;
    }

    if (specular != null && specular!.isColor) {
      data["specular"] = specular!.getHex();
    }
    if (specularIntensity != null) {
      data["specularIntensity"] = specularIntensity;
    }
    if (specularColor != null && specularColor!.isColor) {
      data["specularColor"] = specularColor!.getHex();
    }
    if (shininess != null) data["shininess"] = shininess;
    data["clearcoat"] = clearcoat;
    if (clearcoatRoughness != null) {
      data["clearcoatRoughness"] = clearcoatRoughness;
    }

    if (clearcoatMap != null && clearcoatMap is Texture) {
      data["clearcoatMap"] = clearcoatMap!.toJSON(meta)['uuid'];
    }

    if (clearcoatRoughnessMap != null && clearcoatRoughnessMap is Texture) {
      data["clearcoatRoughnessMap"] =
          clearcoatRoughnessMap!.toJSON(meta)['uuid'];
    }

    if (clearcoatNormalMap != null && clearcoatNormalMap is Texture) {
      data["clearcoatNormalMap"] = clearcoatNormalMap!.toJSON(meta)['uuid'];
      data["clearcoatNormalScale"] = clearcoatNormalScale!.toArray();
    }

    if (map != null && map is Texture) {
      data["map"] = map!.toJSON(meta)["uuid"];
    }
    if (matcap != null && matcap is Texture) {
      data["matcap"] = matcap!.toJSON(meta)["uuid"];
    }
    if (alphaMap != null && alphaMap is Texture) {
      data["alphaMap"] = alphaMap!.toJSON(meta)["uuid"];
    }
    if (lightMap != null && lightMap is Texture) {
      data["lightMap"] = lightMap!.toJSON(meta)["uuid"];
    }

    if (lightMap != null && lightMap is Texture) {
      data["lightMap"] = lightMap!.toJSON(meta)['uuid'];
      data["lightMapIntensity"] = lightMapIntensity;
    }

    if (aoMap != null && aoMap is Texture) {
      data["aoMap"] = aoMap!.toJSON(meta)['uuid'];
      data["aoMapIntensity"] = aoMapIntensity;
    }

    if (bumpMap != null && bumpMap is Texture) {
      data["bumpMap"] = bumpMap!.toJSON(meta)['uuid'];
      data["bumpScale"] = bumpScale;
    }

    if (normalMap != null && normalMap is Texture) {
      data["normalMap"] = normalMap!.toJSON(meta)['uuid'];
      data["normalMapType"] = normalMapType;
      data["normalScale"] = normalScale!.toArray();
    }

    if (displacementMap != null && displacementMap is Texture) {
      data["displacementMap"] = displacementMap!.toJSON(meta)['uuid'];
      data["displacementScale"] = displacementScale;
      data["displacementBias"] = displacementBias;
    }

    if (roughnessMap != null && roughnessMap is Texture) {
      data["roughnessMap"] = roughnessMap!.toJSON(meta)['uuid'];
    }
    if (metalnessMap != null && metalnessMap is Texture) {
      data["metalnessMap"] = metalnessMap!.toJSON(meta)['uuid'];
    }

    if (emissiveMap != null && emissiveMap is Texture) {
      data["emissiveMap"] = emissiveMap!.toJSON(meta)['uuid'];
    }
    if (specularMap != null && specularMap is Texture) {
      data["specularMap"] = specularMap!.toJSON(meta)['uuid'];
    }
    if (specularIntensityMap != null && specularIntensityMap is Texture) {
      data["specularIntensityMap"] =
          specularIntensityMap!.toJSON(meta)['uuid'];
    }
    if (specularColorMap != null && specularColorMap is Texture) {
      data["specularColorMap"] = specularColorMap!.toJSON(meta)['uuid'];
    }

    if (envMap != null && envMap is Texture) {
      data["envMap"] = envMap!.toJSON(meta)['uuid'];

      data["refractionRatio"] = refractionRatio;

      if (combine != null) data["combine"] = combine;
      if (envMapIntensity != null) {
        data["envMapIntensity"] = envMapIntensity;
      }
    }

    if (gradientMap != null && gradientMap is Texture) {
      data["gradientMap"] = gradientMap!.toJSON(meta)['uuid'];
    }

    data["transmission"] = transmission;
    if (transmissionMap != null && transmissionMap is Texture) {
      data["transmissionMap"] = transmissionMap!.toJSON(meta)['uuid'];
    }
    if (thickness != null) data["thickness"] = thickness;
    if (thicknessMap != null && thicknessMap is Texture) {
      data["thicknessMap"] = thicknessMap!.toJSON(meta)['uuid'];
    }
    if (attenuationColor != null) {
      data["attenuationColor"] = attenuationColor!.getHex();
    }
    if (attenuationDistance != null) {
      data["attenuationDistance"] = attenuationDistance;
    }

    if (size != null) data["size"] = size;
    if (shadowSide != null) data["shadowSide"] = shadowSide;
    data["sizeAttenuation"] = sizeAttenuation;

    if (blending != NormalBlending) data["blending"] = blending;
    if (side != FrontSide) data["side"] = side;
    if (vertexColors) data["vertexColors"] = true;

    if (opacity < 1) data["opacity"] = opacity;
    if (transparent == true) data["transparent"] = transparent;

    data["depthFunc"] = depthFunc;
    data["depthTest"] = depthTest;
    data["depthWrite"] = depthWrite;
    data["colorWrite"] = colorWrite;

    data["stencilWrite"] = stencilWrite;
    data["stencilWriteMask"] = stencilWriteMask;
    data["stencilFunc"] = stencilFunc;
    data["stencilRef"] = stencilRef;
    data["stencilFuncMask"] = stencilFuncMask;
    data["stencilFail"] = stencilFail;
    data["stencilZFail"] = stencilZFail;
    data["stencilZPass"] = stencilZPass;

    if (rotation != 0) {
      data["rotation"] = rotation;
    }

    if (polygonOffset == true) data["polygonOffset"] = true;
    if (polygonOffsetFactor != 0) {
      data["polygonOffsetFactor"] = polygonOffsetFactor;
    }
    if (polygonOffsetUnits != 0) {
      data["polygonOffsetUnits"] = polygonOffsetUnits;
    }

    if (linewidth != null && linewidth != 1) {
      data["linewidth"] = linewidth;
    }
    if (dashSize != null) data["dashSize"] = dashSize;
    if (gapSize != null) data["gapSize"] = gapSize;
    if (scale != null) data["scale"] = scale;

    if (dithering == true) data["dithering"] = true;

    if (alphaTest > 0) data["alphaTest"] = alphaTest;
    if (alphaToCoverage == true) {
      data["alphaToCoverage"] = alphaToCoverage;
    }
    if (premultipliedAlpha == true) {
      data["premultipliedAlpha"] = premultipliedAlpha;
    }

    if (wireframe == true) data["wireframe"] = wireframe;
    if (wireframeLinewidth != null && wireframeLinewidth! > 1) {
      data["wireframeLinewidth"] = wireframeLinewidth;
    }
    if (wireframeLinecap != 'round') {
      data["wireframeLinecap"] = wireframeLinecap;
    }
    if (wireframeLinejoin != 'round') {
      data["wireframeLinejoin"] = wireframeLinejoin;
    }

    if (visible == false) data["visible"] = false;

    if (toneMapped == false) data["toneMapped"] = false;

    if (jsonEncode(userData) != '{}') data["userData"] = userData;

    // TODO: Copied from Object3D.toJSON

    extractFromCache(cache) {
      var values = [];

      cache.keys.forEach((key) {
        var data = cache[key];
        data.remove("metadata");
        values.add(data);
      });

      return values;
    }

    if (isRoot) {
      var textures = extractFromCache(meta!.textures);
      var images = extractFromCache(meta.images);

      if (textures.isNotEmpty) data["textures"] = textures;
      if (images.isNotEmpty) data["images"] = images;
    }

    return data;
  }

  Material clone() {
    throw ("Material.clone $type need implement.... ");
  }

  Material copy(Material source) {
    name = source.name;

    fog = source.fog;

    blending = source.blending;
    side = source.side;
    vertexColors = source.vertexColors;

    opacity = source.opacity;
    transparent = source.transparent;

    blendSrc = source.blendSrc;
    blendDst = source.blendDst;
    blendEquation = source.blendEquation;
    blendSrcAlpha = source.blendSrcAlpha;
    blendDstAlpha = source.blendDstAlpha;
    blendEquationAlpha = source.blendEquationAlpha;

    depthFunc = source.depthFunc;
    depthTest = source.depthTest;
    depthWrite = source.depthWrite;

    stencilWriteMask = source.stencilWriteMask;
    stencilFunc = source.stencilFunc;
    stencilRef = source.stencilRef;
    stencilFuncMask = source.stencilFuncMask;
    stencilFail = source.stencilFail;
    stencilZFail = source.stencilZFail;
    stencilZPass = source.stencilZPass;
    stencilWrite = source.stencilWrite;

    var srcPlanes = source.clippingPlanes;
    List<Plane>? dstPlanes;

    if (srcPlanes != null) {
      var n = srcPlanes.length;
      dstPlanes = List<Plane>.filled(n, Plane(null, null));

      for (var i = 0; i != n; ++i) {
        dstPlanes[i] = srcPlanes[i].clone();
      }
    }

    clippingPlanes = dstPlanes;
    clipIntersection = source.clipIntersection;
    clipShadows = source.clipShadows;

    shadowSide = source.shadowSide;

    colorWrite = source.colorWrite;

    precision = source.precision;

    polygonOffset = source.polygonOffset;
    polygonOffsetFactor = source.polygonOffsetFactor;
    polygonOffsetUnits = source.polygonOffsetUnits;

    dithering = source.dithering;

    alphaTest = source.alphaTest;
    alphaToCoverage = source.alphaToCoverage;
    premultipliedAlpha = source.premultipliedAlpha;

    visible = source.visible;

    toneMapped = source.toneMapped;

    userData = json.decode(json.encode(source.userData));

    return this;
  }

  void dispose() {
    dispatchEvent(Event({"type": "dispose"}));
  }

  Object? getProperty(String propertyName) {
    if (propertyName == "vertexParameters") {
      return color;
    } else if (propertyName == "opacity") {
      return opacity;
    } else if (propertyName == "color") {
      return color;
    } else if (propertyName == "emissive") {
      return emissive;
    } else if (propertyName == "flatShading") {
      return flatShading;
    } else if (propertyName == "wireframe") {
      return wireframe;
    } else if (propertyName == "vertexColors") {
      return vertexColors;
    } else if (propertyName == "transparent") {
      return transparent;
    } else if (propertyName == "depthTest") {
      return depthTest;
    } else if (propertyName == "depthWrite") {
      return depthWrite;
    } else if (propertyName == "visible") {
      return visible;
    } else if (propertyName == "blending") {
      return blending;
    } else if (propertyName == "side") {
      return side;
    } else if (propertyName == "roughness") {
      return roughness;
    } else if (propertyName == "metalness") {
      return metalness;
    } else {
      throw ("Material.getProperty type: $type propertyName: $propertyName is not support ");
    }
  }

  void setProperty(String propertyName, dynamic value) {
    if (propertyName == "color") {
      color = value;
    } else if (propertyName == "opacity") {
      opacity = value;
    } else if (propertyName == "emissive") {
      emissive = value;
    } else if (propertyName == "flatShading") {
      flatShading = value;
    } else if (propertyName == "wireframe") {
      wireframe = value;
    } else if (propertyName == "vertexColors") {
      vertexColors = value;
    } else if (propertyName == "transparent") {
      transparent = value;
    } else if (propertyName == "depthTest") {
      depthTest = value;
    } else if (propertyName == "depthWrite") {
      depthWrite = value;
    } else if (propertyName == "visible") {
      visible = value;
    } else if (propertyName == "blending") {
      blending = value;
    } else if (propertyName == "side") {
      side = value;
    } else if (propertyName == "roughness") {
      roughness = value;
    } else if (propertyName == "metalness") {
      metalness = value;
    } else {
      throw ("Material.setProperty type: $type propertyName: $propertyName is not support ");
    }
  }

  set needsUpdate(bool value) {
    if (value == true) version++;
  }
}
