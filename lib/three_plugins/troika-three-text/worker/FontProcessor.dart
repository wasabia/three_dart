part of troika_three_text;

/**
 * Creates a self-contained environment for processing text rendering requests.
 *
 * It is important that this function has no closure dependencies, so that it can be easily injected
 * into the source for a Worker without requiring a build step or complex dependency loading. All its
 * dependencies must be passed in at initialization.
 *
 * @param {function} fontParser - a function that accepts an ArrayBuffer of the font data and returns
 * a standardized structure giving access to the font and its glyphs:
 *   {
 *     unitsPerEm: number,
 *     ascender: number,
 *     descender: number,
 *     forEachGlyph(string, fontSize, letterSpacing, callback) {
 *       //invokes callback for each glyph to render, passing it an object:
 *       callback({
 *         index: number,
 *         advanceWidth: number,
 *         xMin: number,
 *         yMin: number,
 *         xMax: number,
 *         yMax: number,
 *         pathCommandCount: number,
 *         forEachPathCommand(callback) {
 *           //invokes callback for each path command, with args:
 *           callback(
 *             type: 'M|L|C|Q|Z',
 *             ...args //0 to 6 args depending on the type
 *           )
 *         }
 *       })
 *     }
 *   }
 * @param {function} sdfGenerator - a function that accepts a glyph object and generates an SDF texture
 * from it.
 * @param {Object} config
 * @return {Object}
 */
class FontProcessor {

  /**
   * @private
   * Holds data about font glyphs and how they relate to SDF atlases
   *
   * {
   *   'fontUrl@sdfSize': {
   *     fontObj: {}, //result of the fontParser
   *     glyphs: {
   *       [glyphIndex]: {
   *         atlasIndex: 0,
   *         glyphObj: {}, //glyph object from the fontParser
   *         renderingBounds: [x0, y0, x1, y1]
   *       },
   *       ...
   *     },
   *     glyphCount: 123
   *   }
   * }
   */
  var fontAtlases = {};

  /**
   * Holds parsed font objects by url
   */
  var fonts = {};

  var INF = Math.Infinity;

  // Set of Unicode Default_Ignorable_Code_Point characters, these will not produce visible glyphs
  var DEFAULT_IGNORABLE_CHARS = RegExp("[\u00AD\u034F\u061C\u115F-\u1160\u17B4-\u17B5\u180B-\u180E\u200B-\u200F\u202A-\u202E\u2060-\u206F\u3164\uFE00-\uFE0F\uFEFF\uFFA0\uFFF0-\uFFF8]");

  late String defaultFontURL;
  Function fontParser;
  Function sdfGenerator;

  Map<String, dynamic> config;

  FontProcessor(this.fontParser, this.sdfGenerator, this.config) {
    defaultFontURL = config["defaultFontURL"];
  }

  
  /**
   * Load a given font url
   */
  doLoadFont(url, callback) {
    tryLoad() async {
      var onError = (err) {
        print("Failure loading font ${url}${url == defaultFontURL ? '' : '; trying fallback'} ${err} ");
        if (url != defaultFontURL) {
          url = defaultFontURL;
          tryLoad();
        }
      };

      // try {
        var response = await http.get(Uri.parse(url));
        
        var fontObj = fontParser(response.bodyBytes);
        callback(fontObj);

        // var request = new XMLHttpRequest()
        // request.open('get', url, true)
        // request.responseType = 'arraybuffer'
        // request.onload = function () {
        //   if (request.status >= 400) {
        //     onError(new Error(request.statusText))
        //   }
        //   else if (request.status > 0) {
        //     try {
        //       var fontObj = fontParser(request.response)
        //       callback(fontObj)
        //     } catch (e) {
        //       onError(e)
        //     }
        //   }
        // };
        // request.onerror = onError;
        // request.send();
      // } catch(err) {
      //   onError(err);
      // }
    }
    tryLoad();
  }


