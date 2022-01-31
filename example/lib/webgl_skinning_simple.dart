import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_skinning_simple extends StatefulWidget {
  String fileName;
  webgl_skinning_simple({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_skinning_simple> {
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

  bool loaded = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  THREE.AnimationMixer? mixer;
  THREE.Clock clock = new THREE.Clock();

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

  clickRender() {
    print(" click render... ");
    animate();
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
    renderer!.shadowMap.enabled = true;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
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

  initPage() async {
    camera = new THREE.PerspectiveCamera(45, width / height, 1, 1000);
    camera.position.set(18, 6, 18);

    scene = new THREE.Scene();
    scene.background = THREE.Color.fromHex(0xa0a0a0);
    scene.fog = new THREE.Fog(0xa0a0a0, 70, 100);

    clock = new THREE.Clock();

    // ground

    var geometry = new THREE.PlaneGeometry(500, 500);
    var material =
        new THREE.MeshPhongMaterial({"color": 0x999999, "depthWrite": false});

    var ground = new THREE.Mesh(geometry, material);
    ground.position.set(0, -5, 0);
    ground.rotation.x = -THREE.Math.PI / 2;
    ground.receiveShadow = true;
    scene.add(ground);

    var grid = new THREE.GridHelper(500, 100, 0x000000, 0x000000);
    grid.position.y = -5;
    grid.material.opacity = 0.2;
    grid.material.transparent = true;
    scene.add(grid);

    // lights

    var hemiLight = new THREE.HemisphereLight(0xffffff, 0x444444, 0.6);
    hemiLight.position.set(0, 200, 0);
    scene.add(hemiLight);

    var dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
    dirLight.position.set(0, 20, 10);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.top = 18;
    dirLight.shadow!.camera!.bottom = -10;
    dirLight.shadow!.camera!.left = -12;
    dirLight.shadow!.camera!.right = 12;
    scene.add(dirLight);

    camera.lookAt(scene.position);

    var loader = THREE_JSM.GLTFLoader(null).setPath('assets/models/gltf/');

    // var result = await loader.loadAsync( 'Parrot.gltf');
    var result = await loader.loadAsync('SimpleSkinning.gltf');

    print(" gltf load sucess result: ${result}  ");

    object = result["scene"];

    object.traverse((child) {
      if (child.isSkinnedMesh) child.castShadow = true;
    });

    var skeleton = new THREE.SkeletonHelper(object);
    skeleton.visible = true;
    scene.add(skeleton);

    mixer = new THREE.AnimationMixer(object);

    var clip = result["animations"][0];
    if (clip != null) {
      var action = mixer!.clipAction(clip);
      action.play();
    }

    scene.add(object);

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();

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

    print(" animate render ");

    var delta = clock.getDelta();

    mixer?.update(delta);

    render();

    // 60FPS
    // Future.delayed(Duration(milliseconds: 17), () {
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
