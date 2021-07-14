part of troika_three_text;





var defaultMaterial = new MeshBasicMaterial({
    "color": 0xffffff,
    "side": DoubleSide,
    "transparent": true
  });

  var defaultStrokeColor = 0x808080;

  var tempMat4 = new Matrix4();
  var tempVec3a = new Vector3.init();
  var tempVec3b = new Vector3.init();
  var tempArray = [];
  var origin = new Vector3.init();
  var defaultOrient = '+x+y';

  first(o) {
    return o is List ? o[0] : o;
  }

  
  Mesh? flatRaycastMesh;
  getFlatRaycastMesh() {
    if(flatRaycastMesh == null) {
      flatRaycastMesh = new Mesh(
        new PlaneBufferGeometry(width: 1, height: 1),
        defaultMaterial
      );
    }
    return flatRaycastMesh;
  }

  Mesh? curvedRaycastMesh;
  getCurvedRaycastMesh() {
    if(curvedRaycastMesh == null) {
      curvedRaycastMesh = new Mesh(
        new PlaneBufferGeometry(width: 1, height: 1, widthSegments: 32, heightSegments: 1),
        defaultMaterial
      );
    }
    return curvedRaycastMesh;
  }

  var syncStartEvent = Event({"type": 'syncstart'});
  var syncCompleteEvent = Event({"type": 'synccomplete'});

  var SYNCABLE_PROPS = [
    'font',
    'fontSize',
    'letterSpacing',
    'lineHeight',
    'maxWidth',
    'overflowWrap',
    'text',
    'direction',
    'textAlign',
    'textIndent',
    'whiteSpace',
    'anchorX',
    'anchorY',
    'colorRanges',
    'sdfGlyphSize'
  ];

  List<String> COPYABLE_PROPS = [
    'material',
    'color',
    'depthOffset',
    'clipRect',
    'curveRadius',
    'orientation',
    'glyphGeometryDetail'
  ] + SYNCABLE_PROPS;
  

/**
 * @class Text
 *
 * A ThreeJS Mesh that renders a string of text on a plane in 3D space using signed distance
 * fields (SDF).
 */
class Text extends Mesh {
  num _curveRadius = 0;
  
  Color color = Color.fromHex(0xFFFFFF);

  /**
   * @member {number|string} outlineWidth
   * WARNING: This API is experimental and may change.
   * The width of an outline/halo to be drawn around each text glyph using the `outlineColor` and `outlineOpacity`.
   * Can be specified as either an absolute number in local units, or as a percentage string e.g.
   * `"12%"` which is treated as a percentage of the `fontSize`. Defaults to `0`, which means
   * no outline will be drawn unless an `outlineOffsetX/Y` or `outlineBlur` is set.
   */
  num outlineWidth = 0;


  /**
   * @member {string|number|THREE.Color} outlineColor
   * WARNING: This API is experimental and may change.
   * The color of the text outline, if `outlineWidth`/`outlineBlur`/`outlineOffsetX/Y` are set.
   * Defaults to black.
   */
  Color outlineColor = Color.fromHex(0xFFFFFF);

  /**
   * @member {number} outlineOpacity
   * WARNING: This API is experimental and may change.
   * The opacity of the outline, if `outlineWidth`/`outlineBlur`/`outlineOffsetX/Y` are set.
   * Defaults to `1`.
   */
  num outlineOpacity = 1;


  /**
   * @member {number|string} outlineBlur
   * WARNING: This API is experimental and may change.
   * A blur radius applied to the outer edge of the text's outline. If the `outlineWidth` is
   * zero, the blur will be applied at the glyph edge, like CSS's `text-shadow` blur radius.
   * Can be specified as either an absolute number in local units, or as a percentage string e.g.
   * `"12%"` which is treated as a percentage of the `fontSize`. Defaults to `0`.
   */
  num outlineBlur = 0;


  /**
   * @member {number|string} outlineOffsetX
   * WARNING: This API is experimental and may change.
   * A horizontal offset for the text outline.
   * Can be specified as either an absolute number in local units, or as a percentage string e.g. `"12%"`
   * which is treated as a percentage of the `fontSize`. Defaults to `0`.
   */
  num outlineOffsetX = 0;
  num outlineOffsetY = 0;
  num strokeWidth = 0;

