part of troika_three_text;

/**
 * An adapter that allows Typr.js to be used as if it were (a subset of) the OpenType.js API.
 * Also adds support for WOFF files (not WOFF2).
 */

var cmdArgLengths = {
  "M": 2,
  "L": 2,
  "Q": 4,
  "C": 6,
  "Z": 0
};

var JT_LEFT = 1, //indicates that a character joins with the subsequent character, but does not join with the preceding character.
  JT_RIGHT = 2, //indicates that a character joins with the preceding character, but does not join with the subsequent character.
  JT_DUAL = 4, //indicates that a character joins with the preceding character and joins with the subsequent character.
  JT_TRANSPARENT = 8, //indicates that the character does not join with adjacent characters and that the character must be skipped over when the shaping engine is evaluating the joining positions in a sequence of characters. When a JT_TRANSPARENT character is encountered in a sequence, the JOINING_TYPE of the preceding character passes through. Diacritical marks are frequently assigned this value.
  JT_JOIN_CAUSING = 16, //indicates that the character forces the use of joining forms with the preceding and subsequent characters. Kashidas and the Zero Width Joiner (U+200D) are both JOIN_CAUSING characters.
  JT_NON_JOINING = 32; //indicates that a character does not join with the preceding or with the subsequent character.,
var ISOL = 1, INIT = 2, FINA = 3, MEDI = 4;
var formsToFeatures = [null, 'isol', 'init', 'fina', 'medi'];

// {joinType: "skip+step,..."}
var joiningTypeRawData = {"C":"18g,ca,368,1kz","D":"17k,6,2,2+4,5+c,2+6,2+1,10+1,9+f,j+11,2+1,a,2,2+1,15+2,3,j+2,6+3,2+8,2,2,2+1,w+a,4+e,3+3,2,3+2,3+5,23+w,2f+4,3,2+9,2,b,2+3,3,1k+9,6+1,3+1,2+2,2+d,30g,p+y,1,1+1g,f+x,2,sd2+1d,jf3+4,f+3,2+4,2+2,b+3,42,2,4+2,2+1,2,3,t+1,9f+w,2,el+2,2+g,d+2,2l,2+1,5,3+1,2+1,2,3,6,16wm+1v","R":"17m+3,2,2,6+3,m,15+2,2+2,h+h,13,3+8,2,2,3+1,2,p+1,x,5+4,5,a,2,2,3,u,c+2,g+1,5,2+1,4+1,5j,6+1,2,b,2+2,f,2+1,1s+2,2,3+1,7,1ez0,2,2+1,4+4,b,4,3,b,42,2+2,4,3,2+1,2,o+3,ae,ep,x,2o+2,3+1,3,5+1,6","L":"x9u,jff,a,fd,jv","T":"4t,gj+33,7o+4,1+1,7c+18,2,2+1,2+1,2,21+a,2,1b+k,h,2u+6,3+5,3+1,2+3,y,2,v+q,2k+a,1n+8,a,p+3,2+8,2+2,2+4,18+2,3c+e,2+v,1k,2,5+7,5,4+6,b+1,u,1n,5+3,9,l+1,r,3+1,1m,5+1,5+1,3+2,4,v+1,4,c+1,1m,5+4,2+1,5,l+1,n+5,2,1n,3,2+3,9,8+1,c+1,v,1q,d,1f,4,1m+2,6+2,2+3,8+1,c+1,u,1n,3,7,6+1,l+1,t+1,1m+1,5+3,9,l+1,u,21,8+2,2,2j,3+6,d+7,2r,3+8,c+5,23+1,s,2,2,1k+d,2+4,2+1,6+a,2+z,a,2v+3,2+5,2+1,3+1,q+1,5+2,h+3,e,3+1,7,g,jk+2,qb+2,u+2,u+1,v+1,1t+1,2+6,9,3+a,a,1a+2,3c+1,z,3b+2,5+1,a,7+2,64+1,3,1n,2+6,2,2,3+7,7+9,3,1d+d,1,1+1,1s+3,1d,2+4,2,6,15+8,d+1,x+3,3+1,2+2,1l,2+1,4,2+2,1n+7,3+1,49+2,2+c,2+6,5,7,4+1,5j+1l,2+4,ek,3+1,r+4,1e+4,6+5,2p+c,1+3,1,1+2,1+b,2db+2,3y,2p+v,ff+3,30+1,n9x,1+2,2+9,x+1,29+1,7l,4,5,q+1,6,48+1,r+h,e,13+7,q+a,1b+2,1d,3+3,3+1,14,1w+5,3+1,3+1,d,9,1c,1g,2+2,3+1,6+1,2,17+1,9,6n,3,5,fn5,ki+f,h+f,5s,6y+2,ea,6b,46+4,1af+2,2+1,6+3,15+2,5,4m+1,fy+3,as+1,4a+a,4x,1j+e,1l+2,1e+3,3+1,1y+2,11+4,2+7,1r,d+1,1h+8,b+3,3,2o+2,3,2+1,7,4h,4+7,m+1,1m+1,4,12+6,4+4,5g+7,3+2,2,o,2d+5,2,5+1,2+1,6n+3,7+1,2+1,s+1,2e+7,3,2+1,2z,2,3+5,2,2u+2,3+3,2+4,78+8,2+1,75+1,2,5,41+3,3+1,5,x+9,15+5,3+3,9,a+5,3+2,1b+c,2+1,bb+6,2+5,2,2b+l,3+6,2+1,2+1,3f+5,4,2+1,2+6,2,21+1,4,2,9o+1,470+8,at4+4,1o+6,t5,1s+3,2a,f5l+1,2+3,43o+2,a+7,1+7,3+6,v+3,45+2,1j0+1i,5+1d,9,f,n+4,2+e,11t+6,2+g,3+6,2+1,2+4,7a+6,c6+3,15t+6,32+6,1,gzau,v+2n,3l+6n"};
  