  /**
   * Load a given font url if needed, invoking a callback when it's loaded. If already
   * loaded, the callback will be called synchronously.
   */
  loadFont(Map<String, dynamic> font, callback) {

    var fontObj = fontParser(font);
    callback(fontObj);

    // if (fontUrl == null) fontUrl = defaultFontURL;
    // var font = fonts[fontUrl];
    // if (font != null) {
    //   // if currently loading font, add to callbacks, otherwise execute immediately
    //   if (font.pending) {
    //     font.pending.add(callback);
    //   } else {
    //     callback(font);
    //   }
    // } else {
    //   fonts[fontUrl] = {"pending": [callback]};
    //   doLoadFont(fontUrl, (fontObj) {
    //     var callbacks = fonts[fontUrl]["pending"];
    //     fonts[fontUrl] = fontObj;
    //     callbacks.forEach((cb) => cb(fontObj));
    //   });
    // }
  }


  /**
   * Get the atlas data for a given font url, loading it from the network and initializing
   * its atlas data objects if necessary.
   */
  getSdfAtlas(Map<String, dynamic> font, sdfGlyphSize, callback) {
    String _familyName = font["familyName"];

    var atlasKey = "${_familyName}@${sdfGlyphSize}";
    var atlas = fontAtlases[atlasKey];
    if (atlas != null) {
      callback(atlas);
    } else {
      loadFont(font, (fontObj) {
        atlas = fontAtlases[atlasKey] ?? (fontAtlases[atlasKey] = {
          "fontObj": fontObj,
          "glyphs": {},
          "glyphCount": 0
        });
        callback(atlas);
      });
    }
  }


