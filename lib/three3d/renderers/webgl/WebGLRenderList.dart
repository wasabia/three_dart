part of three_webgl;

class RenderItem {
  num? id;
  Object3D? object;
  BufferGeometry? geometry;
  Material? material;
  dynamic? program;
  num? groupOrder;
  num? renderOrder;
  num? z;
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

  WebGLRenderList() {}

  Map<int, RenderItem> renderItems = {};
  var renderItemsIndex = 0;

  var opaque = [];
  var transmissive = [];
  var transparent = [];

  var defaultProgram = DefaultProgram();

  init() {
    renderItemsIndex = 0;

    opaque.length = 0;
    transmissive.length = 0;
    transparent.length = 0;
  }

  getNextRenderItem(object, geometry, material, groupOrder, z, group) {
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

  push(object, geometry, material, groupOrder, z, group) {
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

  unshift(object, geometry, material, groupOrder, z, group) {
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

  sort(customOpaqueSort, customTransparentSort) {
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

  finish() {
    // Clear references from inactive renderItems in the list

    for (var i = renderItemsIndex, il = renderItems.length; i < il; i++) {
      var renderItem = renderItems[i]!;

      if (renderItem.id == null) break;

      renderItem.id = null;
      renderItem.object = null;
      renderItem.geometry = null;
      renderItem.material = null;
      renderItem.program = null;
      renderItem.group = null;
    }
  }

  int painterSortStable(a, b) {
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

  int reversePainterSortStable(a, b) {
    // print("3 reversePainterSortStable ${a.id} ${b.id} ");

    if (a.groupOrder != b.groupOrder) {
      return a.groupOrder - b.groupOrder;
    } else if (a.renderOrder != b.renderOrder) {
      return (a.renderOrder - b.renderOrder).toInt();
    } else if (a.z != b.z) {
      final _v = b.z - a.z;
      return _v > 0 ? 1 : -1;
    } else {
      return a.id - b.id;
    }
  }
}