  Color strokeColor = Color.fromHex(defaultStrokeColor);
  num strokeOpacity = 1;
  num fillOpacity = 1;
  /**
   * @member {number} depthOffset
   * This is a shortcut for setting the material's `polygonOffset` and related properties,
   * which can be useful in preventing z-fighting when this text is laid on top of another
   * plane in the scene. Positive numbers are further from the camera, negatives closer.
   */
  num depthOffset = 0;

  /**
   * @member {Array<number>} clipRect
   * If specified, defines a `[minX, minY, maxX, maxY]` of a rectangle outside of which all
   * pixels will be discarded. This can be used for example to clip overflowing text when
   * `whiteSpace='nowrap'`.
   */
  List<num>? clipRect;



  /**
   * @member {string} orientation
   * Defines the axis plane on which the text should be laid out when the mesh has no extra
   * rotation transform. It is specified as a string with two axes: the horizontal axis with
   * positive pointing right, and the vertical axis with positive pointing up. By default this
   * is '+x+y', meaning the text sits on the xy plane with the text's top toward positive y
   * and facing positive z. A value of '+x-z' would place it on the xz plane with the text's
   * top toward negative z and facing positive y.
   */
  String orientation = defaultOrient;


  /**
   * @member {number} glyphGeometryDetail
   * Controls number of vertical/horizontal segments that make up each glyph's rectangular
   * plane. Defaults to 1. This can be increased to provide more geometrical detail for custom
   * vertex shader effects, for example.
   */
  // num _glyphGeometryDetail = 1;



  

  bool debugSDF = false;



  bool _needsSync = true;
  bool _isSyncing = false;
  List<Function> _queuedSyncs = [];
  dynamic _textRenderInfo;
  Material? _derivedMaterial;
  Material? _baseMaterial;
  Material? _defaultMaterial;

  Text.create(geometry, material) : super(geometry, material) {
    /**
     * Initiate a sync if needed - note it won't complete until next frame at the
     * earliest so if possible it's a good idea to call sync() manually as soon as
     * all the properties have been set.
     * @override
     */
    this.onBeforeRender = ({renderer, scene, camera, geometry, material, group}) {
      this.syncText(null);

      // This may not always be a text material, e.g. if there's a scene.overrideMaterial present
      if (material.isTroikaTextMaterial) {
        this._prepareForRender(material);
      }
    };
  }

  factory Text() {
    var geometry = new GlyphsGeometry();
    var _text = Text.create(geometry, null);
    return _text;
  }

  GlyphsGeometry get geometry_cast => this.geometry as GlyphsGeometry;


  Map<String, dynamic> getOptions() {
    return {
      "text": this.text,
      "font": this.font,
      "fontSize": this.fontSize ?? 0.1,
      "letterSpacing": this.letterSpacing ?? 0,
      "lineHeight": this.lineHeight ?? 'normal',
      "maxWidth": this.maxWidth,
      "direction": this.direction,
      "textAlign": this.textAlign,
      "textIndent": this.textIndent,
      "whiteSpace": this.whiteSpace,
      "overflowWrap": this.overflowWrap,
      "anchorX": this.anchorX,
      "anchorY": this.anchorY,
      "colorRanges": this.colorRanges,
      "includeCaretPositions": true, //TODO parameterize
      "sdfGlyphSize": this.sdfGlyphSize
    };
  }

  measure() {
    var _args = getOptions();
    return fontProcessor().measure(_args);
  }