  /**
   * Main entry point.
   * Process a text string with given font and formatting parameters, and return all info
   * necessary to render all its glyphs.
   */
  process(args, callback, {metricsOnly=false}) {
    var text = args["text"] ?? "";
    var font = args["font"];
    var sdfGlyphSize = args["sdfGlyphSize"] ?? 64;
    var fontSize = args["fontSize"] ?? 1;
    var letterSpacing = args["letterSpacing"] ?? 0;
    var lineHeight = args["lineHeight"] ?? "normal";
    var maxWidth = args["maxWidth"] ?? INF;
    var direction = args["direction"];
    var textAlign = args["textAlign"] ?? "left";
    var textIndent = args["textIndent"] ?? 0;
    var whiteSpace = args["whiteSpace"] ?? "normal";
    var overflowWrap = args["overflowWrap"] ?? "normal";
    var anchorX = args["anchorX"] ?? 0;
    var anchorY = args["anchorY"] ?? 0;
    var includeCaretPositions = args["includeCaretPositions"] ?? false;
    var chunkedBoundsSize = args["chunkedBoundsSize"] ?? 8192;
    var colorRanges = args["colorRanges"];

    var mainStart = now();
    Map<String, dynamic> timings = {"total": 0, "fontLoad": 0, "layout": 0, "sdf": {}, "sdfTotal": 0};

    // Ensure newlines are normalized
    if (text.indexOf('\r') > -1) {
      print('FontProcessor.process: got text with \\r chars; normalizing to \\n');
      text = text.replaceAll("\r\n", '\n').replaceAll("\r", '\n');
    }

    // Ensure we've got numbers not strings
    // fontSize = +fontSize;
    // letterSpacing = +letterSpacing;
    // maxWidth = +maxWidth;
    // textIndent = +textIndent;

    getSdfAtlas(font, sdfGlyphSize, (atlas) {
      var fontObj = atlas["fontObj"];
      var hasMaxWidth = isFinite(maxWidth);
      var newGlyphs = null;
      var glyphBounds = null;
      var glyphAtlasIndices = null;
      var glyphColors = null;
      var caretPositions = null;
      var visibleBounds = null;
      var chunkedBounds = null;
      num maxLineWidth = 0;
      var renderableGlyphCount = 0;
      var canWrap = whiteSpace != 'nowrap';
   
      var ascender = fontObj.ascender;
      var descender = fontObj.descender;

      var unitsPerEm = fontObj.unitsPerEm;

      timings["fontLoad"] = now() - mainStart;
      var layoutStart = now();

      // Find conversion between native font units and fontSize units; this will already be done
      // for the gx/gy values below but everything else we'll need to convert
      var fontSizeMult = fontSize / unitsPerEm;

      // Determine appropriate value for 'normal' line height based on the font's actual metrics
      // TODO this does not guarantee individual glyphs won't exceed the line height, e.g. Roboto; should we use yMin/Max instead?
      if (lineHeight == 'normal') {
        lineHeight = (ascender - descender) / unitsPerEm;
      }

      // Determine line height and leading adjustments
      lineHeight = lineHeight * fontSize;
      var halfLeading = (lineHeight - (ascender - descender) * fontSizeMult) / 2;
      var topBaseline = -(ascender * fontSizeMult + halfLeading);
      var caretHeight = Math.min(lineHeight, (ascender - descender) * fontSizeMult);
      var caretBottomOffset = (ascender + descender) / 2 * fontSizeMult - caretHeight / 2;

      // Distribute glyphs into lines based on wrapping
      var lineXOffset = textIndent;
      var currentLine = new TextLine();
      var lines = [currentLine];

      fontObj.forEachGlyph(text, fontSize, letterSpacing, (glyphObj, glyphX, charIndex) {
        var char = text[charIndex];
        var glyphWidth = glyphObj["advanceWidth"] * fontSizeMult;
        var curLineCount = currentLine.count;
        var nextLine;

        // Calc isWhitespace and isEmpty once per glyphObj
        if ( glyphObj.keys.toList().indexOf("isEmpty") < 0 ) {
          var _breg = RegExp(r"\s"); 
          glyphObj["isWhitespace"] = char != null && _breg.hasMatch(char);
          glyphObj["isEmpty"] = glyphObj["xMin"] == glyphObj["xMax"] || glyphObj["yMin"] == glyphObj["yMax"] || DEFAULT_IGNORABLE_CHARS.hasMatch(char);
        }

        if (!glyphObj["isWhitespace"] && !glyphObj["isEmpty"]) {
          renderableGlyphCount++;
        }

        // If a non-whitespace character overflows the max width, we need to soft-wrap
        if (canWrap && hasMaxWidth && !glyphObj["isWhitespace"] && glyphX + glyphWidth + lineXOffset > maxWidth && curLineCount) {
          // If it's the first char after a whitespace, start a new line
          if (currentLine.glyphAt(curLineCount - 1).glyphObj["isWhitespace"]) {
            nextLine = new TextLine();
            lineXOffset = -glyphX;
          } else {
            // Back up looking for a whitespace character to wrap at
            for (var i = curLineCount; i--;) {
              // If we got the start of the line there's no soft break point; make hard break if overflowWrap='break-word'
              if (i == 0 && overflowWrap == 'break-word') {
                nextLine = new TextLine();
                lineXOffset = -glyphX;
                break;
              }
              // Found a soft break point; move all chars since it to a new line
              else if (currentLine.glyphAt(i).glyphObj["isWhitespace"]) {
                nextLine = currentLine.splitAt(i + 1);
                var adjustX = nextLine.glyphAt(0).x;
                lineXOffset -= adjustX;
                for (var j = nextLine.count; j--;) {
                  nextLine.glyphAt(j).x -= adjustX;
                }
                break;
              }
            }
          }
          if (nextLine) {
            currentLine.isSoftWrapped = true;
            currentLine = nextLine;
            lines.add(currentLine);
            maxLineWidth = maxWidth; //after soft wrapping use maxWidth as calculated width
          }
        }

        var fly = currentLine.glyphAt(currentLine.count);
        fly.glyphObj = glyphObj;
        fly.x = glyphX + lineXOffset;
        fly.width = glyphWidth;
        fly.charIndex = charIndex;

        // Handle hard line breaks
        if (char == '\n') {
          currentLine = new TextLine();
          lines.add(currentLine);
          lineXOffset = -(glyphX + glyphWidth + (letterSpacing * fontSize)) + textIndent;
        }
      });

      // Calculate width of each line (excluding trailing whitespace) and maximum block width
      lines.forEach((line) {
        var i = line.count;
        while (i>0) {
          i--;

          var _glyph = line.glyphAt(i);
          var glyphObj = _glyph.glyphObj;
          var x = _glyph.x;
          var width = _glyph.width;
          
          if (!glyphObj["isWhitespace"]) {
            line.width = x + width;
            if (line.width > maxLineWidth) {
              maxLineWidth = line.width;
            }
            return;
          }
        }
      });

      // Find overall position adjustments for anchoring
      num anchorXOffset = 0;
      num anchorYOffset = 0;
      if (anchorX != null) {
        if (anchorX is num) {
          anchorXOffset = -anchorX;
        } else if (anchorX is String) {
          anchorXOffset = -maxLineWidth * (
            anchorX == 'left' ? 0 :
            anchorX == 'center' ? 0.5 :
            anchorX == 'right' ? 1 :
            parsePercent(anchorX)
          );
        }
      }
      if (anchorY != null) {
        if (anchorY is num) {
          anchorYOffset = -anchorY;
        } else if (anchorY is String) {
          var height = lines.length * lineHeight;
          anchorYOffset = anchorY == 'top' ? 0 :
            anchorY == 'top-baseline' ? -topBaseline :
            anchorY == 'middle' ? height / 2 :
            anchorY == 'bottom' ? height :
            anchorY == 'bottom-baseline' ? height - halfLeading + descender * fontSizeMult :
            parsePercent(anchorY) * height;
        }
      }

      if (!metricsOnly) {

        var bidiLevelsResult = bidi.getEmbeddingLevels(text, direction);

        // Process each line, applying alignment offsets, adding each glyph to the atlas, and
        // collecting all renderable glyphs into a single collection.
        glyphBounds = new Float32List(renderableGlyphCount * 4);
        glyphAtlasIndices = new Float32List(renderableGlyphCount);
        visibleBounds = [INF, INF, -INF, -INF];
        chunkedBounds = [];
        var lineYOffset = topBaseline;
        if (includeCaretPositions) {
          caretPositions = new Float32List(text.length * 3);
        }
        if (colorRanges != null) {
          glyphColors = new Uint8List(renderableGlyphCount * 3);
        }
        var renderableGlyphIndex = 0;
        var prevCharIndex = -1;
        var colorCharIndex = -1;
        var chunk;
        var currentColor;
        lines.asMap().forEach((lineIndex, line) {
          // var {count:lineGlyphCount, width:lineWidth} = line;

          var lineGlyphCount = line.count;
          var lineWidth = line.width;

          // Ignore empty lines
          if (lineGlyphCount > 0) {
            // Count trailing whitespaces, we want to ignore these for certain things
            var trailingWhitespaceCount = 0;
            var i = lineGlyphCount;
            while ( i-- != 0 && line.glyphAt(i).glyphObj["isWhitespace"] ) {
              trailingWhitespaceCount++;
            }

            // Apply horizontal alignment adjustments
            num lineXOffset = 0;
            num justifyAdjust = 0;
            if (textAlign == 'center') {
              lineXOffset = (maxLineWidth - lineWidth) / 2;
            } else if (textAlign == 'right') {
              lineXOffset = maxLineWidth - lineWidth;
            } else if (textAlign == 'justify' && line.isSoftWrapped) {
              // count non-trailing whitespace characters, and we'll adjust the offsets per character in the next loop
              var whitespaceCount = 0;
              for (var i = lineGlyphCount - trailingWhitespaceCount; i--;) {
                if (line.glyphAt(i).glyphObj.isWhitespace) {
                  whitespaceCount++;
                }
              }
              justifyAdjust = (maxLineWidth - lineWidth) / whitespaceCount;
            }
            if (justifyAdjust != 0 || lineXOffset != 0) {
              num justifyOffset = 0;
              for (var i = 0; i < lineGlyphCount; i++) {
                var glyphInfo = line.glyphAt(i);
                var glyphObj = glyphInfo.glyphObj;
                glyphInfo.x += lineXOffset + justifyOffset;
                // Expand non-trailing whitespaces for justify alignment
                if (justifyAdjust != 0 && glyphObj.isWhitespace && i < lineGlyphCount - trailingWhitespaceCount) {
                  justifyOffset += justifyAdjust;
                  glyphInfo.width += justifyAdjust;
                }
              }
            }

            // Perform bidi range flipping
            var flips = bidi.getReorderSegments(
              text, bidiLevelsResult, line.glyphAt(0).charIndex, line.glyphAt(line.count - 1).charIndex
            );

            for (var fi = 0; fi < flips.length; fi++) {
              // var [start, end] = flips[fi];
              var _fi = flips[fi];
              var start = _fi[0];
              var end = _fi[1];
              
              // Map start/end string indices to indices in the line
              var left = Math.Infinity, right = -Math.Infinity;
              for (var i = 0; i < lineGlyphCount; i++) {
                if (line.glyphAt(i).charIndex >= start) { // gte to handle removed characters
                  var startInLine = i, endInLine = i;
                  for (; endInLine < lineGlyphCount; endInLine++) {
                    var info = line.glyphAt(endInLine);
                    if (info.charIndex > end) {
                      break;
                    }
                    if (endInLine < lineGlyphCount - trailingWhitespaceCount) { //don't include trailing ws in flip width
                      left = Math.min(left, info.x);
                      right = Math.max(right, info.x + info.width);
                    }
                  }
                  for (var j = startInLine; j < endInLine; j++) {
                    var glyphInfo = line.glyphAt(j);
                    glyphInfo.x = right - (glyphInfo.x + glyphInfo.width - left);
                  }
                  break;
                }
              }
            }

            // Assemble final data arrays
            var glyphObj;
            var setGlyphObj = (g) { glyphObj = g; };

            print(" lineGlyphCount: ${lineGlyphCount} ");

            for (var i = 0; i < lineGlyphCount; i++) {
              var glyphInfo = line.glyphAt(i);
              glyphObj = glyphInfo.glyphObj;

              

              // Replace mirrored characters in rtl
              var rtl = bidiLevelsResult["levels"][glyphInfo.charIndex] & 1; //odd level means rtl
              if (rtl != 0) {
                var mirrored = bidi.getMirroredCharacter(text[glyphInfo.charIndex]);
                if (mirrored) {
                  fontObj.forEachGlyph(mirrored, 0, 0, setGlyphObj);
                }
              }

              // Add caret positions
              if (includeCaretPositions) {
                var charIndex = glyphInfo.charIndex;
                var caretLeft = glyphInfo.x + anchorXOffset;
                var caretRight = glyphInfo.x + glyphInfo.width + anchorXOffset;
                caretPositions[charIndex * 3] = rtl != 0 ? caretRight : caretLeft; //start edge x
                caretPositions[charIndex * 3 + 1] = rtl != 0 ? caretLeft : caretRight; //end edge x
                caretPositions[charIndex * 3 + 2] = lineYOffset + caretBottomOffset + anchorYOffset; //common bottom y

                // If we skipped any chars from the previous glyph (due to ligature subs), copy the
                // previous glyph's info to those missing char indices. In the future we may try to
                // use the font's LigatureCaretList table to get interior caret positions.
                while (charIndex - prevCharIndex > 1) {
                  caretPositions[(prevCharIndex + 1) * 3] = caretPositions[prevCharIndex * 3];
                  caretPositions[(prevCharIndex + 1) * 3 + 1] = caretPositions[prevCharIndex * 3 + 1];
                  caretPositions[(prevCharIndex + 1) * 3 + 2] = caretPositions[prevCharIndex * 3 + 2];
                  prevCharIndex++;
                }
                prevCharIndex = charIndex;
              }

              // Track current color range
              if (colorRanges != null) {
                var charIndex = glyphInfo["charIndex"];
                while(charIndex > colorCharIndex) {
                  colorCharIndex++;
                  if (colorRanges.hasOwnProperty(colorCharIndex)) {
                    currentColor = colorRanges[colorCharIndex];
                  }
                }
              }

              print(" i: ${i} glyphObj isWhitespace: ${glyphObj["isWhitespace"]} ");
              print(" i: ${i} glyphObj isEmpty: ${glyphObj["isEmpty"]} ");

              bool _isWhitespace = glyphObj["isWhitespace"];
              bool _isEmpty = glyphObj["isEmpty"];

              // Get atlas data for renderable glyphs
              if (!_isWhitespace && !_isEmpty) {
                var idx = renderableGlyphIndex++;

                
                // If we haven't seen this glyph yet, generate its SDF
                Map<String, dynamic>? glyphAtlasInfo = atlas["glyphs"][glyphObj["index"]];
                if (glyphAtlasInfo == null) {
                  var sdfStart = now();
                  Map<String, dynamic> glyphSDFData = sdfGenerator(glyphObj, sdfGlyphSize);
                  timings["sdf"][text[glyphInfo.charIndex]] = now() - sdfStart;

                  // Assign this glyph the next available atlas index
                  glyphSDFData["atlasIndex"] = atlas["glyphCount"]++;

                  // Queue it up in the response's newGlyphs list
                  if (newGlyphs == null) newGlyphs = [];
                  newGlyphs.add(glyphSDFData);

                  // Store its metadata (not the texture) in our atlas info
                  glyphAtlasInfo = {
                    "atlasIndex": glyphSDFData["atlasIndex"],
                    "glyphObj": glyphObj,
                    "renderingBounds": glyphSDFData["renderingBounds"]
                  };
                  atlas["glyphs"][glyphObj["index"]] = glyphAtlasInfo;
                }

                // Determine final glyph quad bounds and add them to the glyphBounds array
                var bounds = glyphAtlasInfo["renderingBounds"];
                var startIdx = idx * 4;
                var xStart = glyphInfo.x + anchorXOffset;
                var yStart = lineYOffset + anchorYOffset;
                glyphBounds[startIdx] = xStart + bounds[0] * fontSizeMult;
                glyphBounds[startIdx + 1] = yStart + bounds[1] * fontSizeMult;
                glyphBounds[startIdx + 2] = xStart + bounds[2] * fontSizeMult;
                glyphBounds[startIdx + 3] = yStart + bounds[3] * fontSizeMult;

                // Track total visible bounds
                var visX0 = xStart + glyphObj["xMin"] * fontSizeMult;
                var visY0 = yStart + glyphObj["yMin"] * fontSizeMult;
                var visX1 = xStart + glyphObj["xMax"] * fontSizeMult;
                var visY1 = yStart + glyphObj["yMax"] * fontSizeMult;
                if (visX0 < visibleBounds[0]) visibleBounds[0] = visX0;
                if (visY0 < visibleBounds[1]) visibleBounds[1] = visY0;
                if (visX1 > visibleBounds[2]) visibleBounds[2] = visX1;
                if (visY1 > visibleBounds[3]) visibleBounds[3] = visY1;

                // Track bounding rects for each chunk of N glyphs
                if (idx % chunkedBoundsSize == 0) {
                  chunk = {"start": idx, "end": idx, "rect": [INF, INF, -INF, -INF]};
                  chunkedBounds.add(chunk);
                }
                chunk["end"]++;
                var chunkRect = chunk["rect"];
                if (visX0 < chunkRect[0]) chunkRect[0] = visX0;
                if (visY0 < chunkRect[1]) chunkRect[1] = visY0;
                if (visX1 > chunkRect[2]) chunkRect[2] = visX1;
                if (visY1 > chunkRect[3]) chunkRect[3] = visY1;

                // Add to atlas indices array
                glyphAtlasIndices[idx] = glyphAtlasInfo["atlasIndex"];

                // Add colors
                if (colorRanges != null) {
                  var start = idx * 3;
                  glyphColors[start] = currentColor >> 16 & 255;
                  glyphColors[start + 1] = currentColor >> 8 & 255;
                  glyphColors[start + 2] = currentColor & 255;
                }
              }
            }
          }

          // Increment y offset for next line
          lineYOffset -= lineHeight;
        });
      }

      // Timing stats
      var _sdf = timings["sdf"]!;
      for (var ch in _sdf.keys) {
        timings["sdfTotal"] += timings["sdf"][ch];
      }
      timings["layout"] = now() - layoutStart - timings["sdfTotal"];
      timings["total"] = now() - mainStart;


      var _result = {
        "glyphBounds": glyphBounds, //rendering quad bounds for each glyph [x1, y1, x2, y2]
        "glyphAtlasIndices": glyphAtlasIndices, //atlas indices for each glyph
        "caretPositions": caretPositions, //x,y of bottom of cursor position before each char, plus one after last char
        "caretHeight": caretHeight, //height of cursor from bottom to top
        "glyphColors": glyphColors, //color for each glyph, if color ranges supplied
        "chunkedBounds": chunkedBounds, //total rects per (n=chunkedBoundsSize) consecutive glyphs
        "ascender": ascender * fontSizeMult, //font ascender
        "descender": descender * fontSizeMult, //font descender
        "lineHeight": lineHeight, //computed line height
        "topBaseline": topBaseline, //y coordinate of the top line's baseline
        "blockBounds": [ //bounds for the whole block of text, including vertical padding for lineHeight
          anchorXOffset,
          anchorYOffset - lines.length * lineHeight,
          anchorXOffset + maxLineWidth,
          anchorYOffset
        ],
        "visibleBounds": visibleBounds, //total bounds of visible text paths, may be larger or smaller than totalBounds
        "newGlyphSDFs": newGlyphs, //if this request included any new SDFs for the atlas, they'll be included here
        "timings": timings
      };

      callback(_result);
    });
  }


