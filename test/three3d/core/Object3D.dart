import 'package:flutter_test/flutter_test.dart';
import 'package:three_dart/three_dart.dart';


void main() {
  test('Object3D test', () async {

    var raycaster = new Raycaster(null, null, null, null);
			
    var camera = new PerspectiveCamera( 45, 1, 1, 1000 );

    camera.position.set(10, 10, 40);

    var _p1 = Vector2(0.01, 0.01);

    raycaster.setFromCamera( _p1, camera );



    var _size = 5000;

    var geometry = new PlaneGeometry( _size, _size );
    var plane = new Mesh(
      geometry, 
      MeshBasicMaterial( { 
        "visible": true,
        "color": 0xff0000,
        "opacity": 0.5,
        "transparent": true
      } ) 
    );
  
    plane.name = "Main Plane";
    plane.rotateX( -Math.PI / 2.0 );

    plane.updateMatrixWorld(false);

    var fullObjects = [plane];

    var intersects = raycaster.intersectObjects( fullObjects, null );

    print( " intersects ................." );
    print(intersects);

    int i = 0;

    intersects.forEach((_intersect) {
      print(" i: ${i} ");
      i = i + 1;
      print(" _intersect point: ${_intersect.point.toJSON()} ");
      print("_intersect normal face ");
      print(_intersect.face.normal.toJSON());
    });


  });
}
