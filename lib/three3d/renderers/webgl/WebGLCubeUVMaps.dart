part of three_webgl;

class WebGLCubeUVMaps {
  var cubeUVmaps = new WeakMap();
  WebGLRenderer renderer;
  dynamic pmremGenerator;

  WebGLCubeUVMaps(this.renderer) {}

  get(texture) {
    if (texture != null && texture.isTexture) {
      var mapping = texture.mapping;

      bool isEquirectMap = (mapping == EquirectangularReflectionMapping ||
          mapping == EquirectangularRefractionMapping);
      bool isCubeMap = (mapping == CubeReflectionMapping ||
          mapping == CubeRefractionMapping);

      // equirect/cube map to cubeUV conversion
      if (isEquirectMap || isCubeMap) {
        if (texture.isRenderTargetTexture && texture.needsPMREMUpdate == true) {
          texture.needsPMREMUpdate = false;

          var renderTarget = cubeUVmaps.get(texture);

          if (pmremGenerator == null)
            pmremGenerator = new PMREMGenerator(renderer);

          renderTarget = isEquirectMap
              ? pmremGenerator.fromEquirectangular(texture, renderTarget)
              : pmremGenerator.fromCubemap(texture, renderTarget);
          cubeUVmaps.add(key: texture, value: renderTarget);

          return renderTarget.texture;
        } else {
          if (cubeUVmaps.has(texture)) {
            return cubeUVmaps.get(texture).texture;
          } else {
            var image = texture.image;

            if ((isEquirectMap && image != null && image.height > 0) ||
                (isCubeMap && image != null && isCubeTextureComplete(image))) {
              if (pmremGenerator == null)
                pmremGenerator = new PMREMGenerator(renderer);

              var renderTarget = isEquirectMap
                  ? pmremGenerator.fromEquirectangular(texture)
                  : pmremGenerator.fromCubemap(texture);
              cubeUVmaps.add(key: texture, value: renderTarget);

              texture.addEventListener('dispose', onTextureDispose);

              return renderTarget.texture;
            } else {
              // image not yet ready. try the conversion next frame

              return null;
            }
          }
        }
      }
    }

    return texture;
  }

  isCubeTextureComplete(image) {
    var count = 0;
    var length = 6;

    for (var i = 0; i < length; i++) {
      if (image[i] != null) count++;
    }

    return count == length;
  }

  onTextureDispose(event) {
    var texture = event.target;

    texture.removeEventListener('dispose', onTextureDispose);

    var cubemapUV = cubeUVmaps.get(texture);

    if (cubemapUV != null) {
      cubemapUV.delete(texture);
      cubemapUV.dispose();
    }
  }

  dispose() {
    cubeUVmaps = new WeakMap();

    if (pmremGenerator != null) {
      pmremGenerator.dispose();
      pmremGenerator = null;
    }
  }
}