class ParserFactory {

  Uint8List buffer;

  ParserFactory(this.buffer) {

  }
  


  wrapFontObj(typrFont) {
    var fontObj = FontObj(typrFont);

    return fontObj;
  }

  parse() {
    // Look to see if we have a WOFF file and convert it if so:
    var peek = new Uint8List.sublistView(buffer, 0, 4);
    var tag = typr_dart.TyprBin.readASCII(peek, 0, 4);
    if (tag == 'wOFF') {
      // buffer = woff2otf(buffer);
      // todo use native like rust ???
      throw('woff fonts not supported');
    } else if (tag == 'wOF2') {
      throw('woff2 fonts not supported');
    }
    return wrapFontObj(typr_dart.Font(buffer));
  }
}

fontParser(buffer) {
  return ParserFactory(buffer).parse();
}


// var workerModule = /*#__PURE__*/defineWorkerModule({
//   name: 'Typr Font Parser',
//   dependencies: [typrFactory, woff2otfFactory, parserFactory],
//   init(typrFactory, woff2otfFactory, parserFactory) {
//     var Typr = typrFactory()
//     var woff2otf = woff2otfFactory()
//     return parserFactory(Typr, woff2otf)
//   }
// })


// export default workerModule



class FontObj {

  typr_dart.Font typrFont;
  late num unitsPerEm;
  late dynamic ascender;
  late dynamic descender;
  var glyphMap = {};

  FontObj(this.typrFont) {
    unitsPerEm = typrFont.head["unitsPerEm"];
    ascender = typrFont.hhea["ascender"];
    descender = typrFont.hhea["descender"];


  }

  forEachGlyph(text, fontSize, letterSpacing, callback) {
    num glyphX = 0;
    var fontScale = 1 / unitsPerEm * fontSize;

    var glyphIndices = stringToGlyphs(typrFont, text);
    var charIndex = 0;
    var prevGlyphIndex = -1;
    glyphIndices.asMap().forEach((i, glyphIndex) {
      // Typr returns a glyph index per string codepoint, with -1s in place of those that
      // were omitted due to ligature substitution. So we can track original index in the
      // string via simple increment, and skip everything else when seeing a -1.
      if (glyphIndex != -1) {
        var glyphObj = glyphMap[glyphIndex];
        if (glyphObj == null) {
          var _path = typr_dart.Typr_U.glyphToPath(typrFont, glyphIndex);
          var cmds = _path["cmds"];
          var crds = _path["crds"];

          // Find extents - Glyf gives this in metadata but not CFF, and Typr doesn't
          // normalize the two, so it's simplest just to iterate ourselves.
          var xMin, yMin, xMax, yMax;
          if (crds.length > 0) {
            xMin = yMin = Math.Infinity;
            xMax = yMax = -Math.Infinity;
            for (var i = 0, len = crds.length; i < len; i += 2) {
              var x = crds[i];
              var y = crds[i + 1];
              if (x < xMin) xMin = x;
              if (y < yMin) yMin = y;
              if (x > xMax) xMax = x;
              if (y > yMax) yMax = y;
            }
          } else {
            xMin = xMax = yMin = yMax = 0;
          }

          glyphObj = glyphMap[glyphIndex] = {
            "index": glyphIndex,
            "advanceWidth": typrFont.hmtx["aWidth"][glyphIndex],
            "xMin": xMin,
            "yMin": yMin,
            "xMax": xMax,
            "yMax": yMax,
            "pathCommandCount": cmds.length,
            "forEachPathCommand": (callback) {
              var argsIndex = 0;
              var argsArray = [];
              for (var i = 0, len = cmds.length; i < len; i++) {
                int numArgs = cmdArgLengths[cmds[i]]!;
                argsArray.length = 1 + numArgs;
                argsArray[0] = cmds[i];
                for (var j = 1; j <= numArgs; j++) {
                  argsArray[j] = crds[argsIndex++];
                }
                callback.apply(null, argsArray);
              }
            }
          };
        }

        // Kerning
        if (prevGlyphIndex != -1) {
          glyphX += typr_dart.Typr_U.getPairAdjustment(typrFont, prevGlyphIndex, glyphIndex) * fontScale;
        }

        callback(glyphObj, glyphX, charIndex);

        if (glyphObj["advanceWidth"] != null && glyphObj["advanceWidth"] > 0) {
          glyphX += glyphObj["advanceWidth"] * fontScale;
        }
        if (letterSpacing != null) {
          glyphX += letterSpacing * fontSize;
        }

        prevGlyphIndex = glyphIndex;
      }


      charIndex += (text.codeUnitAt(charIndex) > 0xffff ? 2 : 1);
    });

    return glyphX;
  }

