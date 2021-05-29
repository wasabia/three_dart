// import { voidMainRegExp } from './voidMainRegExp.js'
// import { expandShaderIncludes } from './expandShaderIncludes.js'
// import { MeshDepthMaterial, MeshDistanceMaterial, RGBADepthPacking, UniformsUtils } from 'three'
// import { generateUUID } from './generateUUID.js'

part of troika_three_text;



var voidMainRegExp = RegExp(r"\bvoid\s+main\s*\(\s*\)\s*{");

class DerivedBasicMaterial extends MeshBasicMaterial {
  String type = "DerivedBasicMaterial";
  String? shaderid = "MeshBasicMaterial";

  bool isDerivedMaterial = true;
  late Map<String, dynamic> options;
  late Map<String, dynamic> optionsFn;
  MeshBasicMaterial? baseMaterial;

  bool isTextOutlineMaterial = false;

  Material? _depthMaterial;
  Material? _distanceMaterial;
  DerivedBasicMaterial? _outlineMaterial;
  DerivedBasicMaterial? get outlineMaterial => _outlineMaterial;

  String? orientation;

  set outlineMaterial(value) {
    _outlineMaterial = value;
  }

  bool isTroikaTextMaterial = true;

  DerivedBasicMaterial.create(parameters) : super(parameters) {}

  factory DerivedBasicMaterial(MeshBasicMaterial baseMaterial, Map<String, dynamic> options, Map<String, dynamic> optionsFn, optionsKey) {
    var _deriveMaterial = DerivedBasicMaterial.create(null);
    _deriveMaterial.copy(baseMaterial);
    _deriveMaterial.baseMaterial = baseMaterial;

    _deriveMaterial.options = options;
    _deriveMaterial.optionsFn = optionsFn;
    // Private onBeforeCompile handler that injects the modified shaders and uniforms when
    // the renderer switches to this material's program
    _deriveMaterial.onBeforeCompile = (WebGLParameters shaderInfo, render) {
      if(baseMaterial.onBeforeCompile != null) {
        baseMaterial.onBeforeCompile!(shaderInfo, render);
      }
      

      // Upgrade the shaders, caching the result by incoming source code
      var cacheKey = "${optionsKey}|||${shaderInfo.vertexShader}|||${shaderInfo.fragmentShader}";
      var upgradedShaders = SHADER_UPGRADE_CACHE[cacheKey];
      if (upgradedShaders == null) {
        var upgraded = upgradeShaders(shaderInfo, options, optionsFn, optionsKey);
        upgradedShaders = SHADER_UPGRADE_CACHE[cacheKey] = upgraded;
      }

      // Inject upgraded shaders and uniforms into the program
      shaderInfo.vertexShader = upgradedShaders["vertexShader"];
      shaderInfo.fragmentShader = upgradedShaders["fragmentShader"];

   
      assign(shaderInfo.uniforms!, _deriveMaterial.uniforms);

      // Inject auto-updating time uniform if requested
      if (options["timeUniform"] != null) {
        throw("DerivedBasicMaterial timeUniform auto-updating need todo ");
        // shaderInfo.uniforms[options["timeUniform"]] = {
        //   get value() {return Date.now() - epoch};
        // };
      }

      // Users can still add their own handlers on top of ours
      // if (_deriveMaterial[privateBeforeCompileProp]) {
      //   _deriveMaterial[privateBeforeCompileProp](shaderInfo);
      // }
      // TODO ....
    };

    return _deriveMaterial;
  }

  // WebGLShadowMap reverses the side of the shadow material by default, which fails
  // for planes, so here we force the `shadowSide` to always match the main side.
  get shadowSide => this.side;

    
   

