import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_helpers extends StatefulWidget {
  String fileName;

  webgl_helpers({Key? key, required this.fileName}) : super(key: key);

  @override
  createState() => _State();
}

class _State extends State<webgl_helpers> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.AnimationMixer mixer;
  THREE.Clock clock = THREE.Clock();
  THREE_JSM.OrbitControls? controls;

  double dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.PointLight light;

  THREE_JSM.VertexNormalsHelper? vnh;
  THREE_JSM.VertexTangentsHelper? vth;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

  late THREE.Object3D model;

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

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

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
      renderTarget = THREE.WebGLMultisampleRenderTarget(
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

  initPage() async {
    camera = THREE.PerspectiveCamera(70, width / height, 1, 1000);
    camera.position.z = 400;

    // scene

    scene = THREE.Scene();

    light = THREE.PointLight(0xffffff);
    light.position.set(200, 100, 150);
    scene.add(light);

    scene.add(THREE.PointLightHelper(light, 15, THREE.Color(0xffffff)));

    var gridHelper = THREE.GridHelper(400, 40, 0x0000ff, 0x808080);
    gridHelper.position.y = -150;
    gridHelper.position.x = -150;
    scene.add(gridHelper);

    var polarGridHelper =
        THREE.PolarGridHelper(200, 16, 8, 64, 0x0000ff, 0x808080);
    polarGridHelper.position.y = -150;
    polarGridHelper.position.x = 200;
    scene.add(polarGridHelper);

    camera.lookAt(scene.position);

    var loader = THREE_JSM.GLTFLoader(null).setPath('assets/models/gltf/');

    var result = await loader.loadAsync('LeePerrySmith.gltf');
    // var result = await loader.loadAsync( 'animate7.gltf', null);
    // var result = await loader.loadAsync( 'untitled22.gltf', null);

    print(result);
    print(" load gltf success result: $result  ");

    model = result["scene"];

    var mesh = model.children[2];

    print(" load gltf success mesh: $mesh  ");

    mesh.geometry!
        .computeTangents(); // generates bad data due to degenerate UVs

    var group = THREE.Group();
    group.scale.multiplyScalar(50);
    scene.add(group);

    // To make sure that the matrixWorld is up to date for the boxhelpers
    group.updateMatrixWorld(true);

    group.add(mesh);

    vnh = THREE_JSM.VertexNormalsHelper(mesh, 5);
    scene.add(vnh!);

    vth = THREE_JSM.VertexTangentsHelper(mesh, 5);
    scene.add(vth!);

    scene.add(THREE.BoxHelper(mesh));

    var wireframe = THREE.WireframeGeometry(mesh.geometry!);

    var line = THREE.LineSegments(wireframe, null);

    line.material.depthTest = false;
    line.material.opacity = 0.25;
    line.material.transparent = true;
    line.position.x = 4;
    group.add(line);
    scene.add(THREE.BoxHelper(line));

    var edges = THREE.EdgesGeometry(mesh.geometry!, null);
    line = THREE.LineSegments(edges, null);
    line.material.depthTest = false;
    line.material.opacity = 0.25;
    line.material.transparent = true;
    line.position.x = -4;
    group.add(line);
    scene.add(THREE.BoxHelper(line));

    scene.add(THREE.BoxHelper(group));
    scene.add(THREE.BoxHelper(scene));

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

    var delta = clock.getDelta();

    var time = -DateTime.now().millisecondsSinceEpoch * 0.00003;

    camera.position.x = 400 * THREE.Math.cos(time);
    camera.position.z = 400 * THREE.Math.sin(time);
    camera.lookAt(scene.position);

    light.position.x = THREE.Math.sin(time * 1.7) * 300;
    light.position.y = THREE.Math.cos(time * 1.5) * 400;
    light.position.z = THREE.Math.cos(time * 1.3) * 300;

    if (vnh != null) vnh!.update();
    if (vth != null) vth!.update();

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
