
import 'package:three_dart/three3d/core/object_3d.dart';
import 'package:three_dart/three3d/extras/core/path.dart';
import 'package:three_dart/three3d/math/index.dart';

class Shape extends Path {
  late String uuid;
  late List<Path> holes;
  @override
  String type = "Shape";

  Shape(points) : super(points) {
    uuid = MathUtils.generateUUID();
    holes = [];
  }

  Shape.fromJSON(Map<String, dynamic> json) : super.fromJSON(json) {
    uuid = json["uuid"];
    holes = [];

    for (var i = 0, l = json["holes"].length; i < l; i++) {
      var hole = json["holes"][i];
      holes.add(Path.fromJSON(hole));
    }
  }

  getPointsHoles(divisions) {
    var holesPts = List<dynamic>.filled(holes.length, null);

    for (var i = 0, l = holes.length; i < l; i++) {
      holesPts[i] = holes[i].getPoints(divisions);
    }

    return holesPts;
  }

  // get points of shape and holes (keypoints based on segments parameter)

  Map<String, dynamic> extractPoints(divisions) {
    return {
      "shape": getPoints(divisions),
      "holes": getPointsHoles(divisions)
    };
  }

  @override
  copy(source) {
    super.copy(source);

    holes = [];

    for (var i = 0, l = source.holes.length; i < l; i++) {
      var hole = source.holes[i];

      holes.add(hole.clone());
    }

    return this;
  }

  @override
  toJSON({Object3dMeta? meta}) {
    var data = super.toJSON();

    data["uuid"] = uuid;
    data["holes"] = [];

    for (var i = 0, l = holes.length; i < l; i++) {
      var hole = holes[i];
      data["holes"].add(hole.toJSON());
    }

    return data;
  }

  @override
  fromJSON(json) {
    super.fromJSON(json);

    uuid = json.uuid;
    holes = [];

    for (var i = 0, l = json.holes.length; i < l; i++) {
      var hole = json.holes[i];
      holes.add(Path(null).fromJSON(hole));
    }

    return this;
  }
}
