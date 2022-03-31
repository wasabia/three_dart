part of three_helpers;

var _SpotLightHelpervector = /*@__PURE__*/ Vector3.init();

class SpotLightHelper extends Object3D {
  late Light light;
  @override
  late Matrix4 matrix;

  /**
	 * @default false
	 */
  @override
  bool matrixAutoUpdate = false;

  late Color? color;
  late LineSegments cone;

  SpotLightHelper(this.light, this.color) : super() {
    light.updateMatrixWorld(false);

    matrix = light.matrixWorld;

    var geometry = BufferGeometry();

    List<double> positions = [
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      0,
      1,
      0,
      0,
      0,
      -1,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
      1,
      0,
      0,
      0,
      0,
      -1,
      1
    ];

    for (var i = 0, j = 1, l = 32; i < l; i++, j++) {
      var p1 = (i / l) * Math.PI * 2;
      var p2 = (j / l) * Math.PI * 2;

      positions.addAll(
          [Math.cos(p1), Math.sin(p1), 1, Math.cos(p2), Math.sin(p2), 1]);
    }

    geometry.setAttribute(
        'position',
        Float32BufferAttribute(Float32Array.from(positions), 3, false));

    var material = LineBasicMaterial({"fog": false, "toneMapped": false});

    cone = LineSegments(geometry, material);
    add(cone);

    update();
  }

  @override
  dispose() {
    cone.geometry!.dispose();
    cone.material.dispose();
  }

  update() {
    light.updateMatrixWorld(false);

    double coneLength = light.distance ?? 1000;
    var coneWidth = coneLength * Math.tan(light.angle!);

    cone.scale.set(coneWidth, coneWidth, coneLength);

    _SpotLightHelpervector.setFromMatrixPosition(
        light.target!.matrixWorld);

    cone.lookAt(_SpotLightHelpervector);

    if (color != null) {
      cone.material.color.copy(color);
    } else {
      cone.material.color.copy(light.color);
    }
  }
}
