
import 'package:three_dart/three3d/weak_map.dart';

class WebGLProperties {
  var properties = WeakMap<dynamic, Map<String, dynamic>?>();

  Map<String, dynamic> get(object) {
    Map<String, dynamic> map;

    if (!properties.contains(object)) {
      map = <String, dynamic>{};
      properties[object] = map;
    } else {
      map = properties[object]!;
    }

    return map;
  }

  remove(object) {
    properties.remove(object);
  }

  update(object, key, value) {
    var m = properties[object]!;

    m[key] = value;
  }

  dispose() {}
}
