part of troika_three_text;


var templateGeometries = {};
getTemplateGeometry(detail) {
  var geom = templateGeometries[detail];
  if (geom == null) {
    geom = PlaneBufferGeometry(width: 1.0, height: 1.0, widthSegments: detail, heightSegments: detail);
    geom.translate(0.5, 0.5, 0);
    
    templateGeometries[detail] = geom;
  }
  return geom;
}
var tempVec3 = new Vector3.init();

var glyphBoundsAttrName = 'aTroikaGlyphBounds';
var glyphIndexAttrName = 'aTroikaGlyphIndex';
var glyphColorAttrName = 'aTroikaGlyphColor';

/**
@class GlyphsGeometry

A specialized Geometry for rendering a set of text glyphs. Uses InstancedBufferGeometry to
render the glyphs using GPU instancing of a single quad, rather than constructing a whole
geometry with vertices, for much smaller attribute arraybuffers according to this math:

  Where N = number of glyphs...

  Instanced:
  - position: 4 * 3
  - index: 2 * 3
  - normal: 4 * 3
  - uv: 4 * 2
  - glyph x/y bounds: N * 4
  - glyph indices: N * 1
  = 5N + 38

  Non-instanced:
  - position: N * 4 * 3
  - index: N * 2 * 3
  - normal: N * 4 * 3
  - uv: N * 4 * 2
  - glyph indices: N * 1
  = 39N

A downside of this is the rare-but-possible lack of the instanced arrays extension,
which we could potentially work around with a fallback non-instanced implementation.

*/
class GlyphsGeometry extends InstancedBufferGeometry {

  int? _detail;
  num _curveRadius = 0;

  late List? _blockBounds;
  late List? _chunkedBounds;

  // Define groups for rendering text outline as a separate pass; these will only
  // be used when the `material` getter returns an array, i.e. outlineWidth > 0.
  List<Map<String, dynamic>> groups = [
    {"start": 0, "count": Math.Infinity, "materialIndex": 0},
    {"start": 0, "count": Math.Infinity, "materialIndex": 1}
  ];


  GlyphsGeometry() : super() {
    // Preallocate empty bounding objects
    this.boundingSphere = Sphere(null, null);
    this.boundingBox = new Box3(null, null);
    this.detail = 1;
  }

  computeBoundingSphere () {
    // No-op; we'll sync the boundingSphere proactively when needed.
  }

  computeBoundingBox() {
    // No-op; we'll sync the boundingBox proactively when needed.
  }

  set detail(detail) {
    if (detail != this._detail) {
      this._detail = detail;
      if (!(detail is num) || detail < 1) {
        detail = 1;
      }
      var tpl = getTemplateGeometry(detail);

      ['position', 'normal', 'uv'].forEach((attr) {
        var _attribute = tpl.attributes[attr];
        this.attributes[attr] = _attribute.clone();
      });

      this.setIndex(tpl.getIndex().clone());
    }
  }
  get detail {
    return this._detail;
  }

  set curveRadius(r) {
    if (r != this._curveRadius) {
      this._curveRadius = r;
      this._updateBounds();
    }
  }
  get curveRadius {
    return this._curveRadius;
  }

  setAttribute(name, attribute) {
    this.attributes[ name ] = attribute;
    return this;
  }

  /**
   * Update the geometry for a new set of glyphs.
   * @param {Float32Array} glyphBounds - An array holding the planar bounds for all glyphs
   *        to be rendered, 4 entries for each glyph: x1,x2,y1,y1
   * @param {Float32Array} glyphAtlasIndices - An array holding the index of each glyph within
   *        the SDF atlas texture.
   * @param {Array} blockBounds - An array holding the [minX, minY, maxX, maxY] across all glyphs
   * @param {Array} [chunkedBounds] - An array of objects describing bounds for each chunk of N
   *        consecutive glyphs: `{start:N, end:N, rect:[minX, minY, maxX, maxY]}`. This can be
   *        used with `applyClipRect` to choose an optimized `instanceCount`.
   * @param {Uint8Array} [glyphColors] - An array holding r,g,b values for each glyph.
   */
  updateGlyphs(glyphBounds, glyphAtlasIndices, blockBounds, chunkedBounds, glyphColors) {
    // Update the instance attributes
    updateBufferAttr(this, glyphBoundsAttrName, glyphBounds, 4);
    updateBufferAttr(this, glyphIndexAttrName, glyphAtlasIndices, 1);
    updateBufferAttr(this, glyphColorAttrName, glyphColors, 3);
    this._blockBounds = blockBounds;
    this._chunkedBounds = chunkedBounds;
    setInstanceCount(this, glyphAtlasIndices.length);
    this._updateBounds();
  }

