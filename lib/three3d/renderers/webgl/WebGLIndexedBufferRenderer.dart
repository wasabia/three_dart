part of three_webgl;

class WebGLIndexedBufferRenderer extends BaseWebGLBufferRenderer {
  bool isWebGL2 = false;
  var mode;
  var type;
  var bytesPerElement;
  dynamic gl;
  WebGLExtensions extensions;
  WebGLInfo info;
  WebGLCapabilities capabilities;

  WebGLIndexedBufferRenderer(
      this.gl, this.extensions, this.info, this.capabilities) {
    this.isWebGL2 = capabilities.isWebGL2;
  }

  setMode(value) {
    mode = value;
  }

  setIndex(value) {
    type = value["type"];
    bytesPerElement = value["bytesPerElement"];
  }

  render(start, count) {

    gl.drawElements(mode, count, type, start * bytesPerElement);

    info.update(count, mode, 1);
  }

  renderInstances(start, count, primcount) {

    if (primcount == 0) return;

    // var extension, methodName;

    // if ( isWebGL2 ) {

    // 	extension = gl;
    // 	methodName = 'drawElementsInstanced';

    // } else {

    // 	extension = extensions.get( 'ANGLE_instanced_arrays' );
    // 	methodName = 'drawElementsInstancedANGLE';

    // 	if ( extension == null ) {

    // 		print( 'THREE.WebGLIndexedBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.' );
    // 		return;

    // 	}

    // }

    // extension[ methodName ]( mode, count, type, start * bytesPerElement, primcount );

    gl.drawElementsInstanced(
        mode, count, type, start * bytesPerElement, primcount);

    info.update(count, mode, primcount);
  }
}
