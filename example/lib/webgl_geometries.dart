import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/objects/index.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebglGeometries extends StatefulWidget {
  final String fileName;

  const WebglGeometries({Key? key, required this.fileName}) : super(key: key);

  @override
  State<WebglGeometries> createState() => _State();
}

class _State extends State<WebglGeometries> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.AnimationMixer mixer;
  three.Clock clock = three.Clock();

  double dpr = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  int startTime = 0;

  late three.WebGLMultisampleRenderTarget renderTarget;

  dynamic sourceTexture;

  bool loaded = false;

  late three.Object3D model;

  late List<three.Plane> planes;
  late List<three.PlaneHelper> planeHelpers;
  late List<three.Mesh> planeObjects;

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
          clickRender();
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
    renderer!.localClippingEnabled = true;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
      renderTarget = three.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {
    camera = three.PerspectiveCamera(45, width / height, 1, 2000);
    camera.position.y = 400;

    scene = three.Scene();

    three.Mesh object;

    var ambientLight = three.AmbientLight(0xcccccc, 0.4);
    scene.add(ambientLight);

    var pointLight = three.PointLight(0xffffff, 0.8);
    camera.add(pointLight);
    scene.add(camera);

    var loader = three.TextureLoader(null);
    var map = await loader.loadAsync('assets/textures/uv_grid_opengl.jpg', null);
    map.wrapS = map.wrapT = three.RepeatWrapping;
    map.anisotropy = 16;

    var material = three.MeshPhongMaterial({"map": map, "side": three.DoubleSide});

    //

    object = three.Mesh(three.SphereGeometry(75, 20, 10), material);
    object.position.set(-300, 0, 200);
    scene.add(object);

    object = three.Mesh(three.IcosahedronGeometry(75, 1), material);
    object.position.set(-100, 0, 200);
    scene.add(object);

    object = three.Mesh(three.OctahedronGeometry(75, 2), material);
    object.position.set(100, 0, 200);
    scene.add(object);

    object = three.Mesh(three.TetrahedronGeometry(75, 0), material);
    object.position.set(300, 0, 200);
    scene.add(object);

    //

    object = three.Mesh(three.PlaneGeometry(100, 100, 4, 4), material);
    object.position.set(-300, 0, 0);
    scene.add(object);

    object = three.Mesh(three.BoxGeometry(100, 100, 100, 4, 4, 4), material);
    object.position.set(-100, 0, 0);
    scene.add(object);

    object = three.Mesh(
        three.CircleGeometry(radius: 50, segments: 20, thetaStart: 0, thetaLength: three.Math.PI * 2), material);
    object.position.set(100, 0, 0);
    scene.add(object);

    object = three.Mesh(three.RingGeometry(10, 50, 20, 5, 0, three.Math.PI * 2), material);
    object.position.set(300, 0, 0);
    scene.add(object);

    //

    object = three.Mesh(three.CylinderGeometry(25, 75, 100, 40, 5), material);
    object.position.set(-300, 0, -200);
    scene.add(object);

    var points = [];

    for (var i = 0; i < 50; i++) {
      points.add(three.Vector2(three.Math.sin(i * 0.2) * three.Math.sin(i * 0.1) * 15 + 50, (i - 5) * 2));
    }

    object = three.Mesh(three.LatheGeometry(points, segments: 20), material);
    object.position.set(-100, 0, -200);
    scene.add(object);

    object = three.Mesh(three.TorusGeometry(50, 20, 20, 20), material);
    object.position.set(100, 0, -200);
    scene.add(object);

    object = three.Mesh(three.TorusKnotGeometry(50, 10, 50, 20), material);
    object.position.set(300, 0, -200);
    scene.add(object);

    startTime = DateTime.now().millisecondsSinceEpoch;
    loaded = true;

    animate();

    // scene.overrideMaterial = new three.MeshBasicMaterial();
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

    var timer = DateTime.now().millisecondsSinceEpoch * 0.0001;

    camera.position.x = three.Math.cos(timer) * 800;
    camera.position.z = three.Math.sin(timer) * 800;

    camera.lookAt(scene.position);

    scene.traverse((object) {
      if (object is Mesh) {
        object.rotation.x = timer * 5;
        object.rotation.y = timer * 2.5;
      }
    });

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
