part of three_webgl;

class BaseWebGLBufferRenderer {
  setIndex(value) {
    throw (" BaseWebGLBufferRenderer.setIndex value: $value  ");
  }

  render(start, count) {
    throw (" BaseWebGLBufferRenderer.render start: $start $count  ");
  }

  renderInstances(start, count, primcount) {
    throw (" BaseWebGLBufferRenderer.renderInstances start: $start $count primcount: $primcount  ");
  }

  setMode(value) {
    throw (" BaseWebGLBufferRenderer.setMode value: $value ");
  }
}

class WebGLBufferRenderer extends BaseWebGLBufferRenderer {
  dynamic gl;
  bool isWebGL2 = true;
  var mode;
  WebGLExtensions extensions;
  WebGLInfo info;
  WebGLCapabilities capabilities;

  WebGLBufferRenderer(this.gl, this.extensions, this.info, this.capabilities) {
    isWebGL2 = capabilities.isWebGL2;
  }

  @override
  setMode(value) {
    mode = value;
  }

  @override
  void render(start, count) {
    gl.drawArrays(mode, start, count);
    info.update(count, mode, 1);
  }

  @override
  void renderInstances(start, count, primcount) {
    if (primcount == 0) return;

    var extension, methodName;

    if (isWebGL2) {
      gl.drawArraysInstanced(mode, start, count, primcount);
    } else {
      extension = extensions.get('ANGLE_instanced_arrays');
      methodName = 'drawArraysInstancedANGLE';

      if (extension == null) {
        print(
            'three.WebGLBufferRenderer: using three.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.');
        return;
      }
      extension[methodName](mode, start, count, primcount);
    }

    info.update(count, mode, primcount);
  }
}
