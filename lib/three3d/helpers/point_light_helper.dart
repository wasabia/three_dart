import 'package:three_dart/three3d/geometries/sphere_geometry.dart';
import 'package:three_dart/three3d/lights/index.dart';
import 'package:three_dart/three3d/materials/mesh_basic_material.dart';
import 'package:three_dart/three3d/math/color.dart';
import 'package:three_dart/three3d/objects/index.dart';

class PointLightHelper extends Mesh {
  late PointLight light;
  Color? color;

  PointLightHelper.create(geometry, material) : super(geometry, material) {
    type = "PointLightHelper";
  }

  factory PointLightHelper(light, sphereSize, Color color) {
    var geometry = SphereGeometry(sphereSize, 4, 2);
    var material = MeshBasicMaterial({"wireframe": true, "fog": false, "toneMapped": false});

    var plh = PointLightHelper.create(geometry, material);

    plh.light = light;
    plh.light.updateMatrixWorld(false);

    plh.color = color;
    plh.matrix = plh.light.matrixWorld;
    plh.matrixAutoUpdate = false;

    plh.update();
    return plh;

    /*
	// TODO: delete this comment?
	const distanceGeometry = new three.IcosahedronBufferGeometry( 1, 2 );
	const distanceMaterial = new three.MeshBasicMaterial( { color: hexColor, fog: false, wireframe: true, opacity: 0.1, transparent: true } );

	this.lightSphere = new three.Mesh( bulbGeometry, bulbMaterial );
	this.lightDistance = new three.Mesh( distanceGeometry, distanceMaterial );

	const d = light.distance;

	if ( d === 0.0 ) {

		this.lightDistance.visible = false;

	} else {

		this.lightDistance.scale.set( d, d, d );

	}

	this.add( this.lightDistance );
	*/
  }

  @override
  dispose() {
    geometry!.dispose();
    material.dispose();
  }

  update() {
    if (color != null) {
      material.color.set(color);
    } else {
      material.color.copy(light.color);
    }

    /*
		const d = this.light.distance;

		if ( d === 0.0 ) {

			this.lightDistance.visible = false;

		} else {

			this.lightDistance.visible = true;
			this.lightDistance.scale.set( d, d, d );

		}
		*/
  }
}
