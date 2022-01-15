import 'dart:io';

import 'package:three_dart/three3d/math/index.dart';
import 'dart:convert' as convert;

class TypefaceConvert {
  static bool restrictCharactersCheck = true;
  static bool reverseTypeface = true;

  static exportToFile(font, String filePath) {
    String content = convertFont(font);

    final file = File(filePath);

    // Write the file.
    return file.writeAsString(content);
  }

  static convertFont(font, [String? restrictContent]) {
    var scale = (1000 * 100) / ((font.unitsPerEm ?? 2048) * 72);
    Map<String, dynamic> result = {};
    result["glyphs"] = {};

    Map<String, dynamic> restriction = {"set": null};

    if (restrictCharactersCheck) {
      restriction["set"] = restrictContent;
    }

    font.glyphs.forEach((glyph) {
      if (glyph.unicode != null) {
        var glyphCharacter = String.fromCharCode(glyph.unicode);
        var needToExport = true;
        if (restriction["set"] != null) {
          needToExport = (restrictContent!.indexOf(glyphCharacter) != -1);
        }

        if (needToExport) {
          Map<String, dynamic> token = {};
          token["ha"] = Math.round(glyph.advanceWidth * scale);
          token["x_min"] = Math.round(glyph.xMin * scale);
          token["x_max"] = Math.round(glyph.xMax * scale);
          token["o"] = "";
          if (reverseTypeface) {
            glyph.path.commands = reverseCommands(glyph.path.commands);
          }
          glyph.path.commands.asMap().forEach((i, command) {
            if (command.type.toLowerCase() == "c") {
              command.type = "b";
            }
            token["o"] += command.type.toLowerCase();
            token["o"] += " ";
            if (command.x != null && command.y != null) {
              token["o"] += Math.round(command.x * scale);
              token["o"] += " ";
              token["o"] += Math.round(command.y * scale);
              token["o"] += " ";
            }
            if (command.x1 != null && command.y1 != null) {
              token["o"] += Math.round(command.x1 * scale);
              token["o"] += " ";
              token["o"] += Math.round(command.y1 * scale);
              token["o"] += " ";
            }
            if (command.x2 != null && command.y2 != null) {
              token["o"] += Math.round(command.x2 * scale);
              token["o"] += " ";
              token["o"] += Math.round(command.y2 * scale);
              token["o"] += " ";
            }
          });

          result["glyphs"][String.fromCharCode(glyph.unicode)] = token;
        }
      }
      ;
    });
    result["familyName"] = font.familyName;
    result["ascender"] = Math.round(font.ascender * scale);
    result["descender"] = Math.round(font.descender * scale);
    result["underlinePosition"] =
        Math.round(font.tables.post.underlinePosition * scale);
    result["underlineThickness"] =
        Math.round(font.tables.post.underlineThickness * scale);
    result["boundingBox"] = {
      "yMin": Math.round(font.tables.head.yMin * scale),
      "xMin": Math.round(font.tables.head.xMin * scale),
      "yMax": Math.round(font.tables.head.yMax * scale),
      "xMax": Math.round(font.tables.head.xMax * scale)
    };
    result["resolution"] = 1000;
    result["original_font_information"] = font.tables.name;
    if (font.styleName.toLowerCase().indexOf("bold") > -1) {
      result["cssFontWeight"] = "bold";
    } else {
      result["cssFontWeight"] = "normal";
    }
    ;

    if (font.styleName.toLowerCase().indexOf("italic") > -1) {
      result["cssFontStyle"] = "italic";
    } else {
      result["cssFontStyle"] = "normal";
    }
    ;

    return convert.jsonEncode(result);
  }

  static reverseCommands(commands) {
    var paths = [];
    var path;

    commands.forEach((c) {
      if (c.type.toLowerCase() == "m") {
        path = [c];
        paths.add(path);
      } else if (c.type.toLowerCase() != "z") {
        path.add(c);
      }
    });

    var reversed = [];
    paths.forEach((p) {
      var result = {
        "type": "m",
        "x": p[p.length - 1].x,
        "y": p[p.length - 1].y
      };
      reversed.add(result);

      for (var i = p.length - 1; i > 0; i--) {
        var command = p[i];
        result = {"type": command.type};
        if (command.x2 != null && command.y2 != null) {
          result["x1"] = command.x2;
          result["y1"] = command.y2;
          result["x2"] = command.x1;
          result["y2"] = command.y1;
        } else if (command.x1 != null && command.y1 != null) {
          result["x1"] = command.x1;
          result["y1"] = command.y1;
        }
        result["x"] = p[i - 1].x;
        result["y"] = p[i - 1].y;
        reversed.add(result);
      }
    });

    return reversed;
  }
}
