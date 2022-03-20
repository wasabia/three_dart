part of three_helpers;

var _vectorHemisphereLightHelper = /*@__PURE__*/ Vector3.init();
var _color1 = /*@__PURE__*/ Color(0, 0, 0);
var _color2 = /*@__PURE__*/ Color(0, 0, 0);

class HemisphereLightHelper extends Object3D {
  Color? color;
  late Light light;

  HemisphereLightHelper(this.light, size, this.color) : super() {
    light.updateMatrixWorld(false);

    matrix = light.matrixWorld;
    matrixAutoUpdate = false;

    var geometry = OctahedronGeometry(size);
    geometry.rotateY(Math.PI * 0.5);

    material = MeshBasicMaterial(
        {"wireframe": true, "fog": false, "toneMapped": false});
    if (color == null) material.vertexColors = true;

    var position = geometry.getAttribute('position');
    var colors = Float32List(position.count * 3);

    geometry.setAttribute(
        'color', Float32BufferAttribute(colors, 3, false));

    add(Mesh(geometry, material));

    update();
  }

  dispose() {
    children[0].geometry!.dispose();
    children[0].material.dispose();
  }

  update() {
    var mesh = children[0];

    if (color != null) {
      material.color.copy(color);
    } else {
      var colors = mesh.geometry!.getAttribute('color');

      _color1.copy(light.color!);
      _color2.copy(light.groundColor!);

      for (var i = 0, l = colors.count; i < l; i++) {
        var color = (i < (l / 2)) ? _color1 : _color2;

        colors.setXYZ(i, color.r, color.g, color.b);
      }

      colors.needsUpdate = true;
    }

    mesh.lookAt(_vectorHemisphereLightHelper
        .setFromMatrixPosition(light.matrixWorld)
        .negate());
  }
}
