part of three_webgl;

int _id = 0;

class WebGLShaderCache {
  var shaderCache = {};
  var materialCache = {};

  WebGLShaderCache();

  WebGLShaderCache update(Material material) {
    var vertexShader = material.vertexShader;
    var fragmentShader = material.fragmentShader;

    var vertexShaderStage = _getShaderStage(vertexShader);
    var fragmentShaderStage = _getShaderStage(fragmentShader);

    var materialShaders = _getShaderCacheForMaterial(material);

    if (materialShaders.contains(vertexShaderStage) == false) {
      materialShaders.add(vertexShaderStage);
      vertexShaderStage.usedTimes++;
    }

    if (materialShaders.contains(fragmentShaderStage) == false) {
      materialShaders.add(fragmentShaderStage);
      fragmentShaderStage.usedTimes++;
    }

    return this;
  }

  WebGLShaderCache remove(Material material) {
    var materialShaders = materialCache[material];

    for (var shaderStage in materialShaders) {
      shaderStage.usedTimes--;

      if (shaderStage.usedTimes == 0) shaderCache.remove(shaderStage);
    }

    materialCache.remove(material);

    return this;
  }

  getVertexShaderID(Material material) {
    return _getShaderStage(material.vertexShader).id;
  }

  getFragmentShaderID(material) {
    return _getShaderStage(material.fragmentShader).id;
  }

  void dispose() {
    shaderCache.clear();
    materialCache.clear();
  }

  _getShaderCacheForMaterial(material) {
    var cache = materialCache;

    if (cache.containsKey(material) == false) {
      cache[material] = [];
    }

    return cache[material];
  }

  _getShaderStage(code) {
    var cache = shaderCache;

    if (cache.containsKey(code) == false) {
      var stage = WebGLShaderStage();
      cache[code] = stage;
    }

    return cache[code];
  }
}

class WebGLShaderStage {
  late int id;
  late int usedTimes;
  WebGLShaderStage() {
    id = _id++;

    usedTimes = 0;
  }
}
