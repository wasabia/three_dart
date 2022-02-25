part of three_textures;

int textureId = 0;

class Texture with EventDispatcher {
  static String? DEFAULT_IMAGE = null;
  static int DEFAULT_MAPPING = UVMapping;

  bool isTexture = true;
  bool isWebGLRenderTarget = false;
  bool isVideoTexture = false;
  bool isDataTexture2DArray = false;
  bool isDataTexture3D = false;
  bool isDepthTexture = false;
  bool isDataTexture = false;
  bool isCompressedTexture = false;
  bool isOpenGLTexture = false;
  bool isRenderTargetTexture =
      false; // indicates whether a texture belongs to a render target or not
  bool needsPMREMUpdate =
      false; // indicates whether this texture should be processed by PMREMGenerator or not (only relevant for render target textures)

  // image or List ???
  dynamic image;

  int id = textureId++;
  String uuid = MathUtils.generateUUID();
  String name = "";
  int? mapping;
  int wrapS = ClampToEdgeWrapping;
  int wrapT = ClampToEdgeWrapping;
  int wrapR = ClampToEdgeWrapping;
  int magFilter = LinearFilter;
  int minFilter = LinearMipmapLinearFilter;
  late int anisotropy;
  int format = RGBAFormat;
  late int? internalFormat;
  int type = UnsignedByteType;

  Vector2 offset = Vector2(0, 0);
  Vector2 repeat = Vector2(1, 1);
  Vector2 center = Vector2(0, 0);
  num rotation = 0;

  bool matrixAutoUpdate = true;
  Matrix3 matrix = Matrix3();

  bool generateMipmaps = true;
  bool premultiplyAlpha = false;
  bool flipY = true;
  int unpackAlignment =
      4; // valid values: 1, 2, 4, 8 (see http://www.khronos.org/opengles/sdk/docs/man/xhtml/glPixelStorei.xml)

  // Values of encoding !== THREE.LinearEncoding only supported on map, envMap and emissiveMap.
  //
  // Also changing the encoding after already used by a Material will not automatically make the Material
  // update. You need to explicitly call Material.needsUpdate to trigger it to recompile.
  int encoding = LinearEncoding;

  Map userData = {};

  int version = 0;

  Function? onUpdate;

  List mipmaps = [];

  Texture(this.image, [int? mapping, int? wrapS, int? wrapT, int? magFilter,
      int? minFilter, int? format, int? type, int? anisotropy, int? encoding]) {
    this.mapping = mapping ?? Texture.DEFAULT_MAPPING;

    this.wrapS = wrapS ?? ClampToEdgeWrapping;
    this.wrapT = wrapT ?? ClampToEdgeWrapping;

    this.magFilter = magFilter ?? LinearFilter;
    this.minFilter = minFilter ?? LinearMipmapLinearFilter;

    this.anisotropy = anisotropy ?? 1;

    this.format = format ?? RGBAFormat;
    this.internalFormat = null;
    this.type = type ?? UnsignedByteType;
    this.encoding = encoding ?? LinearEncoding;
  }

  set needsUpdate(bool value) {
    if (value) {
      this.version++;
    }
  }

  updateMatrix() {
    this.matrix.setUvTransform(this.offset.x, this.offset.y, this.repeat.x,
        this.repeat.y, this.rotation, this.center.x, this.center.y);
  }

  Texture clone() {
    return Texture(null, null, null, null, null, null, null, null, null, null)
        .copy(this);
  }

  copy(source) {
    this.name = source.name;

    this.image = source.image;
    // this.mipmaps = source.mipmaps.slice( 0 );

    this.mapping = source.mapping;

    this.wrapS = source.wrapS;
    this.wrapT = source.wrapT;

    this.magFilter = source.magFilter;
    this.minFilter = source.minFilter;

    this.anisotropy = source.anisotropy;

    this.format = source.format;
    this.internalFormat = source.internalFormat;
    this.type = source.type;

    this.offset.copy(source.offset);
    this.repeat.copy(source.repeat);
    this.center.copy(source.center);
    this.rotation = source.rotation;

    this.matrixAutoUpdate = source.matrixAutoUpdate;
    this.matrix.copy(source.matrix);

    this.generateMipmaps = source.generateMipmaps;
    this.premultiplyAlpha = source.premultiplyAlpha;
    this.flipY = source.flipY;
    this.unpackAlignment = source.unpackAlignment;
    this.encoding = source.encoding;

    this.userData = json.decode(json.encode(source.userData));

    return this;
  }