  /**
   * For a given text string and font parameters, determine the resulting block dimensions
   * after wrapping for the given maxWidth.
   * @param args
   * @param callback
   */
  measure(args, callback) {
    process(args, (result) {
      var _bb = result.blockBounds;
      var x0 = _bb[0];
      var y0 = _bb[1];
      var x1 = _bb[2];
      var y1 = _bb[3];
    
      callback({
        "width": x1 - x0,
        "height": y1 - y0
      });
    }, metricsOnly: true);
  }

  parsePercent(str) {
    var _reg = RegExp(r"^([\d.]+)%$");
    var match = _reg.firstMatch(str);

    var pct = match != null ? num.parse(match.group(1)!) : null;
    return pct == null ? 0 : pct / 100;
  }

  now() {
    return DateTime.now().millisecondsSinceEpoch;
  }

}

var textLineProps = ['glyphObj', 'x', 'width', 'charIndex'];
 // Array-backed structure for a single line's glyphs data
class TextLine {
  Map<int, dynamic> data = {};
  
  num width = 0;
  bool isSoftWrapped = false;

  TextLine() {

  }

  get count => Math.ceil(this.data.keys.length / textLineProps.length);
  
  glyphAt(i) {
    var fly = TextLine.flyweight;
    fly.data = this.data;
    fly.index = i;
    return fly;
  }

  splitAt(i) {
    var newLine = new TextLine();
    // newLine.data = splice(this.data, i * textLineProps.length);

    this.data.keys.forEach((element) {
      if(element >= i * textLineProps.length) {
        this.data.remove(element);
      }
    });

    newLine.data = this.data;

    return newLine;
  }

  static get flyweight => Fly();

}
  

class Fly {

  late Map<int, dynamic> data;
  int index = 0;

  Fly() {

  }

  // 'glyphObj', 'x', 'width', 'charIndex'
  get glyphObj => this.data[this.index * textLineProps.length + 0];
  set glyphObj(value) {
    this.data[this.index * textLineProps.length + 0] = value;
  }

  get x => this.data[this.index * textLineProps.length + 1];
  set x(value) {
    this.data[this.index * textLineProps.length + 1] = value;
  }

  get width => this.data[this.index * textLineProps.length + 2];
  set width(value) {
    this.data[this.index * textLineProps.length + 2] = value;
  }

  get charIndex => this.data[this.index * textLineProps.length + 3];
  set charIndex(value) {
    this.data[this.index * textLineProps.length + 3] = value;
  }

}
