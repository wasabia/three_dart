part of three_core;

int _object3DId = 0;

Vector3 _v1 = Vector3.init();
Quaternion _q1 = Quaternion();
Matrix4 _m1 = Matrix4();
Vector3 _target = Vector3.init();

Vector3 _position = Vector3.init();
Vector3 _scale = Vector3.init();
Quaternion _quaternion = Quaternion();

Vector3 _xAxis = Vector3(1, 0, 0);
Vector3 _yAxis = Vector3(0, 1, 0);
Vector3 _zAxis = Vector3(0, 0, 1);

Event _addedEvent = Event({"type": "added"});
Event _removedEvent = Event({"type": "removed"});

class Object3D with EventDispatcher {
  static Vector3 DefaultUp = Vector3(0.0, 1.0, 0.0);
  static bool DefaultMatrixAutoUpdate = true;

  int id = _object3DId++;

  String uuid = MathUtils.generateUUID();

  String? tag;

  String name = '';
  String type = 'Object3D';

  Object3D? parent;
  List<Object3D> children = [];

  bool castShadow = false;

  bool isMesh = false;
  bool isLine = false;
  bool isPoints = false;
  bool isSkinnedMesh = false;
  bool isBone = false;
  bool isInstancedMesh = false;
  bool isCamera = false;
  bool isLight = false;
  bool isLineSegments = false;
  bool isLineLoop = false;
  bool isScene = false;

  bool autoUpdate = false; // checked by the renderer

  Matrix4 matrix = Matrix4();
  Matrix4 matrixWorld = Matrix4();

  bool matrixAutoUpdate = Object3D.DefaultMatrixAutoUpdate;
  bool matrixWorldNeedsUpdate = false;

  Layers layers = Layers();
  bool visible = true;
  bool receiveShadow = false;

  bool frustumCulled = true;
  double renderOrder = 0.0;

  // List<AnimationClip> animations = [];

  bool isImmediateRenderObject = false;

  Map<String, dynamic> userData = {};

  Map<String, dynamic> extra = {};

  bool isObject3D = true;
  BufferGeometry? geometry;

  Vector3 up = Object3D.DefaultUp.clone();

  Vector3 position = Vector3(0, 0, 0);
  Euler rotation = Euler(0, 0, 0);
  Quaternion quaternion = Quaternion();
  Vector3 scale = Vector3(1, 1, 1);
  Matrix4 modelViewMatrix = Matrix4();
  Matrix3 normalMatrix = Matrix3();

  // how to handle material is a single material or List<Material>
  dynamic material;

  List<num>? morphTargetInfluences;
  Map<String, dynamic>? morphTargetDictionary;

  // InstancedMesh
  int? count;

  Matrix4? bindMatrix;
  Skeleton? skeleton;

  Material? overrideMaterial;
  Material? customDistanceMaterial;

  /**
	 * Custom depth material to be used when rendering to the depth map. Can only be used in context of meshes.
	 * When shadow-casting with a DirectionalLight or SpotLight, if you are (a) modifying vertex positions in
	 * the vertex shader, (b) using a displacement map, (c) using an alpha map with alphaTest, or (d) using a
	 * transparent texture with alphaTest, you must specify a customDepthMaterial for proper shadows.
	 */
  Material? customDepthMaterial;

  // onBeforeRender({WebGLRenderer? renderer, scene, Camera? camera, RenderTarget? renderTarget, dynamic? geometry, Material? material, dynamic group}) {
  // print(" Object3D.onBeforeRender ${type} ${id} ");
  // }
  Function? onBeforeRender;

  dynamic background;
  Texture? environment;

  Object3D() {
    init();
  }

