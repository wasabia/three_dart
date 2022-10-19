import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/loaders/file_loader.dart';
import 'package:three_dart/three3d/loaders/loader.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/utils.dart';

class BufferGeometryLoader extends Loader {
  BufferGeometryLoader(manager) : super(manager);

  @override
  loadAsync(url) async {
    var completer = Completer();

    load(url, (data) {
      completer.complete(data);
    });

    return completer.future;
  }

  @override
  load(url, onLoad, [onProgress, onError]) {
    var scope = this;

    var loader = FileLoader(scope.manager);
    loader.setPath(scope.path);
    loader.setRequestHeader(scope.requestHeader);
    loader.setWithCredentials(scope.withCredentials);
    loader.load(url, (text) {
      try {
        onLoad(scope.parse(convert.jsonDecode(text)));
      } catch (e) {
        if (onError != null) {
          onError(e);
        } else {
          print(e);
        }

        scope.manager.itemError(url);
      }
    }, onProgress, onError);
  }

  @override
  parse(json, [String? path, Function? onLoad, Function? onError]) {
    var interleavedBufferMap = {};
    var arrayBufferMap = {};

    getArrayBuffer(json, uuid) {
      if (arrayBufferMap[uuid] != null) return arrayBufferMap[uuid];

      var arrayBuffers = json.arrayBuffers;
      var arrayBuffer = arrayBuffers[uuid];

      var ab = Uint32Array(arrayBuffer).buffer;

      arrayBufferMap[uuid] = ab;

      return ab;
    }

    getInterleavedBuffer(json, uuid) {
      if (interleavedBufferMap[uuid] != null) return interleavedBufferMap[uuid];

      var interleavedBuffers = json.interleavedBuffers;
      var interleavedBuffer = interleavedBuffers[uuid];

      var buffer = getArrayBuffer(json, interleavedBuffer.buffer);

      var array = getTypedArray(interleavedBuffer.type, buffer);
      var ib = InterleavedBuffer(array, interleavedBuffer.stride);
      ib.uuid = interleavedBuffer.uuid;

      interleavedBufferMap[uuid] = ib;

      return ib;
    }

    var geometry = json["isInstancedBufferGeometry"] == true ? InstancedBufferGeometry() : BufferGeometry();

    var index = json["data"]["index"];

    if (index != null) {
      var typedArray = getTypedArray(index["type"], index["array"]);
      geometry.setIndex(getTypedAttribute(typedArray, 1, false));
    }

    var attributes = json["data"]["attributes"];

    for (var key in attributes.keys) {
      var attribute = attributes[key];
      BaseBufferAttribute bufferAttribute;

      if (attribute["isInterleavedBufferAttribute"] == true) {
        var interleavedBuffer = getInterleavedBuffer(json["data"], attribute["data"]);
        bufferAttribute = InterleavedBufferAttribute(
            interleavedBuffer, attribute["itemSize"], attribute["offset"], attribute["normalized"]);
      } else {
        var typedArray = getTypedArray(attribute["type"], attribute["array"]);
        // var bufferAttributeConstr = attribute.isInstancedBufferAttribute ? InstancedBufferAttribute : BufferAttribute;
        if (attribute["isInstancedBufferAttribute"] == true) {
          bufferAttribute = InstancedBufferAttribute(typedArray, attribute["itemSize"], attribute["normalized"]);
        } else {
          bufferAttribute = getTypedAttribute(typedArray, attribute["itemSize"], attribute["normalized"] == true);
        }
      }

      if (attribute["name"] != null) bufferAttribute.name = attribute["name"];
      if (attribute["usage"] != null) {
        if (bufferAttribute is InstancedBufferAttribute) {
          bufferAttribute.setUsage(attribute["usage"]);
        }
      }

      if (attribute["updateRange"] != null) {
        if (bufferAttribute is InterleavedBufferAttribute) {
          bufferAttribute.updateRange?['offset'] = attribute["updateRange"]["offset"];
          bufferAttribute.updateRange?['count'] = attribute["updateRange"]["count"];
        }
      }

      geometry.setAttribute(key, bufferAttribute);
    }

    var morphAttributes = json["data"]["morphAttributes"];

    if (morphAttributes != null) {
      for (var key in morphAttributes.keys) {
        var attributeArray = morphAttributes[key];

        final array = <BufferAttribute>[];

        for (var i = 0, il = attributeArray.length; i < il; i++) {
          var attribute = attributeArray[i];
          BufferAttribute bufferAttribute;

          if (attribute is InterleavedBufferAttribute) {
            var interleavedBuffer = getInterleavedBuffer(json["data"], attribute.data);
            bufferAttribute = InterleavedBufferAttribute(
                interleavedBuffer, attribute.itemSize, attribute.offset, attribute.normalized);
          } else {
            var typedArray = getTypedArray(attribute.type, attribute.array);
            bufferAttribute = getTypedAttribute(typedArray, attribute.itemSize, attribute.normalized);
          }

          if (attribute.name != null) bufferAttribute.name = attribute.name;
          array.add(bufferAttribute);
        }

        geometry.morphAttributes[key] = array;
      }
    }

    var morphTargetsRelative = json["data"]["morphTargetsRelative"];

    if (morphTargetsRelative == true) {
      geometry.morphTargetsRelative = true;
    }

    var groups = json["data"]["groups"] ?? json["data"]["drawcalls"] ?? json["data"]["offsets"];

    if (groups != null) {
      for (var i = 0, n = groups.length; i != n; ++i) {
        var group = groups[i];

        geometry.addGroup(group["start"], group["count"], group["materialIndex"]);
      }
    }

    var boundingSphere = json["data"]["boundingSphere"];

    if (boundingSphere != null) {
      var center = Vector3(0, 0, 0);

      if (boundingSphere["center"] != null) {
        center.fromArray(boundingSphere["center"]);
      }

      geometry.boundingSphere = Sphere(center, boundingSphere["radius"]);
    }

    if (json["name"] != null) geometry.name = json["name"];
    if (json["userData"] != null) geometry.userData = json["userData"];

    return geometry;
  }
}
