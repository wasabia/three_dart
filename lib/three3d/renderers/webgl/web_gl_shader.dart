class WebGLShader {
  dynamic gl;
  dynamic shader;
  String content;

  WebGLShader(this.gl, int type, this.content) {
    shader = gl.createShader(type);

    gl.shaderSource(shader, content);
    gl.compileShader(shader);

    final status = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (status != 1 && status != true) {
      print(gl.getShaderInfoLog(shader));
      throw (" WebGLShader comile error.... _status: $status ${gl.getShaderInfoLog(shader)} ");
    }
  }
}