  toJSON(meta) {
    bool isRootObject = (meta == null || meta is String);

    if (!isRootObject && meta.textures[this.uuid] != null) {
      return meta.textures[this.uuid];
    }

    Map<String, dynamic> output = {
      "metadata": {
        "version": 4.5,
        "type": 'Texture',
        "generator": 'Texture.toJSON'
      },
      "uuid": this.uuid,
      "name": this.name,
      "mapping": this.mapping,
      "repeat": [this.repeat.x, this.repeat.y],
      "offset": [this.offset.x, this.offset.y],
      "center": [this.center.x, this.center.y],
      "rotation": this.rotation,
      "wrap": [this.wrapS, this.wrapT],
      "format": this.format,
      "type": this.type,
      "encoding": this.encoding,
      "minFilter": this.minFilter,
      "magFilter": this.magFilter,
      "anisotropy": this.anisotropy,
      "flipY": this.flipY,
      "premultiplyAlpha": this.premultiplyAlpha,
      "unpackAlignment": this.unpackAlignment
    };

    if (this.image != null) {
      // TODO: Move to THREE.Image

      var image = this.image;

      if (image!.uuid == null) {
        image.uuid = MathUtils.generateUUID(); // UGH

      }

      if (!isRootObject && meta.images[image.uuid] == null) {
        var url;

        if (image is List) {
          // process array of images e.g. CubeTexture

          url = [];

          for (var i = 0, l = image.length; i < l; i++) {
            // check cube texture with data textures

            if (image[i].isDataTexture) {
              url.add(serializeImage(image[i].image));
            } else {
              url.add(serializeImage(image[i]));
            }
          }
        } else {
          // process single image

          url = serializeImage(image);
        }

        meta.images[image.uuid] = {"uuid": image.uuid, "url": url};
      }

      output["image"] = image.uuid;
    }

    if (this.userData.isNotEmpty) output["userData"] = this.userData;

    if (!isRootObject) {
      meta.textures[this.uuid] = output;
    }

    return output;
  }

  dispose() {
    this.dispatchEvent(Event({"type": "dispose"}));
    if (image is List) {
      image.forEach((img) {
        img.dispose();
      });
    } else {
      image?.dispose();
    }
  }

  transformUv(uv) {
    if (this.mapping != UVMapping) return uv;

    uv.applyMatrix3(this.matrix);

    if (uv.x < 0 || uv.x > 1) {
      switch (this.wrapS) {
        case RepeatWrapping:
          uv.x = uv.x - Math.floor(uv.x);
          break;

        case ClampToEdgeWrapping:
          uv.x = uv.x < 0 ? 0 : 1;
          break;

        case MirroredRepeatWrapping:
          if (Math.abs(Math.floor(uv.x) % 2) == 1) {
            uv.x = Math.ceil(uv.x) - uv.x;
          } else {
            uv.x = uv.x - Math.floor(uv.x);
          }

          break;
      }
    }

    if (uv.y < 0 || uv.y > 1) {
      switch (this.wrapT) {
        case RepeatWrapping:
          uv.y = uv.y - Math.floor(uv.y);
          break;

        case ClampToEdgeWrapping:
          uv.y = uv.y < 0 ? 0 : 1;
          break;

        case MirroredRepeatWrapping:
          if (Math.abs(Math.floor(uv.y) % 2) == 1) {
            uv.y = Math.ceil(uv.y) - uv.y;
          } else {
            uv.y = uv.y - Math.floor(uv.y);
          }

          break;
      }
    }

    if (this.flipY) {
      uv.y = 1 - uv.y;
    }

    return uv;
  }
}

class ImageDataInfo {
  Uint8List data;
  num width;
  num height;
  num depth;

  ImageDataInfo(this.data, this.width, this.height, this.depth) {}
}

serializeImage(image) {
  // if ( ( typeof HTMLImageElement !== 'undefined' && image instanceof HTMLImageElement ) ||
  // 	( typeof HTMLCanvasElement !== 'undefined' && image instanceof HTMLCanvasElement ) ||
  // 	( typeof ImageBitmap !== 'undefined' && image instanceof ImageBitmap ) ) {

  // 	// default images

  // 	return ImageUtils.getDataURL( image );

  if (image is ImageElement) {
    // default images

    // return ImageUtils.getDataURL( image );
    return image.url;
  } else {
    if (image.data != null) {
      // images of DataTexture

      return {
        "data": image.data.clone(),
        "width": image.width,
        "height": image.height,
        "type": image.data.runtimeType.toString()
      };
    } else {
      print('THREE.Texture: Unable to serialize Texture.');
      return {};
    }
  }
}
