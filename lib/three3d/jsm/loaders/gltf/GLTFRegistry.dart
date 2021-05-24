part of gltf_loader;


/* GLTFREGISTRY */

class GLTFRegistry {

  var objects = {};

  GLTFRegistry() {}

  get(key) {
    return objects[ key ];
  }


  add( key, object ) {

    objects[ key ] = object;

  }

  remove( key ) {

    // delete objects[ key ];
    objects.remove(key);

  }

  removeAll() {

    objects = {};

  }

}