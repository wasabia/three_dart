part of three_animation;

/**
 *
 * A group of objects that receives a shared animation state.
 *
 * Usage:
 *
 *  - Add objects you would otherwise pass as 'root' to the
 *    constructor or the .clipAction method of AnimationMixer.
 *
 *  - Instead pass this object as 'root'.
 *
 *  - You can also add and remove objects later when the mixer
 *    is running.
 *
 * Note:
 *
 *    Objects of this class appear as one object to the mixer,
 *    so cache control of the individual objects must be done
 *    on the group.
 *
 * Limitation:
 *
 *  - The animated properties must be compatible among the
 *    all objects in the group.
 *
 *  - A single property can either be controlled through a
 *    target group or directly, but not both.
 */

class AnimationObjectGroup {
  bool isAnimationObjectGroup = true;

  String uuid = MathUtils.generateUUID();

  // threshold
  int nCachedObjects_ = 0;
  // note: read by PropertyBinding.Composite

  late Map _indicesByUUID;
  late dynamic _paths;
  late dynamic _parsedPaths;
  late dynamic _bindings;
  late dynamic _bindingsIndicesByPath;
  List<Mesh> _objects = [];

  AnimationObjectGroup(List<Mesh>? items) {
    // cached objects followed by the active ones
    this._objects = items != null ? items.sublist(0) : [];

    var indices = {};
    this._indicesByUUID = indices; // for bookkeeping

    if (items != null && items.length > 0) {
      for (var i = 0, n = items.length; i != n; ++i) {
        indices[items[i].uuid] = i;
      }
    }

    this._paths = []; // inside: string
    this._parsedPaths = []; // inside: { we don't care, here }
    this._bindings = []; // inside: Array< PropertyBinding >
    this._bindingsIndicesByPath = {}; // inside: indices in these arrays

    var scope = this;

    // this.stats = {

    //   objects: {
    //     get total() {

    //       return scope._objects.length;

    //     },
    //     get inUse() {

    //       return this.total - scope.nCachedObjects_;

    //     }
    //   },
    //   get bindingsPerObject() {

    //     return scope._bindings.length;

    //   }

    // };
  }

  add(List<Mesh> items) {
    var objects = this._objects,
        indicesByUUID = this._indicesByUUID,
        paths = this._paths,
        parsedPaths = this._parsedPaths,
        bindings = this._bindings,
        nBindings = bindings.length;

    var knownObject = null,
        nObjects = objects.length,
        nCachedObjects = this.nCachedObjects_;

    for (var i = 0, n = items.length; i != n; ++i) {
      var object = items[i], uuid = object.uuid;
      var index = indicesByUUID[uuid];

      if (index == null) {
        // unknown object -> add it to the ACTIVE region

        index = nObjects++;
        indicesByUUID[uuid] = index;
        objects.add(object);

        // accounting is done, now do the same for all bindings

        for (var j = 0, m = nBindings; j != m; ++j) {
          bindings[j]
              .add(new PropertyBinding(object, paths[j], parsedPaths[j]));
        }
      } else if (index < nCachedObjects) {
        knownObject = objects[index];

        // move existing object to the ACTIVE region

        var firstActiveIndex = --nCachedObjects,
            lastCachedObject = objects[firstActiveIndex];

        indicesByUUID[lastCachedObject.uuid] = index;
        objects[index] = lastCachedObject;

        indicesByUUID[uuid] = firstActiveIndex;
        objects[firstActiveIndex] = object;

        // accounting is done, now do the same for all bindings

        for (var j = 0, m = nBindings; j != m; ++j) {
          var bindingsForPath = bindings[j],
              lastCached = bindingsForPath[firstActiveIndex];

          var binding = bindingsForPath[index];

          bindingsForPath[index] = lastCached;

          if (binding == null) {
            // since we do not bother to create new bindings
            // for objects that are cached, the binding may
            // or may not exist

            binding = new PropertyBinding(object, paths[j], parsedPaths[j]);
          }

          bindingsForPath[firstActiveIndex] = binding;
        }
      } else if (objects[index] != knownObject) {
        print('THREE.AnimationObjectGroup: Different objects with the same UUID ' +
            'detected. Clean the caches or recreate your infrastructure when reloading scenes.');
      } // else the object is already where we want it to be

    } // for arguments

    this.nCachedObjects_ = nCachedObjects;
  }

