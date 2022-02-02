import 'dart:async';

import 'package:example/TouchListener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;

class webgl_morphtargets_sphere extends StatefulWidget {
  String fileName;

  webgl_morphtargets_sphere({Key? key, required this.fileName}) : super(key: key);

  createState() => _State();
}

class _State extends State<webgl_morphtargets_sphere> {
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
  THREE.Clock clock = new THREE.Clock();
  THREE_JSM.OrbitControls? controls;

  num dpr = 1.0;

  var AMOUNT = 4;

  var sign = 1;
  var speed = 0.5;

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
    

    camera = new THREE.PerspectiveCamera( 45, width / height, 0.2, 100 );
    camera.position.set( 0, 5, 5 );

    scene = new THREE.Scene();

    camera.lookAt(scene.position);

    clock = new THREE.Clock();

    var light1 = new THREE.PointLight( 0xff2200, 0.7 );
    light1.position.set( 100, 100, 100 );
    scene.add( light1 );

    var light2 = new THREE.PointLight( 0x22ff00, 0.7 );
    light2.position.set( - 100, - 100, - 100 );
    scene.add( light2 );

    scene.add( new THREE.AmbientLight( 0x111111, 1 ) );

    var loader = new THREE_JSM.GLTFLoader(null);

    var gltf = await loader.loadAsync( 'assets/models/gltf/AnimatedMorphSphere/glTF/AnimatedMorphSphere.gltf');

    mesh = gltf["scene"].getObjectByName( 'AnimatedMorphSphere' );
    mesh.rotation.z = THREE.Math.PI / 2;
    scene.add( mesh );

    print(" load sucess mesh: ${mesh}  ");
    print( mesh.geometry!.morphAttributes );

    var _texture = await new THREE.TextureLoader(null).loadAsync( 'assets/textures/sprites/disc.png' );

    var pointsMaterial = new THREE.PointsMaterial( {
      "size": 10,
      "sizeAttenuation": false,
      "map": _texture,
      "alphaTest": 0.5
    } );

    var points = new THREE.Points( mesh.geometry!, pointsMaterial );
    points.morphTargetInfluences = mesh.morphTargetInfluences;
    points.morphTargetDictionary = mesh.morphTargetDictionary;
    mesh.add( points );



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

    if ( mesh != null ) {

      var step = delta * speed;

      mesh.rotation.y += step;

      print(" mesh.morphTargetInfluences: ${mesh.morphTargetInfluences} ");

      mesh.morphTargetInfluences![ 1 ] = mesh.morphTargetInfluences![ 1 ] + step * sign;

      if ( mesh.morphTargetInfluences![ 1 ] <= 0 || mesh.morphTargetInfluences![ 1 ] >= 1 ) {

        sign *= - 1;

      }

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
