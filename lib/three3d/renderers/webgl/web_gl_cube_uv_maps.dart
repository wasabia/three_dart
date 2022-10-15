
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/extras/pmrem_generator.dart';
import 'package:three_dart/three3d/renderers/web_gl_renderer.dart';
import 'package:three_dart/three3d/textures/index.dart';
import 'package:three_dart/three3d/weak_map.dart';

class WebGLCubeUVMaps {
  var cubeUVmaps = WeakMap();
  WebGLRenderer renderer;
  PMREMGenerator? pmremGenerator;

  WebGLCubeUVMaps(this.renderer);

  Texture? get(Texture? texture) {
    if (texture != null) {
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

          pmremGenerator ??= PMREMGenerator(renderer);

          renderTarget = isEquirectMap
              ? pmremGenerator!.fromEquirectangular(texture, renderTarget)
              : pmremGenerator!.fromCubemap(texture, renderTarget);
          cubeUVmaps.add(key: texture, value: renderTarget);

          return renderTarget.texture;
        } else {
          if (cubeUVmaps.has(texture)) {
            return cubeUVmaps.get(texture).texture;
          } else {
            var image = texture.image;

            if ((isEquirectMap && image != null && image.height > 0) ||
                (isCubeMap && image != null && isCubeTextureComplete(image))) {
              pmremGenerator ??= PMREMGenerator(renderer);

              var renderTarget = isEquirectMap
                  ? pmremGenerator!.fromEquirectangular(texture)
                  : pmremGenerator!.fromCubemap(texture);
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
    cubeUVmaps = WeakMap();

    if (pmremGenerator != null) {
      pmremGenerator!.dispose();
      pmremGenerator = null;
    }
  }
}
