part of three_materials;

/**
 * parameters = {
 *  color: <THREE.Color>
 * }
 */

class ShadowMaterial extends Material {
  bool isShadowMaterial = true;
  String type = 'ShadowMaterial';

  ShadowMaterial([parameters]) : super() {
    this.color = Color.fromHex(0x000000);
    this.transparent = true;

    this.setValues(parameters);
  }

  copy(source) {
    super.copy(source);

    if (source.color != null) this.color?.copy(source.color);

    return this;
  }

  clone() {
    return ShadowMaterial().copy(this);
  }
}