  Object3D.fromJSON(Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    uuid = json["uuid"];
    if (json["name"] != null) {
      name = json["name"]!;
    }
    type = json["type"];
    layers.mask = json["layers"];

    position = Vector3.fromJSON(json["position"]);
    quaternion = Quaternion.fromJSON(json["quaternion"]);
    scale = Vector3.fromJSON(json["scale"]);

    if (json["geometry"] != null) {
      List<BufferGeometry>? geometries = rootJSON["geometries"];

      if (geometries != null) {
        BufferGeometry _geometry = geometries
            .firstWhere((element) => element.uuid == json["geometry"]);
        geometry = _geometry;
      }
    }

    if (json["material"] != null) {
      List<Material>? materials = rootJSON["materials"];

      if (materials != null) {
        Material _material =
            materials.firstWhere((element) => element.uuid == json["material"]);
        material = _material;
      }
    }

    init();

    if (json["children"] != null) {
      List<Map<String, dynamic>> _children = json["children"];
      for (var _child in _children) {
        final obj = Object3D.castJSON(_child, rootJSON);
        if (obj is Object3D) children.add(obj);
      }
    }
  }

  void init() {
    // TODO
    rotation.onChange(onRotationChange);
    quaternion.onChange(onQuaternionChange);
  }

  static EventDispatcher castJSON(
      Map<String, dynamic> json, Map<String, dynamic> rootJSON) {
    String? _type = json["type"];

    if (_type == null) {
      Map<String, dynamic>? _object = json["object"];
      if (_object != null) {
        _type = _object["type"];
        json = _object;
        print(" object is not null use object as json type: $_type ");
      }
    }

    if (_type == "Camera") {
      return Camera.fromJSON(json, rootJSON);
    } else if (_type == "PerspectiveCamera") {
      return PerspectiveCamera.fromJSON(json, rootJSON);
    } else if (_type == "Scene") {
      return Scene.fromJSON(json, rootJSON);
    } else if (_type == "PointLight") {
      return PointLight.fromJSON(json, rootJSON);
    } else if (_type == "Group") {
      return Group.fromJSON(json, rootJSON);
    } else if (_type == "Mesh") {
      return Mesh.fromJSON(json, rootJSON);
    } else if (_type == "Line") {
      return Line.fromJSON(json, rootJSON);
    } else if (_type == "Points") {
      return Points.fromJSON(json, rootJSON);
    } else if (_type == "AmbientLight") {
      return AmbientLight.fromJSON(json, rootJSON);
    } else if (_type == "Sprite") {
      return Sprite.fromJSON(json, rootJSON);
    } else if (_type == "SpriteMaterial") {
      return SpriteMaterial.fromJSON(json, rootJSON);
    } else if (_type == "ShapeGeometry") {
      return ShapeGeometry.fromJSON(json, rootJSON);
    } else {
      throw " type: $_type Object3D.castJSON is not support yet... ";
    }
  }

  void onRotationChange() {
    quaternion.setFromEuler(rotation, false);
  }

  void onQuaternionChange() {
    rotation.setFromQuaternion(quaternion, null, false);
  }

  void applyMatrix4(Matrix4 matrix) {
    if (matrixAutoUpdate) updateMatrix();

    this.matrix.premultiply(matrix);

    this.matrix.decompose(position, quaternion, scale);
  }

  Object3D applyQuaternion(Quaternion q) {
    quaternion.premultiply(q);

    return this;
  }

  void setRotationFromAxisAngle(axis, num angle) {
    // assumes axis is normalized

    quaternion.setFromAxisAngle(axis, angle);
  }

  void setRotationFromEuler(Euler euler) {
    quaternion.setFromEuler(euler, true);
  }

  void setRotationFromMatrix(m) {
    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    quaternion.setFromRotationMatrix(m);
  }

  void setRotationFromQuaternion(Quaternion q) {
    // assumes q is normalized

    quaternion.copy(q);
  }

  Object3D rotateOnAxis(axis, num angle) {
    // rotate object on axis in object space
    // axis is assumed to be normalized

    _q1.setFromAxisAngle(axis, angle);

    quaternion.multiply(_q1);

    return this;
  }

  Object3D rotateOnWorldAxis(axis, num angle) {
    // rotate object on axis in world space
    // axis is assumed to be normalized
    // method assumes no rotated parent

    _q1.setFromAxisAngle(axis, angle);

    quaternion.premultiply(_q1);

    return this;
  }

