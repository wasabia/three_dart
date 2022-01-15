import 'package:example/app_debug.dart';
import 'package:example/app_debug2.dart';
import 'package:example/misc_animation_keys.dart';
import 'package:example/webgl_animation_cloth.dart';
import 'package:example/webgl_animation_keyframes.dart';
import 'package:example/webgl_animation_multiple.dart';
import 'package:example/webgl_clipping.dart';
import 'package:example/webgl_clipping_advanced.dart';
import 'package:example/webgl_clipping_intersection.dart';
import 'package:example/webgl_clipping_stencil.dart';
import 'package:example/webgl_debug.dart';
import 'package:example/webgl_debug2.dart';
import 'package:example/webgl_debug3.dart';
import 'package:example/webgl_debug_for_macos.dart';
import 'package:example/webgl_geometries.dart';
import 'package:example/webgl_loader_gltf_2.dart';
import 'package:example/webgl_loader_gltf_3.dart';
import 'package:example/webgl_loader_obj.dart';
import 'package:example/webgl_materials.dart';
import 'package:example/webgl_skinning_simple.dart';
import 'package:flutter/material.dart';
import 'ExampleApp.dart';

void main() {
  runApp(ExampleApp()
      // app_debug2(fileName: "app_debug2")
      // webgl_loader_obj(fileName: "webgl_loader_obj")
      // webgl_skinning_simple(fileName: "webgl_skinning_simple")
      // webgl_debug3(fileName: "webgl_debug3")
      // webgl_debug(fileName: "webgl_debug")
      // webgl_animation_multiple(fileName: "webgl_animation_multiple")
      // webgl_loader_gltf_2(fileName: "webgl_loader_gltf_2")
      // webgl_loader_gltf_3(fileName: "webgl_loader_gltf_3")
      // webgl_debug2(fileName: "webgl_debug2")
      // webgl_materials(fileName: "webgl_materials")
      // webgl_animation_keyframes(key: webgl_animation_keyframesGlobalKey, fileName: "webgl_animation_keyframes")
      );
}
