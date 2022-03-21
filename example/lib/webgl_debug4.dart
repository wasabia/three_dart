import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;


class webgl_debug4 extends StatefulWidget {
  String fileName;

  webgl_debug4({Key? key, required this.fileName}) : super(key: key);

  createState() => _State();
}

class _State extends State<webgl_debug4> {
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

    if (verbose) print(" render: sourceTexture: ${sourceTexture} three3dRender.textureId! ${three3dRender.textureId!} ");

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
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
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
    camera = new THREE.PerspectiveCamera(45, width / height, 1, 100);
    camera.position.z = 100;


    scene = new THREE.Scene();

    var ambientLight = new THREE.AmbientLight(0xcccccc, 0.4);
    scene.add(ambientLight);

    camera.lookAt(scene.position);


    var clothMaterial = new THREE.MeshBasicMaterial(
        {"color": THREE.Color(1, 0.5, 1)});

    var plane = THREE.BoxGeometry(50, 50, 50);

    mesh = new THREE.Mesh(plane, clothMaterial);
    scene.add(mesh);

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

    // mesh.rotation.x = mesh.rotation.x + 0.1;
    // mesh.rotation.y = mesh.rotation.y + 0.05;

    mesh.rotation.x += 0.1;
    mesh.rotation.y += 0.05;

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
