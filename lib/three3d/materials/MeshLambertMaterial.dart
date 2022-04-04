part of three_materials;

class MeshLambertMaterial extends Material {
  MeshLambertMaterial([parameters]) : super() {
    type = "MeshLambertMaterial";

    color = Color(0, 0, 0).setHex(0xffffff); // diffuse

    map = null;

    lightMap = null;
    lightMapIntensity = 1.0;

    aoMap = null;
    aoMapIntensity = 1.0;

    emissive = Color(0, 0, 0);
    emissiveIntensity = 1.0;
    emissiveMap = null;

    specularMap = null;

    alphaMap = null;

    // this.envMap = null;
    combine = MultiplyOperation;
    reflectivity = 1;
    refractionRatio = 0.98;

    wireframe = false;
    wireframeLinewidth = 1;
    wireframeLinecap = 'round';
    wireframeLinejoin = 'round';

    setValues(parameters);
  }

  // copy( source ) {

  //   Material.prototype.copy.call( this, source );

  //   this.color.copy( source.color );

  //   this.map = source.map;

  //   this.lightMap = source.lightMap;
  //   this.lightMapIntensity = source.lightMapIntensity;

  //   this.aoMap = source.aoMap;
  //   this.aoMapIntensity = source.aoMapIntensity;

  //   this.emissive.copy( source.emissive );
  //   this.emissiveMap = source.emissiveMap;
  //   this.emissiveIntensity = source.emissiveIntensity;

  //   this.specularMap = source.specularMap;

  //   this.alphaMap = source.alphaMap;

  //   this.envMap = source.envMap;
  //   this.combine = source.combine;
  //   this.reflectivity = source.reflectivity;
  //   this.refractionRatio = source.refractionRatio;

  //   this.wireframe = source.wireframe;
  //   this.wireframeLinewidth = source.wireframeLinewidth;
  //   this.wireframeLinecap = source.wireframeLinecap;
  //   this.wireframeLinejoin = source.wireframeLinejoin;

  //   return this;

  // }

}
