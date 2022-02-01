part of three_webgl;

int _id = 0;

class WebGLShaderCache {
  var shaderCache = new Map();
  var materialCache = new Map();

  WebGLShaderCache() {}

  update(material) {
    var vertexShader = material.vertexShader;
    var fragmentShader = material.fragmentShader;

    var vertexShaderStage = this._getShaderStage(vertexShader);
    var fragmentShaderStage = this._getShaderStage(fragmentShader);

    var materialShaders = this._getShaderCacheForMaterial(material);

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

  remove(material) {
    var materialShaders = this.materialCache[material];

    for (var shaderStage in materialShaders) {
      shaderStage.usedTimes--;

      if (shaderStage.usedTimes == 0) this.shaderCache.remove(shaderStage);
    }

    this.materialCache.remove(material);

    return this;
  }

  getVertexShaderID(material) {
    return this._getShaderStage(material.vertexShader).id;
  }

  getFragmentShaderID(material) {
    return this._getShaderStage(material.fragmentShader).id;
  }

  dispose() {
    this.shaderCache.clear();
    this.materialCache.clear();
  }

  _getShaderCacheForMaterial(material) {
    var cache = this.materialCache;

    if (cache.containsKey(material) == false) {
      cache[material] = [];
    }

    return cache[material];
  }

  _getShaderStage(code) {
    var cache = this.shaderCache;

    if (cache.containsKey(code) == false) {
      var stage = new WebGLShaderStage();
      cache[code] = stage;
    }

    return cache[code];
  }
}

class WebGLShaderStage {
  late int id;
  late int usedTimes;
  WebGLShaderStage() {
    this.id = _id++;

    this.usedTimes = 0;
  }
}
