part of three_webgl;


class WebGLRenderLists {

  WebGLProperties properties;

  WebGLRenderLists( this.properties) {
  }

  var lists = new WeakMap();

  WebGLRenderList get(scene, camera) {
    var cameras = lists.get(scene);
    var list;

    if (cameras == null) {
      list = new WebGLRenderList(properties);
      lists.add(key: scene, value: WeakMap());
      lists.get(scene).add(key: camera, value: list);
    } else {
      list = cameras.get(camera);
      if (list == null) {
        list = new WebGLRenderList(properties);
        cameras.add(key: camera, value: list);
      }
    }

    return list;
  }

  dispose() {
    lists = new WeakMap();
  }
}


