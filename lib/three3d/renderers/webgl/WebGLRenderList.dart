part of three_webgl;

class RenderItem {
  int id = 0;
  Object3D? object;
  BufferGeometry? geometry;
  Material? material;
  dynamic? program;
  int groupOrder = 0;
  int renderOrder = 0;
  double z = 0;
  Map<String, dynamic>? group;

  RenderItem(Map<String, dynamic> json) {
    if (json["id"] != null) {
      id = json["id"];
    }
    if (json["object"] != null) {
      object = json["object"];
    }
    if (json["geometry"] != null) {
      geometry = json["geometry"];
    }
    if (json["material"] != null) {
      material = json["material"];
    }
    if (json["program"] != null) {
      program = json["program"];
    }
    if (json["groupOrder"] != null) {
      groupOrder = json["groupOrder"];
    }

    if (json["renderOrder"] != null) {
      renderOrder = json["renderOrder"];
    }
    if (json["z"] != null) {
      z = json["z"];
    }
    if (json["group"] != null) {
      group = json["group"];
    }
  }
}

class WebGLRenderList {
  WebGLRenderList();

  Map<int, RenderItem> renderItems = {};
  int renderItemsIndex = 0;

  List<RenderItem> opaque = [];
  List<RenderItem> transmissive = [];
  List<RenderItem> transparent = [];

  var defaultProgram = DefaultProgram();

  void init() {
    renderItemsIndex = 0;

    opaque.length = 0;
    transmissive.length = 0;
    transparent.length = 0;
  }

  RenderItem getNextRenderItem(
      Object3D object,
      BufferGeometry? geometry,
      Material? material,
      int groupOrder,
      double z,
      Map<String, dynamic>? group) {
    var renderItem = renderItems[renderItemsIndex];

    if (renderItem == null) {
      renderItem = RenderItem({
        "id": object.id,
        "object": object,
        "geometry": geometry,
        "material": material,
        "groupOrder": groupOrder,
        "renderOrder": object.renderOrder,
        "z": z,
        "group": group
      });

      renderItems[renderItemsIndex] = renderItem;
    } else {
      renderItem.id = object.id;
      renderItem.object = object;
      renderItem.geometry = geometry;
      renderItem.material = material;
      renderItem.groupOrder = groupOrder;
      renderItem.renderOrder = object.renderOrder;
      renderItem.z = z;
      renderItem.group = group;
    }

    renderItemsIndex++;

    return renderItem;
  }

  void push(Object3D object, BufferGeometry geometry, material, int groupOrder,
      double z, Map<String, dynamic>? group) {
    var renderItem =
        getNextRenderItem(object, geometry, material, groupOrder, z, group);

    if (material.transmission > 0.0) {
      transmissive.add(renderItem);
    } else {
      if (material.transparent == true) {
        transparent.add(renderItem);
      } else {
        opaque.add(renderItem);
      }
    }
  }

  void unshift(Object3D object, BufferGeometry? geometry, Material material,
      int groupOrder, double z, Map<String, dynamic>? group) {
    var renderItem =
        getNextRenderItem(object, geometry, material, groupOrder, z, group);

    if (material.transmission > 0.0) {
      transmissive.insert(0, renderItem);
    } else {
      if (material.transparent == true) {
        transparent.insert(0, renderItem);
      } else {
        opaque.insert(0, renderItem);
      }
    }
  }

  void sort(customOpaqueSort, customTransparentSort) {
    if (opaque.length > 1) {
      opaque.sort(customOpaqueSort ?? painterSortStable);
    }

    if (transmissive.length > 1) {
      transmissive.sort(customTransparentSort ?? reversePainterSortStable);
    }

    if (transparent.length > 1) {
      transparent.sort(customTransparentSort ?? reversePainterSortStable);
    }
  }

  void finish() {
    // Clear references from inactive renderItems in the list

    for (var i = renderItemsIndex, il = renderItems.length; i < il; i++) {
      var renderItem = renderItems[i]!;

      if (renderItem.id == 0) break;

      renderItem.id = 0;
      renderItem.object = null;
      renderItem.geometry = null;
      renderItem.material = null;
      renderItem.program = null;
      renderItem.group = null;
    }
  }

  int painterSortStable(RenderItem a, RenderItem b) {
    if (a.groupOrder != b.groupOrder) {
      return a.groupOrder - b.groupOrder;
    } else if (a.renderOrder != b.renderOrder) {
      return (a.renderOrder - b.renderOrder) > 0 ? 1 : -1;
    } else if (a.program != b.program) {
      return a.program.id - b.program.id;
    } else if (a.material.id != b.material.id) {
      return a.material.id - b.material.id;
    } else if (a.z != b.z) {
      return (a.z - b.z) > 0 ? 1 : -1;
    } else {
      return a.id - b.id;
    }
  }

  int reversePainterSortStable(RenderItem a, RenderItem b) {
    // print("3 reversePainterSortStable ${a.id} ${b.id} ");

    if (a.groupOrder != b.groupOrder) {
      return a.groupOrder - b.groupOrder;
    } else if (a.renderOrder != b.renderOrder) {
      return a.renderOrder - b.renderOrder;
    } else if (a.z != b.z) {
      final _v = b.z - a.z;
      return _v > 0 ? 1 : -1;
    } else {
      return a.id - b.id;
    }
  }
}
