
part of troika_three_text;
/**
 * Initializes and returns a function to generate an SDF texture for a given glyph.
 * @param {function} createGlyphSegmentsIndex - factory for a GlyphSegmentsIndex implementation.
 * @param {number} config.sdfExponent
 * @param {number} config.sdfMargin
 *
 * @return {function(Object): {renderingBounds: [minX, minY, maxX, maxY], textureData: Uint8Array}}
 */
createSDFGenerator(createGlyphSegmentsIndex, config) {
  var sdfExponent = config["sdfExponent"];
  var sdfMargin = config["sdfMargin"];
  /**
   * How many straight line segments to use when approximating a glyph's quadratic/cubic bezier curves.
   */
  var CURVE_POINTS = 16;

  /**
   * Find the point on a quadratic bezier curve at t where t is in the range [0, 1]
   */
  pointOnQuadraticBezier(x0, y0, x1, y1, x2, y2, t) {
    var t2 = 1 - t;
    return {
      "x": t2 * t2 * x0 + 2 * t2 * t * x1 + t * t * x2,
      "y": t2 * t2 * y0 + 2 * t2 * t * y1 + t * t * y2
    };
  }

  /**
   * Find the point on a cubic bezier curve at t where t is in the range [0, 1]
   */
  pointOnCubicBezier(x0, y0, x1, y1, x2, y2, x3, y3, t) {
    var t2 = 1 - t;
    return {
      "x": t2 * t2 * t2 * x0 + 3 * t2 * t2 * t * x1 + 3 * t2 * t * t * x2 + t * t * t * x3,
      "y": t2 * t2 * t2 * y0 + 3 * t2 * t2 * t * y1 + 3 * t2 * t * t * y2 + t * t * t * y3
    };
  }

  /**
   * Generate an SDF texture segment for a single glyph.
   * @param {object} glyphObj
   * @param {number} sdfSize - the length of one side of the SDF image.
   *        Larger images encode more details. Must be a power of 2.
   * @return {{textureData: Uint8Array, renderingBounds: *[]}}
   */
  generateSDF(Map<String, dynamic> glyphObj, sdfSize) {
    //console.time('glyphSDF')

    var textureData = new Uint8List(sdfSize * sdfSize);

    // Determine mapping between glyph grid coords and sdf grid coords
    num glyphW = glyphObj["xMax"] - glyphObj["xMin"];
    num glyphH = glyphObj["yMax"] - glyphObj["yMin"];

    // Choose a maximum search distance radius in font units, based on the glyph's max dimensions
    var fontUnitsMaxSearchDist = Math.max(glyphW, glyphH);

    // Margin - add an extra 0.5 over the configured value because the outer 0.5 doesn't contain
    // useful interpolated values and will be ignored anyway.
    var fontUnitsMargin = Math.max(glyphW, glyphH) / sdfSize * (sdfMargin * sdfSize + 0.5);

    // Metrics of the texture/quad in font units
    var textureMinFontX = glyphObj["xMin"] - fontUnitsMargin;
    var textureMinFontY = glyphObj["yMin"] - fontUnitsMargin;
    var textureMaxFontX = glyphObj["xMax"] + fontUnitsMargin;
    var textureMaxFontY = glyphObj["yMax"] + fontUnitsMargin;
    num fontUnitsTextureWidth = textureMaxFontX - textureMinFontX;
    num fontUnitsTextureHeight = textureMaxFontY - textureMinFontY;
    var fontUnitsTextureMaxDim = Math.max(fontUnitsTextureWidth, fontUnitsTextureHeight);

    textureXToFontX(x) {
      return textureMinFontX + fontUnitsTextureWidth * x / sdfSize;
    }

    textureYToFontY(y) {
      return textureMinFontY + fontUnitsTextureHeight * y / sdfSize;
    }

    int pathCommandCount = glyphObj["pathCommandCount"];

    if (pathCommandCount != 0) { //whitespace chars will have no commands, so we can skip all this
      // Decompose all paths into straight line segments and add them to a quadtree
      Map<String, dynamic> lineSegmentsIndex = createGlyphSegmentsIndex();
      var firstX, firstY, prevX, prevY;
      glyphObj["forEachPathCommand"]((type, x0, y0, x1, y1, x2, y2) {
        switch (type) {
          case 'M':
            prevX = firstX = x0;
            prevY = firstY = y0;
            break;
          case 'L':
            if (x0 != prevX || y0 != prevY) { //yup, some fonts have zero-length line commands
              lineSegmentsIndex["addLineSegment"](prevX, prevY, (prevX = x0), (prevY = y0));
            }
            break;
          case 'Q': {
            var prevPoint = {"x": prevX, "y": prevY};
            for (var i = 1; i < CURVE_POINTS; i++) {
              var nextPoint = pointOnQuadraticBezier(
                prevX, prevY,
                x0, y0,
                x1, y1,
                i / (CURVE_POINTS - 1)
              );
              lineSegmentsIndex["addLineSegment"](prevPoint["x"], prevPoint["y"], nextPoint["x"], nextPoint["y"]);
              prevPoint = nextPoint;
            }
            prevX = x1;
            prevY = y1;
            break;
          }
          case 'C': {
            var prevPoint = {"x": prevX, "y": prevY};
            for (var i = 1; i < CURVE_POINTS; i++) {
              var nextPoint = pointOnCubicBezier(
                prevX, prevY,
                x0, y0,
                x1, y1,
                x2, y2,
                i / (CURVE_POINTS - 1)
              );
              lineSegmentsIndex["addLineSegment"](prevPoint["x"], prevPoint["y"], nextPoint["x"], nextPoint["y"]);
              prevPoint = nextPoint;
            }
            prevX = x2;
            prevY = y2;
            break;
          }
          case 'Z':
            if (prevX != firstX || prevY != firstY) {
              lineSegmentsIndex["addLineSegment"](prevX, prevY, firstX, firstY);
            }
            break;
        }
      });

      // For each target SDF texel, find the distance from its center to its nearest line segment,
      // map that distance to an alpha value, and write that alpha to the texel
      for (var sdfX = 0; sdfX < sdfSize; sdfX++) {
        for (var sdfY = 0; sdfY < sdfSize; sdfY++) {
          num signedDist = lineSegmentsIndex["findNearestSignedDistance"](
            textureXToFontX(sdfX + 0.5),
            textureYToFontY(sdfY + 0.5)
            // fontUnitsMaxSearchDist
          );

          // Use an exponential scale to ensure the texels very near the glyph path have adequate
          // precision, while allowing the distance field to cover the entire texture, given that
          // there are only 8 bits available. Formula visualized: https://www.desmos.com/calculator/uiaq5aqiam
          var alpha = Math.pow((1 - (signedDist).abs() / fontUnitsTextureMaxDim), sdfExponent) / 2;
          if (signedDist < 0) {
            alpha = 1 - alpha;
          }

          alpha = Math.max(0, Math.min( 255, (alpha * 255).round() )).toDouble(); //clamp
          textureData[(sdfY * sdfSize + sdfX).toInt()] = alpha.toInt();
        }
      }
    }

    //console.timeEnd('glyphSDF')

    Map<String, dynamic> _reuslt0 = {
      "textureData": textureData,

      "renderingBounds": [
        textureMinFontX,
        textureMinFontY,
        textureMaxFontX,
        textureMaxFontY
      ]
    };

    return _reuslt0;
  }


  return generateSDF;
}