  /**
   * Utility to get a MeshDepthMaterial that will honor this derived material's vertex
   * transformations and discarded fragments.
   */
  getDepthMaterial() {
    var depthMaterial = this._depthMaterial;
    if (depthMaterial == null) {
      var _base;
      if(baseMaterial!.type == "DerivedBasicMaterial") {
        var _bm = baseMaterial as DerivedBasicMaterial;
        _base = _bm.getDepthMaterial();
      } else {
        _base = new MeshDepthMaterial({ "depthPacking": RGBADepthPacking });
      }
    
      depthMaterial = this._depthMaterial = createDerivedMaterial(
        _base, options, optionsFn
      );
      depthMaterial!.defines!["IS_DEPTH_MATERIAL"] = '';
      depthMaterial.uniforms = this.uniforms; //automatically recieve same uniform values
    }
    return depthMaterial;
  }

  /**
   * Utility to get a MeshDistanceMaterial that will honor this derived material's vertex
   * transformations and discarded fragments.
   */
  getDistanceMaterial() {
    var distanceMaterial = this._distanceMaterial;
    if (distanceMaterial == null) {
      var _base;
      if(baseMaterial!.type == "DerivedBasicMaterial") {
        var _bm = baseMaterial as DerivedBasicMaterial;
        _base = _bm.getDistanceMaterial();
      } else {
        _base = new MeshDistanceMaterial({});
      }

      // var _base = baseMaterial.isDerivedMaterial ? baseMaterial.getDistanceMaterial() : MeshDistanceMaterial({});
      distanceMaterial = this._distanceMaterial = createDerivedMaterial(
        _base, options, optionsFn
      );
      distanceMaterial!.defines!["IS_DISTANCE_MATERIAL"] = '';
      distanceMaterial.uniforms = this.uniforms; //automatically recieve same uniform values
    }
    return distanceMaterial;
    
  }

  copy(source) {
    super.copy(source);
    baseMaterial?.copy(source);
    if (baseMaterial != null && !(baseMaterial!.isShaderMaterial) && !(baseMaterial!.type == "DerivedBasicMaterial")) {
      assign(this.extensions!, source.extensions);
      assign(this.defines!, source.defines);
      assign(this.uniforms!, UniformsUtils.clone(source.uniforms));
    }
    return this;
  }

  clone () {
    var _p = Map<String, dynamic>();
    return DerivedBasicMaterial.create(_p).copy(this); 
  }

  dispose() {
    if (_depthMaterial != null) _depthMaterial!.dispose();
    if (_distanceMaterial != null) _distanceMaterial!.dispose();
    baseMaterial!.dispose();
  }

}



// Local assign polyfill to avoid importing troika-core
assign(Map<String, dynamic> target, Map<String, dynamic>? source0, [Map<String, dynamic>? source1, Map<String, dynamic>? source2]) {
  
  if(source0 != null) target.addAll(source0);
  if(source1 != null) target.addAll(source1);
  if(source2 != null) target.addAll(source2);

  return target;
}


var epoch = DateTime.now();
var CONSTRUCTOR_CACHE = new WeakMap();
var SHADER_UPGRADE_CACHE = new Map();

// Material ids must be integers, but we can't access the increment from Three's `Material` module,
// so let's choose a sufficiently large starting value that should theoretically never collide.
var materialInstanceId = 1e10;

