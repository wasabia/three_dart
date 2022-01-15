part of three_webgl;

class WebGLGeometries {
  dynamic gl;
  WebGLAttributes attributes;
  WebGLInfo info;
  WebGLBindingStates bindingStates;

  Map<int, bool> geometries = {};
  var wireframeAttributes = new WeakMap();

  WebGLGeometries(this.gl, this.attributes, this.info, this.bindingStates) {}

  onGeometryDispose(event) {
    var geometry = event.target;

    if (geometry.index != null) {
      attributes.remove(geometry.index);
    }

    for (var name in geometry.attributes.keys) {
      attributes.remove(geometry.attributes[name]);
    }

    geometry.removeEventListener('dispose', onGeometryDispose);

    geometries.remove(geometry.id);

    var attribute = wireframeAttributes.get(geometry);

    if (attribute != null) {
      attributes.remove(attribute);
      wireframeAttributes.delete(geometry);
    }

    bindingStates.releaseStatesOfGeometry(geometry);

    if (geometry.isInstancedBufferGeometry == true) {
      // geometry.remove("maxInstanceCount");
      geometry.maxInstanceCount = null;
    }

    //

    info.memory["geometries"] = info.memory["geometries"]! - 1;
  }

  BufferGeometry get(object, BufferGeometry geometry) {
    if (geometries[geometry.id] == true) return geometry;

    geometry.addEventListener('dispose', onGeometryDispose);

    geometries[geometry.id] = true;

    info.memory["geometries"] = info.memory["geometries"]! + 1;

    return geometry;
  }

  update(geometry) {
    var geometryAttributes = geometry.attributes;

    // Updating index buffer in VAO now. See WebGLBindingStates.

    geometryAttributes.keys.forEach((name) {
      attributes.update(geometryAttributes[name], gl.ARRAY_BUFFER, name: name);
    });

    // morph targets

    var morphAttributes = geometry.morphAttributes;

    morphAttributes.keys.forEach((name) {
      var array = morphAttributes[name];

      for (var i = 0, l = array.length; i < l; i++) {
        attributes.update(array[i], gl.ARRAY_BUFFER,
            name: "${name} - morphAttributes i: ${i}");
      }
    });
  }

  updateWireframeAttribute(geometry) {
    List<int> indices = [];

    var geometryIndex = geometry.index;
    var geometryPosition = geometry.attributes["position"];
    var version = 0;

    if (geometryIndex != null) {
      var array = geometryIndex.array;
      version = geometryIndex.version;

      for (var i = 0, l = array.length; i < l; i += 3) {
        var a = array[i + 0];
        var b = array[i + 1];
        var c = array[i + 2];

        indices.addAll([a, b, b, c, c, a]);
      }
    } else {
      var array = geometryPosition.array;
      version = geometryPosition.version;

      for (var i = 0, l = (array.length / 3) - 1; i < l; i += 3) {
        var a = i + 0;
        var b = i + 1;
        var c = i + 2;

        indices.addAll([a, b, b, c, c, a]);
      }
    }

    BufferAttribute attribute;

    if (arrayMax(indices) > 65535) {
      attribute = Uint32BufferAttribute(Uint32Array.from(indices), 1, false);
    } else {
      attribute = Uint16BufferAttribute(Uint16Array.from(indices), 1, false);
    }

    attribute.version = version;

    // Updating index buffer in VAO now. See WebGLBindingStates

    //

    var previousAttribute = wireframeAttributes.get(geometry);

    if (previousAttribute != null) attributes.remove(previousAttribute);

    //

    wireframeAttributes.add(key: geometry, value: attribute);
  }

  getWireframeAttribute(geometry) {
    var currentAttribute = wireframeAttributes.get(geometry);

    if (currentAttribute != null) {
      var geometryIndex = geometry.index;

      if (geometryIndex != null) {
        // if the attribute is obsolete, create a new one

        if (currentAttribute.version < geometryIndex.version) {
          updateWireframeAttribute(geometry);
        }
      }
    } else {
      updateWireframeAttribute(geometry);
    }

    return wireframeAttributes.get(geometry);
  }

  dispose() {}
}
