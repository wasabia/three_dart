
import 'package:three_dart/three3d/extras/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/textures/image_element.dart';

class Source {
  late String uuid;
  dynamic data;
  late int version;

  int currentVersion = 0;

  Source([data]) {
    uuid = MathUtils.generateUUID();

    this.data = data;

    version = 0;
  }

  set needsUpdate(value) {
    if (value == true) version++;
  }

  toJSON(meta) {
    var isRootObject = (meta == null || meta is String);

    if (!isRootObject && meta.images[uuid] != null) {
      return meta.images[uuid];
    }

    var output = {"uuid": uuid, "url": ''};

    var data = this.data;

    if (data != null) {
      var url;

      if (data is List) {
        // cube texture

        url = [];

        for (var i = 0, l = data.length; i < l; i++) {
          if (data[i].isDataTexture) {
            url.add(serializeImage(data[i].image));
          } else {
            url.add(serializeImage(data[i]));
          }
        }
      } else {
        // texture

        url = serializeImage(data);
      }

      output["url"] = url;
    }

    if (!isRootObject) {
      meta.images[uuid] = output;
    }

    return output;
  }
}

serializeImage(image) {
  if (image is ImageElement) {
    // default images

    return ImageUtils.getDataURL(image);
  } else {
    if (image.data != null) {
      // images of DataTexture

      return {
        "data": image.data.sublist(0),
        "width": image.width,
        "height": image.height,
        "type": image.data.runtimeType.toString(), // TODO remove runtimeType for web release mode
      };
    } else {
      print('three.Texture: Unable to serialize Texture.');
      return {};
    }
  }
}
