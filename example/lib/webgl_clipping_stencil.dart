import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;

class webgl_clipping_stencil extends StatefulWidget {
  String fileName;

  webgl_clipping_stencil({Key? key, required this.fileName}) : super(key: key);

  @override
  createState() => _State();
}

class _State extends State<webgl_clipping_stencil> {
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
  THREE.Clock clock = THREE.Clock();

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

  late THREE.Object3D model;

  late List<THREE.Plane> planes;
  late List<THREE.PlaneHelper> planeHelpers;
  late List<THREE.Mesh> planeObjects;

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
    Future.delayed(const Duration(milliseconds: 100), () async {
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
        child: const Text("render"),
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

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

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
    renderer!.setClearColor(THREE.Color.fromHex(0x263238));

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

  createPlaneStencilGroup(geometry, plane, int renderOrder) {
    var group = THREE.Group();
    var baseMat = THREE.MeshBasicMaterial({
      "depthWrite": false,
      "depthTest": false,
      "colorWrite": false,
      "stencilWrite": true,
      "stencilFunc": THREE.AlwaysStencilFunc
    });

    // back faces
    // var mat0 = baseMat.clone();
    // mat0.side = THREE.BackSide;
    // mat0.clippingPlanes = List<THREE.Plane>.from([plane]);
    // mat0.stencilFail = THREE.IncrementWrapStencilOp;
    // mat0.stencilZFail = THREE.IncrementWrapStencilOp;
    // mat0.stencilZPass = THREE.IncrementWrapStencilOp;
    var mat0 = THREE.MeshBasicMaterial({
      "side": THREE.BackSide,
      "clippingPlanes": List<THREE.Plane>.from([plane]),
      "stencilFail": THREE.IncrementWrapStencilOp,
      "stencilZFail": THREE.IncrementWrapStencilOp,
      "stencilZPass": THREE.IncrementWrapStencilOp,
      "depthWrite": false,
      "depthTest": false,
      "colorWrite": false,
      "stencilWrite": true,
      "stencilFunc": THREE.AlwaysStencilFunc
    });

    var mesh0 = THREE.Mesh(geometry, mat0);
    mesh0.renderOrder = renderOrder;
    group.add(mesh0);

    // front faces
    // var mat1 = baseMat.clone();
    // mat1.side = THREE.FrontSide;
    // mat1.clippingPlanes = List<THREE.Plane>.from([plane]);
    // mat1.stencilFail = THREE.DecrementWrapStencilOp;
    // mat1.stencilZFail = THREE.DecrementWrapStencilOp;
    // mat1.stencilZPass = THREE.DecrementWrapStencilOp;
    var mat1 = THREE.MeshBasicMaterial({
      "side": THREE.BackSide,
      "clippingPlanes": List<THREE.Plane>.from([plane]),
      "stencilFail": THREE.DecrementWrapStencilOp,
      "stencilZFail": THREE.DecrementWrapStencilOp,
      "stencilZPass": THREE.DecrementWrapStencilOp,
      "depthWrite": false,
      "depthTest": false,
      "colorWrite": false,
      "stencilWrite": true,
      "stencilFunc": THREE.AlwaysStencilFunc
    });

    var mesh1 = THREE.Mesh(geometry, mat1);
    mesh1.renderOrder = renderOrder;

    group.add(mesh1);

    return group;
  }

  initPage() async {
    scene = THREE.Scene();

    camera = THREE.PerspectiveCamera(36, width / height, 1, 100);
    camera.position.set(2, 2, 2);

    scene.add(THREE.AmbientLight(0xffffff, 0.5));

    camera.lookAt(scene.position);

    var dirLight = THREE.DirectionalLight(0xffffff, 1);
    dirLight.position.set(5, 10, 7.5);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.right = 2;
    dirLight.shadow!.camera!.left = -2;
    dirLight.shadow!.camera!.top = 2;
    dirLight.shadow!.camera!.bottom = -2;

    dirLight.shadow!.mapSize.width = 1024;
    dirLight.shadow!.mapSize.height = 1024;
    scene.add(dirLight);

    planes = [
      THREE.Plane(THREE.Vector3(-1, 0, 0), 0),
      THREE.Plane(THREE.Vector3(0, -1, 0), 0),
      THREE.Plane(THREE.Vector3(0, 0, -1), 0)
    ];

    planeHelpers =
        planes.map((p) => THREE.PlaneHelper(p, 2, 0xffffff)).toList();
    for (var ph in planeHelpers) {
      ph.visible = true;
      scene.add(ph);
    }

    var geometry = THREE.TorusKnotGeometry(0.4, 0.15, 220, 60);
    object = THREE.Group();
    scene.add(object);

    // Set up clip plane rendering
    planeObjects = [];
    var planeGeom = THREE.PlaneGeometry(4, 4);

    for (int i = 0; i < 1; i++) {
      var poGroup = THREE.Group();
      var plane = planes[i];
      var stencilGroup = createPlaneStencilGroup(geometry, plane, i + 1);

      List<THREE.Plane> _planes = planes.where((p) => p != plane).toList();

      // plane is clipped by the other clipping planes
      var planeMat = THREE.MeshStandardMaterial({
        "color": 0xff00ff,
        "metalness": 0.1,
        "roughness": 0.75,
        "clippingPlanes": planes,
        "stencilWrite": true,
        "stencilRef": 0,
        "stencilFunc": THREE.NotEqualStencilFunc,
        "stencilFail": THREE.ReplaceStencilOp,
        "stencilZFail": THREE.ReplaceStencilOp,
        "stencilZPass": THREE.ReplaceStencilOp,
      });

      var po = THREE.Mesh(planeGeom, planeMat);
      // po.onAfterRender =  ( renderer ) {

      //   renderer.clearStencil();

      // };

      po.renderOrder = i + 1;

      // object.add(stencilGroup);
      poGroup.add(po);
      planeObjects.add(po);
      scene.add(poGroup);
    }

    var material = THREE.MeshStandardMaterial({
      "color": 0xFFC107,
      "metalness": 0.1,
      "roughness": 0.75,
      "clippingPlanes": planes,
      "clipShadows": true,
      "shadowSide": THREE.DoubleSide,
    });

    // add the color
    // var clippedColorFront = new THREE.Mesh(geometry, material);
    // clippedColorFront.castShadow = true;
    // clippedColorFront.renderOrder = 6;
    // object.add(clippedColorFront);

    var ground = THREE.Mesh(
        THREE.PlaneGeometry(9, 9, 1, 1),
        THREE.ShadowMaterial(
            {"color": 0, "opacity": 0.25, "side": THREE.DoubleSide}));

    ground.rotation.x = -THREE.Math.PI / 2; // rotates X/Y to X/Z
    ground.position.y = -1;
    ground.receiveShadow = true;
    scene.add(ground);

    loaded = true;

    animate();

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();
  }

  clickRender() {
    print("clickRender..... ");
    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    var delta = clock.getDelta();

    if (true) {
      object.rotation.x += delta * 0.5;
      object.rotation.y += delta * 0.2;
    }

    for (var i = 0; i < planeObjects.length; i++) {
      var plane = planes[i];
      var po = planeObjects[i];
      plane.coplanarPoint(po.position);
      po.lookAt(THREE.Vector3(
        po.position.x - plane.normal.x,
        po.position.y - plane.normal.y,
        po.position.z - plane.normal.z,
      ));
    }

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
