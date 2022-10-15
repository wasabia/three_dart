
import 'package:three_dart/extra/console.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/objects/index.dart';
import 'package:three_dart/three3d/renderers/webgl/index.dart';

class WebGLBindingStates {
  dynamic gl;
  WebGLExtensions extensions;
  WebGLAttributes attributes;
  WebGLCapabilities capabilities;

  late int maxVertexAttributes;

  dynamic extension;
  late bool vaoAvailable;

  late Map<String, dynamic> defaultState;
  late Map<String, dynamic> currentState;
  late Map<int, dynamic> bindingStates;

  bool forceUpdate = false;

  WebGLBindingStates(
    this.gl,
    this.extensions,
    this.attributes,
    this.capabilities,
  ) {
    maxVertexAttributes = gl.getParameter(gl.MAX_VERTEX_ATTRIBS);

    bindingStates = <int, dynamic>{};

    extension = capabilities.isWebGL2
        ? null
        : extensions.get('OES_vertex_array_object');
    vaoAvailable = capabilities.isWebGL2 || extension != null;

    defaultState = createBindingState(null);
    currentState = defaultState;
  }

  void setup(
    Object3D object,
    Material material,
    WebGLProgram program,
    BufferGeometry geometry,
    BufferAttribute? index,
  ) {
    bool updateBuffers = false;

    if (vaoAvailable) {
      var state = getBindingState(geometry, program, material);

      if (currentState != state) {
        currentState = state;
        bindVertexArrayObject(currentState["object"]);
      }

      updateBuffers = needsUpdate(object, geometry, program, index);
      // print("WebGLBindingStates.dart setup object: ${object}  updateBuffers: ${updateBuffers}  ");

      if (updateBuffers) saveCache(object, geometry, program, index);
    } else {
      var wireframe = (material.wireframe == true);

      if (currentState["geometry"] != geometry.id ||
          currentState["program"] != program.id ||
          currentState["wireframe"] != wireframe) {
        currentState["geometry"] = geometry.id;
        currentState["program"] = program.id;
        currentState["wireframe"] = wireframe;

        updateBuffers = true;
      }
    }

    if (index != null) {
      attributes.update(index, gl.ELEMENT_ARRAY_BUFFER);
    }

    if (updateBuffers || forceUpdate) {
      forceUpdate = false;

      setupVertexAttributes(object, material, program, geometry);

      if (index != null) {
        var _buffer = attributes.get(index)["buffer"];
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _buffer);
      }
    }
  }

  createVertexArrayObject() {
    if (capabilities.isWebGL2) return gl.createVertexArray();

    return extension.createVertexArrayOES();
  }

  bindVertexArrayObject(vao) {
    if (capabilities.isWebGL2) {
      if (vao != null) {
        return gl.bindVertexArray(vao);
      } else {
        print(" WebGLBindingStates.dart  bindVertexArrayObject VAO is null");
        return;
      }
    }

    return extension.bindVertexArrayOES(vao);
  }

  deleteVertexArrayObject(vao) {
    if (capabilities.isWebGL2) return gl.deleteVertexArray(vao);

    return extension.deleteVertexArrayOES(vao);
  }

  getBindingState(
    BufferGeometry geometry,
    program,
    Material material,
  ) {
    var wireframe = (material.wireframe == true);

    var programMap = bindingStates[geometry.id];

    if (programMap == null) {
      programMap = {};
      bindingStates[geometry.id] = programMap;
    }

    var stateMap = programMap[program.id];

    if (stateMap == null) {
      stateMap = {};
      programMap[program.id] = stateMap;
    }

    var state = stateMap[wireframe];

    if (state == null) {
      state = createBindingState(createVertexArrayObject());
      stateMap[wireframe] = state;
    }

    return state;
  }

  Map<String, dynamic> createBindingState(vao) {
    var newAttributes = List<int>.filled(maxVertexAttributes, 0);
    var enabledAttributes = List<int>.filled(maxVertexAttributes, 0);
    var attributeDivisors = List<int>.filled(maxVertexAttributes, 0);

    for (var i = 0; i < maxVertexAttributes; i++) {
      newAttributes[i] = 0;
      enabledAttributes[i] = 0;
      attributeDivisors[i] = 0;
    }

    return {
      // for backward compatibility on non-VAO support browser
      "geometry": null,
      "program": null,
      "wireframe": false,

      "newAttributes": newAttributes,
      "enabledAttributes": enabledAttributes,
      "attributeDivisors": attributeDivisors,
      "object": vao,
      "attributes": {},
      "index": null
    };
  }

  bool needsUpdate(Object3D object, BufferGeometry geometry, WebGLProgram program, BufferAttribute? index) {
    var cachedAttributes = currentState["attributes"];
    var geometryAttributes = geometry.attributes;
    var attributesNum = 0;
    var programAttributes = program.getAttributes();

		for ( final name in programAttributes.keys ) {

			Map programAttribute = programAttributes[ name ];

			if ( programAttribute["location"] >= 0 ) {

				var cachedAttribute = cachedAttributes[ name ];
				var geometryAttribute = geometryAttributes[ name ];

				if ( geometryAttribute == undefined ) {

					if ( name == 'instanceMatrix' && object.instanceMatrix != null ) geometryAttribute = object.instanceMatrix;
					if ( name == 'instanceColor' && object.instanceColor != null ) geometryAttribute = object.instanceColor;

				}

				if ( cachedAttribute == undefined ) return true;

				if ( cachedAttribute["attribute"] != geometryAttribute ) return true;

				if ( geometryAttribute != null && cachedAttribute["data"] != geometryAttribute.data ) return true;

				attributesNum ++;

			}
    }

    if (currentState["attributesNum"] != attributesNum) return true;
    if (currentState["index"] != index) return true;
    return false;
  }

  void saveCache(object, BufferGeometry geometry, WebGLProgram program, BufferAttribute? index) {
    var cache = {};
    var attributes = geometry.attributes;
    var attributesNum = 0;

    var programAttributes = program.getAttributes();

    for ( final name in programAttributes.keys ) {

			Map programAttribute = programAttributes[ name ];

			if ( programAttribute["location"] >= 0 ) {

				var attribute = attributes[ name ];

				if ( attribute == undefined ) {

					if ( name == 'instanceMatrix' && object.instanceMatrix != null) attribute = object.instanceMatrix;
					if ( name == 'instanceColor' && object.instanceColor != null) attribute = object.instanceColor;

				}

				var data = {};
				data["attribute"] = attribute;

				if ( attribute != null && attribute.data != null ) {

					data["data"] = attribute.data;

				}

				cache[ name ] = data;

				attributesNum ++;

			}
    }

    currentState["attributes"] = cache;
    currentState["attributesNum"] = attributesNum;

    currentState["index"] = index;
  }

  void initAttributes() {
    var newAttributes = currentState["newAttributes"];

    for (var i = 0, il = newAttributes.length; i < il; i++) {
      newAttributes[i] = 0;
    }
  }

  void enableAttribute(attribute) {
    enableAttributeAndDivisor(attribute, 0);
  }

  void enableAttributeAndDivisor(attribute, meshPerAttribute) {
    var newAttributes = currentState["newAttributes"];
    var enabledAttributes = currentState["enabledAttributes"];
    var attributeDivisors = currentState["attributeDivisors"];

    newAttributes[attribute] = 1;

    if (enabledAttributes[attribute] == 0) {
      gl.enableVertexAttribArray(attribute);
      enabledAttributes[attribute] = 1;
    }

    if (attributeDivisors[attribute] != meshPerAttribute) {
      // var extension = capabilities.isWebGL2 ? gl : extensions.get( 'ANGLE_instanced_arrays' );
      // extension[ capabilities.isWebGL2 ? 'vertexAttribDivisor' : 'vertexAttribDivisorANGLE' ]( attribute, meshPerAttribute );

      gl.vertexAttribDivisor(attribute, meshPerAttribute);
      attributeDivisors[attribute] = meshPerAttribute;
    }
  }

  void disableUnusedAttributes() {
    var newAttributes = currentState["newAttributes"];
    var enabledAttributes = currentState["enabledAttributes"];

    for (var i = 0, il = enabledAttributes.length; i < il; i++) {
      if (enabledAttributes[i] != newAttributes[i]) {
        gl.disableVertexAttribArray(i);
        enabledAttributes[i] = 0;
      }
    }
  }

  void vertexAttribPointer(index, size, type, normalized, stride, offset) {
    if (capabilities.isWebGL2 == true &&
        (type == gl.INT || type == gl.UNSIGNED_INT)) {
      gl.vertexAttribIPointer(index, size, type, stride, offset);
    } else {
      gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
    }
  }

  void setupVertexAttributes(
    Object3D object,
    Material material,
    WebGLProgram program,
    BufferGeometry geometry,
  ) {
    if (capabilities.isWebGL2 == false &&
        (object is InstancedMesh || geometry is InstancedBufferGeometry)) {
      if (extensions.get('ANGLE_instanced_arrays') == null) return;
    }

    initAttributes();

    var geometryAttributes = geometry.attributes;

    var programAttributes = program.getAttributes();

    var materialDefaultAttributeValues = material.defaultAttributeValues;

    for (var name in programAttributes.keys) {
      var programAttribute = programAttributes[name];

      if (programAttribute["location"] >= 0) {
        // var geometryAttribute = geometryAttributes[ name ];
        BufferAttribute? geometryAttribute = geometryAttributes[name];

        if (geometryAttribute == null) {
          if (name == 'instanceMatrix' && object is InstancedMesh) {
            geometryAttribute = object.instanceMatrix;
          }
          if (name == 'instanceColor' &&
              object is InstancedMesh &&
              object.instanceColor != null) {
            geometryAttribute = object.instanceColor;
          }
        }

        if (geometryAttribute != null) {
          var normalized = geometryAttribute.normalized;
          var size = geometryAttribute.itemSize;

          var attribute = attributes.get(geometryAttribute);

          // TODO Attribute may not be available on context restore

          if (attribute == null) {
            print(
                "WebGLBindingState setupVertexAttributes name: $name attribute == null ");
            continue;
          }

          var buffer = attribute["buffer"];
          var type = attribute["type"];
          var bytesPerElement = attribute["bytesPerElement"];

          if (geometryAttribute is InterleavedBufferAttribute) {
            var data = geometryAttribute.data;
            var stride = data?.stride;
            var offset = geometryAttribute.offset;

            if (data != null && data is InstancedInterleavedBuffer) {
              // enableAttributeAndDivisor( programAttribute, data.meshPerAttribute );
              for (var i = 0; i < programAttribute["locationSize"]; i++) {
                enableAttributeAndDivisor(
                    programAttribute["location"] + i, data.meshPerAttribute);
              }

              if (object is! InstancedMesh &&
                  geometry.maxInstanceCount == null) {
                geometry.maxInstanceCount = data.meshPerAttribute * data.count;
              }
            } else {
              // enableAttribute( programAttribute );
              for (var i = 0; i < programAttribute["locationSize"]; i++) {
                enableAttribute(programAttribute["location"] + i);
              }
            }

            gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

            // vertexAttribPointer( programAttribute, size, type, normalized, stride * bytesPerElement, offset * bytesPerElement );
            for (var i = 0; i < programAttribute["locationSize"]; i++) {
              vertexAttribPointer(
                  programAttribute["location"] + i,
                  size ~/ programAttribute["locationSize"],
                  type,
                  normalized,
                  stride! * bytesPerElement,
                  (offset + (size ~/ programAttribute["locationSize"]) * i) *
                      bytesPerElement);
            }
          } else {
            if (geometryAttribute is InstancedBufferAttribute) {
              // enableAttributeAndDivisor( programAttribute, geometryAttribute.meshPerAttribute );
              for (var i = 0; i < programAttribute["locationSize"]; i++) {
                enableAttributeAndDivisor(programAttribute["location"] + i,
                    geometryAttribute.meshPerAttribute);
              }

              geometry.maxInstanceCount ??=
                  geometryAttribute.meshPerAttribute * geometryAttribute.count;
            } else {
              // enableAttribute( programAttribute );
              for (var i = 0; i < programAttribute["locationSize"]; i++) {
                enableAttribute(programAttribute["location"] + i);
              }
            }

            gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
            // vertexAttribPointer( programAttribute, size, type, normalized, 0, 0 );
            for (var i = 0; i < programAttribute["locationSize"]; i++) {
              vertexAttribPointer(
                  programAttribute["location"] + i,
                  size ~/ programAttribute["locationSize"],
                  type,
                  normalized,
                  size * bytesPerElement,
                  (size ~/ programAttribute["locationSize"]) *
                      i *
                      bytesPerElement);
            }
          }
        } else if (materialDefaultAttributeValues != null) {
          var value = materialDefaultAttributeValues[name];

          if (value != null) {
            switch (value.length) {
              case 2:
                gl.vertexAttrib2fv(programAttribute["location"], value);
                break;

              case 3:
                gl.vertexAttrib3fv(programAttribute["location"], value);
                break;

              case 4:
                gl.vertexAttrib4fv(programAttribute["location"], value);
                break;

              default:
                gl.vertexAttrib1fv(programAttribute["location"], value);
            }
          }
        }
      }
    }

    disableUnusedAttributes();
  }

  void dispose() {
    reset();

    // for ( var geometryId in bindingStates ) {

    // 	var programMap = bindingStates[ geometryId ];

    // 	for ( var programId in programMap ) {

    // 		var stateMap = programMap[ programId ];

    // 		for ( var wireframe in stateMap ) {

    // 			deleteVertexArrayObject( stateMap[ wireframe ].object );

    // 			delete stateMap[ wireframe ];

    // 		}

    // 		delete programMap[ programId ];

    // 	}

    // 	delete bindingStates[ geometryId ];

    // }
  }

  void releaseStatesOfGeometry(BufferGeometry geometry) {
    if (bindingStates[geometry.id] == null) return;

    var programMap = bindingStates[geometry.id];
    for (var programId in programMap.keys) {
      var stateMap = programMap[programId];
      for (var wireframe in stateMap.keys) {
        deleteVertexArrayObject(stateMap[wireframe]["object"]);
      }
      stateMap.clear();
    }
    programMap.clear();

    bindingStates.remove(geometry.id);
  }

  void releaseStatesOfProgram(program) {
    print(" WebGLBindingStates releaseStatesOfProgram ");

    // for ( var geometryId in bindingStates ) {

    // 	var programMap = bindingStates[ geometryId ];

    // 	if ( programMap[ program.id ] == null ) continue;

    // 	var stateMap = programMap[ program.id ];

    // 	for ( var wireframe in stateMap ) {

    // 		deleteVertexArrayObject( stateMap[ wireframe ].object );

    // 		delete stateMap[ wireframe ];

    // 	}

    // 	delete programMap[ program.id ];

    // }
  }

  void reset() {
    resetDefaultState();

    forceUpdate = true;

    if (currentState == defaultState) return;

    currentState = defaultState;
    bindVertexArrayObject(currentState["object"]);
  }

  // for backward-compatilibity

  void resetDefaultState() {
    defaultState["geometry"] = null;
    defaultState["program"] = null;
    defaultState["wireframe"] = false;
  }
}
