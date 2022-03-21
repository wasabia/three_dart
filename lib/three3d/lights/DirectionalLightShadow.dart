part of three_lights;

class DirectionalLightShadow extends LightShadow {
  bool isDirectionalLightShadow = true;

  DirectionalLightShadow()
      : super(OrthographicCamera(-5, 5, 5, -5, 0.5, 500));

}
