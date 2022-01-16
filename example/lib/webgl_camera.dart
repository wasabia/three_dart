import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;

class webgl_camera extends StatefulWidget {
  String fileName;
  webgl_camera({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_camera> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.Camera cameraPerspective;
  late THREE.Camera cameraOrtho;

  late THREE.Group cameraRig;

  late THREE.Camera activeCamera;
  late THREE.CameraHelper activeHelper;

  late THREE.CameraHelper cameraOrthoHelper;
  late THREE.CameraHelper cameraPerspectiveHelper;

  int frustumSize = 600;

  num dpr = 1.0;

  num aspect = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

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

    // renderer!.render(scene, camera);

    var r = DateTime.now().millisecondsSinceEpoch * 0.0005;

    mesh.position.x = 700 * THREE.Math.cos(r);
    mesh.position.z = 700 * THREE.Math.sin(r);
    mesh.position.y = 700 * THREE.Math.sin(r);

    mesh.children[0].position.x = 70 * THREE.Math.cos(2 * r);
    mesh.children[0].position.z = 70 * THREE.Math.sin(r);

    if (activeCamera == cameraPerspective) {
      cameraPerspective.fov = 35 + 30 * THREE.Math.sin(0.5 * r);
      cameraPerspective.far = mesh.position.length();
      cameraPerspective.updateProjectionMatrix();

      cameraPerspectiveHelper.update();
      cameraPerspectiveHelper.visible = true;

      cameraOrthoHelper.visible = false;
    } else {
      cameraOrtho.far = mesh.position.length();
      cameraOrtho.updateProjectionMatrix();

      cameraOrthoHelper.update();
      cameraOrthoHelper.visible = true;

      cameraPerspectiveHelper.visible = false;
    }

    cameraRig.lookAt(mesh.position);

    renderer!.clear(null, null, null);

    activeHelper.visible = false;

    renderer!.setViewport(0, 0, width / 2, height);
    renderer!.render(scene, activeCamera);

    activeHelper.visible = true;

    renderer!.setViewport(width / 2, 0, width / 2, height);
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
    renderer!.autoClear = false;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({
        "minFilter": THREE.LinearFilter,
        "magFilter": THREE.LinearFilter,
        "format": THREE.RGBAFormat
      });
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() {
    aspect = width / height;

    scene = new THREE.Scene();

    //

    camera = new THREE.PerspectiveCamera(50, 0.5 * aspect, 1, 10000);
    camera.position.z = 2500;

    cameraPerspective =
        new THREE.PerspectiveCamera(50, 0.5 * aspect, 150, 1000);

    cameraPerspectiveHelper = new THREE.CameraHelper(cameraPerspective);
    scene.add(cameraPerspectiveHelper);

    //
    cameraOrtho = new THREE.OrthographicCamera(
        0.5 * frustumSize * aspect / -2,
        0.5 * frustumSize * aspect / 2,
        frustumSize / 2,
        frustumSize / -2,
        150,
        1000);

    cameraOrthoHelper = new THREE.CameraHelper(cameraOrtho);
    scene.add(cameraOrthoHelper);

    //

    activeCamera = cameraPerspective;
    activeHelper = cameraPerspectiveHelper;

    // counteract different front orientation of cameras vs rig

    cameraOrtho.rotation.y = THREE.Math.PI;
    cameraPerspective.rotation.y = THREE.Math.PI;

    cameraRig = new THREE.Group();

    cameraRig.add(cameraPerspective);
    cameraRig.add(cameraOrtho);

    scene.add(cameraRig);

    //

    mesh = new THREE.Mesh(new THREE.SphereGeometry(100, 16, 8),
        new THREE.MeshBasicMaterial({"color": 0xffffff, "wireframe": true}));
    scene.add(mesh);

    var mesh2 = new THREE.Mesh(new THREE.SphereGeometry(50, 16, 8),
        new THREE.MeshBasicMaterial({"color": 0x00ff00, "wireframe": true}));
    mesh2.position.y = 150;
    mesh.add(mesh2);

    var mesh3 = new THREE.Mesh(new THREE.SphereGeometry(5, 16, 8),
        new THREE.MeshBasicMaterial({"color": 0x0000ff, "wireframe": true}));
    mesh3.position.z = 150;
    cameraRig.add(mesh3);

    //

    var geometry = new THREE.BufferGeometry();
    var vertices = [];

    for (var i = 0; i < 10000; i++) {
      vertices.add(THREE.MathUtils.randFloatSpread(2000)); // x
      vertices.add(THREE.MathUtils.randFloatSpread(2000)); // y
      vertices.add(THREE.MathUtils.randFloatSpread(2000)); // z

    }

    geometry.setAttribute(
        'position', new THREE.Float32BufferAttribute(vertices, 3));

    var particles = new THREE.Points(
        geometry, new THREE.PointsMaterial({"color": 0x888888}));
    scene.add(particles);

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
