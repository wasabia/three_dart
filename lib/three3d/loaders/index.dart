library three_loaders;

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:image/image.dart' hide Color;
import 'package:three_dart/extra/Blob.dart';
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
import 'ImageLoaderForApp.dart' if (dart.library.js) 'ImageLoaderForWeb.dart';

import 'package:http/http.dart' as http;

part './LoadingManager.dart';
part './Loader.dart';
part './FileLoader.dart';
part './FontLoader.dart';
part './ImageLoader.dart';
part './TextureLoader.dart';
part './LoaderUtils.dart';
part './SVGLoader.dart';
part './SVGLoaderParser.dart';
part './SVGLoaderPointsToStroke.dart';
part './Cache.dart';
part './ObjectLoader.dart';
part './BufferGeometryLoader.dart';
part './MaterialLoader.dart';
part './DataTextureLoader.dart';
