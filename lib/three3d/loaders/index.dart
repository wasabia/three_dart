library three_loaders;

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:image/image.dart' hide Color;
import 'package:three_dart/extra/blob.dart';
import 'package:three_dart/three3d/animation/index.dart';
import 'package:three_dart/three3d/cameras/index.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/dart_helpers.dart';
import 'package:three_dart/three3d/extras/index.dart';
import 'package:three_dart/three3d/geometries/index.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart' hide Matrix4;

// for MaterialLoader Matrix4. why conflicts with flutter Matrix4 ???
import 'package:three_dart/three3d/math/index.dart' as mathmath;

import 'package:three_dart/three3d/objects/index.dart';
import 'package:three_dart/three3d/scenes/index.dart';
import 'package:three_dart/three3d/textures/index.dart';
import 'package:three_dart/three3d/utils.dart';

import 'package:universal_html/parsing.dart';
import 'image_loader_for_app.dart' if (dart.library.js) 'ImageLoaderForWeb.dart';

import 'package:http/http.dart' as http;

part 'loading_manager.dart';
part 'loader.dart';
part 'file_loader.dart';
part 'font_loader.dart';
part 'image_loader.dart';
part 'texture_loader.dart';
part 'loader_utils.dart';
part 'svg_loader.dart';
part 'svg_loader_parser.dart';
part 'svg_loader_points_to_stroke.dart';
part 'cache.dart';
part 'object_loader.dart';
part 'buffer_geometry_loader.dart';
part 'material_loader.dart';
part 'data_texture_loader.dart';
