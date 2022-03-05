import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class misc_controls_map extends StatefulWidget {
  String fileName;
  misc_controls_map({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<misc_controls_map> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  final GlobalKey<THREE_JSM.DomLikeListenableState> _globalKey =
      GlobalKey<THREE_JSM.DomLikeListenableState>();

  late THREE_JSM.MapControls controls;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height - 60;

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
              THREE_JSM.DomLikeListenable(
                  key: _globalKey,
                  builder: (BuildContext context) {
                    return Container(
                        width: width,
                        height: height,
                        color: Colors.black,
                        child: Builder(builder: (BuildContext context) {
                          if (kIsWeb) {
                            return three3dRender.isInitialized
                                ? HtmlElementView(
                                    viewType:
                                        three3dRender.textureId!.toString())
                                : Container();
                          } else {
                            return three3dRender.isInitialized
                                ? Texture(textureId: three3dRender.textureId!)
                                : Container();
                          }
                        }));
                  }),
            ],
          ),
        ),
      ],
    );
  }

  render() {
    int _t = DateTime.now().millisecondsSinceEpoch;
    final _gl = three3dRender.gl;

    controls.update();

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    // var pixels = _gl.readCurrentPixels(0, 0, 10, 10);
    // print(" --------------pixels............. ");
    // print(pixels);

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
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({
        "minFilter": THREE.LinearFilter,
        "magFilter": THREE.LinearFilter,
        "format": THREE.RGBAFormat
      });
      renderTarget = THREE.WebGLRenderTarget(
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

  initPage() {
    var ASPECT_RATIO = width / height;

    var WIDTH = (width / AMOUNT) * dpr;
    var HEIGHT = (height / AMOUNT) * dpr;

    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xcccccc);
    scene.fog = new THREE.FogExp2(0xcccccc, 0.002);

    camera = new THREE.PerspectiveCamera(60, width / height, 1, 1000);
    camera.position.set(400, 200, 0);
    camera.lookAt(scene.position);

    // controls

    controls = new THREE_JSM.MapControls(camera, _globalKey);

    controls.enableDamping =
        true; // an animation loop is required when either damping or auto-rotation are enabled
    controls.dampingFactor = 0.05;

    controls.screenSpacePanning = false;

    controls.minDistance = 100;
    controls.maxDistance = 500;

    controls.maxPolarAngle = THREE.Math.PI / 2;

    // world
    var geometry = new THREE.BoxGeometry(1, 1, 1);
    geometry.translate(0, 0.5, 0);
    var material =
        new THREE.MeshPhongMaterial({'color': 0xffffff, 'flatShading': true});

    for (var i = 0; i < 500; i++) {
      var mesh = new THREE.Mesh(geometry, material);
      mesh.position.x = THREE.Math.random() * 1600 - 800;
      mesh.position.y = 0;
      mesh.position.z = THREE.Math.random() * 1600 - 800;
      mesh.scale.x = 20;
      mesh.scale.y = THREE.Math.random() * 80 + 10;
      mesh.scale.z = 20;
      mesh.updateMatrix();
      mesh.matrixAutoUpdate = false;
      scene.add(mesh);
    }
    // lights

    var dirLight1 = new THREE.DirectionalLight(0xffffff);
    dirLight1.position.set(1, 1, 1);
    scene.add(dirLight1);

    var dirLight2 = new THREE.DirectionalLight(0x002288);
    dirLight2.position.set(-1, -1, -1);
    scene.add(dirLight2);

    var ambientLight = new THREE.AmbientLight(0x222222);
    scene.add(ambientLight);

    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

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
