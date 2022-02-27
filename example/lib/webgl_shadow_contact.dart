import 'dart:async';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;
import 'package:three_dart_jsm/three_dart_jsm/shaders/HorizontalBlurShader.dart';
import 'package:three_dart_jsm/three_dart_jsm/shaders/VerticalBlurShader.dart';

class webgl_shadow_contact extends StatefulWidget {
  String fileName;
  webgl_shadow_contact({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_shadow_contact> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;
  late THREE.Group shadowGroup;
  late THREE.Mesh plane;
  late THREE.Mesh blurPlane;
  late THREE.Mesh fillPlane;

  num dpr = 1.0;

  var AMOUNT = 4;

  bool verbose = true;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  THREE.WebGLMultisampleRenderTarget? renderTarget;

  late THREE.WebGLRenderTarget renderTarget2;
  late THREE.WebGLRenderTarget renderTargetBlur;

  var meshes = [];

  var PLANE_WIDTH = 2.5;
  var PLANE_HEIGHT = 2.5;
  var CAMERA_HEIGHT = 0.3;

  bool inited = false;

  late THREE.Camera shadowCamera;
  late THREE.CameraHelper cameraHelper;

  late THREE.Material depthMaterial;
  late THREE.Material horizontalBlurMaterial;
  late THREE.Material verticalBlurMaterial;

  dynamic? sourceTexture;

  Map<String, dynamic> state = {
    "shadow": {
      "blur": 3.5,
      "darkness": 1,
      "opacity": 1,
    },
    "plane": {
      "color": 0xffffff,
      "opacity": 1,
    },
    "showWireframe": false,
  };

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
      "alpha": true,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      await initScene();
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

    if (!inited) {
      return;
    }

    print(" render ..... ");

    meshes.forEach((mesh) {
      mesh.rotation.x += 0.01;
      mesh.rotation.y += 0.02;
    });

    // remove the background
    var initialBackground = scene.background;
    scene.background = null;

    // force the depthMaterial to everything
    cameraHelper.visible = false;
    scene.overrideMaterial = depthMaterial;

    // render to the render target to get the depths
    renderer!.setRenderTarget(renderTarget2);
    renderer!.render(scene, shadowCamera);

    // and reset the override material
    scene.overrideMaterial = null;
    cameraHelper.visible = true;

    blurShadow(state["shadow"]["blur"]);

    // a second pass to reduce the artifacts
    // (0.4 is the minimum blur amout so that the artifacts are gone)
    blurShadow(state["shadow"]["blur"] * 0.4);

    // reset and render the normal scene
    renderer!.setRenderTarget(renderTarget);
    scene.background = initialBackground;

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    // _gl.finish();
    _gl.flush();

    if (verbose) print(" render: sourceTexture: ${sourceTexture} ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  // renderTarget --> blurPlane (horizontalBlur) --> renderTargetBlur --> blurPlane (verticalBlur) --> renderTarget
  blurShadow(amount) {
    blurPlane.visible = true;

    // blur horizontally and draw in the renderTargetBlur
    blurPlane.material = horizontalBlurMaterial;
    blurPlane.material.uniforms["tDiffuse"]["value"] = renderTarget2.texture;
    horizontalBlurMaterial.uniforms["h"]["value"] = amount * 1 / 256;

    renderer!.setRenderTarget(renderTargetBlur);
    renderer!.render(blurPlane, shadowCamera);

    // blur vertically and draw in the main renderTarget
    blurPlane.material = verticalBlurMaterial;
    blurPlane.material.uniforms["tDiffuse"]["value"] = renderTargetBlur.texture;
    verticalBlurMaterial.uniforms["v"]["value"] = amount * 1 / 256;

    renderer!.setRenderTarget(renderTarget2);
    renderer!.render(blurPlane, shadowCamera);

    blurPlane.visible = false;
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element,
      "alpha": true // 设置透明
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget!.samples = 4;
      renderer!.setRenderTarget(renderTarget!);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget!);
    } else {
      renderTarget = null;
    }
  }

  initScene() async {
    initRenderer();
    await initPage();
  }

  initPage() async {
    camera = new THREE.PerspectiveCamera(50, width / height, 0.1, 100);
    camera.position.set(0.5, 1, 2);

    scene = new THREE.Scene();
    scene.background = THREE.Color.fromHex(0xffffff);

    camera.lookAt(scene.position);

    // add the example meshes

    var geometries = [
      new THREE.BoxGeometry(0.4, 0.4, 0.4),
      new THREE.IcosahedronGeometry(0.3),
      new THREE.TorusKnotGeometry(0.4, 0.05, 256, 24, 1, 3)
    ];

    var material = new THREE.MeshNormalMaterial();

    for (var i = 0, l = geometries.length; i < l; i++) {
      var angle = (i / l) * THREE.Math.PI * 2;

      var geometry = geometries[i];
      var mesh = new THREE.Mesh(geometry, material);
      mesh.position.y = 0.1;
      mesh.position.x = THREE.Math.cos(angle) / 2.0;
      mesh.position.z = THREE.Math.sin(angle) / 2.0;
      scene.add(mesh);
      meshes.add(mesh);
    }

    // the container, if you need to move the plane just move this
    shadowGroup = new THREE.Group();
    shadowGroup.position.y = -0.3;
    scene.add(shadowGroup);

    var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
    // the render target that will show the shadows in the plane texture
    renderTarget2 = new THREE.WebGLRenderTarget(512, 512, pars);
    renderTarget2.texture.generateMipmaps = false;

    // the render target that we will use to blur the first render target
    renderTargetBlur = new THREE.WebGLRenderTarget(512, 512, pars);
    renderTargetBlur.texture.generateMipmaps = false;

    // make a plane and make it face up
    var planeGeometry = new THREE.PlaneGeometry(PLANE_WIDTH, PLANE_HEIGHT)
        .rotateX(THREE.Math.PI / 2);
    var planeMaterial = new THREE.MeshBasicMaterial({
      "map": renderTarget2.texture,
      "opacity": state["shadow"]!["opacity"]!,
      "transparent": true,
      "depthWrite": false,
    });
    plane = new THREE.Mesh(planeGeometry, planeMaterial);
    // make sure it's rendered after the fillPlane
    plane.renderOrder = 1;
    shadowGroup.add(plane);

    // the y from the texture is flipped!
    plane.scale.y = -1;

    // the plane onto which to blur the texture
    blurPlane = new THREE.Mesh(planeGeometry, null);
    blurPlane.visible = false;
    shadowGroup.add(blurPlane);

    // the plane with the color of the ground
    var fillPlaneMaterial = new THREE.MeshBasicMaterial({
      "color": state["plane"]["color"],
      "opacity": state["plane"]["opacity"],
      "transparent": true,
      "depthWrite": false,
    });
    fillPlane = new THREE.Mesh(planeGeometry, fillPlaneMaterial);
    fillPlane.rotateX(THREE.Math.PI);
    shadowGroup.add(fillPlane);

    // the camera to render the depth material from
    shadowCamera = new THREE.OrthographicCamera(-PLANE_WIDTH / 2,
        PLANE_WIDTH / 2, PLANE_HEIGHT / 2, -PLANE_HEIGHT / 2, 0, CAMERA_HEIGHT);
    shadowCamera.rotation.x = THREE.Math.PI / 2; // get the camera to look up
    shadowGroup.add(shadowCamera);

    cameraHelper = THREE.CameraHelper(shadowCamera);

    // like MeshDepthMaterial, but goes from black to transparent
    depthMaterial = new THREE.MeshDepthMaterial();
    depthMaterial.userData["darkness"] = {"value": state["shadow"]["darkness"]};
    depthMaterial.onBeforeCompile = (shader, renderer) {
      shader.uniforms["darkness"] = depthMaterial.userData["darkness"];
      shader.fragmentShader = """
        uniform float darkness;
        ${shader.fragmentShader.replaceFirst('gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );', 'gl_FragColor = vec4( vec3( 0.0 ), ( 1.0 - fragCoordZ ) * darkness );')}
      """;
    };

    depthMaterial.depthTest = false;
    depthMaterial.depthWrite = false;

    horizontalBlurMaterial = new THREE.ShaderMaterial(HorizontalBlurShader);
    horizontalBlurMaterial.depthTest = false;

    verticalBlurMaterial = new THREE.ShaderMaterial(VerticalBlurShader);
    verticalBlurMaterial.depthTest = false;

    inited = true;
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
