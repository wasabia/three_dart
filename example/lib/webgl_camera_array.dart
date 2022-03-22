import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;

class webgl_camera_array extends StatefulWidget {
  String fileName;
  webgl_camera_array({Key? key, required this.fileName}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_camera_array> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;


  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

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

    print("three3dRender.initialize _options: $_options ");

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 200), () async {
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
          animate();
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
                  color: Colors.red,
                  child: Builder(builder: (BuildContext context) {
                    if (kIsWeb) {
                      return three3dRender.isInitialized
                          ? HtmlElementView(
                              viewType: three3dRender.textureId!.toString())
                          : Container(color: Colors.red,);
                    } else {
                      return three3dRender.isInitialized
                          ? Texture(textureId: three3dRender.textureId!)
                          : Container(color: Colors.red);
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
    _gl.finish();

    // var pixels = _gl.readCurrentPixels(0, 0, 10, 10);
    // print(" --------------pixels............. ");
    // print(pixels);

    if (verbose) print(" render: sourceTexture: $sourceTexture three3dRender.textureId! ${three3dRender.textureId!}");

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
        "format": THREE.RGBAFormat
      });
      renderTarget = THREE.WebGLRenderTarget(
          (width * dpr), (height * dpr), pars);
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
    var ASPECTRATIO = width / height;

    var WIDTH = (width / AMOUNT) * dpr;
    var HEIGHT = (height / AMOUNT) * dpr;

    List<THREE.Camera> cameras = [];

    for (var y = 0; y < AMOUNT; y++) {
      for (var x = 0; x < AMOUNT; x++) {
        var subcamera = THREE.PerspectiveCamera(40, ASPECTRATIO, 0.1, 10);
        subcamera.viewport = THREE.Vector4(
            THREE.Math.floor(x * WIDTH),
            THREE.Math.floor(y * HEIGHT),
            THREE.Math.ceil(WIDTH),
            THREE.Math.ceil(HEIGHT));
        subcamera.position.x = (x / AMOUNT) - 0.5;
        subcamera.position.y = 0.5 - (y / AMOUNT);
        subcamera.position.z = 1.5;
        subcamera.position.multiplyScalar(2);
        subcamera.lookAt(THREE.Vector3(0, 0, 0));
        subcamera.updateMatrixWorld(false);
        cameras.add(subcamera);
      }
    }

    camera = THREE.ArrayCamera(cameras);
    // camera = new THREE.PerspectiveCamera(45, width / height, 1, 10);
    camera.position.z = 3;

    scene = THREE.Scene();

    


    var ambientLight = THREE.AmbientLight(0xcccccc, 0.4);
    scene.add(ambientLight);

    camera.lookAt(scene.position);

    var light = THREE.DirectionalLight(0xffffff, null);
    light.position.set(0.5, 0.5, 1);
    light.castShadow = true;
    light.shadow!.camera!.zoom = 4; // tighter shadow map
    scene.add(light);

    var geometryBackground = THREE.PlaneGeometry(100, 100);
    var materialBackground = THREE.MeshPhongMaterial({"color": 0x000066});

    var background = THREE.Mesh(geometryBackground, materialBackground);
    background.receiveShadow = true;
    background.position.set(0, 0, -1);
    scene.add(background);

    var geometryCylinder = THREE.CylinderGeometry(0.5, 0.5, 1, 32);
    var materialCylinder = THREE.MeshPhongMaterial({"color": 0xff0000});

    mesh = THREE.Mesh(geometryCylinder, materialCylinder);
    // mesh.castShadow = true;
    // mesh.receiveShadow = true;
    scene.add(mesh);
     

    loaded = true;
    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    mesh.rotation.x += 0.1;
    mesh.rotation.y += 0.05;

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
