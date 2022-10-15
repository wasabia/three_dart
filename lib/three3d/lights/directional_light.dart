
import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/lights/directional_light_shadow.dart';
import 'package:three_dart/three3d/lights/light.dart';

class DirectionalLight extends Light {
  bool isDirectionalLight = true;

  DirectionalLight(color, [double? intensity]) : super(color, intensity) {
    type = "DirectionalLight";
    position.copy(Object3D.DefaultUp);
    updateMatrix();
    target = Object3D();
    shadow = DirectionalLightShadow();
  }

  @override
  DirectionalLight copy(Object3D source, [bool? recursive]) {
    super.copy(source, false);

    if (source is DirectionalLight) {
      target = source.target!.clone(false);
      shadow = source.shadow!.clone();
    }
    return this;
  }

  @override
  void dispose() {
    shadow!.dispose();
  }
}
