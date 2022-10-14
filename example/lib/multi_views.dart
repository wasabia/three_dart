import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Matrix4;

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class MultiViews extends StatefulWidget {
  final String fileName;

  const MultiViews({Key? key, required this.fileName}) : super(key: key);

  @override
  State<MultiViews> createState() => _MyAppState();
}

class _MyAppState extends State<MultiViews> {
  three.WebGLRenderer? renderer;
  bool show = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      init();
    }
  }

  init() async {
    var three3dRender = FlutterGlPlugin();
    await three3dRender.initialize(options: {"width": 1024, "height": 1024, "dpr": 1.0});
    await three3dRender.prepareContext();

    Map<String, dynamic> options = {
      "width": 1024,
      "height": 1024,
      "gl": three3dRender.gl,
      "antialias": true,
    };
    renderer = three.WebGLRenderer(options);
    renderer!.autoClear = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: SingleChildScrollView(child: _build(context)),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        MultiViews1(renderer: renderer),
        Container(
          height: 2,
          color: Colors.red,
        ),
        MultiViews2(renderer: renderer)
      ],
    );
  }
}

class MultiViews1 extends StatefulWidget {
  final three.WebGLRenderer? renderer;

  const MultiViews1({Key? key, this.renderer}) : super(key: key);

  @override
  State<MultiViews1> createState() => _MultiViews1State();
}

class _MultiViews1State extends State<MultiViews1> {
  three.WebGLRenderer? renderer;

  double width = 300;
  double height = 300;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  double dpr = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;

  bool loaded = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  three.AnimationMixer? mixer;
  three.Clock clock = three.Clock();

  dynamic sourceTexture;

  late FlutterGlPlugin three3dRender;

  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = width;

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
    return Builder(
      builder: (BuildContext context) {
        initSize(context);
        return SingleChildScrollView(child: _build(context));
      },
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
                width: 300,
                height: 300,
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

  clickRender() {
    print(" click render... ");
    animate();
  }

  render() {
    final gl = three3dRender.gl;

    if (!kIsWeb) renderer!.setRenderTarget(renderTarget);
    renderer!.render(scene, camera);

    if (verbose) {
      // print("render cost: ${_t1 - _t} ");
      // print(renderer!.info.memory);
      // print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    // print("three3dRender 1: ${three3dRender.textureId} render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    renderer = widget.renderer;

    if (renderer == null) {
      Map<String, dynamic> options = {
        "width": width,
        "height": height,
        "gl": three3dRender.gl,
        "antialias": true,
      };
      renderer = three.WebGLRenderer(options);
      renderer!.autoClear = true;
    }

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
    camera = three.PerspectiveCamera(45, width / height, 1, 2200);
    camera.position.set(3, 6, 100);

    // scene

    scene = three.Scene();

    var ambientLight = three.AmbientLight(0xffffff, 0.9);
    scene.add(ambientLight);

    var pointLight = three.PointLight(0xffffff, 0.8);

    pointLight.position.set(0, 0, 0);

    camera.add(pointLight);
    scene.add(camera);

    camera.lookAt(scene.position);

    var geometry = three.BoxGeometry(20, 20, 20);
    var material = three.MeshBasicMaterial({"color": 0xff0000});

    object = three.Mesh(geometry, material);

    scene.add(object);

    // scene.overrideMaterial = new three.MeshBasicMaterial();

    loaded = true;

    setState(() {});

    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }
    object.rotation.x = object.rotation.x + 0.01;

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

class MultiViews2 extends StatefulWidget {
  final three.WebGLRenderer? renderer;

  const MultiViews2({Key? key, this.renderer}) : super(key: key);

  @override
  State<MultiViews2> createState() => _MultiViews2State();
}

class _MultiViews2State extends State<MultiViews2> {
  three.WebGLRenderer? renderer;
  late FlutterGlPlugin three3dRender;
  int? fboId;
  double width = 300;
  double height = 300;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  double dpr = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;

  bool loaded = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  three.AnimationMixer? mixer;
  three.Clock clock = three.Clock();

  dynamic sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = width;
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
    return SizedBox(
      width: width,
      height: height,
      child: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
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
                    return three3dRender.isInitialized
                        ? Texture(textureId: three3dRender.textureId!)
                        : Container(
                            color: Colors.yellow,
                          );
                  }
                })),
          ],
        ),
      ],
    );
  }

  clickRender() {
    print(" click render... ");
    animate();
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;
    if (!kIsWeb) renderer!.setRenderTarget(renderTarget);
    renderer!.render(scene, camera);

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    print("three3dRender 2: ${three3dRender.textureId} render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    renderer = widget.renderer;

    if (renderer == null) {
      Map<String, dynamic> options = {
        "width": width,
        "height": height,
        "gl": three3dRender.gl,
        "antialias": true,
      };
      renderer = three.WebGLRenderer(options);
      renderer!.autoClear = true;
    }

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
    camera = three.PerspectiveCamera(45, width / height, 1, 2200);
    camera.position.set(3, 6, 100);

    // scene

    scene = three.Scene();

    scene.background = three.Color(1, 1, 0);

    var ambientLight = three.AmbientLight(0xffffff, 0.9);
    scene.add(ambientLight);

    var pointLight = three.PointLight(0xffffff, 0.8);

    pointLight.position.set(0, 0, 0);

    camera.add(pointLight);
    scene.add(camera);

    camera.lookAt(scene.position);

    var geometry = three.BoxGeometry(10, 10, 20);
    var material = three.MeshBasicMaterial();

    object = three.Mesh(geometry, material);

    scene.add(object);

    loaded = true;

    animate();
  }

  animate() {
    var delta = clock.getDelta();

    object.rotation.y = object.rotation.y + 0.02;
    object.rotation.x = object.rotation.x + 0.01;

    mixer?.update(delta);

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
