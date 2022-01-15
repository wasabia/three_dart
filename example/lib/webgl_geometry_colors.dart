import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_geometry_colors extends StatefulWidget {
  String fileName;
  webgl_geometry_colors({Key? key, required this.fileName}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_geometry_colors> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.PointLight pointLight;

  var objects = [], materials = [];

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
    
    camera = new THREE.PerspectiveCamera( 20, width / height, 1, 10000 );
    camera.position.z = 1800;

    scene = new THREE.Scene();
    scene.background = THREE.Color.fromHex( 0xffffff );

    var light = new THREE.DirectionalLight( 0xffffff );
    light.position.set( 0, 0, 1 );
    scene.add( light );

    // shadow

    // var canvas = document.createElement( 'canvas' );
    // canvas.width = 128;
    // canvas.height = 128;

    // var context = canvas.getContext( '2d' );
    // var gradient = context.createRadialGradient( canvas.width / 2, canvas.height / 2, 0, canvas.width / 2, canvas.height / 2, canvas.width / 2 );
    // gradient.addColorStop( 0.1, 'rgba(210,210,210,1)' );
    // gradient.addColorStop( 1, 'rgba(255,255,255,1)' );

    // context.fillStyle = gradient;
    // context.fillRect( 0, 0, canvas.width, canvas.height );

    // var shadowTexture = new THREE.CanvasTexture( canvas );

    var shadowMaterial = new THREE.MeshBasicMaterial( {  } );
    var shadowGeo = new THREE.PlaneGeometry( 300, 300, 1, 1 );

    var shadowMesh;

    shadowMesh = new THREE.Mesh( shadowGeo, shadowMaterial );
    shadowMesh.position.y = - 250;
    shadowMesh.rotation.x = - THREE.Math.PI / 2;
    scene.add( shadowMesh );

    shadowMesh = new THREE.Mesh( shadowGeo, shadowMaterial );
    shadowMesh.position.y = - 250;
    shadowMesh.position.x = - 400;
    shadowMesh.rotation.x = - THREE.Math.PI / 2;
    scene.add( shadowMesh );

    shadowMesh = new THREE.Mesh( shadowGeo, shadowMaterial );
    shadowMesh.position.y = - 250;
    shadowMesh.position.x = 400;
    shadowMesh.rotation.x = - THREE.Math.PI / 2;
    scene.add( shadowMesh );

    var radius = 200;

    var geometry1 = new THREE.IcosahedronGeometry( radius, 1 );

    var count = geometry1.attributes["position"].count;
    geometry1.setAttribute( 'color', new THREE.Float32BufferAttribute( new Float32Array( count * 3 ), 3 ) );

    var geometry2 = geometry1.clone();
    var geometry3 = geometry1.clone();

    var color = new THREE.Color(1,1,1);
    var positions1 = geometry1.attributes["position"];
    var positions2 = geometry2.attributes["position"];
    var positions3 = geometry3.attributes["position"];
    var colors1 = geometry1.attributes["color"];
    var colors2 = geometry2.attributes["color"];
    var colors3 = geometry3.attributes["color"];

    for ( var i = 0; i < count; i ++ ) {

      color.setHSL( ( positions1.getY( i ) / radius + 1 ) / 2, 1.0, 0.5 );
      colors1.setXYZ( i, color.r, color.g, color.b );

      color.setHSL( 0, ( positions2.getY( i ) / radius + 1 ) / 2, 0.5 );
      colors2.setXYZ( i, color.r, color.g, color.b );

      color.setRGB( 1, 0.8 - ( positions3.getY( i ) / radius + 1 ) / 2, 0 );
      colors3.setXYZ( i, color.r, color.g, color.b );

    }

    var material = new THREE.MeshPhongMaterial( {
      "color": 0xffffff,
      "flatShading": true,
      "vertexColors": true,
      "shininess": 0
    } );

    var wireframeMaterial = new THREE.MeshBasicMaterial( { 
      "color": 0x000000, "wireframe": true, "transparent": true 
    } );

    var mesh = new THREE.Mesh( geometry1, material );
    var wireframe = new THREE.Mesh( geometry1, wireframeMaterial );
    mesh.add( wireframe );
    mesh.position.x = - 400;
    mesh.rotation.x = - 1.87;
    scene.add( mesh );

    mesh = new THREE.Mesh( geometry2, material );
    wireframe = new THREE.Mesh( geometry2, wireframeMaterial );
    mesh.add( wireframe );
    mesh.position.x = 400;
    scene.add( mesh );

    mesh = new THREE.Mesh( geometry3, material );
    wireframe = new THREE.Mesh( geometry3, wireframeMaterial );
    mesh.add( wireframe );
    scene.add( mesh );


    // scene.overrideMaterial = new THREE.MeshBasicMaterial();

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
      pixels[i + 3] = THREE.Math.floor(x ^ y);
    }

    return THREE.ImageElement(data: pixels, width: 256, height: 256);
  }

  addMesh(geometry, material) {
    var mesh = new THREE.Mesh(geometry, material);

    mesh.position.x = (objects.length % 4) * 200 - 400;
    mesh.position.z = THREE.Math.floor(objects.length / 4) * 200 - 200;

    mesh.rotation.x = THREE.Math.random() * 200 - 100;
    mesh.rotation.y = THREE.Math.random() * 200 - 100;
    mesh.rotation.z = THREE.Math.random() * 200 - 100;

    objects.add(mesh);

    scene.add(mesh);
  }

  animate() {
    print("before animate render mounted: ${mounted} loaded: ${loaded}");

    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    print(" animate render ");

    var delta = clock.getDelta();


    render();

    // 30FPS
    Future.delayed(Duration(milliseconds: 33), () {
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