  Object3D rotateX(num angle) {
    return rotateOnAxis(_xAxis, angle);
  }

  Object3D rotateY(num angle) {
    return rotateOnAxis(_yAxis, angle);
  }

  Object3D rotateZ(num angle) {
    return rotateOnAxis(_zAxis, angle);
  }

  Object3D translateOnAxis(axis, num distance) {
    // translate object by distance along axis in object space
    // axis is assumed to be normalized

    _v1.copy(axis).applyQuaternion(quaternion);

    position.add(_v1.multiplyScalar(distance));

    return this;
  }

  Object3D translateX(distance) {
    return translateOnAxis(_xAxis, distance);
  }

  Object3D translateY(distance) {
    return translateOnAxis(_yAxis, distance);
  }

  Object3D translateZ(distance) {
    return translateOnAxis(_zAxis, distance);
  }

  localToWorld(vector) {
    return vector.applyMatrix4(matrixWorld);
  }

  worldToLocal(vector) {
    return vector.applyMatrix4(_m1.copy(matrixWorld).invert());
  }

  void lookAt(Vector3 position) {
    // This method does not support objects having non-uniformly-scaled parent(s)

    _target.copy(position);

    var parent = this.parent;

    updateWorldMatrix(true, false);

    _position.setFromMatrixPosition(matrixWorld);

    // TODO
    if (this is Camera || this is Light) {
      _m1.lookAt(_position, _target, up);
    } else {
      _m1.lookAt(_target, _position, up);
    }

    quaternion.setFromRotationMatrix(_m1);

    if (parent != null) {
      _m1.extractRotation(parent.matrixWorld);
      _q1.setFromRotationMatrix(_m1);
      quaternion.premultiply(_q1.invert());
    }
  }

  Object3D addAll(List<Object3D> objects) {
    for (var i = 0; i < objects.length; i++) {
      add(objects[i]);
    }

    return this;
  }

  Object3D add(Object3D? object) {
    if (object == this) {
      print(
          'THREE.Object3D.add: object can\'t be added as a child of itself. $object');
      return this;
    }

    if (object != null && object.isObject3D) {
      if (object.parent != null) {
        object.parent!.remove(object);
      }

      object.parent = this;
      children.add(object);

      object.dispatchEvent(_addedEvent);
    } else {
      print(
          'THREE.Object3D.add: object not an instance of THREE.Object3D. $object');
    }

    return this;
  }

  Object3D removeList(List<Object3D> objects) {
    for (var i = 0; i < objects.length; i++) {
      remove(objects[i]);
    }

    return this;
  }

  Object3D remove(Object3D object) {
    var index = children.indexOf(object);

    if (index != -1) {
      object.parent = null;
      children.removeAt(index);

      object.dispatchEvent(_removedEvent);
    }

    return this;
  }

  Object3D removeFromParent() {
    var parent = this.parent;

    if (parent != null) {
      parent.remove(this);
    }

    return this;
  }

  Object3D clear() {
    for (var i = 0; i < children.length; i++) {
      var object = children[i];

      object.parent = null;

      object.dispatchEvent(_removedEvent);
    }

    children.length = 0;

    return this;
  }

  Object3D attach(Object3D object) {
    // adds object as a child of this, while maintaining the object's world transform

    updateWorldMatrix(true, false);

    _m1.copy(matrixWorld).invert();

    if (object.parent != null) {
      object.parent!.updateWorldMatrix(true, false);

      _m1.multiply(object.parent!.matrixWorld);
    }

    object.applyMatrix4(_m1);

    add(object);
    object.updateWorldMatrix(false, false);

    return this;
  }

  Object3D? getObjectById(String id) {
    return getObjectByProperty('id', id);
  }

  Object3D? getObjectByName(String name) {
    return getObjectByProperty('name', name);
  }

  // TODO
  Object3D? getObjectByProperty(String name, String value) {
    if (getProperty(name) == value) return this;

    for (var i = 0, l = children.length; i < l; i++) {
      var child = children[i];
      var object = child.getObjectByProperty(name, value);

      if (object != null) {
        return object;
      }
    }

    return null;
  }

