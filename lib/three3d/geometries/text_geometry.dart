
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/extras/core/shape.dart';
import 'package:three_dart/three3d/extras/core/ttf_font.dart';
import 'package:three_dart/three3d/geometries/extrude_geometry.dart';
import 'package:three_dart/three3d/math/index.dart';


class TextGeometry extends ExtrudeGeometry {
  @override
  String type = "TextGeometry";

  TextGeometry.create(List<Shape> shapes, Map<String, dynamic> options) : super(shapes, options);

  factory TextGeometry(String text, Map<String, dynamic> parameters) {
    Font? font = parameters["font"];

    if (!(font != null && font.isFont)) {
      throw ('three.TextGeometry: font parameter is not an instance of three.Font.');
    }

    var shapes = font.generateShapes(text, size: parameters["size"]);

    // translate parameters to ExtrudeGeometry API

    parameters["depth"] = parameters["height"] ?? 50;

    // defaults

    if (parameters["bevelThickness"] == null) parameters["bevelThickness"] = 10;
    if (parameters["bevelSize"] == null) parameters["bevelSize"] = 8;
    if (parameters["bevelEnabled"] == null) parameters["bevelEnabled"] = false;

    TextGeometry _textBufferGeometry = TextGeometry.create(shapes, parameters);

    return _textBufferGeometry;
  }
}
