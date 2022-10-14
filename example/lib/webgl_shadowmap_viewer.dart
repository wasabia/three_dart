import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as three;

class WebGlShadowmapViewer extends StatefulWidget {
  final String fileName;
  const WebGlShadowmapViewer({Key? key, required this.fileName}) : super(key: key);

  @override
  State<WebGlShadowmapViewer> createState() => _MyAppState();
}

class _MyAppState extends State<WebGlShadowmapViewer> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.Light spotLight;
  late three.Light dirLight;
  late three.Mesh torusKnot;
  late three.Mesh cube;

  int delta = 0;

  late three.Material material;

  double dpr = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;

  int count = 1000;

  bool inited = false;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    setState(() {});

    // Wait for web
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
          render();
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
                width: width,
                height: height,
                color: Colors.black,
                child: Builder(builder: (BuildContext context) {
                  if (kIsWeb) {
                    return three3dRender.isInitialized
                        ? HtmlElementView(viewType: three3dRender.textureId!.toString())
                        : Container();
                  } else {
                    return three3dRender.isInitialized ? Texture(textureId: three3dRender.textureId!) : Container();
                  }
                })),
          ],
        ),
      ],
    );
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions(
          {"minFilter": three.LinearFilter, "magFilter": three.LinearFilter, "format": three.RGBAFormat});
      renderTarget = three.WebGLRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
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
    camera = three.PerspectiveCamera(45, width / height, 1, 1000);
    camera.position.set(0, 15, 70);

    scene = three.Scene();
    camera.lookAt(scene.position);

    // Lights

    scene.add(three.AmbientLight(0x404040, null));

    spotLight = three.SpotLight(0xffffff);
    spotLight.name = 'Spot Light';
    spotLight.angle = three.Math.PI / 5;
    spotLight.penumbra = 0.3;
    spotLight.position.set(10, 10, 5);
    spotLight.castShadow = true;
    spotLight.shadow!.camera!.near = 8;
    spotLight.shadow!.camera!.far = 30;
    spotLight.shadow!.mapSize.width = 1024;
    spotLight.shadow!.mapSize.height = 1024;
    scene.add(spotLight);

    scene.add(three.CameraHelper(spotLight.shadow!.camera));

    dirLight = three.DirectionalLight(0xffffff, 1);
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

    scene.add(three.CameraHelper(dirLight.shadow!.camera));

    // Geometry
    var geometry = three.TorusKnotGeometry(25, 8, 75, 20);
    var material = three.MeshPhongMaterial(
        {"color": three.Color.fromHex(0x222222), "shininess": 150, "specular": three.Color.fromHex(0x222222)});

    torusKnot = three.Mesh(geometry, material);
    torusKnot.scale.multiplyScalar(1 / 18);
    torusKnot.position.y = 3;
    torusKnot.castShadow = true;
    torusKnot.receiveShadow = true;
    scene.add(torusKnot);

    var geometry2 = three.BoxGeometry(3, 3, 3);
    cube = three.Mesh(geometry2, material);
    cube.position.set(8, 3, 8);
    cube.castShadow = true;
    cube.receiveShadow = true;
    scene.add(cube);

    var geometry3 = three.BoxGeometry(10, 0.15, 10);
    material = three.MeshPhongMaterial({"color": 0xa0adaf, "shininess": 150, "specular": 0x111111});

    var ground = three.Mesh(geometry3, material);
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

    Future.delayed(const Duration(milliseconds: 40), () {
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
