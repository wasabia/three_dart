import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class WebGlShadowContact extends StatefulWidget {
  final String fileName;
  const WebGlShadowContact({Key? key, required this.fileName}) : super(key: key);

  @override
  State<WebGlShadowContact> createState() => _MyAppState();
}

class _MyAppState extends State<WebGlShadowContact> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;
  late three.Group shadowGroup;
  late three.Mesh plane;
  late three.Mesh blurPlane;
  late three.Mesh fillPlane;

  double dpr = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;

  late three.Object3D object;

  late three.Texture texture;

  three.WebGLRenderTarget? renderTarget;

  late three.WebGLRenderTarget renderTarget2;
  late three.WebGLRenderTarget renderTargetBlur;

  var meshes = [];

  var planeWidth = 2.5;
  var planeHeight = 2.5;
  var cameraHeight = 0.3;

  bool inited = false;

  late three.Camera shadowCamera;
  late three.CameraHelper cameraHelper;

  late three.Material depthMaterial;
  late three.Material horizontalBlurMaterial;
  late three.Material verticalBlurMaterial;

  dynamic sourceTexture;

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

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": true,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    setState(() {});

    // Wait for web
    Future.delayed(const Duration(milliseconds: 100), () async {
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

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    if (!inited) {
      return;
    }

    print(" render ..... ");

    for (var mesh in meshes) {
      mesh.rotation.x += 0.01;
      mesh.rotation.y += 0.02;
    }

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

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    // _gl.finish();
    gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

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
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element,
      "alpha": true // 设置透明
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
      renderTarget = three.WebGLRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
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
    camera = three.PerspectiveCamera(50, width / height, 0.1, 100);
    camera.position.set(0.5, 1, 2);

    scene = three.Scene();
    scene.background = three.Color.fromHex(0xffffff);

    camera.lookAt(scene.position);

    // add the example meshes

    var geometries = [
      three.BoxGeometry(0.4, 0.4, 0.4),
      three.IcosahedronGeometry(0.3),
      three.TorusKnotGeometry(0.4, 0.05, 256, 24, 1, 3)
    ];

    var material = three.MeshNormalMaterial();

    for (var i = 0, l = geometries.length; i < l; i++) {
      var angle = (i / l) * three.Math.PI * 2;

      var geometry = geometries[i];
      var mesh = three.Mesh(geometry, material);
      mesh.position.y = 0.1;
      mesh.position.x = three.Math.cos(angle) / 2.0;
      mesh.position.z = three.Math.sin(angle) / 2.0;
      scene.add(mesh);
      meshes.add(mesh);
    }

    // the container, if you need to move the plane just move this
    shadowGroup = three.Group();
    shadowGroup.position.y = -0.3;
    scene.add(shadowGroup);

    var pars = three.WebGLRenderTargetOptions({"format": three.RGBAFormat});
    // the render target that will show the shadows in the plane texture
    renderTarget2 = three.WebGLRenderTarget(512, 512, pars);
    renderTarget2.texture.generateMipmaps = false;

    // the render target that we will use to blur the first render target
    renderTargetBlur = three.WebGLRenderTarget(512, 512, pars);
    renderTargetBlur.texture.generateMipmaps = false;

    // make a plane and make it face up
    var planeGeometry = three.PlaneGeometry(planeWidth, planeHeight).rotateX(three.Math.PI / 2);
    var planeMaterial = three.MeshBasicMaterial({
      "map": renderTarget2.texture,
      "opacity": state["shadow"]!["opacity"]!,
      "transparent": true,
      "depthWrite": false,
    });
    plane = three.Mesh(planeGeometry, planeMaterial);
    // make sure it's rendered after the fillPlane
    plane.renderOrder = 1;
    shadowGroup.add(plane);

    // the y from the texture is flipped!
    plane.scale.y = -1;

    // the plane onto which to blur the texture
    blurPlane = three.Mesh(planeGeometry, null);
    blurPlane.visible = false;
    shadowGroup.add(blurPlane);

    // the plane with the color of the ground
    var fillPlaneMaterial = three.MeshBasicMaterial({
      "color": state["plane"]["color"],
      "opacity": state["plane"]["opacity"],
      "transparent": true,
      "depthWrite": false,
    });
    fillPlane = three.Mesh(planeGeometry, fillPlaneMaterial);
    fillPlane.rotateX(three.Math.PI);
    shadowGroup.add(fillPlane);

    // the camera to render the depth material from
    shadowCamera =
        three.OrthographicCamera(-planeWidth / 2, planeWidth / 2, planeHeight / 2, -planeHeight / 2, 0, cameraHeight);
    shadowCamera.rotation.x = three.Math.PI / 2; // get the camera to look up
    shadowGroup.add(shadowCamera);

    cameraHelper = three.CameraHelper(shadowCamera);

    // like MeshDepthMaterial, but goes from black to transparent
    depthMaterial = three.MeshDepthMaterial();
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

    horizontalBlurMaterial = three.ShaderMaterial(three_jsm.HorizontalBlurShader);
    horizontalBlurMaterial.depthTest = false;

    verticalBlurMaterial = three.ShaderMaterial(three_jsm.VerticalBlurShader);
    verticalBlurMaterial.depthTest = false;

    inited = true;
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