  Vector3 getWorldPosition(Vector3? target) {
    if (target == null) {
      print('THREE.Object3D: .getWorldPosition() target is now required');
      target = Vector3.init();
    }

    updateWorldMatrix(true, false);

    return target.setFromMatrixPosition(matrixWorld);
  }

  Quaternion getWorldQuaternion(Quaternion target) {
    updateWorldMatrix(true, false);

    matrixWorld.decompose(_position, target, _scale);

    return target;
  }

  Vector3 getWorldScale(Vector3 target) {
    updateWorldMatrix(true, false);

    matrixWorld.decompose(_position, _quaternion, target);

    return target;
  }

  Vector3 getWorldDirection(Vector3 target) {
    updateWorldMatrix(true, false);

    var e = matrixWorld.elements;

    return target.set(e[8], e[9], e[10]).normalize();
  }

  void raycast(Raycaster raycaster, List<Intersection> intersects) {
    print("Object3D raycast todo ");
  }

  void traverse(callback) {
    callback(this);

    var children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].traverse(callback);
    }
  }

  void traverseVisible(callback) {
    if (visible == false) return;

    callback(this);

    var children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].traverseVisible(callback);
    }
  }

  void traverseAncestors(callback) {
    var parent = this.parent;

    if (parent != null) {
      callback(parent);

      parent.traverseAncestors(callback);
    }
  }

  void updateMatrix() {
    matrix.compose(position, quaternion, scale);
    matrixWorldNeedsUpdate = true;
  }

  void updateMatrixWorld([bool force = false]) {
    if (matrixAutoUpdate) updateMatrix();

    if (matrixWorldNeedsUpdate || force) {
      if (parent == null) {
        matrixWorld.copy(matrix);
      } else {
        matrixWorld.multiplyMatrices(parent!.matrixWorld, matrix);
      }

      matrixWorldNeedsUpdate = false;

      force = true;
    }

    // update children

    List<Object3D> children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].updateMatrixWorld(force);
    }
  }

  void updateWorldMatrix(bool updateParents, bool updateChildren) {
    var parent = this.parent;

    if (updateParents == true && parent != null) {
      parent.updateWorldMatrix(true, false);
    }

    if (matrixAutoUpdate) updateMatrix();

    if (this.parent == null) {
      matrixWorld.copy(matrix);
    } else {
      matrixWorld.multiplyMatrices(this.parent!.matrixWorld, matrix);
    }

    // update children

    if (updateChildren == true) {
      var children = this.children;

      for (var i = 0, l = children.length; i < l; i++) {
        children[i].updateWorldMatrix(false, true);
      }
    }
  }

  Map<String, dynamic> toJSON({Object3dMeta? meta}) {
    // meta is a string when called from JSON.stringify
    var isRootObject = (meta == null || meta is String);

    Map<String, dynamic> output = <String, dynamic>{};

    // meta is a hash used to collect geometries, materials.
    // not providing it implies that this is the root object
    // being serialized.
    if (isRootObject) {
      // initialize meta obj
      meta = Object3dMeta();

      output["metadata"] = {
        "version": 4.5,
        "type": 'Object',
        "generator": 'Object3D.toJSON'
      };
    }

    // standard Object3D serialization

    Map<String, dynamic> object = <String, dynamic>{};

    object["uuid"] = uuid;
    object["type"] = type;

    if (name != "") object["name"] = name;
    if (castShadow == true) object["castShadow"] = true;
    if (receiveShadow == true) object["receiveShadow"] = true;
    if (visible == false) object["visible"] = false;
    if (frustumCulled == false) object["frustumCulled"] = false;
    if (renderOrder != 0) object["renderOrder"] = renderOrder;
    if (userData.isNotEmpty) object["userData"] = userData;

    object["layers"] = layers.mask;
    object["matrix"] = matrix.toArray(List<num>.filled(16, 0.0));

    if (matrixAutoUpdate == false) object["matrixAutoUpdate"] = false;

    // object specific properties

    if (type == "InstancedMesh") {
      InstancedMesh _instanceMesh = this as InstancedMesh;

      object["type"] = 'InstancedMesh';
      object["count"] = _instanceMesh.count;
      object["instanceMatrix"] = _instanceMesh.instanceMatrix.toJSON();

      if (_instanceMesh.instanceColor != null) {
        object["instanceColor"] = _instanceMesh.instanceColor!.toJSON();
      }
    }

    if (this is Scene) {
      if (background != null) {
        if (background is Color) {
          object["background"] = background!.getHex();
        } else if (background is Texture) {
          object["background"] = background.toJSON(meta).uuid;
        }
      }

      if (environment != null && environment!.isTexture) {
        object["environment"] = environment!.toJSON(meta)['uuid'];
      }
    } else if (this is Mesh || this is Line || this is Points) {
      object["geometry"] = serialize(meta!.geometries, geometry, meta);

      var parameters = geometry!.parameters;

      if (parameters != null && parameters["shapes"] != null) {
        var shapes = parameters["shapes"];

        if (shapes is List) {
          for (var i = 0, l = shapes.length; i < l; i++) {
            var shape = shapes[i];

            serialize(meta.shapes, shape, meta);
          }
        } else {
          serialize(meta.shapes, shapes, meta);
        }
      }
    }

    // TODO
    // if ( this.type == "SkinnedMesh" ) {

    //   SkinnedMesh _skinnedMesh = this;

    // 	object["bindMode"] = _skinnedMesh.bindMode;
    // 	object["bindMatrix"] = _skinnedMesh.bindMatrix.toArray();

    // 	if ( _skinnedMesh.skeleton != null ) {

    // 		serialize( meta.skeletons, _skinnedMesh.skeleton );

    // 		object.skeleton = _skinnedMesh.skeleton.uuid;

    // 	}

    // }

    if (material != null) {
      List<String> uuids = [];

      if (material is List) {
        for (var i = 0, l = material.length; i < l; i++) {
          uuids.add(serialize(meta!.materials, material[i], meta));
        }

        object["material"] = uuids;
      } else {
        object["material"] = serialize(meta!.materials, material, meta);
      }
    }

    if (children.isNotEmpty) {
      List<Map<String, dynamic>> _childrenJSON = [];

      for (var i = 0; i < children.length; i++) {
        _childrenJSON.add(children[i].toJSON(meta: meta)["object"]);
      }

      object["children"] = _childrenJSON;
    }

    // //
    // TODO
    // if ( this.animations.length > 0 ) {

    // 	List<Map<String, dynamic>> _animationJSON = [];

    // 	for ( var i = 0; i < this.animations.length; i ++ ) {

    // 		const animation = this.animations[ i ];

    // 		_animationJSON.add( serialize( meta.animations, animation ) );

    // 	}

    //   object["animations"] = _animationJSON;

    // }

    if (isRootObject) {
      var geometries = extractFromCache(meta!.geometries);
      var materials = extractFromCache(meta.materials);
      var textures = extractFromCache(meta.textures);
      var images = extractFromCache(meta.images);
      var shapes = extractFromCache(meta.shapes);
      var skeletons = extractFromCache(meta.skeletons);
      var animations = extractFromCache(meta.animations);

      print(textures);
      print(" isRootObject: $isRootObject ");

      if (geometries.isNotEmpty) output["geometries"] = geometries;
      if (materials.isNotEmpty) output["materials"] = materials;
      if (textures.isNotEmpty) output["textures"] = textures;
      if (images.isNotEmpty) output["images"] = images;
      if (shapes.isNotEmpty) output["shapes"] = shapes;
      if (skeletons.isNotEmpty) output["skeletons"] = skeletons;
      if (animations.isNotEmpty) output["animations"] = animations;
    }

    output["object"] = object;

    return output;
  }

  serialize(Map<String, dynamic> library, dynamic element, Object3dMeta? meta) {
    if (library[element.uuid] == null) {
      library[element.uuid] = element.toJSON(meta: meta);
    }

    return element.uuid;
  }

  // extract data from the cache hash
  // remove metadata on each item
  // and return as array
  List<Map<String, dynamic>> extractFromCache(Map<String, dynamic> cache) {
    List<Map<String, dynamic>> values = [];
    for (var key in cache.keys) {
      Map<String, dynamic> data = cache[key];
      data.remove("metadata");

      values.add(data);
    }

    return values;
  }

  Object3D clone([bool? recursive]) {
    return Object3D().copy(this, recursive);
  }

  Object3D copy(Object3D source, [bool? recursive = true]) {
    recursive = recursive ?? true;

    name = source.name;

    up.copy(source.up);

    position.copy(source.position);
    rotation.order = source.rotation.order;
    quaternion.copy(source.quaternion);
    scale.copy(source.scale);

    matrix.copy(source.matrix);
    matrixWorld.copy(source.matrixWorld);

    matrixAutoUpdate = source.matrixAutoUpdate;
    matrixWorldNeedsUpdate = source.matrixWorldNeedsUpdate;

    layers.mask = source.layers.mask;
    visible = source.visible;

    castShadow = source.castShadow;
    receiveShadow = source.receiveShadow;

    frustumCulled = source.frustumCulled;
    renderOrder = source.renderOrder;

    userData = json.decode(json.encode(source.userData));

    if (recursive == true) {
      for (var i = 0; i < source.children.length; i++) {
        var child = source.children[i];
        add(child.clone());
      }
    }

    return this;
  }

  void onAfterRender(
      {WebGLRenderer? renderer,
      scene,
      Camera? camera,
      geometry,
      material,
      group}) {
    // print(" Object3D.onAfterRender ${type} ${id} ");
  }

  // 用于WebGLUniforms setOptional
  Matrix4? getValue(String name) {
    if (name == "bindMatrix") {
      return bindMatrix;
    } else {
      throw ("Object3D.getValue type: $type name: $name is not support .... ");
    }
  }

  dynamic getProperty(String propertyName) {
    if (propertyName == "id") {
      return id;
    } else if (propertyName == "name") {
      return name;
    } else if (propertyName == "scale") {
      return scale;
    } else if (propertyName == "position") {
      return position;
    } else if (propertyName == "quaternion") {
      return quaternion;
    } else if (propertyName == "material") {
      return material;
    } else if (propertyName == "opacity") {
      // opacity 是别的对象的属性 Object3d 直接返回null
      return null;
    } else if (propertyName == "morphTargetInfluences") {
      return morphTargetInfluences;
    } else if (propertyName == "castShadow") {
      return castShadow;
    } else if (propertyName == "receiveShadow") {
      return receiveShadow;
    } else if (propertyName == "visible") {
      return visible;
    } else {
      throw ("Object3D.getProperty type: $type propertyName: $propertyName is not support ");
    }
  }

  Object3D setProperty(String propertyName, value) {
    if (propertyName == "id") {
      id = value;
    } else if (propertyName == "castShadow") {
      castShadow = value;
    } else if (propertyName == "receiveShadow") {
      receiveShadow = value;
    } else if (propertyName == "visible") {
      visible = value;
    } else if (propertyName == "name") {
      name = value;
    } else if (propertyName == "quaternion") {
      quaternion.copy(value);
    } else {
      throw ("Object3D.setProperty type: $type propertyName: $propertyName is not support ");
    }

    return this;
  }

  void dispose() {}
}

class Object3dMeta {
  Map<String, dynamic> geometries = <String, dynamic>{};
  Map<String, dynamic> materials = <String, dynamic>{};
  Map<String, dynamic> textures = <String, dynamic>{};
  Map<String, dynamic> images = <String, dynamic>{};
  Map<String, dynamic> shapes = <String, dynamic>{};
  Map<String, dynamic> skeletons = <String, dynamic>{};
  Map<String, dynamic> animations = <String, dynamic>{};
}
