import 'dart:async';



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_loader_fbx extends StatefulWidget {
  String fileName;
  webgl_loader_fbx({Key? key, required this.fileName}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_loader_fbx> {
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

  THREE.Clock clock = THREE.Clock();

  THREE.AnimationMixer? mixer;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  final GlobalKey<THREE_JSM.DomLikeListenableState> _globalKey =
      GlobalKey<THREE_JSM.DomLikeListenableState>();

  late THREE_JSM.OrbitControls controls;

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

    if(mixer == null) {
      return;
    }

    var delta = clock.getDelta();

    mixer!.update(delta);

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
    renderer!.shadowMap.enabled = true;

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

  initPage() async {
    var ASPECTRATIO = width / height;

    var WIDTH = (width / AMOUNT) * dpr;
    var HEIGHT = (height / AMOUNT) * dpr;

    scene = THREE.Scene();
    scene.background = THREE.Color(0xcccccc);
    scene.fog = THREE.FogExp2(0xcccccc, 0.002);

    camera = THREE.PerspectiveCamera(60, width / height, 1, 2000);
    camera.position.set( 100, 200, 300 );

    // controls

    controls = THREE_JSM.OrbitControls(camera, _globalKey);

    controls.enableDamping =
        true; // an animation loop is required when either damping or auto-rotation are enabled
    controls.dampingFactor = 0.05;

    controls.screenSpacePanning = false;

    controls.minDistance = 100;
    controls.maxDistance = 500;

    controls.maxPolarAngle = THREE.Math.PI / 2;

    scene = THREE.Scene();
    scene.background = THREE.Color( 0xa0a0a0 );
    scene.fog = THREE.Fog( 0xa0a0a0, 200, 1000 );

    var hemiLight = THREE.HemisphereLight( 0xffffff, 0x444444 );
    hemiLight.position.set( 0, 200, 0 );
    scene.add( hemiLight );

    var dirLight = THREE.DirectionalLight( 0xffffff );
    dirLight.position.set( 0, 200, 100 );
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.top = 180;
    dirLight.shadow!.camera!.bottom = - 100;
    dirLight.shadow!.camera!.left = - 120;
    dirLight.shadow!.camera!.right = 120;
    scene.add( dirLight );

    // scene.add( new THREE.CameraHelper( dirLight.shadow!.camera ) );

    // ground
    // var mesh = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000 ), new THREE.MeshPhongMaterial( { "color": 0x999999, "depthWrite": false } ) );
    // mesh.rotation.x = - THREE.Math.PI / 2;
    // mesh.receiveShadow = true;
    // scene.add( mesh );

    // var grid = new THREE.GridHelper( 2000, 20, 0x000000, 0x000000 );
    // grid.material.opacity = 0.2;
    // grid.material.transparent = true;
    // scene.add( grid );

    var textureLoader = THREE.TextureLoader(null);
    textureLoader.flipY = true;
    // var diffueTexture = await textureLoader.loadAsync(
    //     "assets/models/fbx/model_tex_u1_v1_diffuse.jpg", null);
    // var normalTexture = await textureLoader.loadAsync(
    //     "assets/models/fbx/model_tex_u1_v1_normal.jpg", null);

    // model
    var loader = THREE_JSM.FBXLoader(null, width.toInt(), height.toInt());
    var object = await loader.loadAsync( 'assets/models/fbx/Samba Dancing.fbx');
    // var object = await loader.loadAsync( 'assets/models/fbx/model.fbx');
    // var object = await loader.loadAsync( 'assets/models/fbx/Twist-Dance.fbx');
    // var object = await loader.loadAsync( 'assets/models/fbx/Falling.fbx');

    mixer = THREE.AnimationMixer( object );

    var action = mixer!.clipAction( object.animations[ 1 ] );
    action!.play();

    object.traverse( ( child ) {

      if ( child is THREE.Mesh ) {

        child.castShadow = true;
        child.receiveShadow = true;
      }

    } );

    scene.add( object );

    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

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
