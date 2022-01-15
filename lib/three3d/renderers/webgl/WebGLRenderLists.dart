part of three_webgl;

class WebGLRenderLists {
  WebGLProperties properties;

  WebGLRenderLists(this.properties) {}

  var lists = new WeakMap();

  WebGLRenderList get(scene, renderCallDepth) {
    var list;

    if (lists.has(scene) == false) {
      list = new WebGLRenderList(properties);
      lists.add(key: scene, value: [list]);
    } else {
      if (renderCallDepth >= lists.get(scene).length) {
        list = new WebGLRenderList(properties);
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
