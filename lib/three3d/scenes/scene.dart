import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/extras/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/scenes/fog.dart';

class Scene extends Object3D {
  FogBase? fog;

  Scene() : super() {
    type = 'Scene';
    autoUpdate = true;
  }

  Scene.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) : super.fromJSON(json, rootJSON) {
    type = 'Scene';
    autoUpdate = true;
  }

  static Scene initJSON(Map<String, dynamic> json) {
    Map<String, dynamic> rootJSON = {};

    List<Shape> shapes = [];
    List<Map<String, dynamic>> shapesJSON = json["shapes"];
    for (var shape in shapesJSON) {
      shapes.add(Curve.castJSON(shape));
    }
    rootJSON["shapes"] = shapes;

    List<BufferGeometry> geometries = [];
    List<Map<String, dynamic>> geometriesJSON = json["geometries"];
    for (var geometry in geometriesJSON) {
      geometries.add(BufferGeometry.castJSON(geometry, rootJSON));
    }

    List<Material> materials = [];
    List<Map<String, dynamic>> materialsJSON = json["materials"];
    for (var material in materialsJSON) {
      materials.add(Material.fromJSON(material, {}));
    }

    rootJSON["materials"] = materials;
    rootJSON["geometries"] = geometries;

    return Object3D.castJSON(json["object"], rootJSON) as Scene;
  }

  @override
  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    // if ( source.background !== null ) this.background = source.background.clone();
    // if ( source.environment !== null ) this.environment = source.environment.clone();
    // if ( source.fog !== null ) this.fog = source.fog.clone();

    // if ( source.overrideMaterial !== null ) this.overrideMaterial = source.overrideMaterial.clone();

    // this.autoUpdate = source.autoUpdate;
    // this.matrixAutoUpdate = source.matrixAutoUpdate;

    return this;
  }

  @override
  toJSON({Object3dMeta? meta}) {
    Map<String, dynamic> data = super.toJSON(meta: meta);

    if (fog != null) data["object"]["fog"] = fog!.toJSON();

    return data;
  }
}
