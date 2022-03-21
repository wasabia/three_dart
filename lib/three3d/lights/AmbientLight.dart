part of three_lights;

// 环境光 环境光颜色与网格模型的颜色进行RGB进行乘法运算

class AmbientLight extends Light {
  bool isAmbientLight = true;
  @override
  String type = 'AmbientLight';

  AmbientLight(color, [intensity]) : super(color, intensity);

  AmbientLight.fromJSON(
      Map<String, dynamic> json, Map<String, dynamic> rootJSON)
      : super.fromJSON(json, rootJSON);
}