  _updateBounds() {
    var bounds = this._blockBounds;
    if (bounds != null) {
      var bbox = this.boundingBox;

      if (curveRadius != null && curveRadius != 0) {
        // var { PI, floor, min, max, sin, cos } = Math;
        var halfPi = Math.PI / 2;
        var twoPi = Math.PI * 2;
        var absR = Math.abs(curveRadius);
        var leftAngle = bounds[0] / absR;
        var rightAngle = bounds[2] / absR;
        var minX = Math.floor((leftAngle + halfPi) / twoPi) != Math.floor((rightAngle + halfPi) / twoPi)
          ? -absR : Math.min(Math.sin(leftAngle) * absR, Math.sin(rightAngle) * absR);
        var maxX = Math.floor((leftAngle - halfPi) / twoPi) != Math.floor((rightAngle - halfPi) / twoPi)
          ? absR : Math.max(Math.sin(leftAngle) * absR, Math.sin(rightAngle) * absR);
        var maxZ = Math.floor((leftAngle + Math.PI) / twoPi) != Math.floor((rightAngle + Math.PI) / twoPi)
          ? absR * 2 : Math.max(absR - Math.cos(leftAngle) * absR, absR - Math.cos(rightAngle) * absR);
        bbox!.min.set(minX, bounds[1], curveRadius < 0 ? -maxZ : 0);
        bbox.max.set(maxX, bounds[3], curveRadius < 0 ? 0 : maxZ);
      } else {
        bbox!.min.set(bounds[0], bounds[1], 0);
        bbox.max.set(bounds[2], bounds[3], 0);
      }
      bbox.getBoundingSphere(this.boundingSphere);
    }
  }

  /**
   * Given a clipping rect, and the chunkedBounds from the last updateGlyphs call, choose the lowest
   * `instanceCount` that will show all glyphs within the clipped view. This is an optimization
   * for long blocks of text that are clipped, to skip vertex shader evaluation for glyphs that would
   * be clipped anyway.
   *
   * Note that since `drawElementsInstanced[ANGLE]` only accepts an instance count and not a starting
   * offset, this optimization becomes less effective as the clipRect moves closer to the end of the
   * text block. We could fix that by switching from instancing to a full geometry with a drawRange,
   * but at the expense of much larger attribute buffers (see classdoc above.)
   *
   * @param {Vector4} clipRect
   */
  applyClipRect(clipRect) {
    var count = this.getAttribute(glyphIndexAttrName).count;
    var chunks = this._chunkedBounds;
    if (chunks != null) {
      var i = chunks.length;
      while ( i > 0) {
        i--;
        count = chunks[i]["end"];
        var rect = chunks[i]["rect"];
        // note: both rects are l-b-r-t
        if (rect[1] < clipRect.w && rect[3] > clipRect.y && rect[0] < clipRect.z && rect[2] > clipRect.x) {
          break;
        }
      }
    }
    setInstanceCount(this, count);
  }
}



updateBufferAttr(geom, attrName, newArray, itemSize) {


  var attr = geom.getAttribute(attrName);
  if (newArray != null) {
    // If length isn't changing, just update the attribute's array data
    if (attr != null && attr.array.length == newArray.length) {
      attr.array.set(newArray);
      attr.needsUpdate = true;
    } else {
      geom.setAttribute(attrName, new InstancedBufferAttribute(newArray, itemSize, null, null));
      // If the new attribute has a different size, we also have to (as of r117) manually clear the
      // internal cached max instance count. See https://github.com/mrdoob/three.js/issues/19706
      // It's unclear if this is a threejs bug or a truly unsupported scenario; discussion in
      // that ticket is ambiguous as to whether replacing a BufferAttribute with one of a
      // different size is supported, but https://github.com/mrdoob/three.js/pull/17418 strongly
      // implies it should be supported. It's possible we need to

      
      geom.dispose(); //for r118+, more robust feeling, but more heavy-handed than I'd like
    }
  } else if (attr != null) {
    geom.deleteAttribute(attrName);
  }
}


setInstanceCount(geom, count) {
  geom.instanceCount = count;
}


