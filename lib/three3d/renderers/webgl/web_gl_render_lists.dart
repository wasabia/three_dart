
import 'package:three_dart/three3d/renderers/webgl/index.dart';
import 'package:three_dart/three3d/weak_map.dart';

class WebGLRenderLists {
  WebGLRenderLists();

  var lists = WeakMap();

  WebGLRenderList get(scene, renderCallDepth) {
    var list;

    if (lists.has(scene) == false) {
      list = WebGLRenderList();
      lists.add(key: scene, value: [list]);
    } else {
      if (renderCallDepth >= lists.get(scene).length) {
        list = WebGLRenderList();
        lists.get(scene).add(list);
      } else {
        list = lists.get(scene)[renderCallDepth];
      }
    }

    return list;
  }

  dispose() {
    lists = WeakMap();
  }
}
