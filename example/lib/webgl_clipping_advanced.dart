import 'dart:async';

import 'package:example/TouchListener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_clipping_advanced extends StatefulWidget {
  String fileName;

  webgl_clipping_advanced({Key? key, required this.fileName}) : super(key: key);

  createState() => _State();
}

class _State extends State<webgl_clipping_advanced> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.AnimationMixer mixer;
  THREE.Clock clock = new THREE.Clock();

  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

  late THREE.Object3D model;

  late THREE.MeshPhongMaterial clipMaterial;

  int startTime = 0;

  dynamic volumeVisualization, globalClippingPlanes;

  Map<String, List<Function>> _listeners = {};

  late List<THREE.Plane> _Planes;

  late List<THREE.Matrix4> _PlaneMatrices;
  late List<THREE.Plane> GlobalClippingPlanes;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("render"),
        onPressed: () {
          clickRender();
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Container(
                  child: Container(
                      width: width,
                      height: height,
                      color: Colors.black,
                      child: Builder(builder: (BuildContext context) {
                        if (kIsWeb) {
                          return three3dRender.isInitialized
                              ? HtmlElementView(
                                  viewType: three3dRender.textureId!.toString())
                              : Container();
                        } else {
                          return three3dRender.isInitialized
                              ? Texture(textureId: three3dRender.textureId!)
                              : Container();
                        }
                      }))),
            ],
          ),
        ),
      ],
    );
  }

  render() {
    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    if (verbose) print(" render: sourceTexture: ${sourceTexture} ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;
    renderer!.localClippingEnabled = true;
    renderer!.clippingPlanes = [];

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  planesFromMesh(vertices, indices) {
    // creates a clipping volume from a convex triangular mesh
    // specified by the arrays 'vertices' and 'indices'

    var n = indices.length / 3;
    var result = new List<THREE.Plane>.filled(n, new THREE.Plane(null, null));

    for (var i = 0, j = 0; i < n; ++i, j += 3) {
      var a = vertices[indices[j]],
          b = vertices[indices[j + 1]],
          c = vertices[indices[j + 2]];

      result[i] = new THREE.Plane(null, null).setFromCoplanarPoints(a, b, c);
    }

    return result;
  }

  createPlanes(n) {
    // creates an array of n uninitialized plane objects

    var result = new List<THREE.Plane>.filled(n, new THREE.Plane(null, null));

    // for ( var i = 0; i != n; ++ i )
    //   result[ i ] = new THREE.Plane(null, null);

    return result;
  }

  assignTransformedPlanes(planesOut, planesIn, matrix) {
    // sets an array of existing planes to transformed 'planesIn'

    for (var i = 0, n = planesIn.length; i != n; ++i)
      planesOut[i].copy(planesIn[i]).applyMatrix4(matrix, null);
  }

  cylindricalPlanes(n, innerRadius) {
    var result = createPlanes(n);

    for (var i = 0; i != n; ++i) {
      var plane = result[i], angle = i * THREE.Math.PI * 2 / n;

      plane.normal.set(THREE.Math.cos(angle), 0, THREE.Math.sin(angle));

      plane.constant = innerRadius;
    }

    return result;
  }

  var xAxis = new THREE.Vector3(),
      yAxis = new THREE.Vector3(),
      trans = new THREE.Vector3();

  THREE.Matrix4 planeToMatrix(plane) {
    var zAxis = plane.normal, matrix = new THREE.Matrix4();

    // Hughes & Moeller '99
    // "Building an Orthonormal Basis from a Unit Vector."

    if (THREE.Math.abs(zAxis.x) > THREE.Math.abs(zAxis.z)) {
      yAxis.set(-zAxis.y, zAxis.x, 0);
    } else {
      yAxis.set(0, -zAxis.z, zAxis.y);
    }

    xAxis.crossVectors(yAxis.normalize(), zAxis);

    plane.coplanarPoint(trans);
    return matrix.set(xAxis.x, yAxis.x, zAxis.x, trans.x, xAxis.y, yAxis.y,
        zAxis.y, trans.y, xAxis.z, yAxis.z, zAxis.z, trans.z, 0, 0, 0, 1);
  }

  initPage() async {
    var Vertices = [
          new THREE.Vector3(1, 0, THREE.Math.SQRT1_2),
          new THREE.Vector3(-1, 0, THREE.Math.SQRT1_2),
          new THREE.Vector3(0, 1, -THREE.Math.SQRT1_2),
          new THREE.Vector3(0, -1, -THREE.Math.SQRT1_2)
        ],
        Indices = [0, 1, 2, 0, 2, 3, 0, 3, 1, 1, 3, 2];

    _Planes = planesFromMesh(Vertices, Indices);

    _PlaneMatrices = _Planes.map(planeToMatrix).toList();

    GlobalClippingPlanes = cylindricalPlanes(5, 2.5);

    var Empty = [];

    camera = new THREE.PerspectiveCamera(45, width / height, 0.25, 16);

    camera.position.set(0, 1.5, 5);

    scene = new THREE.Scene();

    // Lights

    camera.lookAt(scene.position);

    scene.add(new THREE.AmbientLight(0xffffff, 0.3));

    var spotLight = new THREE.SpotLight(0xffffff, 0.5);
    spotLight.angle = THREE.Math.PI / 5;
    spotLight.penumbra = 0.2;
    spotLight.position.set(2, 3, 3);
    spotLight.castShadow = true;
    spotLight.shadow!.camera!.near = 3;
    spotLight.shadow!.camera!.far = 10;
    spotLight.shadow!.mapSize.width = 1024;
    spotLight.shadow!.mapSize.height = 1024;
    scene.add(spotLight);

    var dirLight = new THREE.DirectionalLight(0xffffff, 0.5);
    dirLight.position.set(0, 2, 0);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.near = 1;
    dirLight.shadow!.camera!.far = 10;

    dirLight.shadow!.camera!.right = 1;
    dirLight.shadow!.camera!.left = -1;
    dirLight.shadow!.camera!.top = 1;
    dirLight.shadow!.camera!.bottom = -1;

    dirLight.shadow!.mapSize.width = 1024;
    dirLight.shadow!.mapSize.height = 1024;
    scene.add(dirLight);

    // Geometry

    clipMaterial = new THREE.MeshPhongMaterial({
      "color": 0xee0a10,
      "shininess": 100,
      "side": THREE.DoubleSide,
      // Clipping setup:
      "clippingPlanes": createPlanes(_Planes.length),
      "clipShadows": true
    });

    object = new THREE.Group();

    var geometry = new THREE.BoxGeometry(0.18, 0.18, 0.18);

    for (var z = -2; z <= 2; ++z)
      for (var y = -2; y <= 2; ++y)
        for (var x = -2; x <= 2; ++x) {
          var mesh = new THREE.Mesh(geometry, clipMaterial);
          mesh.position.set(x / 5, y / 5, z / 5);
          mesh.castShadow = true;
          object.add(mesh);
        }

    scene.add(object);

    var planeGeometry = new THREE.PlaneGeometry(3, 3, 1, 1),
        color = new THREE.Color(0, 0, 0);

    volumeVisualization = new THREE.Group();
    volumeVisualization.visible = true;

    for (var i = 0, n = _Planes.length; i != n; ++i) {
      List<THREE.Plane> __clippingPlanes = [];

      clipMaterial.clippingPlanes!.asMap().forEach((index, elm) {
        if (index != i) {
          __clippingPlanes.add(elm);
        }
      });

      var material = new THREE.MeshBasicMaterial({
        "color": color.setHSL(i / n, 0.5, 0.5).getHex(),
        "side": THREE.DoubleSide,

        "opacity": 0.2,
        "transparent": true,

        // clip to the others to show the volume (wildly
        // intersecting transparent planes look bad)
        "clippingPlanes": __clippingPlanes

        // no need to enable shadow clipping - the plane
        // visualization does not cast shadows
      });

      var mesh = new THREE.Mesh(planeGeometry, material);
      mesh.matrixAutoUpdate = false;

      volumeVisualization.add(mesh);
    }

    scene.add(volumeVisualization);

    var ground = new THREE.Mesh(planeGeometry,
        new THREE.MeshPhongMaterial({"color": 0xa0adaf, "shininess": 10}));
    ground.rotation.x = -THREE.Math.PI / 2;
    ground.scale.multiplyScalar(3);
    ground.receiveShadow = true;
    scene.add(ground);

    globalClippingPlanes = createPlanes(GlobalClippingPlanes.length);

    startTime = DateTime.now().millisecondsSinceEpoch;

    loaded = true;

    animate();

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();
  }

  clickRender() {
    print("clickRender..... ");
    animate();
  }

  setObjectWorldMatrix(object, matrix) {
    // set the orientation of an object based on a world matrix

    var parent = object.parent;
    scene.updateMatrixWorld(false);
    object.matrix.copy(parent.matrixWorld).invert();
    object.applyMatrix4(matrix);
  }

  var transform = new THREE.Matrix4(), tmpMatrix = new THREE.Matrix4();

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    var currentTime = DateTime.now().millisecondsSinceEpoch,
        time = (currentTime - startTime) / 1000;

    object.position.y = 1;
    object.rotation.x = time * 0.5;
    object.rotation.y = time * 0.2;

    object.updateMatrix();
    transform.copy(object.matrix);

    var bouncy = THREE.Math.cos(time * .5) * 0.5 + 0.7;
    transform.multiply(tmpMatrix.makeScale(bouncy, bouncy, bouncy));

    assignTransformedPlanes(clipMaterial.clippingPlanes, _Planes, transform);

    var planeMeshes = volumeVisualization.children;
    var n = planeMeshes.length;

    for (var i = 0; i < n; ++i) {
      tmpMatrix.multiplyMatrices(transform, _PlaneMatrices[i]);
      setObjectWorldMatrix(planeMeshes[i], tmpMatrix);
    }

    transform.makeRotationY(time * 0.1);

    assignTransformedPlanes(
        globalClippingPlanes, GlobalClippingPlanes, transform);

    render();

    // Future.delayed(Duration(milliseconds: 40), () {
    //   animate();
    // });
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }
}
