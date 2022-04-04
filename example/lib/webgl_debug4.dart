import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;


class webgl_debug4 extends StatefulWidget {
  String fileName;

  webgl_debug4({Key? key, required this.fileName}) : super(key: key);

  @override
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

    if (verbose) print(" render: sourceTexture: $sourceTexture three3dRender.textureId! ${three3dRender.textureId!} ");

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
    camera = THREE.PerspectiveCamera(45, width / height, 1, 100);
    camera.position.z = 100;
    
    var segmentHeight = 8;
    var segmentCount = 4;
    var height2 = segmentHeight * segmentCount;
    var halfHeight = height2 * 0.5;

    Map<String, int> sizing = {
      "segmentHeight": segmentHeight,
      "segmentCount": segmentCount,
      "height": height2,
      "halfHeight": halfHeight.toInt()
    };

    scene = THREE.Scene();

    var ambientLight = THREE.AmbientLight(0xcccccc, 0.4);
    scene.add(ambientLight);

    camera.lookAt(scene.position);

    var geometry = new THREE.CylinderGeometry( 5, 5, 5, 5, 15, false, 5, 360 );

    // create the skin indices and skin weights manually
    // (typically a loader would read this data from a 3D model for you)

    var position = geometry.attributes["position"];

    var vertex = new THREE.Vector3();

    List<int> skinIndices = [];
    List<double> skinWeights = [];

    for ( var i = 0; i < position.count; i ++ ) {

      vertex.fromBufferAttribute( position, i );

      // compute skinIndex and skinWeight based on some configuration data

      var y = ( vertex.y + sizing["halfHeight"]! );

      var skinIndex = THREE.Math.floor( y / sizing["segmentHeight"]! );
      var skinWeight = ( y % sizing["segmentHeight"]! ) / sizing["segmentHeight"]!;

      skinIndices.addAll( [skinIndex, skinIndex + 1, 0, 0] );
      skinWeights.addAll( [1 - skinWeight, skinWeight, 0, 0] );

    }

    geometry.setAttribute( 'skinIndex', new THREE.Uint16BufferAttribute( Uint16Array.fromList(skinIndices), 4 ) );
    geometry.setAttribute( 'skinWeight', new THREE.Float32BufferAttribute( Float32Array.fromList(skinWeights), 4 ) );

    // create skinned mesh and skeleton

    var material = new THREE.MeshBasicMaterial( {
      "color": 0x156289,
      "side": THREE.DoubleSide,
      "flatShading": true
    } );

    List<THREE.Bone> bones = [];
    var prevBone = new THREE.Bone();
    bones.add( prevBone );
    prevBone.position.y = - sizing["halfHeight"]!.toDouble();

    for ( var i = 0; i < sizing["segmentCount"]!; i ++ ) {

      var bone = new THREE.Bone();
      bone.position.y = sizing["segmentHeight"]!.toDouble();
      bones.add( bone );
      prevBone.add( bone );
      prevBone = bone;

    }



    var mesh = new THREE.SkinnedMesh( geometry, material );
    var skeleton = new THREE.Skeleton( bones );


    var rootBone = skeleton.bones[ 0 ];
    mesh.add( rootBone );
    mesh.bind( skeleton );
    skeleton.bones[ 0 ].rotation.x = -0.1;
    skeleton.bones[ 1 ].rotation.x = 0.2;

    scene.add( mesh );

    loaded = true;

    animate();
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
