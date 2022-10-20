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

    List<Shape> _shapes = [];
    List<Map<String, dynamic>> _shapesJSON = json["shapes"];
    for (var _shape in _shapesJSON) {
      _shapes.add(Curve.castJSON(_shape));
    }
    rootJSON["shapes"] = _shapes;

    List<BufferGeometry> _geometries = [];
    List<Map<String, dynamic>> _geometriesJSON = json["geometries"];
    for (var _geometry in _geometriesJSON) {
      _geometries.add(BufferGeometry.castJSON(_geometry, rootJSON));
    }

    List<Material> _materials = [];
    List<Map<String, dynamic>> _materialsJSON = json["materials"];
    for (var _material in _materialsJSON) {
      _materials.add(Material.fromJSON(_material, {}));
    }

    rootJSON["materials"] = _materials;
    rootJSON["geometries"] = _geometries;

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