/**
 * A utility for creating a custom shader material derived from another material's
 * shaders. This allows you to inject custom shader logic and transforms into the
 * builtin ThreeJS materials without having to recreate them from scratch.
 *
 * @param {THREE.Material} baseMaterial - the original material to derive from
 *
 * @param {Object} options - How the base material should be modified.
 * @param {Object} options.defines - Custom `defines` for the material
 * @param {Object} options.extensions - Custom `extensions` for the material, e.g. `{derivatives: true}`
 * @param {Object} options.uniforms - Custom `uniforms` for use in the modified shader. These can
 *        be accessed and manipulated via the resulting material's `uniforms` property, just like
 *        in a ShaderMaterial. You do not need to repeat the base material's own uniforms here.
 * @param {String} options.timeUniform - If specified, a uniform of this name will be injected into
 *        both shaders, and it will automatically be updated on each render frame with a number of
 *        elapsed milliseconds. The "zero" epoch time is not significant so don't rely on this as a
 *        true calendar time.
 * @param {String} options.vertexDefs - Custom GLSL code to inject into the vertex shader's top-level
 *        definitions, above the `void main()` function.
 * @param {String} options.vertexMainIntro - Custom GLSL code to inject at the top of the vertex
 *        shader's `void main` function.
 * @param {String} options.vertexMainOutro - Custom GLSL code to inject at the end of the vertex
 *        shader's `void main` function.
 * @param {String} options.vertexTransform - Custom GLSL code to manipulate the `position`, `normal`,
 *        and/or `uv` vertex attributes. This code will be wrapped within a standalone function with
 *        those attributes exposed by their normal names as read/write values.
 * @param {String} options.fragmentDefs - Custom GLSL code to inject into the fragment shader's top-level
 *        definitions, above the `void main()` function.
 * @param {String} options.fragmentMainIntro - Custom GLSL code to inject at the top of the fragment
 *        shader's `void main` function.
 * @param {String} options.fragmentMainOutro - Custom GLSL code to inject at the end of the fragment
 *        shader's `void main` function. You can manipulate `gl_FragColor` here but keep in mind it goes
 *        after any of ThreeJS's color postprocessing shader chunks (tonemapping, fog, etc.), so if you
 *        want those to apply to your changes use `fragmentColorTransform` instead.
 * @param {String} options.fragmentColorTransform - Custom GLSL code to manipulate the `gl_FragColor`
 *        output value. Will be injected near the end of the `void main` function, but before any
 *        of ThreeJS's color postprocessing shader chunks (tonemapping, fog, etc.), and before the
 *        `fragmentMainOutro`.
 * @param {function<{vertexShader,fragmentShader}>:{vertexShader,fragmentShader}} options.customRewriter - A function
 *        for performing custom rewrites of the full shader code. Useful if you need to do something
 *        special that's not covered by the other builtin options. This function will be executed before
 *        any other transforms are applied.
 * @param {boolean} options.chained - Set to `true` to prototype-chain the derived material to the base
 *        material, rather than the default behavior of copying it. This allows the derived material to
 *        automatically pick up changes made to the base material and its properties. This can be useful
 *        where the derived material is hidden from the user as an implementation detail, allowing them
 *        to work with the original material like normal. But it can result in unexpected behavior if not
 *        handled carefully.
 *
 * @return {THREE.Material}
 *
 * The returned material will also have two new methods, `getDepthMaterial()` and `getDistanceMaterial()`,
 * which can be called to get a variant of the derived material for use in shadow casting. If the
 * target mesh is expected to cast shadows, then you can assign these to the mesh's `customDepthMaterial`
 * (for directional and spot lights) and/or `customDistanceMaterial` (for point lights) properties to
 * allow the cast shadow to honor your derived shader's vertex transforms and discarded fragments. These
 * will also set a custom `#define IS_DEPTH_MATERIAL` or `#define IS_DISTANCE_MATERIAL` that you can look
 * for in your derived shaders with `#ifdef` to customize their behavior for the depth or distance
 * scenarios, e.g. skipping antialiasing or expensive shader logic.
 */
createDerivedMaterial(baseMaterial, Map<String, dynamic> options, Map<String, dynamic> optionsFn) {
  // Generate a key that is unique to the content of these `options`. We'll use this
  // throughout for caching and for generating the upgraded shader code. This increases
  // the likelihood that the resulting shaders will line up across multiple calls so
  // their GL programs can be shared and cached.
  var optionsKey = getKeyForOptions(options);

  // First check to see if we've already derived from this baseMaterial using this
  // unique set of options, and if so reuse the constructor to avoid some allocations.
  var ctorsByDerivation = CONSTRUCTOR_CACHE.get(baseMaterial);

  if (ctorsByDerivation == null) {
    ctorsByDerivation = {};
    CONSTRUCTOR_CACHE.add(key: baseMaterial, value: ctorsByDerivation);
  }
  if (ctorsByDerivation[optionsKey] != null) {
    Function _val = ctorsByDerivation[optionsKey];
    return _val();
  }

  var privateBeforeCompileProp = "_onBeforeCompile${optionsKey}";

  


  var derive = (Material base) {
    // Prototype chain to the base material
    var derived;


    if(base.type == "MeshBasicMaterial") {
      // derived = Object.create(base, descriptor);
      derived = DerivedBasicMaterial(base as MeshBasicMaterial, options, optionsFn, optionsKey);
    }

    derived.customProgramCacheKey = () {
      return optionsKey.toString();
    };
    // derived.onBeforeCompile = _onBeforeCompile;


    // Merge uniforms, defines, and extensions
    derived.uniforms = assign({}, base.uniforms, options["uniforms"]);
    derived.defines = assign({}, base.defines, options["defines"]);

    //force a program change from the base material
    derived.defines["TROIKA_DERIVED_MATERIAL_${optionsKey}"] = '';
    derived.extensions = assign({}, base.extensions, options["extensions"]);

    // Don't inherit EventDispatcher listeners
    // derived.clearListeners();

    return derived;
  };


  var _createDerivedMaterial = () {
    return derive(options["chained"] != null ? baseMaterial : baseMaterial.clone());
  };

  ctorsByDerivation[optionsKey] = _createDerivedMaterial;
  return _createDerivedMaterial();
}


