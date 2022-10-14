part of three_loaders;

class Cache {
  static bool enabled = false;
  static Map<String, dynamic> files = {};

  static add(key, file) {
    if (enabled == false) return;

    // console.log( 'three.Cache', 'Adding key:', key );

    files[key] = file;
  }

  static get(key) {
    if (enabled == false) return;

    // console.log( 'three.Cache', 'Checking key:', key );

    return files[key];
  }

  static remove(key) {
    files.remove(key);
  }

  static clear() {
    files.clear();
  }
}
