import 'package:example/misc_animation_keys.dart';
import 'package:example/multi_views.dart';
import 'package:example/webgl_animation_cloth.dart';
import 'package:example/webgl_animation_keyframes.dart';
import 'package:example/webgl_animation_multiple.dart';
import 'package:example/webgl_animation_skinning_additive_blending.dart';
import 'package:example/webgl_animation_skinning_blending.dart';
import 'package:example/webgl_animation_skinning_morph.dart';
import 'package:example/webgl_camera.dart';
import 'package:example/webgl_camera_array.dart';
import 'package:example/webgl_clipping.dart';
import 'package:example/webgl_clipping_advanced.dart';
import 'package:example/webgl_clipping_intersection.dart';
import 'package:example/webgl_clipping_stencil.dart';
import 'package:example/webgl_geometries.dart';
import 'package:example/webgl_geometry_colors.dart';
import 'package:example/webgl_geometry_shapes.dart';
import 'package:example/webgl_geometry_text.dart';
import 'package:example/webgl_helpers.dart';
import 'package:example/webgl_instancing_performance.dart';
import 'package:example/webgl_loader_fbx.dart';
import 'package:example/webgl_loader_gltf.dart';
import 'package:example/webgl_loader_gltf_test.dart';
import 'package:example/webgl_loader_obj.dart';
import 'package:example/webgl_loader_obj_mtl.dart';
import 'package:example/webgl_loader_texture_basis.dart';
import 'package:example/webgl_materials.dart';
import 'package:example/webgl_materials_browser.dart';
import 'package:example/webgl_morphtargets.dart';
import 'package:example/webgl_morphtargets_horse.dart';
import 'package:example/webgl_morphtargets_sphere.dart';
import 'package:example/webgl_shadow_contact.dart';
import 'package:example/webgl_shadowmap_viewer.dart';
import 'package:example/webgl_skinning_simple.dart';
import 'package:flutter/material.dart';

import 'misc_controls_arcball.dart';
import 'misc_controls_map.dart';
import 'misc_controls_orbit.dart';
import 'misc_controls_trackball.dart';
import 'webgl_loader_svg.dart';

class ExamplePage extends StatefulWidget {
  final String? id;

  const ExamplePage({Key? key, this.id}) : super(key: key);

  @override
  State<ExamplePage> createState() => _MyAppState();
}

class _MyAppState extends State<ExamplePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    String fileName = widget.id!;

    if (fileName == "webgl_camera_array") {
      page = WebglCameraArray(fileName: fileName);
    } else if (fileName == "webgl_loader_obj") {
      page = WebGlLoaderObj(fileName: fileName);
    } else if (fileName == "webgl_materials_browser") {
      page = WebglMaterialsBrowser(fileName: fileName);
    } else if (fileName == "webgl_shadow_contact") {
      page = WebGlShadowContact(fileName: fileName);
    } else if (fileName == "webgl_geometry_text") {
      page = WebGlGeometryText(fileName: fileName);
    } else if (fileName == "webgl_geometry_shapes") {
      page = WebGlGeometryShapes(fileName: fileName);
    } else if (fileName == "webgl_instancing_performance") {
      page = WebglInstancingPerformance(fileName: fileName);
    } else if (fileName == "webgl_shadowmap_viewer") {
      page = WebGlShadowmapViewer(fileName: fileName);
    } else if (fileName == "webgl_loader_gltf") {
      page = WebGlLoaderGtlf(fileName: fileName);
    } else if (fileName == "webgl_loader_gltf_test") {
      page = WebGlLoaderGltfTest(fileName: fileName);
    } else if (fileName == "webgl_loader_obj_mtl") {
      page = WebGlLoaderObjLtl(fileName: fileName);
    } else if (fileName == "webgl_animation_keyframes") {
      page = WebGlAnimationKeyframes(fileName: fileName);
    } else if (fileName == "webgl_loader_texture_basis") {
      page = WebGlLoaderTextureBasis(fileName: fileName);
    } else if (fileName == "webgl_animation_multiple") {
      page = WebGlAnimationMultiple(fileName: fileName);
    } else if (fileName == "webgl_skinning_simple") {
      page = WebGlSkinningSimple(fileName: fileName);
    } else if (fileName == "misc_animation_keys") {
      page = MiscAnimationKeys(fileName: fileName);
    } else if (fileName == "webgl_clipping_intersection") {
      page = WebGlClippingIntersection(fileName: fileName);
    } else if (fileName == "webgl_clipping_advanced") {
      page = WebGlClippingAdvanced(fileName: fileName);
    } else if (fileName == "webgl_clipping_stencil") {
      page = WebGlClippingStencil(fileName: fileName);
    } else if (fileName == "webgl_clipping") {
      page = WebGlClipping(fileName: fileName);
    } else if (fileName == "webgl_geometries") {
      page = WebglGeometries(fileName: fileName);
    } else if (fileName == "webgl_animation_cloth") {
      page = WebGlAnimationCloth(fileName: fileName);
    } else if (fileName == "webgl_materials") {
      page = WebGlMaterials(fileName: fileName);
    } else if (fileName == "webgl_animation_skinning_blending") {
      page = WebGlAnimationSkinningBlending(fileName: fileName);
    } else if (fileName == "webgl_animation_skinning_additive_blending") {
      page = WebglAnimationSkinningAdditiveBlending(fileName: fileName);
    } else if (fileName == "webgl_animation_skinning_morph") {
      page = WebGlAnimationSkinningMorph(fileName: fileName);
    } else if (fileName == "webgl_camera") {
      page = WebGlCamera(fileName: fileName);
    } else if (fileName == "webgl_geometry_colors") {
      page = WebGlGeometryColors(fileName: fileName);
    } else if (fileName == "webgl_loader_svg") {
      page = WebGlLoaderSvg(fileName: fileName);
    } else if (fileName == "webgl_helpers") {
      page = WebGlHelpers(fileName: fileName);
    } else if (fileName == "webgl_morphtargets") {
      page = WebGlMorphtargets(fileName: fileName);
    } else if (fileName == "webgl_morphtargets_sphere") {
      page = WebGlMorphtargetsSphere(fileName: fileName);
    } else if (fileName == "webgl_morphtargets_horse") {
      page = WebGlMorphtargetsHorse(fileName: fileName);
    } else if (fileName == "misc_controls_orbit") {
      page = MiscControlsOrbit(fileName: fileName);
    } else if (fileName == "misc_controls_trackball") {
      page = MiscControlsTrackball(fileName: fileName);
    } else if (fileName == "misc_controls_arcball") {
      page = MiscControlsArcball(fileName: fileName);
    } else if (fileName == "misc_controls_map") {
      page = MiscControlsMap(fileName: fileName);
    } else if (fileName == "webgl_loader_fbx") {
      page = WebGlLoaderFbx(fileName: fileName);
    } else if (fileName == "multi_views") {
      page = MultiViews(fileName: fileName);
    } else {
      throw ("ExamplePage fileName $fileName is not support yet ");
    }

    return page;
  }
}