  remove(List<Mesh> items) {
    var objects = this._objects,
        indicesByUUID = this._indicesByUUID,
        bindings = this._bindings,
        nBindings = bindings.length;

    var nCachedObjects = this.nCachedObjects_;

    for (var i = 0, n = items.length; i != n; ++i) {
      var object = items[i], uuid = object.uuid, index = indicesByUUID[uuid];

      if (index != null && index >= nCachedObjects) {
        // move existing object into the CACHED region

        var lastCachedIndex = nCachedObjects++,
            firstActiveObject = objects[lastCachedIndex];

        indicesByUUID[firstActiveObject.uuid] = index;
        objects[index] = firstActiveObject;

        indicesByUUID[uuid] = lastCachedIndex;
        objects[lastCachedIndex] = object;

        // accounting is done, now do the same for all bindings

        for (var j = 0, m = nBindings; j != m; ++j) {
          var bindingsForPath = bindings[j],
              firstActive = bindingsForPath[lastCachedIndex],
              binding = bindingsForPath[index];

          bindingsForPath[index] = firstActive;
          bindingsForPath[lastCachedIndex] = binding;
        }
      }
    } // for arguments

    this.nCachedObjects_ = nCachedObjects;
  }

  // remove & forget
  uncache(List<Mesh> items) {
    var objects = this._objects,
        indicesByUUID = this._indicesByUUID,
        bindings = this._bindings,
        nBindings = bindings.length;

    var nCachedObjects = this.nCachedObjects_, nObjects = objects.length;

    for (var i = 0, n = items.length; i != n; ++i) {
      var object = items[i], uuid = object.uuid, index = indicesByUUID[uuid];

      if (index != null) {
        // delete indicesByUUID[ uuid ];
        indicesByUUID.remove(uuid);

        if (index < nCachedObjects) {
          // object is cached, shrink the CACHED region

          var firstActiveIndex = --nCachedObjects,
              lastCachedObject = objects[firstActiveIndex],
              lastIndex = --nObjects,
              lastObject = objects[lastIndex];

          // last cached object takes this object's place
          indicesByUUID[lastCachedObject.uuid] = index;
          objects[index] = lastCachedObject;

          // last object goes to the activated slot and pop
          indicesByUUID[lastObject.uuid] = firstActiveIndex;
          objects[firstActiveIndex] = lastObject;
          pop(objects);

          // accounting is done, now do the same for all bindings

          for (var j = 0, m = nBindings; j != m; ++j) {
            var bindingsForPath = bindings[j],
                lastCached = bindingsForPath[firstActiveIndex],
                last = bindingsForPath[lastIndex];

            bindingsForPath[index] = lastCached;
            bindingsForPath[firstActiveIndex] = last;
            bindingsForPath.pop();
          }
        } else {
          // object is active, just swap with the last and pop

          var lastIndex = --nObjects, lastObject = objects[lastIndex];

          if (lastIndex > 0) {
            indicesByUUID[lastObject.uuid] = index;
          }

          objects[index] = lastObject;
          pop(objects);

          // accounting is done, now do the same for all bindings

          for (var j = 0, m = nBindings; j != m; ++j) {
            var bindingsForPath = bindings[j];

            bindingsForPath[index] = bindingsForPath[lastIndex];
            pop(bindingsForPath);
          }
        } // cached or active

      } // if object is known

    } // for arguments

    this.nCachedObjects_ = nCachedObjects;
  }

  // Internal interface used by befriended PropertyBinding.Composite:

  subscribe_(path, parsedPath) {
    // returns an array of bindings for the given path that is changed
    // according to the contained objects in the group

    var indicesByPath = this._bindingsIndicesByPath;
    var index = indicesByPath[path];
    var bindings = this._bindings;

    if (index != null) return bindings[index];

    var paths = this._paths,
        parsedPaths = this._parsedPaths,
        objects = this._objects,
        nObjects = objects.length,
        nCachedObjects = this.nCachedObjects_;

    var bindingsForPath = List<PropertyBinding?>.filled(nObjects, null);

    index = bindings.length;

    indicesByPath[path] = index;

    paths.add(path);
    parsedPaths.add(parsedPath);
    bindings.add(bindingsForPath);

    for (var i = nCachedObjects, n = objects.length; i != n; ++i) {
      var object = objects[i];
      bindingsForPath[i] = new PropertyBinding(object, path, parsedPath);
    }

    return bindingsForPath;
  }

  unsubscribe_(path) {
    // tells the group to forget about a property path and no longer
    // update the array previously obtained with 'subscribe_'

    var indicesByPath = this._bindingsIndicesByPath,
        index = indicesByPath[path];

    if (index != null) {
      var paths = this._paths,
          parsedPaths = this._parsedPaths,
          bindings = this._bindings,
          lastBindingsIndex = bindings.length - 1,
          lastBindings = bindings[lastBindingsIndex],
          lastBindingsPath = path[lastBindingsIndex];

      indicesByPath[lastBindingsPath] = index;

      bindings[index] = lastBindings;
      bindings.pop();

      parsedPaths[index] = parsedPaths[lastBindingsIndex];
      parsedPaths.pop();

      paths[index] = paths[lastBindingsIndex];
      paths.pop();
    }
  }
}
