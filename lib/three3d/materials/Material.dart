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
  num? blendSrcAlpha;
  num? blendDstAlpha;
  num? blendEquationAlpha;
  int depthFunc = LessEqualDepth;
  bool depthTest = true;
  bool depthWrite = true;
  num stencilWriteMask = 0xff;
  int stencilFunc = AlwaysStencilFunc;
  num stencilRef = 0;
  num stencilFuncMask = 0xff;
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
  num alphaTest = 0;

  num _clearcoat = 0;
  num get clearcoat => _clearcoat;
  set clearcoat( num value ) {
		if ( (this._clearcoat > 0) != (value > 0) ) {
			this.version ++;
		}
		this._clearcoat = value;
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
  Color? color;

  Color? specular;
  num? specularIntensity;
  Color? specularTint;
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
  Texture? specularTintMap;
  
  Texture? gradientMap;
  Color? sheenTint;
  num transmission = 0.0;
  Texture? transmissionMap;

  num? thickness;
  Texture? thicknessMap;

  Color? attenuationTint;
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
  Texture? envMap;
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

  Map<String, dynamic>? defines;
  Map<String, dynamic>? uniforms;

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

  Material() {
    customProgramCacheKey = () {
      return this.onBeforeCompile?.toString();
    };

  }

  Material.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    this.uuid = json["uuid"];
    this.type = json["type"];
    this.color = Color(0,0,0).setHex(json["color"]);

  }

  onBuild( shaderobject, renderer ) {}

  // onBeforeCompile(shaderobject, renderer) {}

  setValues(Map<String, dynamic>? values) {

    if ( values == null ) return;

    for ( var key in values.keys ) {

      var newValue = values[ key ];

      if ( newValue == null ) {

        print( 'THREE.Material: ${key} parameter is null.' );
        continue;

      }

      setValue(key, newValue);

    }
  }


  setValue(String key, dynamic newValue) {
    if(key == "alphaTest") {
      alphaTest = newValue;
    } else if(key == "blendDst") {
      blendDst = newValue;
    } else if(key == "blendDstAlpha") {
      blendDstAlpha = newValue;
    } else if(key == "blendSrcAlpha") {
      blendSrcAlpha = newValue;
    } else if(key == "blendEquation") {
      blendEquation = newValue;  
    } else if(key == "blending") {
      blending = newValue;
    } else if(key == "blendSrc") {
      blendSrc = newValue;
    } else if(key == "blendSrcAlpha") {
      blendSrcAlpha = newValue;
    } else if(key == "clearcoat") {
      clearcoat = newValue;
    } else if(key == "clipIntersection") {
      clipIntersection = newValue;
    } else if(key == "clipping") {
      clipping = newValue; 
    } else if(key == "clippingPlanes") {
      clippingPlanes = newValue;
    } else if(key == "clipShadows") {
      clipShadows = newValue;
    } else if(key == "color") {
      if(newValue.runtimeType == Color) {
        color = newValue;
      } else {
        color = Color(0,0,0).setHex(newValue);
      }
    } else if(key == "defines") {
      defines = newValue;
    } else if(key == "depthPacking") {
      depthPacking = newValue;
    } else if(key == "depthTest") {
      depthTest = newValue;  
    } else if(key == "depthWrite") {
      depthWrite = newValue;
    } else if(key == "dithering") {
      dithering = newValue;  
    } else if(key == "emissive") {
      if(newValue.runtimeType == Color) {
        emissive = newValue;
      } else {
        emissive = Color(0,0,0).setHex(newValue);
      }
    } else if(key == "flatShading") {
      flatShading = newValue;  
    } else if(key == "fog") {
      fog = newValue;
    } else if(key == "fragmentShader") {
      fragmentShader = newValue;
    } else if(key == "lights") {
      lights = newValue;
    } else if( key == "linecap" ) {
      linecap = newValue;
    } else if( key == "linejoin" ) {
      linejoin = newValue;
    } else if(key == "linewidth") {
      linewidth = newValue;
    } else if(key == "map") {
      map = newValue;
    } else if(key == "metalness") {
      metalness = newValue;
    } else if(key == "normalScale") {
      normalScale = newValue;  
    } else if(key == "opacity") {
      opacity = newValue;
    } else if(key == "polygonOffset") {
      polygonOffset = newValue;  
    } else if(key == "polygonOffsetFactor") {
      polygonOffsetFactor = newValue;
    } else if(key == "polygonOffsetUnits") {
      polygonOffsetUnits = newValue;
    } else if(key == "premultipliedAlpha") {
      premultipliedAlpha = newValue;
    } else if(key == "roughness") {
      roughness = newValue;
    } else if(key == "shading") {
    //   // for backward compatability if shading is set in the constructor
      throw( 'THREE.' + this.type + ': .shading has been removed. Use the boolean .flatShading instead.' );
    //   this.flatShading = ( newValue == FlatShading ) ? true : false;

    } else if(key == "shininess") {
      shininess = newValue;
    } else if(key == "side") {
      side = newValue;
    } else if(key == "size") {
      size = newValue;
    } else if(key == "sizeAttenuation") {
      sizeAttenuation = newValue;
    } else if(key == "toneMapped") {
      toneMapped = newValue;
    } else if(key == "transparent") {
      transparent = newValue;  
    } else if(key == "uniforms") {
      uniforms = newValue;
    } else if(key == "vertexShader") {
      vertexShader = newValue;  
    } else if(key == "visible") {
      visible = newValue;
    } else if(key == "vertexColors") {
      vertexColors = newValue;
    } else if(key == "wireframe") {
      wireframe = newValue;
    } else if(key == "wireframeLinewidth") {
      wireframeLinewidth = newValue;
    } else {
      throw("Material.setValues key: ${key} newValue: ${newValue} is not support");
    }
  }

  toJSON ( {Object3dMeta? meta} ) {

  	var isRoot = ( meta == null || meta is String );

    if ( isRoot ) {
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
  	data["uuid"] = this.uuid;
  	data["type"] = this.type;

  	if ( this.name != '' ) data["name"] = this.name;

  	if ( this.color != null && this.color!.isColor ) data["color"] = this.color!.getHex();

  	if ( this.roughness != null ) data["roughness"] = this.roughness;
  	if ( this.metalness != null ) data["metalness"] = this.metalness;

  	if ( this.sheenTint != null && this.sheenTint!.isColor ) data["sheenTint"] = this.sheenTint!.getHex();
  	if ( this.emissive != null && this.emissive!.isColor ) data["emissive"] = this.emissive!.getHex();
  	if ( this.emissiveIntensity != null && this.emissiveIntensity != 1 ) data["emissiveIntensity"] = this.emissiveIntensity;

  	if ( this.specular != null && this.specular!.isColor ) data["specular"] = this.specular!.getHex();
    if ( this.specularIntensity != null ) data["specularIntensity"] = this.specularIntensity;
		if ( this.specularTint != null && this.specularTint!.isColor ) data["specularTint"] = this.specularTint!.getHex();
    if ( this.shininess != null ) data["shininess"] = this.shininess;
  	if ( this.clearcoat != null ) data["clearcoat"] = this.clearcoat;
  	if ( this.clearcoatRoughness != null ) data["clearcoatRoughness"] = this.clearcoatRoughness;

  	if ( this.clearcoatMap != null && this.clearcoatMap!.isTexture ) {

  		data["clearcoatMap"] = this.clearcoatMap!.toJSON( meta ).uuid;

  	}

  	if ( this.clearcoatRoughnessMap != null && this.clearcoatRoughnessMap!.isTexture ) {

  		data["clearcoatRoughnessMap"] = this.clearcoatRoughnessMap!.toJSON( meta ).uuid;

  	}

  	if ( this.clearcoatNormalMap != null && this.clearcoatNormalMap!.isTexture ) {

  		data["clearcoatNormalMap"] = this.clearcoatNormalMap!.toJSON( meta ).uuid;
  		data["clearcoatNormalScale"] = this.clearcoatNormalScale!.toArray();

  	}

  	if ( this.map != null && this.map!.isTexture ) data["map"] = this.map!.toJSON( meta ).uuid;
  	if ( this.matcap != null && this.matcap!.isTexture ) data["matcap"] = this.matcap!.toJSON( meta ).uuid;
  	if ( this.alphaMap != null && this.alphaMap!.isTexture ) data["alphaMap"] = this.alphaMap!.toJSON( meta ).uuid;
  	if ( this.lightMap != null && this.lightMap!.isTexture ) data["lightMap"] = this.lightMap!.toJSON( meta ).uuid;


		if ( this.lightMap != null && this.lightMap!.isTexture ) {

			data["lightMap"] = this.lightMap!.toJSON( meta ).uuid;
			data["lightMapIntensity"] = this.lightMapIntensity;

		}


  	if ( this.aoMap != null && this.aoMap!.isTexture ) {

  		data["aoMap"] = this.aoMap!.toJSON( meta ).uuid;
  		data["aoMapIntensity"] = this.aoMapIntensity;

  	}

  	if ( this.bumpMap != null && this.bumpMap!.isTexture ) {

  		data["bumpMap"] = this.bumpMap!.toJSON( meta ).uuid;
  		data["bumpScale"] = this.bumpScale;

  	}

  	if ( this.normalMap != null && this.normalMap!.isTexture ) {

  		data["normalMap"] = this.normalMap!.toJSON( meta ).uuid;
  		data["normalMapType"] = this.normalMapType;
  		data["normalScale"] = this.normalScale!.toArray();

  	}

  	if ( this.displacementMap != null && this.displacementMap!.isTexture ) {

  		data["displacementMap"] = this.displacementMap!.toJSON( meta ).uuid;
  		data["displacementScale"] = this.displacementScale;
  		data["displacementBias"] = this.displacementBias;

  	}

  	if ( this.roughnessMap != null && this.roughnessMap!.isTexture ) data["roughnessMap"] = this.roughnessMap!.toJSON( meta ).uuid;
  	if ( this.metalnessMap != null && this.metalnessMap!.isTexture ) data["metalnessMap"] = this.metalnessMap!.toJSON( meta ).uuid;

  	if ( this.emissiveMap != null && this.emissiveMap!.isTexture ) data["emissiveMap"] = this.emissiveMap!.toJSON( meta ).uuid;
  	if ( this.specularMap != null && this.specularMap!.isTexture ) data["specularMap"] = this.specularMap!.toJSON( meta ).uuid;
    if ( this.specularIntensityMap != null && this.specularIntensityMap!.isTexture ) data["specularIntensityMap"] = this.specularIntensityMap!.toJSON( meta ).uuid;
		if ( this.specularTintMap != null && this.specularTintMap!.isTexture ) data["specularTintMap"] = this.specularTintMap!.toJSON( meta ).uuid;

  	if ( this.envMap != null && this.envMap!.isTexture ) {

  		data["envMap"] = this.envMap!.toJSON( meta ).uuid;

  		data["refractionRatio"] = this.refractionRatio;

  		if ( this.combine != null ) data["combine"] = this.combine;
  		if ( this.envMapIntensity != null ) data["envMapIntensity"] = this.envMapIntensity;

  	}

  	if ( this.gradientMap != null && this.gradientMap!.isTexture ) {

  		data["gradientMap"] = this.gradientMap!.toJSON( meta ).uuid;

  	}


		if ( this.transmission != null ) data["transmission"] = this.transmission;
		if ( this.transmissionMap != null && this.transmissionMap!.isTexture ) data["transmissionMap"] = this.transmissionMap!.toJSON( meta ).uuid;
		if ( this.thickness != null ) data["thickness"] = this.thickness;
		if ( this.thicknessMap != null && this.thicknessMap!.isTexture ) data["thicknessMap"] = this.thicknessMap!.toJSON( meta ).uuid;
		if ( this.attenuationTint != null ) data["attenuationTint"] = this.attenuationTint!.getHex();
    if ( this.attenuationDistance != null ) data["attenuationDistance"] = this.attenuationDistance;

  	if ( this.size != null ) data["size"] = this.size;
    if ( this.shadowSide != null ) data["shadowSide"] = this.shadowSide;
  	if ( this.sizeAttenuation != null ) data["sizeAttenuation"] = this.sizeAttenuation;

  	if ( this.blending != NormalBlending ) data["blending"] = this.blending;
  	if ( this.side != FrontSide ) data["side"] = this.side;
  	if ( this.vertexColors ) data["vertexColors"] = true;

  	if ( this.opacity < 1 ) data["opacity"] = this.opacity;
  	if ( this.transparent == true ) data["transparent"] = this.transparent;

  	data["depthFunc"] = this.depthFunc;
  	data["depthTest"] = this.depthTest;
  	data["depthWrite"] = this.depthWrite;
    data["colorWrite"] = this.colorWrite;

  	data["stencilWrite"] = this.stencilWrite;
  	data["stencilWriteMask"] = this.stencilWriteMask;
  	data["stencilFunc"] = this.stencilFunc;
  	data["stencilRef"] = this.stencilRef;
  	data["stencilFuncMask"] = this.stencilFuncMask;
  	data["stencilFail"] = this.stencilFail;
  	data["stencilZFail"] = this.stencilZFail;
  	data["stencilZPass"] = this.stencilZPass;

  	if ( this.rotation != null && this.rotation != 0 ) data["rotation"] = this.rotation;

  	if ( this.polygonOffset == true ) data["polygonOffset"] = true;
  	if ( this.polygonOffsetFactor != 0 ) data["polygonOffsetFactor"] = this.polygonOffsetFactor;
  	if ( this.polygonOffsetUnits != 0 ) data["polygonOffsetUnits"] = this.polygonOffsetUnits;

  	if ( this.linewidth != null && this.linewidth != 1 ) data["linewidth"] = this.linewidth;
  	if ( this.dashSize != null ) data["dashSize"] = this.dashSize;
  	if ( this.gapSize != null ) data["gapSize"] = this.gapSize;
  	if ( this.scale != null ) data["scale"] = this.scale;

  	if ( this.dithering == true ) data["dithering"] = true;

  	if ( this.alphaTest > 0 ) data["alphaTest"] = this.alphaTest;
    if ( this.alphaToCoverage == true ) data["alphaToCoverage"] = this.alphaToCoverage;
  	if ( this.premultipliedAlpha == true ) data["premultipliedAlpha"] = this.premultipliedAlpha;

  	if ( this.wireframe == true ) data["wireframe"] = this.wireframe;
  	if ( this.wireframeLinewidth != null && this.wireframeLinewidth! > 1 ) data["wireframeLinewidth"] = this.wireframeLinewidth;
  	if ( this.wireframeLinecap != 'round' ) data["wireframeLinecap"] = this.wireframeLinecap;
  	if ( this.wireframeLinejoin != 'round' ) data["wireframeLinejoin"] = this.wireframeLinejoin;

  	if ( this.visible == false ) data["visible"] = false;

  	if ( this.toneMapped == false ) data["toneMapped"] = false;

  	if ( jsonEncode( this.userData ) != '{}' ) data["userData"] = this.userData;

  	// TODO: Copied from Object3D.toJSON

  	extractFromCache( cache ) {

  		var values = [];

  		cache.keys.forEach((key) {

  			var data = cache[ key ];
  			data.remove("metadata");
  			values.add( data );

  		});

  		return values;

  	}

  	if ( isRoot ) {

    var textures = extractFromCache( meta!.textures );
  		var images = extractFromCache( meta.images );

  		if ( textures.length > 0 ) data["textures"] = textures;
  		if ( images.length > 0 ) data["images"] = images;

  	}

  	return data;

  }

  clone() {
    throw("Material.clone need implement.... ");
  }

  copy(source) {
    this.name = source.name;

    this.fog = source.fog;

    this.blending = source.blending;
    this.side = source.side;
    this.vertexColors = source.vertexColors;

    this.opacity = source.opacity;
    this.transparent = source.transparent;

    this.blendSrc = source.blendSrc;
    this.blendDst = source.blendDst;
    this.blendEquation = source.blendEquation;
    this.blendSrcAlpha = source.blendSrcAlpha;
    this.blendDstAlpha = source.blendDstAlpha;
    this.blendEquationAlpha = source.blendEquationAlpha;

    this.depthFunc = source.depthFunc;
    this.depthTest = source.depthTest;
    this.depthWrite = source.depthWrite;

    this.stencilWriteMask = source.stencilWriteMask;
    this.stencilFunc = source.stencilFunc;
    this.stencilRef = source.stencilRef;
    this.stencilFuncMask = source.stencilFuncMask;
    this.stencilFail = source.stencilFail;
    this.stencilZFail = source.stencilZFail;
    this.stencilZPass = source.stencilZPass;
    this.stencilWrite = source.stencilWrite;

    var srcPlanes = source.clippingPlanes;
    var dstPlanes = null;

    if (srcPlanes != null) {
      var n = srcPlanes.length;
      dstPlanes = List<Plane>.filled(n, Plane(null, null));

      for (var i = 0; i != n; ++i) {
        dstPlanes[i] = srcPlanes[i].clone();
      }
    }

    this.clippingPlanes = dstPlanes;
    this.clipIntersection = source.clipIntersection;
    this.clipShadows = source.clipShadows;

    this.shadowSide = source.shadowSide;

    this.colorWrite = source.colorWrite;

    this.precision = source.precision;

    this.polygonOffset = source.polygonOffset;
    this.polygonOffsetFactor = source.polygonOffsetFactor;
    this.polygonOffsetUnits = source.polygonOffsetUnits;

    this.dithering = source.dithering;

    this.alphaTest = source.alphaTest;
    this.alphaToCoverage = source.alphaToCoverage;
    this.premultipliedAlpha = source.premultipliedAlpha;

    this.visible = source.visible;

    this.toneMapped = source.toneMapped;

    this.userData = json.decode(json.encode(source.userData));

    return this;
  }

  dispose() {
    this.dispatchEvent(Event({"type": "dispose"}));
  }


  getProperty(propertyName) {
    if(propertyName == "vertexParameters") {
      return this.color;
    } else if(propertyName == "opacity") {
      return this.opacity;
    
    } else {
      throw("Material.getProperty type: ${type} propertyName: ${propertyName} is not support ");
    }
  }

  setProperty(propertyName, value) {
    if(propertyName == "color") {
      this.color = value;
    } else if(propertyName == "opacity") {
      this.opacity = value;
    } else {
      throw("Material.setProperty type: ${type} propertyName: ${propertyName} is not support ");
    }
  }

  set needsUpdate(bool value) {
    if (value == true) this.version++;
  }
}