Map<String, dynamic> upgradeShaders(WebGLParameters shaderInfo, options, optionsFn, key) {
  String vertexShader = shaderInfo.vertexShader;
  String fragmentShader = shaderInfo.fragmentShader;
  
  var vertexDefs = options["vertexDefs"];
  var vertexMainIntro = options["vertexMainIntro"];
  var vertexMainOutro = options["vertexMainOutro"];
  var vertexTransform = options["vertexTransform"];
  var fragmentDefs = options["fragmentDefs"];
  var fragmentMainIntro = options["fragmentMainIntro"];
  var fragmentMainOutro = options["fragmentMainOutro"];
  var fragmentColorTransform = options["fragmentColorTransform"];
  var customRewriter = optionsFn["customRewriter"];
  var timeUniform = options["timeUniform"];

  vertexDefs = vertexDefs ?? '';
  vertexMainIntro = vertexMainIntro ?? '';
  vertexMainOutro = vertexMainOutro ?? '';
  fragmentDefs = fragmentDefs ?? '';
  fragmentMainIntro = fragmentMainIntro ?? '';
  fragmentMainOutro = fragmentMainOutro ?? '';

  // Expand includes if needed
  if (vertexTransform != null || customRewriter != null) {
    vertexShader = expandShaderIncludes(vertexShader);
  }
  if (fragmentColorTransform != null || customRewriter != null) {
    // We need to be able to find postprocessing chunks after include expansion in order to
    // put them after the fragmentColorTransform, so mark them with comments first. Even if
    // this particular derivation doesn't have a fragmentColorTransform, other derivations may,
    // so we still mark them.

    var _reg = RegExp(r"^[ \t]*#include <((?:tonemapping|encodings|fog|premultiplied_alpha|dithering)_fragment)>", multiLine: true);

    var match = _reg.firstMatch(fragmentShader);
    if(match != null) {
      var str = "\n//!BEGIN_POST_CHUNK ${match.group(1)}\n${match.group(0)}\n//!END_POST_CHUNK\n";
      fragmentShader = fragmentShader.replaceFirst(_reg, str);
    } else {
      print("DerivedMaterial.dart fragmentColorTransform || customRewriter no match ..... ");
    }

    
    fragmentShader = expandShaderIncludes(fragmentShader);
  }

  // Apply custom rewriter function
  if (customRewriter != null) {
    var res = customRewriter({"vertexShader": vertexShader, "fragmentShader": fragmentShader});
    vertexShader = res["vertexShader"];
    fragmentShader = res["fragmentShader"];
  }

  // The fragmentColorTransform needs to go before any postprocessing chunks, so extract
  // those and re-insert them into the outro in the correct place:
  if (fragmentColorTransform != null) {
    var postChunks = [];

    // [^]+? = non-greedy match of any chars including newlines
    var _reg = RegExp(r"^\/\/!BEGIN_POST_CHUNK[^]+?^\/\/!END_POST_CHUNK", multiLine: true);
    // var matches = _reg.allMatches(fragmentShader);

    // for(var match in matches) {
    //   var _content = match.group(0)!;
    //   postChunks.add(_content);
    //   fragmentShader = fragmentShader.replaceFirst(_content, "");
    // }

    fragmentShader = fragmentShader.replaceAllMapped(_reg, (match) {
      var _content = match.group(0)!;
      postChunks.add(_content);
      return "";
    });

    // fragmentShader = fragmentShader.replace(
    //   //gm, 
    //   match => {
    //     postChunks.push(match)
    //     return ''
    //   }
    // );

    fragmentMainOutro = "${fragmentColorTransform}\n${postChunks.join('\n')}\n${fragmentMainOutro}";
  }

  // Inject auto-updating time uniform if requested
  if (timeUniform != null) {
    var code = "\nuniform float ${timeUniform};\n";
    vertexDefs = code + vertexDefs;
    fragmentDefs = code + fragmentDefs;
  }

  // Inject a function for the vertexTransform and rename all usages of position/normal/uv
  if (vertexTransform != null) {
    // Hoist these defs to the very top so they work in other function defs
    vertexShader = """vec3 troika_position_${key};
vec3 troika_normal_${key};
vec2 troika_uv_${key};
${vertexShader}
""";

    vertexDefs = """${vertexDefs}
void troikaVertexTransform${key}(inout vec3 position, inout vec3 normal, inout vec2 uv) {
  ${vertexTransform}
}
""";

    vertexMainIntro = """
troika_position_${key} = vec3(position);
troika_normal_${key} = vec3(normal);
troika_uv_${key} = vec2(uv);
troikaVertexTransform${key}(troika_position_${key}, troika_normal_${key}, troika_uv_${key});
${vertexMainIntro}
""";


    var _regExp = RegExp(r"\b(position|normal|uv)\b");
    var _regA = RegExp(r"\battribute\s+vec[23]\s+$");

    var fullStr = vertexShader;

    // for(var match in matches) {
    //   var match1 = match.group(1);
    //   bool _isMatch = _regA.hasMatch(fullStr.substring(0, match.start));
    //   String _str = _isMatch ? match.group(1)! : "troika_${match1}_${key}";
    //   vertexShader = vertexShader.replaceFirst(match.group(0)!, _str);
    // }

    vertexShader = vertexShader.replaceAllMapped(_regExp, (match) {
      bool _isMatch = _regA.hasMatch(fullStr.substring(0, match.start));

      var match1 = match.group(1);
      return _isMatch ? match.group(1)! : "troika_${match1}_${key}";
    });


    // vertexShader = vertexShader.replaceAll(, (match, match1, index, fullStr) => {
    //   return 
    // });
  }


  // fragmentMainOutro = fragmentMainOutro + """
  
  // gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
  // """;

  // Inject defs and intro/outro snippets
  vertexShader = injectIntoShaderCode(vertexShader, key, vertexDefs, vertexMainIntro, vertexMainOutro);
  fragmentShader = injectIntoShaderCode(fragmentShader, key, fragmentDefs, fragmentMainIntro, fragmentMainOutro);

  return {
    "vertexShader": vertexShader,
    "fragmentShader": fragmentShader
  };
}

injectIntoShaderCode(shaderCode, id, defs, intro, outro) {
  if (intro != null || outro != null || defs != null) {

    var _str = """
${defs}
void troikaOrigMain${id}() {
    """;

    shaderCode = shaderCode.replaceFirst(voidMainRegExp, _str);
    shaderCode += """
void main() {
  ${intro}
  troikaOrigMain${id}();
  ${outro}
}
""";

  }
  return shaderCode;
}


optionsJsonReplacer(key, value) {
  return key == 'uniforms' ? null : value is Function ? value.toString() : value;
}

var _idCtr = 0;
var optionsHashesToIds = new Map();
getKeyForOptions(Map<String, dynamic> options) {
  // var optionsHash = JSON.stringify(options, optionsJsonReplacer);
  var optionsHash = convert.jsonEncode(options);
  var id = optionsHashesToIds[optionsHash];
  if (id == null) {
    optionsHashesToIds[optionsHash] = (id = ++_idCtr);
  }
  return id;
}
