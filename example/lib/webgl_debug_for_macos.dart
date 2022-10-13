import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as three;

class WebGlDebugForMacos extends StatefulWidget {
  final String fileName;

  const WebGlDebugForMacos({Key? key, required this.fileName}) : super(key: key);

  @override
  State<WebGlDebugForMacos> createState() => _MyAppState();
}

class _MyAppState extends State<WebGlDebugForMacos> {
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
  late three.Light pointLight;
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

  Uint8List? resultImage;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width * 0.5;
    height = width;
    // height = screenSize!.height;

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
        if (resultImage != null)
          Image.memory(
            resultImage!,
            width: width,
            height: height,
          )
      ],
    );
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    print(gl.getString(gl.VENDOR));
    print(gl.getString(gl.RENDERER));

    renderer!.render(scene, camera);

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    // var pixels = _gl.readCurrentPixels(0, 0, 10, 10);
    // print(" --------------pixels............. ");
    // print(pixels);

    // var _target = renderer!.getRenderTarget();
    // var buffer = Uint8List(_target.width * _target.height * 4);
    // renderer!.readRenderTargetPixels(_target, 0, 0, _target.width, _target.height, buffer, 0);

    // // print(" --------------buffer............. ");
    // // print(buffer.sublist(0, 100));

    // decodeImageFromPixels(buffer, _target.width, _target.height, ui.PixelFormat.rgba8888, (image) async {
    //   final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    //   setState(() {
    //     resultImage = pngBytes!.buffer.asUint8List();
    //   });
    // });

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
    renderer!.shadowMap.type = three.BasicShadowMap;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions(
          {"minFilter": three.LinearFilter, "magFilter": three.LinearFilter, "format": three.RGBAFormat});
      renderTarget = three.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
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
  }

  _initScene() {
    camera = three.PerspectiveCamera(45, width / height, 1, 1000);
    camera.position.set(0, 15, 70);

    scene = three.Scene();
    scene.background = three.Color(1.0, 0.0, 0.0);

    camera.lookAt(scene.position);

    dirLight = three.DirectionalLight(0xffffff, 1);
    dirLight.name = 'Dir. Light';
    dirLight.position.set(0, 20, 40);
    scene.add(dirLight);

    var geometry = three.BoxGeometry(10, 10, 10);
    var material = three.MeshLambertMaterial({"color": 0xffffff});

    var box = three.Mesh(geometry, material);

    scene.add(box);

    inited = true;

    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!inited) {
      return;
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
