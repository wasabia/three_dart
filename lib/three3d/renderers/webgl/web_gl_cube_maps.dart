import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/renderers/web_gl_cube_render_target.dart';
import 'package:three_dart/three3d/renderers/web_gl_renderer.dart';
import 'package:three_dart/three3d/textures/index.dart';
import 'package:three_dart/three3d/weak_map.dart';

class WebGLCubeMaps {
  WebGLRenderer renderer;
  var cubemaps = WeakMap();

  WebGLCubeMaps(this.renderer);

  Texture mapTextureMapping(Texture texture, int? mapping) {
    if (mapping == EquirectangularReflectionMapping) {
      texture.mapping = CubeReflectionMapping;
    } else if (mapping == EquirectangularRefractionMapping) {
      texture.mapping = CubeRefractionMapping;
    }
    return texture;
  }

  Texture? get(Texture? texture) {
    if (texture != null && texture.isRenderTargetTexture == false) {
      var mapping = texture.mapping;

      if (mapping == EquirectangularReflectionMapping || mapping == EquirectangularRefractionMapping) {
        if (cubemaps.has(texture)) {
          var cubemap = cubemaps.get(texture).texture;
          return mapTextureMapping(cubemap, texture.mapping);
        } else {
          var image = texture.image;

          if (image != null && image.height > 0) {
            var renderTarget = WebGLCubeRenderTarget(image.height ~/ 2, null, null);
            renderTarget.fromEquirectangularTexture(renderer, texture);
            cubemaps.add(key: texture, value: renderTarget);

            texture.addEventListener('dispose', onTextureDispose);

            return mapTextureMapping(renderTarget.texture, texture.mapping);
          } else {
            // image not yet ready. try the conversion next frame

            return null;
          }
        }
      }
    }

    return texture;
  }

  onTextureDispose(event) {
    var texture = event.target;

    texture.removeEventListener('dispose', onTextureDispose);

    var cubemap = cubemaps.get(texture);

    if (cubemap != null) {
      cubemaps.delete(texture);
      cubemap.dispose();
    }
  }

  void dispose() {
    cubemaps = WeakMap();
  }
}
