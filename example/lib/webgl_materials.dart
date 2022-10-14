import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;

class WebGlMaterials extends StatefulWidget {
  final String fileName;
  const WebGlMaterials({Key? key, required this.fileName}) : super(key: key);

  @override
  State<WebGlMaterials> createState() => _MyAppState();
}

class _MyAppState extends State<WebGlMaterials> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.PointLight pointLight;

  var objects = [], materials = [];

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
    height = screenSize!.height;

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
          clickRender();
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

    renderer!.render(scene, camera);

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

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
    camera = three.PerspectiveCamera(45, width / height, 1, 2000);
    camera.position.set(0, 200, 800);

    scene = three.Scene();

    // Grid

    var helper = three.GridHelper(1000, 40, 0x303030, 0x303030);
    helper.position.y = -75;
    scene.add(helper);

    // Materials

    var texture =
        three.DataTexture(generateTexture().data, 256, 256, null, null, null, null, null, null, null, null, null);
    texture.needsUpdate = true;

    materials.add(three.MeshLambertMaterial({"map": texture, "transparent": true}));
    materials.add(three.MeshLambertMaterial({"color": 0xdddddd}));
    materials
        .add(three.MeshPhongMaterial({"color": 0xdddddd, "specular": 0x009900, "shininess": 30, "flatShading": true}));
    materials.add(three.MeshNormalMaterial());
    materials
        .add(three.MeshBasicMaterial({"color": 0xffaa00, "transparent": true, "blending": three.AdditiveBlending}));
    materials.add(three.MeshLambertMaterial({"color": 0xdddddd}));
    materials.add(three.MeshPhongMaterial(
        {"color": 0xdddddd, "specular": 0x009900, "shininess": 30, "map": texture, "transparent": true}));
    materials.add(three.MeshNormalMaterial({"flatShading": true}));
    materials.add(three.MeshBasicMaterial({"color": 0xffaa00, "wireframe": true}));
    materials.add(three.MeshDepthMaterial());
    materials.add(three.MeshLambertMaterial({"color": 0x666666, "emissive": 0xff0000}));
    materials.add(three.MeshPhongMaterial({
      "color": 0x000000,
      "specular": 0x666666,
      "emissive": 0xff0000,
      "shininess": 10,
      "opacity": 0.9,
      "transparent": true
    }));
    materials.add(three.MeshBasicMaterial({"map": texture, "transparent": true}));

    // Spheres geometry

    var geometry = three.SphereGeometry(70, 32, 16);

    for (var i = 0, l = materials.length; i < l; i++) {
      addMesh(geometry, materials[i]);
    }

    // Lights

    scene.add(three.AmbientLight(0x111111, 1));

    var directionalLight = three.DirectionalLight(0xffffff, 0.125);

    directionalLight.position.x = three.Math.random() - 0.5;
    directionalLight.position.y = three.Math.random() - 0.5;
    directionalLight.position.z = three.Math.random() - 0.5;
    directionalLight.position.normalize();

    scene.add(directionalLight);

    pointLight = three.PointLight(0xffffff, 1);
    scene.add(pointLight);

    pointLight.add(three.Mesh(three.SphereGeometry(4, 8, 8), three.MeshBasicMaterial({"color": 0xffffff})));

    //

    // scene.overrideMaterial = new three.MeshBasicMaterial();

    loaded = true;

    animate();
  }

  generateTexture() {
    var pixels = Uint8Array(256 * 256 * 4);

    var x = 0, y = 0, l = pixels.length;

    for (var i = 0, j = 0; i < l; i += 4, j++) {
      x = j % 256;
      y = (x == 0) ? y + 1 : y;

      pixels[i] = 255;
      pixels[i + 1] = 255;
      pixels[i + 2] = 255;
      pixels[i + 3] = three.Math.floor(x ^ y);
    }

    return three.ImageElement(data: pixels, width: 256, height: 256);
  }

  addMesh(geometry, material) {
    var mesh = three.Mesh(geometry, material);

    mesh.position.x = (objects.length % 4) * 200 - 400;
    mesh.position.z = three.Math.floor(objects.length / 4) * 200 - 200;

    mesh.rotation.x = three.Math.random() * 200 - 100;
    mesh.rotation.y = three.Math.random() * 200 - 100;
    mesh.rotation.z = three.Math.random() * 200 - 100;

    objects.add(mesh);

    scene.add(mesh);
  }

  animate() {
    print("before animate render mounted: $mounted loaded: $loaded");

    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    print(" animate render ");

    var timer = 0.0001 * DateTime.now().millisecondsSinceEpoch;

    camera.position.x = three.Math.cos(timer) * 1000;
    camera.position.z = three.Math.sin(timer) * 1000;

    camera.lookAt(scene.position);

    for (var i = 0, l = objects.length; i < l; i++) {
      var object = objects[i];

      object.rotation.x += 0.01;
      object.rotation.y += 0.005;
    }

    materials[materials.length - 2].emissive.setHSL(0.54, 1.0, 0.35 * (0.5 + 0.5 * three.Math.sin(35 * timer)));
    materials[materials.length - 3].emissive.setHSL(0.04, 1.0, 0.35 * (0.5 + 0.5 * three.Math.cos(35 * timer)));

    pointLight.position.x = three.Math.sin(timer * 7) * 300;
    pointLight.position.y = three.Math.cos(timer * 5) * 400;
    pointLight.position.z = three.Math.cos(timer * 3) * 300;

    render();

    // 30FPS
    Future.delayed(const Duration(milliseconds: 33), () {
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
