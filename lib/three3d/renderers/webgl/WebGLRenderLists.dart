part of three_webgl;

class WebGLRenderLists {

  WebGLRenderLists() {}

  var lists = new WeakMap();

  WebGLRenderList get(scene, renderCallDepth) {
    var list;

    if (lists.has(scene) == false) {
      list = new WebGLRenderList();
      lists.add(key: scene, value: [list]);
    } else {
      if (renderCallDepth >= lists.get(scene).length) {
        list = new WebGLRenderList();
        lists.get(scene).add(list);
      } else {
        list = lists.get(scene)[renderCallDepth];
      }
    }

    return list;
  }

  dispose() {
    lists = new WeakMap();
  }
}
