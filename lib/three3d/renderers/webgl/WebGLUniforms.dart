part of three_webgl;

/**
 * Uniforms of a program.
 * Those form a tree structure with a special top-level container for the root,
 * which you get by calling 'new WebGLUniforms( gl, program )'.
 *
 *
 * Properties of inner nodes including the top-level container:
 *
 * .seq - array of nested uniforms
 * .map - nested uniforms by name
 *
 *
 * Methods of all nodes except the top-level container:
 *
 * .setValue( gl, value, [textures] )
 *
 * 		uploads a uniform value(s)
 *  	the 'textures' parameter is needed for sampler uniforms
 *
 *
 * Static methods of the top-level container (textures factorizations):
 *
 * .upload( gl, seq, values, textures )
 *
 * 		sets uniforms in 'seq' to 'values[id].value'
 *
 * .seqWithValue( seq, values ) : filteredSeq
 *
 * 		filters 'seq' entries with corresponding entry in values
 *
 *
 * Methods of the top-level container (textures factorizations):
 *
 * .setValue( gl, name, value, textures )
 *
 * 		sets uniform with  name 'name' to 'value'
 *
 * .setOptional( gl, obj, prop )
 *
 * 		like .set for an optional property of the object
 *
 */

// Root Container

class WebGLUniforms with WebGLUniform {
  dynamic gl;
  WebGLProgram program;

  WebGLUniforms(this.gl, this.program) {
    this.seq = [];
    this.map = {};

    var n = gl.getProgramParameter(program.program, gl.ACTIVE_UNIFORMS);

    for (var i = 0; i < n; ++i) {
      var info = gl.getActiveUniform(program.program, i);
      var addr = gl.getUniformLocation(program.program, info.name);

      // print(" WebGLUniforms info.name: ${info.name} addr: ${addr}  ");

      parseUniform(info, addr, this);
    }
  }

  setValue(gl, name, value, [WebGLTextures? textures]) {
    var u = this.map[name];

    // var _vt = value.runtimeType.toString();
    // print("WebGLUniforms.setValue name: ${name}  value: ${_vt} ");
    // if(_vt == "Matrix4" || _vt == "Matrix3" || _vt == "Color") {
    //   print(value.toJSON());
    // } else {
    //   print(value);
    // }

    if (u != null) u.setValue(gl, value, textures);
  }

  setOptional(gl, object, name) {
    // var v = object[ name ];
    var v = object.getValue(name);

    if (v != null) this.setValue(gl, name, v, null);
  }

  static upload(gl, seq, values, textures) {
    for (var i = 0, n = seq.length; i != n; ++i) {
      var u = seq[i];
      var v = values[u.id];

      // var value = v["value"];
      // var _vt = value.runtimeType.toString();
      // print("WebGLUniforms.upload ${_vt} name: ${u.id}  value: ${value} ");
      // if(_vt == "Matrix4" || _vt == "Matrix3" || _vt == "Color" || _vt == "Vector2" || _vt == "Vector3") {
      //   print(value.toJSON());
      // } else if(_vt == "List<Vector3>") {
      //   print(value.map((e) => e.toJSON()));
      // } else if( u.id == "lightProbe" ) {
      //   print(value.map((e) => e.toJSON() ) );
      // } else if( u.id == "directionalLights" ) {
      //   print(value.map((e) => e["color"].toJSON() ) );
      //   print(value.map((e) => e["direction"].toJSON() ) );
      // } else if(u.id == "spotLights") {
      //   print("spotLights... ");
      //   print(value.map((e) => e["position"].toJSON() ) );
      //   print(value.map((e) => e["direction"].toJSON() ) );
      //   print(value.map((e) => e["color"].toJSON() ) );
      // } else if(u.id == "spotShadowMatrix" || u.id == "directionalShadowMatrix") {
      //   print(value.map((e) => e.toJSON()));
      // } else {
      //   print(value);
      // }

      if (v["needsUpdate"] != false) {
        // note: always updating when .needsUpdate is null
        u.setValue(gl, v["value"], textures);
      }
    }
  }

  static List<dynamic> seqWithValue(List seq, Map<String, dynamic> values) {
    List<dynamic> r = [];

    for (var i = 0, n = seq.length; i != n; ++i) {
      var u = seq[i];

      // print("seqWithValue  u.id: ${u.id} ");

      if (values.keys.toList().indexOf(u.id) >= 0) {
        r.add(u);
      } else {
        // print("seqWithValue  u.id: ${u.id} is not add ");
      }
    }

    return r;
  }
}