  /**
   * Updates the text rendering according to the current text-related configuration properties.
   * This is an async process, so you can pass in a callback function to be executed when it
   * finishes.
   * @param {function} [callback]
   */
  syncText(Function? callback) {
    if (this._needsSync) {
      this._needsSync = false;

      // If there's another sync still in progress, queue
      if (this._isSyncing) {
        if(callback != null) this._queuedSyncs.add(callback);
      } else {
        this._isSyncing = true;
        this.dispatchEvent(syncStartEvent);

        var _args = getOptions();
        getTextRenderInfo(_args, (textRenderInfo) {
          this._isSyncing = false;

          // print(" --------------textRenderInfo----------------");
          // print(textRenderInfo["glyphBounds"]);
          // var __sdfTexture = textRenderInfo["sdfTexture"];
          // print(__sdfTexture);
          // print(__sdfTexture.image);
          // print(__sdfTexture.image.data);

          // Save result for later use in onBeforeRender
          this._textRenderInfo = textRenderInfo;

          // Update the geometry attributes
          var _geometry = this.geometry as GlyphsGeometry;
          _geometry.updateGlyphs(
            textRenderInfo["glyphBounds"],
            textRenderInfo["glyphAtlasIndices"],
            textRenderInfo["blockBounds"],
            textRenderInfo["chunkedBounds"],
            textRenderInfo["glyphColors"]
          );

          // If we had extra sync requests queued up, kick it off
          var queued = this._queuedSyncs;
          if (queued.length > 0) {
          
            this._queuedSyncs.clear();
            this._needsSync = true;
            this.syncText(() => {
              queued.forEach((fn) => fn())
            });
          }

          this.dispatchEvent(syncCompleteEvent);
          if (callback != null) {
            callback();
          }
        });
      }
    }
  }

  

  /**
   * Shortcut to dispose the geometry specific to this instance.
   * Note: we don't also dispose the derived material here because if anything else is
   * sharing the same base material it will result in a pause next frame as the program
   * is recompiled. Instead users can dispose the base material manually, like normal,
   * and we'll also dispose the derived material at that time.
   */
  dispose() {
    this.geometry.dispose();
  }

  /**
   * @property {TroikaTextRenderInfo|null} textRenderInfo
   * @readonly
   * The current processed rendering data for this TextMesh, returned by the TextBuilder after
   * a `sync()` call. This will be `null` initially, and may be stale for a short period until
   * the asynchrous `sync()` process completes.
   */
  get textRenderInfo {
    return this._textRenderInfo ?? null;
  }


  // Handler for automatically wrapping the base material with our upgrades. We do the wrapping
  // lazily on _read_ rather than write to avoid unnecessary wrapping on transient values.
  get material {
    var derivedMaterial = this._derivedMaterial;
    var baseMaterial = this._baseMaterial ?? this._defaultMaterial ?? (this._defaultMaterial = defaultMaterial.clone());
    if (derivedMaterial == null || (derivedMaterial as DerivedBasicMaterial).baseMaterial != baseMaterial) {
      derivedMaterial = this._derivedMaterial = createTextDerivedMaterial(baseMaterial);
      // dispose the derived material when its base material is disposed:
      // baseMaterial.addEventListener('dispose', onDispose() {
      //   baseMaterial.removeEventListener('dispose', onDispose);
      //   derivedMaterial.dispose();
      // });
    }

    derivedMaterial = derivedMaterial as DerivedBasicMaterial;
    // If text outline is configured, render it as a preliminary draw using Three's multi-material
    // feature (see GlyphsGeometry which sets up `groups` for this purpose) Doing it with multi
    // materials ensures the layers are always rendered consecutively in a consistent order.
    // Each layer will trigger onBeforeRender with the appropriate material.
    if (this.outlineWidth > 0 || this.outlineBlur > 0 || this.outlineOffsetX > 0 || this.outlineOffsetY > 0) {
      var outlineMaterial = derivedMaterial.outlineMaterial;
      if (outlineMaterial == null) {
        derivedMaterial.outlineMaterial = createTextDerivedMaterial(derivedMaterial.baseMaterial);
        outlineMaterial = derivedMaterial.outlineMaterial;
        outlineMaterial!.isTextOutlineMaterial = true;
        outlineMaterial.depthWrite = false;
        outlineMaterial.map = null; //???
        // derivedMaterial.addEventListener('dispose', function onDispose() {
        //   derivedMaterial.removeEventListener('dispose', onDispose);
        //   outlineMaterial.dispose();
        // });
      }
      return [
        outlineMaterial,
        derivedMaterial
      ];
    } else {
      return derivedMaterial;
    }
  }
  
  set material(baseMaterial) {

    if(baseMaterial != null && baseMaterial.type == "DerivedBasicMaterial") {
      var _baseMat = baseMaterial as DerivedBasicMaterial;
      if(_baseMat.isTroikaTextMaterial) {
        this._derivedMaterial = baseMaterial;
        this._baseMaterial = baseMaterial.baseMaterial;
      } else {
        this._baseMaterial = baseMaterial;
      }
    } else {
      this._baseMaterial = baseMaterial;
    }

  }