  stringToGlyphs (font, str) {
    var glyphIds = [];
    for (var i = 0; i < str.length; i++) {
      var cc = str.codeUnitAt(i);
      if (cc > 0xffff) i++;
      glyphIds.add(typr_dart.Typr_U.codeToGlyph(font, cc));
    }

    var gsub = font.GSUB;
    if (gsub != null) {
      var lookupList = gsub["lookupList"];
      var featureList = gsub["featureList"];
      Uint8List? joiningForms;
      var supportedFeatures = RegExp(r"^(rlig|liga|mset|isol|init|fina|medi|half|pres|blws)$");
      var usedLookups = {};
      featureList.forEach((feature) {
        if (supportedFeatures.hasMatch(feature["tag"])) {
          for (var ti = 0; ti < feature["tab"].length; ti++) {
            var _fti = feature["tab"][ti];

            if (usedLookups[_fti] == true) {
              continue;
            }
            usedLookups[_fti] = true;
            var tab = lookupList[_fti];
            bool isJoiningFeature = RegExp(r"^(isol|init|fina|medi)$").hasMatch(feature["tag"]);
            if (isJoiningFeature && joiningForms == null) { //lazy
              joiningForms = detectJoiningForms(str);
            }
            for (var ci = 0; ci < glyphIds.length; ci++) {
              if (joiningForms == null || !isJoiningFeature || formsToFeatures[joiningForms![ci]] == feature["tag"]) {
                typr_dart.Typr_U.applySubs(glyphIds, ci, tab, lookupList);
              }
            }
          }
        }
      });
    }

    return glyphIds;
  }

  detectJoiningForms(str) {
    // This implements the algorithm described here:
    // https://github.com/n8willis/opentype-shaping-documents/blob/master/opentype-shaping-arabic-general.md
    var joiningForms = new Uint8List(str.length);
    var prevJoiningType = JT_NON_JOINING;
    var prevForm = ISOL;
    var prevIndex = -1;
    for (var i = 0; i < str.length; i++) {
      var code = str.codeUnitAt(i);
      var joiningType = getCharJoiningType(code) | 0;
      var form = ISOL;
      if (joiningType & JT_TRANSPARENT) {
        continue;
      }
      if (prevJoiningType & (JT_LEFT | JT_DUAL | JT_JOIN_CAUSING) == 1) {
        if (joiningType & (JT_RIGHT | JT_DUAL | JT_JOIN_CAUSING)) {
          form = FINA;
          // isol->init, fina->medi
          if (prevForm == ISOL || prevForm == FINA) {
            joiningForms[prevIndex]++;
          }
        }
        else if (joiningType & (JT_LEFT | JT_NON_JOINING)) {
          // medi->fina, init->isol
          if (prevForm == INIT || prevForm == MEDI) {
            joiningForms[prevIndex]--;
          }
        }
      }
      else if (prevJoiningType & (JT_RIGHT | JT_NON_JOINING) == 1) {
        // medi->fina, init->isol
        if (prevForm == INIT || prevForm == MEDI) {
          joiningForms[prevIndex]--;
        }
      }
      prevForm = joiningForms[i] = form;
      prevJoiningType = joiningType;
      prevIndex = i;
      if (code > 0xffff) i++;
    }
    // console.log(str.split('').map(ch => ch.codeUnitAt(0).toString(16)))
    // console.log(str.split('').map(ch => getCharJoiningType(ch.codeUnitAt(0))))
    // console.log(Array.from(joiningForms).map(f => formsToFeatures[f] || 'none'))
    return joiningForms;
  }

  var joiningTypeMap;
  getCharJoiningType(ch) {
    if (!joiningTypeMap) {
      var m = {
        "R": JT_RIGHT,
        "L": JT_LEFT,
        "D": JT_DUAL,
        "C": JT_JOIN_CAUSING,
        "U": JT_NON_JOINING,
        "T": JT_TRANSPARENT
      };

      joiningTypeMap = new Map();
      for (var type in joiningTypeRawData.keys) {
        var lastCode = 0;
        joiningTypeRawData[type]!.split(',').forEach((range) {
          var _rgs = range.split('+');
          var skip_str = _rgs[0];
          var step_str = _rgs[1];
          
          var skip = int.parse(skip_str, radix: 36);
          var step = step_str != null ? int.parse(step_str, radix: 36) : 0;
          joiningTypeMap.set(lastCode += skip, m[type]);
          for (var i = step; i >= 0; i--) {
            joiningTypeMap.set(++lastCode, m[type]);
          }
        });
      }
    }
    return joiningTypeMap.get(ch) ?? JT_NON_JOINING;
  }


}