part of three_webgl;

class WebGLShader {
  dynamic gl;
  dynamic shader;
  String content;

  WebGLShader(this.gl, int type, this.content) {
    this.shader = gl.createShader(type);

    gl.shaderSource(shader, content);
    gl.compileShader(shader);

    final _status = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (_status != 1 && _status != true) {
      print(gl.getShaderInfoLog(shader));
      throw (" WebGLShader comile error.... _status: ${_status} ${gl.getShaderInfoLog(shader)} ");
    }
  }
}
