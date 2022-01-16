import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;

class webgl_instancing_performance extends StatefulWidget {
  String fileName;
  webgl_instancing_performance({Key? key, required this.fileName})
      : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_instancing_performance> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.Material material;

  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  int count = 1000;

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
    renderer!.shadowMap.enabled = false;

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

  initScene() async {
    initRenderer();
    await initPage();
  }

  initPage() async {
    camera = new THREE.PerspectiveCamera(70, width / height, 1, 100);
    camera.position.z = 30;

    scene = new THREE.Scene();
    scene.background = THREE.Color.fromHex(0xffffff);

    var _loader = new THREE.BufferGeometryLoader(null);
    material = new THREE.MeshNormalMaterial();

    // var geometry = await _loader.loadAsync("assets/models/json/suzanne_buffergeometry.json", null);
    // geometry.computeVertexNormals();

    var geometry = THREE.BoxGeometry(5, 5, 5);

    // makeInstanced( geometry );

    // makeMerged( geometry );

    makeNaive(geometry);

    animate();
  }

  makeInstanced(geometry) {
    var matrix = new THREE.Matrix4();
    var mesh = new THREE.InstancedMesh(geometry, material, count);

    for (var i = 0; i < count; i++) {
      randomizeMatrix(matrix);
      mesh.setMatrixAt(i, matrix);
    }

    scene.add(mesh);

    //

    // var geometryByteLength = getGeometryByteLength( geometry );

    // guiStatsEl.innerHTML = [

    //   '<i>GPU draw calls</i>: 1',
    //   '<i>GPU memory</i>: ' + formatBytes( api.count * 16 + geometryByteLength, 2 )

    // ].join( '<br/>' );
  }

  makeNaive(geometry) {
    var matrix = new THREE.Matrix4();

    for (var i = 0; i < count; i++) {
      var mesh = new THREE.Mesh(geometry, material);
      randomizeMatrix(matrix);
      mesh.applyMatrix4(matrix);
      scene.add(mesh);
    }
  }

  var position = new THREE.Vector3();
  var rotation = new THREE.Euler(0, 0, 0);
  var quaternion = new THREE.Quaternion();
  var scale = new THREE.Vector3();

  randomizeMatrix(matrix) {
    position.x = THREE.Math.random() * 40 - 20;
    position.y = THREE.Math.random() * 40 - 20;
    position.z = THREE.Math.random() * 40 - 20;

    rotation.x = THREE.Math.random() * 2 * THREE.Math.PI;
    rotation.y = THREE.Math.random() * 2 * THREE.Math.PI;
    rotation.z = THREE.Math.random() * 2 * THREE.Math.PI;

    quaternion.setFromEuler(rotation, false);

    scale.x = scale.y = scale.z = THREE.Math.random() * 1;

    matrix.compose(position, quaternion, scale);
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    scene.rotation.x += 0.002;
    scene.rotation.y += 0.001;

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
