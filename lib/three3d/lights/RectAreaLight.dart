part of three_lights;

class RectAreaLight extends Light {
  RectAreaLight(color, intensity, width, height) : super(color, intensity) {
    this.type = 'RectAreaLight';

    this.width = width ?? 10;
    this.height = height ?? 10;
    this.isRectAreaLight = true;
  }

  copy(Object3D source, [bool? recursive]) {
    super.copy(source);

    RectAreaLight source1 = source as RectAreaLight;

    this.width = source1.width;
    this.height = source1.height;

    return this;
  }

  toJSON({Object3dMeta? meta}) {
    var data = super.toJSON(meta: meta);

    data["object"]["width"] = this.width;
    data["object"]["height"] = this.height;

    return data;
  }
}
