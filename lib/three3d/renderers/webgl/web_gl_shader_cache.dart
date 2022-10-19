import 'package:three_dart/three3d/materials/index.dart';

int _id = 0;

class WebGLShaderCache {
  var shaderCache = {};
  var materialCache = {};

  WebGLShaderCache();

  WebGLShaderCache update(Material material) {
    var vertexShader = material.vertexShader;
    var fragmentShader = material.fragmentShader;

    var vertexShaderStage = _getShaderStage(vertexShader!);
    var fragmentShaderStage = _getShaderStage(fragmentShader!);

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

      if (shaderStage.usedTimes == 0) shaderCache.remove(shaderStage.code);
    }

    materialCache.remove(material);

    return this;
  }

  getVertexShaderID(Material material) {
    return _getShaderStage(material.vertexShader!).id;
  }

  getFragmentShaderID(Material material) {
    return _getShaderStage(material.fragmentShader!).id;
  }

  void dispose() {
    shaderCache.clear();
    materialCache.clear();
  }

  _getShaderCacheForMaterial(Material material) {
    var cache = materialCache;

    if (cache.containsKey(material) == false) {
      cache[material] = [];
    }

    return cache[material];
  }

  _getShaderStage(String code) {
    var cache = shaderCache;

    if (cache.containsKey(code) == false) {
      var stage = WebGLShaderStage(code);
      cache[code] = stage;
    }

    return cache[code];
  }
}

class WebGLShaderStage {
  late int id;
  late int usedTimes;
  late String code;

  WebGLShaderStage(this.code) {
    id = _id++;
    usedTimes = 0;
  }
}