  get glyphGeometryDetail {
    return this.geometry_cast.detail;
  }
  set glyphGeometryDetail(detail) {
    this.geometry_cast.detail = detail;
  }

  get curveRadius {
    return this.geometry_cast.curveRadius;
  }
  set curveRadius(r) {
    this.geometry_cast.curveRadius = r;
  }

  // Create and update material for shadows upon request:
  get customDepthMaterial {
    return first(this.material).getDepthMaterial();
  }
  get customDistanceMaterial {
    return first(this.material).getDistanceMaterial();
  }

  _prepareForRender(material) {
    var isOutline = material.isTextOutlineMaterial;
    Map<String, dynamic> uniforms = material.uniforms;
    Map<String, dynamic>? textInfo = this.textRenderInfo;
    if (textInfo != null) {
      var sdfTexture = textInfo["sdfTexture"];
      var blockBounds = textInfo["blockBounds"];
      
      uniforms["uTroikaSDFTexture"]["value"] = sdfTexture;
      uniforms["uTroikaSDFTextureSize"]["value"].set(sdfTexture.image.width, sdfTexture.image.height);
      uniforms["uTroikaSDFGlyphSize"]["value"] = textInfo["sdfGlyphSize"];
      uniforms["uTroikaSDFExponent"]["value"] = textInfo["sdfExponent"];
      uniforms["uTroikaTotalBounds"]["value"].fromArray(blockBounds);
      uniforms["uTroikaUseGlyphColors"]["value"] = !isOutline && textInfo["glyphColors"] != null;

      num distanceOffset = 0;
      num blurRadius = 0.0;
      num strokeWidth = 0;
      num fillOpacity;
      num _strokeOpacity = 1;

      num offsetX = 0;
      num offsetY = 0;

      if (isOutline) {
        
        distanceOffset = this._parsePercent(outlineWidth) ?? 0;
        blurRadius = Math.max(0.0, this._parsePercent(outlineBlur) ?? 0);
        fillOpacity = outlineOpacity;
        offsetX = this._parsePercent(outlineOffsetX) ?? 0;
        offsetY = this._parsePercent(outlineOffsetY) ?? 0;
      } else {
        strokeWidth = Math.max(0, this._parsePercent(this.strokeWidth) ?? 0);
        if (strokeWidth > 0) {
          uniforms["uTroikaStrokeColor"]["value"].copy(this.strokeColor);
          _strokeOpacity = this.strokeOpacity;
          if (_strokeOpacity == null) _strokeOpacity = 1;
        }
        fillOpacity = this.fillOpacity;
      }


      uniforms["uTroikaDistanceOffset"]["value"] = distanceOffset.toDouble();
      uniforms["uTroikaPositionOffset"]["value"].set(offsetX, offsetY);
      uniforms["uTroikaBlurRadius"]["value"] = blurRadius.toDouble();
      uniforms["uTroikaStrokeWidth"]["value"] = strokeWidth.toDouble();
      uniforms["uTroikaStrokeOpacity"]["value"] = _strokeOpacity.toDouble();
      uniforms["uTroikaFillOpacity"]["value"] = fillOpacity == null ? 1.0 : fillOpacity.toDouble();
      uniforms["uTroikaCurveRadius"]["value"] = (this.curveRadius ?? 0.0).toDouble();

      if (clipRect != null && clipRect is List && clipRect!.length == 4) {
        uniforms["uTroikaClipRect"]["value"].fromArray(clipRect);
      } else {
        // no clipping - choose a finite rect that shouldn't ever be reached by overflowing glyphs or outlines
        var pad = (this.fontSize ?? 0.1) * 100;
        uniforms["uTroikaClipRect"]["value"].set(
          blockBounds[0] - pad,
          blockBounds[1] - pad,
          blockBounds[2] + pad,
          blockBounds[3] + pad
        );
      }
      this.geometry_cast.applyClipRect(uniforms["uTroikaClipRect"]["value"]);
    }
    uniforms["uTroikaSDFDebug"]["value"] = !!this.debugSDF;
    material.polygonOffset = this.depthOffset != 0;
    material.polygonOffsetFactor = material.polygonOffsetUnits = this.depthOffset;

    // Shortcut for setting material color via `color` prop on the mesh; this is
    // applied only to the derived material to avoid mutating a shared base material.
    var _color = isOutline ? this.outlineColor : this.color;

    if (_color == null) {
      material.color = null; //inherit from base
    } else {

      if(material.color == null) {
        material.color = Color(0,0,1);
      }

      var colorObj = material.color;
      if (!(_color.equal(colorObj)) || _color is Color) {
        colorObj.copy(_color);
      }
    }

    // base orientation
    var orient = this.orientation;
    if (orient != material.orientation) {
      var rotMat = uniforms["uTroikaOrient"]["value"];
      orient = orient.replaceAll(RegExp(r"[^-+xyz]"), '');
      var _reg = RegExp(r"^([-+])([xyz])([-+])([xyz])$");
      RegExpMatch? match;
      if(orient != defaultOrient) {
        match = _reg.firstMatch(orient);
      }
  
      if (match != null) {
        var hSign = match.group(1);
        var hAxis = match.group(2);
        var vSign = match.group(3);
        var vAxis = match.group(4);
        // var [, hSign, hAxis, vSign, vAxis] = match;
        tempVec3a.set(0, 0, 0)[hAxis] = hSign == '-' ? 1 : -1;
        tempVec3b.set(0, 0, 0)[vAxis] = vSign == '-' ? -1 : 1;
        tempMat4.lookAt(origin, tempVec3a.cross(tempVec3b), tempVec3b);
        rotMat.setFromMatrix4(tempMat4);
      } else {
        rotMat.identity();
      }
      material.orientation = orient;
    }
  }

