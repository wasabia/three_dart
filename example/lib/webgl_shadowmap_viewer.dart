import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;

class webgl_shadowmap_viewer extends StatefulWidget {
  String fileName;
  webgl_shadowmap_viewer({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_shadowmap_viewer> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.Light spotLight;
  late THREE.Light dirLight;
  late THREE.Mesh torusKnot;
  late THREE.Mesh cube;

  int delta = 0;

  late THREE.Material material;

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  int count = 1000;

  bool inited = false;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

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
          render();
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
                  })),
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

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({
        "minFilter": THREE.LinearFilter,
        "magFilter": THREE.LinearFilter,
        "format": THREE.RGBAFormat
      });
      renderTarget = THREE.WebGLRenderTarget(
          (width * dpr), (height * dpr), pars);
      renderTarget.samples = 4;   
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() async {
    initRenderer();
    await initPage();
  }

  initPage() async {
    _initScene();
    _initShadowMapViewers();

    inited = true;

    animate();
  }

  _initScene() {
    camera = new THREE.PerspectiveCamera(45, width / height, 1, 1000);
    camera.position.set(0, 15, 70);

    scene = new THREE.Scene();
    camera.lookAt(scene.position);

    // Lights

    scene.add(new THREE.AmbientLight(0x404040, null));

    spotLight = new THREE.SpotLight(0xffffff);
    spotLight.name = 'Spot Light';
    spotLight.angle = THREE.Math.PI / 5;
    spotLight.penumbra = 0.3;
    spotLight.position.set(10, 10, 5);
    spotLight.castShadow = true;
    spotLight.shadow!.camera!.near = 8;
    spotLight.shadow!.camera!.far = 30;
    spotLight.shadow!.mapSize.width = 1024;
    spotLight.shadow!.mapSize.height = 1024;
    scene.add(spotLight);

    scene.add(new THREE.CameraHelper(spotLight.shadow!.camera));

    dirLight = new THREE.DirectionalLight(0xffffff, 1);
    dirLight.name = 'Dir. Light';
    dirLight.position.set(0, 10, 0);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.near = 1;
    dirLight.shadow!.camera!.far = 10;
    dirLight.shadow!.camera!.right = 15;
    dirLight.shadow!.camera!.left = -15;
    dirLight.shadow!.camera!.top = 15;
    dirLight.shadow!.camera!.bottom = -15;
    dirLight.shadow!.mapSize.width = 1024;
    dirLight.shadow!.mapSize.height = 1024;
    scene.add(dirLight);

    scene.add(new THREE.CameraHelper(dirLight.shadow!.camera));

    // Geometry
    var geometry = new THREE.TorusKnotGeometry(25, 8, 75, 20);
    var material = new THREE.MeshPhongMaterial({
      "color": THREE.Color.fromHex(0x222222),
      "shininess": 150,
      "specular": THREE.Color.fromHex(0x222222)
    });

    torusKnot = new THREE.Mesh(geometry, material);
    torusKnot.scale.multiplyScalar(1 / 18);
    torusKnot.position.y = 3;
    torusKnot.castShadow = true;
    torusKnot.receiveShadow = true;
    scene.add(torusKnot);

    var geometry2 = new THREE.BoxGeometry(3, 3, 3);
    cube = new THREE.Mesh(geometry2, material);
    cube.position.set(8, 3, 8);
    cube.castShadow = true;
    cube.receiveShadow = true;
    scene.add(cube);

    var geometry3 = new THREE.BoxGeometry(10, 0.15, 10);
    material = new THREE.MeshPhongMaterial(
        {"color": 0xa0adaf, "shininess": 150, "specular": 0x111111});

    var ground = new THREE.Mesh(geometry3, material);
    ground.scale.multiplyScalar(3);
    ground.castShadow = false;
    ground.receiveShadow = true;
    scene.add(ground);
  }

  _initShadowMapViewers() {
    // dirLightShadowMapViewer = new ShadowMapViewer( dirLight );
    // spotLightShadowMapViewer = new ShadowMapViewer( spotLight );
    // resizeShadowMapViewers();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!inited) {
      return;
    }

    torusKnot.rotation.x += 0.025;
    torusKnot.rotation.y += 0.2;
    torusKnot.rotation.z += 0.1;

    cube.rotation.x += 0.025;
    cube.rotation.y += 0.2;
    cube.rotation.z += 0.1;

    render();

    Future.delayed(Duration(milliseconds: 40), () {
      animate();
    });
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }
}