  _parsePercent(value) {
    if (value is String) {
      var _reg = RegExp(r"^(-?[\d.]+)%$");
      var match = _reg.firstMatch(value);
      var pct = match != null ? num.parse(match[1]!) : null;
      value = (pct == null ? 0 : pct / 100) * this.fontSize;
    }
    return value;
  }

  /**
   * Translate a point in local space to an x/y in the text plane.
   */
  localPositionToTextCoords(position, Vector2 target) {
    target.copy(position); //simple non-curved case is 1:1
    var r = this.curveRadius;
    if (r) { //flatten the curve
      target.x = Math.atan2(position.x, Math.abs(r) - Math.abs(position.z)) * Math.abs(r);
    }
    return target;
  }

  /**
   * Translate a point in world space to an x/y in the text plane.
   */
  worldPositionToTextCoords(position, Vector2? target) {
    tempVec3a.copy(position);
    return this.localPositionToTextCoords(this.worldToLocal(tempVec3a), target ?? Vector2(null, null));
  }

  /**
   * @override Custom raycasting to test against the whole text block's max rectangular bounds
   * TODO is there any reason to make this more granular, like within individual line or glyph rects?
   */
  raycast(raycaster, intersects) {
    
    if (textRenderInfo != null) {
      var bounds = textRenderInfo.blockBounds;
      var raycastMesh = curveRadius ? getCurvedRaycastMesh() : getFlatRaycastMesh();
      var geom = raycastMesh.geometry;
      var position = geom.attributes["position"];
      var uv = geom.attributes["uv"];
      for (var i = 0; i < uv.count; i++) {
        var x = bounds[0] + (uv.getX(i) * (bounds[2] - bounds[0]));
        var y = bounds[1] + (uv.getY(i) * (bounds[3] - bounds[1]));
        var z = 0;
        if (curveRadius != 0) {
          z = curveRadius - Math.cos(x / curveRadius) * curveRadius;
          x = Math.sin(x / curveRadius) * curveRadius;
        }
        position.setXYZ(i, x, y, z);
      }
      geom.boundingSphere = this.geometry.boundingSphere;
      geom.boundingBox = this.geometry.boundingBox;
      raycastMesh.matrixWorld = this.matrixWorld;
      raycastMesh.material.side = this.material.side;
      tempArray.length = 0;
      raycastMesh.raycast(raycaster, tempArray);
      for (var i = 0; i < tempArray.length; i++) {
        tempArray[i].object = this;
        intersects.add(tempArray[i]);
      }
    }
  }

  // copy(source) {
  //   // Prevent copying the geometry reference so we don't end up sharing attributes between instances
  //   var geom = this.geometry;
  //   super.copy(source);
  //   this.geometry = geom;

  //   COPYABLE_PROPS.forEach(prop => {
  //     this[prop] = source[prop]
  //   });
  //   return this;
  // }

  // clone() {
  //   return Text().copy(this);
  // }



  // Create setters for properties that affect text layout: SYNCABLE_PROPS
  Map<String, dynamic>? _font;
  get font => _font;
  set font(value) {
    this._font = value;
    this._needsSync = true;
  }

  num _fontSize = 0.1;
  get fontSize => _fontSize;
  set fontSize(value) {
    this._fontSize = value;
    this._needsSync = true;
  }
  
  num _letterSpacing = 0;
  get letterSpacing => _letterSpacing;
  set letterSpacing(value) {
    this._letterSpacing = value;
    this._needsSync = true;
  }

  String _lineHeight = "normal";
  get lineHeight => _lineHeight;
  set lineHeight(value) {
    this._lineHeight = value;
    this._needsSync = true;
  }

  num _maxWidth = double.infinity;
  get maxWidth => _maxWidth;
  set maxWidth(value) {
    this._maxWidth = value;
    this._needsSync = true;
  }

  String _overflowWrap = "normal";
  get overflowWrap => _overflowWrap;
  set overflowWrap(value) {
    this._overflowWrap = value;
    this._needsSync = true;
  }

  String _text = "";
  get text => _text;
  set text(value) {
    this._text = value;
    this._needsSync = true;
  }

  String _direction = "auto";
  get direction => _direction;
  set direction(value) {
    this._direction = value;
    this._needsSync = true;
  }

  String _textAlign = "left";
  get textAlign => _textAlign;
  set textAlign(value) {
    this._textAlign = value;
    this._needsSync = true;
  }

  num _textIndent = 0;
  get textIndent => _textIndent;
  set textIndent(value) {
    this._textIndent = value;
    this._needsSync = true;
  }

  String _whiteSpace = 'normal';
  get whiteSpace => _whiteSpace;
  set whiteSpace(value) {
    this._whiteSpace = value;
    this._needsSync = true;
  }

  num _anchorX = 0;
  get anchorX => _anchorX;
  set anchorX(value) {
    this._anchorX = value;
    this._needsSync = true;
  }

  num _anchorY = 0;
  get anchorY => _anchorY;
  set anchorY(value) {
    this._anchorY = value;
    this._needsSync = true;
  }


  /**
   * @member {object|null} colorRanges
   * WARNING: This API is experimental and may change.
   * This allows more fine-grained control of colors for individual or ranges of characters,
   * taking precedence over the material's `color`. Its format is an Object whose keys each
   * define a starting character index for a range, and whose values are the color for each
   * range. The color value can be a numeric hex color value, a `THREE.Color` object, or
   * any of the strings accepted by `THREE.Color`.
   */
  Color? _colorRanges;
  get colorRanges => _colorRanges;
  set colorRanges(value) {
    this._colorRanges = value;
    this._needsSync = true;
  }

  /**
   * @member {number|null} sdfGlyphSize
   * The size of each glyph's SDF (signed distance field) used for rendering. This must be a
   * power-of-two number. Defaults to 64 which is generally a good balance of size and quality
   * for most fonts. Larger sizes can improve the quality of glyph rendering by increasing
   * the sharpness of corners and preventing loss of very thin lines, at the expense of
   * increased memory footprint and longer SDF generation time.
   */
  int? _sdfGlyphSize;
  get sdfGlyphSize => _sdfGlyphSize;
  set sdfGlyphSize(value) {
    this._sdfGlyphSize = value;
    this._needsSync = true;
  }
  // SYNCABLE_PROPS.forEach(prop => {
  //   var privateKey = '_private_' + prop
  //   Object.defineProperty(Text.prototype, prop, {
  //     get() {
  //       return this[privateKey]
  //     },
  //     set(value) {
  //       if (value != this[privateKey]) {
  //         this[privateKey] = value
  //         this._needsSync = true
  //       }
  //     }
  //   })
  // });


}



