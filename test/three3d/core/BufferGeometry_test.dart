// ignore_for_file: unnecessary_new

import 'package:flutter_gl/native-array/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_dart/three/core/index.dart';
import 'package:three_dart/three/math/index.dart';

var DegToRad = Math.PI / 180;

bufferAttributeEquals(a, b, tolerance) {
  tolerance = tolerance ?? 0.0001;

  if (a.count != b.count || a.itemSize != b.itemSize) {
    return false;
  }

  for (var i = 0, il = a.count * a.itemSize; i < il; i++) {
    var delta = a.array[i] - b.array[i];
    if (delta > tolerance) {
      return false;
    }
  }

  return true;
}

getBBForVertices(vertices) {
  var geometry = new BufferGeometry();

  geometry.setAttribute('position', Float32BufferAttribute(new Float32Array(vertices), 3));
  geometry.computeBoundingBox();

  return geometry.boundingBox;
}

getBSForVertices(vertices) {
  var geometry = new BufferGeometry();

  geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array(vertices), 3));
  geometry.computeBoundingSphere();

  return geometry.boundingSphere;
}

getNormalsForVertices(vertices) {
  var geometry = new BufferGeometry();

  geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array(vertices), 3));

  geometry.computeVertexNormals();

  expect(geometry.attributes["normal"] != null, 'normal attribute was created');

  return geometry.attributes["normal"].array;
}

void main() {
  test('setIndex/getIndex', () {
    var a = new BufferGeometry();
    var uint16 = [1, 2, 3];
    var uint32 = [65535, 65536, 65537];
    var str = 'foo';

    a.setIndex(uint16);
    expect(a.getIndex() is Uint16BufferAttribute, true, reason: 'Index has the right type');
    expect(a.getIndex()!.array.toDartList(), new Uint16Array.from(uint16).toDartList(),
        reason: 'Small index gets stored correctly');

    a.setIndex(uint32);
    expect(a.getIndex() is Uint32BufferAttribute, true, reason: 'Index has the right type');
    expect(a.getIndex()!.array.toDartList(), new Uint32Array.from(uint32).toDartList(),
        reason: 'Large index gets stored correctly');

    // a.setIndex( str );
    // expect( a.getIndex(), str, reason: 'Weird index gets stored correctly' );
  });

  test('set / delete Attribute', () {
    var geometry = new BufferGeometry();
    var attributeName = 'position';

    expect(geometry.attributes[attributeName] == null, true, reason: 'no attribute defined');

    geometry.setAttribute(attributeName, new Float32BufferAttribute(Float32Array.from([1, 2, 3]), 1));

    expect(geometry.attributes[attributeName] != null, true, reason: 'attribute is defined');

    geometry.deleteAttribute(attributeName);

    expect(geometry.attributes[attributeName] == null, true, reason: 'no attribute defined');
  });

  test('addGroup', () {
    var a = new BufferGeometry();
    var expected = [
      {"start": 0, "count": 1, "materialIndex": 0},
      {"start": 1, "count": 2, "materialIndex": 2}
    ];

    a.addGroup(0, 1, 0);
    a.addGroup(1, 2, 2);

    expect(a.groups, expected, reason: 'Check groups were stored correctly and in order');

    a.clearGroups();
    expect(a.groups.length, 0, reason: 'Check groups were deleted correctly');
  });
  test('setDrawRange', () {
    var a = new BufferGeometry();

    a.setDrawRange(1, 7);

    expect(a.drawRange, {"start": 1, "count": 7}, reason: 'Check draw range was stored correctly');
  });

  test('applyMatrix4', () {
    var geometry = new BufferGeometry();
    geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array(6), 3));

    var matrix = new Matrix4().set(1, 0, 0, 1.5, 0, 1, 0, -2, 0, 0, 1, 3, 0, 0, 0, 1);
    geometry.applyMatrix4(matrix);

    var position = geometry.attributes["position"].array;
    var m = matrix.elements;
    expect(position[0] == m[12] && position[1] == m[13] && position[2] == m[14], true,
        reason: 'position was extracted from matrix');
    expect(position[3] == m[12] && position[4] == m[13] && position[5] == m[14], true,
        reason: 'position was extracted from matrix twice');
    expect(geometry.attributes["position"].version == 1, true, reason: 'version was increased during update');
  });

  test('applyQuaternion', () {
    var geometry = new BufferGeometry();
    geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array.from([1, 2, 3, 4, 5, 6]), 3));

    var q = new Quaternion(0.5, 0.5, 0.5, 0.5);
    geometry.applyQuaternion(q);

    var pos = geometry.attributes["position"].array;

    // geometry was rotated around the (1, 1, 1) axis.
    expect(pos[0] == 3 && pos[1] == 1 && pos[2] == 2 && pos[3] == 6 && pos[4] == 4 && pos[5] == 5, true,
        reason: 'vertices were rotated properly');
  });

  test('rotateX/Y/Z', () {
    var geometry = new BufferGeometry();
    geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array.from([1, 2, 3, 4, 5, 6]), 3));

    var pos = geometry.attributes["position"].array;

    geometry.rotateX(180 * DegToRad);

    // object was rotated around x so all items should be flipped but the x ones
    expect(pos[0] == 1 && pos[1] == -2 && pos[2] == -3 && pos[3] == 4 && pos[4] == -5 && pos[5] == -6, true,
        reason: 'vertices were rotated around x by 180 degrees');

    geometry.rotateY(180 * DegToRad);

    // vertices were rotated around y so all items should be flipped again but the y ones
    expect(pos[0] == -1 && pos[1] == -2 && pos[2] == 3 && pos[3] == -4 && pos[4] == -5 && pos[5] == 6, true,
        reason: 'vertices were rotated around y by 180 degrees');

    geometry.rotateZ(180 * DegToRad);

    // vertices were rotated around z so all items should be flipped again but the z ones
    expect(pos[0] == 1 && pos[1] == 2 && pos[2] == 3 && pos[3] == 4 && pos[4] == 5 && pos[5] == 6, true,
        reason: 'vertices were rotated around z by 180 degrees');
  });

  test('translate', () {
    var geometry = new BufferGeometry();
    geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array.from([1, 2, 3, 4, 5, 6]), 3));

    var pos = geometry.attributes["position"].array;

    geometry.translate(10, 20, 30);

    expect(pos[0] == 11 && pos[1] == 22 && pos[2] == 33 && pos[3] == 14 && pos[4] == 25 && pos[5] == 36, true,
        reason: 'vertices were translated');
  });

  test('scale', () {
    var geometry = new BufferGeometry();
    geometry.setAttribute('position', new Float32BufferAttribute(new Float32Array.from([-1, -1, -1, 2, 2, 2]), 3));

    var pos = geometry.attributes["position"].array;

    geometry.scale(1, 2, 3);

    expect(pos[0] == -1 && pos[1] == -2 && pos[2] == -3 && pos[3] == 2 && pos[4] == 4 && pos[5] == 6, true,
        reason: 'vertices were scaled');
  });

  // test( 'lookAt', () {

  // 	var a = new BufferGeometry();
  // 	var vertices = new Float32Array.from( [
  // 		- 1.0, - 1.0, 1.0,
  // 		1.0, - 1.0, 1.0,
  // 		1.0, 1.0, 1.0,

  // 		1.0, 1.0, 1.0,
  // 		- 1.0, 1.0, 1.0,
  // 		- 1.0, - 1.0, 1.0
  // 	] );
  // 	a.setAttribute( 'position', new Float32BufferAttribute( vertices, 3 ) );

  // 	var sqrt = Math.sqrt( 2 );
  // 	var expected = new Float32Array.from( [
  // 		1, 0, - sqrt,
  // 		- 1, 0, - sqrt,
  // 		- 1, sqrt, 0,

  // 		- 1, sqrt, 0,
  // 		1, sqrt, 0,
  // 		1, 0, - sqrt
  // 	] );

  // 	a.lookAt( new Vector3( 0, 1, - 1 ) );

  // 	expect( bufferAttributeEquals( a.attributes.position.array, expected ), 'Rotation is correct' );

  // } );

  // test( 'center', () {

  // 	var geometry = new BufferGeometry();
  // 	geometry.setAttribute( 'position', new Float32BufferAttribute( new Float32Array.from( [
  // 		- 1, - 1, - 1,
  // 		1, 1, 1,
  // 		4, 4, 4
  // 	] ), 3 ) );

  // 	geometry.center();

  // 	var pos = geometry.attributes["position"].array;

  // 	// the boundingBox should go from (-1, -1, -1) to (4, 4, 4) so it has a size of (5, 5, 5)
  // 	// after centering it the vertices should be placed between (-2.5, -2.5, -2.5) and (2.5, 2.5, 2.5)
  // 	expect( pos[ 0 ] == - 2.5 && pos[ 1 ] == - 2.5 && pos[ 2 ] == - 2.5 &&
  // 		pos[ 3 ] == - 0.5 && pos[ 4 ] == - 0.5 && pos[ 5 ] == - 0.5 &&
  // 		pos[ 6 ] == 2.5 && pos[ 7 ] == 2.5 && pos[ 8 ] == 2.5, 'vertices were replaced by boundingBox dimensions' );

  // } );

  // test( 'computeBoundingBox', () {

  // 	var bb = getBBForVertices( [ - 1, - 2, - 3, 13, - 2, - 3.5, - 1, - 20, 0, - 4, 5, 6 ] );

  // 	expect( bb.min.x == - 4 && bb.min.y == - 20 && bb.min.z == - 3.5, 'min values are set correctly' );
  // 	expect( bb.max.x == 13 && bb.max.y == 5 && bb.max.z == 6, 'max values are set correctly' );

  // 	var bb = getBBForVertices( [ - 1, - 1, - 1 ] );

  // 	expect( bb.min.x == bb.max.x && bb.min.y == bb.max.y && bb.min.z == bb.max.z, 'since there is only one vertex, max and min are equal' );
  // 	expect( bb.min.x == - 1 && bb.min.y == - 1 && bb.min.z == - 1, 'since there is only one vertex, min and max are this vertex' );

  // } );

  // test( 'computeBoundingSphere', () {

  // 	var bs = getBSForVertices( [ - 10, 0, 0, 10, 0, 0 ] );

  // 	expect( bs.radius == 10, 'radius is equal to deltaMinMax / 2' );
  // 	expect( bs.center.x == 0 && bs.center.y == 0 && bs.center.y == 0, 'bounding sphere is at ( 0, 0, 0 )' );

  // 	var bs = getBSForVertices( [ - 5, 11, - 3, 5, - 11, 3 ] );
  // 	var radius = new Vector3( 5, 11, 3 ).length();

  // 	expect( bs.radius == radius, 'radius is equal to directionLength' );
  // 	expect( bs.center.x == 0 && bs.center.y == 0 && bs.center.y == 0, 'bounding sphere is at ( 0, 0, 0 )' );

  // } );

  // test( 'computeVertexNormals', () {

  // 	// get normals for a counter clockwise created triangle
  // 	var normals = getNormalsForVertices( [ - 1, 0, 0, 1, 0, 0, 0, 1, 0 ] );

  // 	expect( normals[ 0 ] == 0 && normals[ 1 ] == 0 && normals[ 2 ] == 1,
  // 		'first normal is pointing to screen since the the triangle was created counter clockwise' );

  // 	expect( normals[ 3 ] == 0 && normals[ 4 ] == 0 && normals[ 5 ] == 1,
  // 		'second normal is pointing to screen since the the triangle was created counter clockwise' );

  // 	expect( normals[ 6 ] == 0 && normals[ 7 ] == 0 && normals[ 8 ] == 1,
  // 		'third normal is pointing to screen since the the triangle was created counter clockwise' );

  // 	// get normals for a clockwise created triangle
  // 	var normals = getNormalsForVertices( [ 1, 0, 0, - 1, 0, 0, 0, 1, 0 ] );

  // 	expect( normals[ 0 ] == 0 && normals[ 1 ] == 0 && normals[ 2 ] == - 1,
  // 		'first normal is pointing to screen since the the triangle was created clockwise' );

  // 	expect( normals[ 3 ] == 0 && normals[ 4 ] == 0 && normals[ 5 ] == - 1,
  // 		'second normal is pointing to screen since the the triangle was created clockwise' );

  // 	expect( normals[ 6 ] == 0 && normals[ 7 ] == 0 && normals[ 8 ] == - 1,
  // 		'third normal is pointing to screen since the the triangle was created clockwise' );

  // 	var normals = getNormalsForVertices( [ 0, 0, 1, 0, 0, - 1, 1, 1, 0 ] );

  // 	// the triangle is rotated by 45 degrees to the right so the normals of the three vertices
  // 	// should point to (1, -1, 0).normalized(). The simplest solution is to check against a normalized
  // 	// vector (1, -1, 0) but you will get calculation errors because of floating calculations so another
  // 	// valid technique is to create a vector which stands in 90 degrees to the normals and calculate the
  // 	// dot product which is the cos of the angle between them. This should be < floating calculation error
  // 	// which can be taken from Number.EPSILON
  // 	var direction = new Vector3( 1, 1, 0 ).normalize(); // a vector which should have 90 degrees difference to normals
  // 	var difference = direction.dot( new Vector3( normals[ 0 ], normals[ 1 ], normals[ 2 ] ) );
  // 	expect( difference < Number.EPSILON, 'normal is equal to reference vector' );

  // 	// get normals for a line should be NAN because you need min a triangle to calculate normals
  // 	var normals = getNormalsForVertices( [ 1, 0, 0, - 1, 0, 0 ] );
  // 	for ( var i = 0; i < normals.length; i ++ ) {

  // 		expect( ! normals[ i ], 'normals can\'t be calculated which is good' );

  // 	}

  // } );
  // test( 'computeVertexNormals (indexed)', () {

  // 	var sqrt = 0.5 * Math.sqrt( 2 );
  // 	var normal = new Float32BufferAttribute( new Float32Array.from( [
  // 		- 1, 0, 0, - 1, 0, 0, - 1, 0, 0,
  // 		sqrt, sqrt, 0, sqrt, sqrt, 0, sqrt, sqrt, 0,
  // 		- 1, 0, 0
  // 	] ), 3 );
  // 	var position = new Float32BufferAttribute( new Float32Array.from( [
  // 		0.5, 0.5, 0.5, 0.5, 0.5, - 0.5, 0.5, - 0.5, 0.5,
  // 		0.5, - 0.5, - 0.5, - 0.5, 0.5, - 0.5, - 0.5, 0.5, 0.5,
  // 		- 0.5, - 0.5, - 0.5
  // 	] ), 3 );
  // 	var index = new Uint16BufferAttribute( new Uint16Array.from( [
  // 		0, 2, 1, 2, 3, 1, 4, 6, 5, 6, 7, 5
  // 	] ), 1 );

  // 	var a = new BufferGeometry();
  // 	a.setAttribute( 'position', position );
  // 	a.computeVertexNormals();
  // 	expect(
  // 		bufferAttributeEquals( normal, a.getAttribute( 'normal' ) ),
  // 		'Regular geometry: first computed normals are correct'
  // 	);

  // 	// a second time to see if the existing normals get properly deleted
  // 	a.computeVertexNormals();
  // 	expect(
  // 		bufferAttributeEquals( normal, a.getAttribute( 'normal' ) ),
  // 		'Regular geometry: second computed normals are correct'
  // 	);

  // 	// indexed geometry
  // 	var a = new BufferGeometry();
  // 	a.setAttribute( 'position', position );
  // 	a.setIndex( index );
  // 	a.computeVertexNormals();
  // 	expect( bufferAttributeEquals( normal, a.getAttribute( 'normal' ) ), 'Indexed geometry: computed normals are correct' );

  // } );

  // test( 'merge', () {

  // 	var geometry1 = new BufferGeometry();
  // 	geometry1.setAttribute( 'attrName', new Float32BufferAttribute( new Float32Array( [ 1, 2, 3, 0, 0, 0 ] ), 3 ) );

  // 	var geometry2 = new BufferGeometry();
  // 	geometry2.setAttribute( 'attrName', new Float32BufferAttribute( new Float32Array( [ 4, 5, 6 ] ), 3 ) );

  // 	var attr = geometry1.attributes.attrName.array;

  // 	geometry1.merge( geometry2, 1 );

  // 	// merged array should be 1, 2, 3, 4, 5, 6
  // 	for ( var i = 0; i < attr.length; i ++ ) {

  // 		expect( attr[ i ] == i + 1, '' );

  // 	}

  // 	console.level = CONSOLE_LEVEL.ERROR;
  // 	geometry1.merge( geometry2 );
  // 	console.level = CONSOLE_LEVEL.DEFAULT;

  // 	expect( attr[ 0 ] == 4 && attr[ 1 ] == 5 && attr[ 2 ] == 6, 'copied the 3 attributes without offset' );

  // } );

  // test( 'normalizeNormals', () {

  // 	expect( false, 'everything\'s gonna be alright' );

  // } );

  // test( 'toNonIndexed', () {

  // 	var geometry = new BufferGeometry();
  // 	var vertices = new Float32Array( [
  // 		0.5, 0.5, 0.5, 0.5, 0.5, - 0.5, 0.5, - 0.5, 0.5, 0.5, - 0.5, - 0.5
  // 	] );
  // 	var index = new Float32BufferAttribute( new Uint16Array( [ 0, 2, 1, 2, 3, 1 ] ) );
  // 	var expected = new Float32Array( [
  // 		0.5, 0.5, 0.5, 0.5, - 0.5, 0.5, 0.5, 0.5, - 0.5,
  // 		0.5, - 0.5, 0.5, 0.5, - 0.5, - 0.5, 0.5, 0.5, - 0.5
  // 	] );

  // 	geometry.setAttribute( 'position', new Float32BufferAttribute( vertices, 3 ) );
  // 	geometry.setIndex( index );

  // 	var nonIndexed = geometry.toNonIndexed();

  // 	expect( nonIndexed.getAttribute( 'position' ).array, expected, 'Expected vertices' );

  // } );

  // test( 'toJSON', () {

  // 	var index = new Float32BufferAttribute( new Uint16Array( [ 0, 1, 2, 3 ] ), 1 );
  // 	var attribute1 = new Float32BufferAttribute( new Uint16Array( [ 1, 3, 5, 7 ] ), 1 );
  // 	attribute1.name = 'attribute1';
  // 	var a = new BufferGeometry();
  // 	a.name = 'JSONtest';
  // 	// a.parameters = { "placeholder": 0 };
  // 	a.setAttribute( 'attribute1', attribute1 );
  // 	a.setIndex( index );
  // 	a.addGroup( 0, 1, 2 );
  // 	a.boundingSphere = new Sphere( new Vector3( x, y, z ), 0.5 );
  // 	var j = a.toJSON();
  // 	var gold = {
  // 		'metadata': {
  // 			'version': 4.5,
  // 			'type': 'BufferGeometry',
  // 			'generator': 'BufferGeometry.toJSON'
  // 		},
  // 		'uuid': a.uuid,
  // 		'type': 'BufferGeometry',
  // 		'name': 'JSONtest',
  // 		'data': {
  // 			'attributes': {
  // 				'attribute1': {
  // 					'itemSize': 1,
  // 					'type': 'Uint16Array',
  // 					'array': [ 1, 3, 5, 7 ],
  // 					'normalized': false,
  // 					'name': 'attribute1'
  // 				}
  // 			},
  // 			'index': {
  // 				'type': 'Uint16Array',
  // 				'array': [ 0, 1, 2, 3 ]
  // 			},
  // 			'groups': [
  // 				{
  // 					'start': 0,
  // 					'count': 1,
  // 					'materialIndex': 2
  // 				}
  // 			],
  // 			'boundingSphere': {
  // 				'center': [ 2, 3, 4 ],
  // 				'radius': 0.5
  // 			}
  // 		}
  // 	};

  // 	expect( j, gold, reason: 'Generated JSON is as expected' );

  // 	// add morphAttributes
  // 	a.morphAttributes["attribute1"] = [];
  // 	a.morphAttributes["attribute1"].push( attribute1.clone() );
  // 	j = a.toJSON();
  // 	gold["data"]["morphAttributes"] = {
  // 		'attribute1': [ {
  // 			'itemSize': 1,
  // 			'type': 'Uint16Array',
  // 			'array': [ 1, 3, 5, 7 ],
  // 			'normalized': false,
  // 			'name': 'attribute1'
  // 		} ]
  // 	};
  // 	gold["data"]["morphTargetsRelative"] = false;

  // 	expect( j, gold, 'Generated JSON with morphAttributes is as expected' );

  // } );

  test('clone', () {
    var a = BufferGeometry();
    a.setAttribute('attribute1', Float32BufferAttribute(Float32Array.from([1, 2, 3, 4, 5, 6]), 3));
    a.setAttribute('attribute2', Float32BufferAttribute(Float32Array.from([0, 1, 3, 5, 6]), 1));
    a.addGroup(0, 1, 2);
    a.computeBoundingBox();
    a.computeBoundingSphere();
    a.setDrawRange(0, 1);
    var b = a.clone();

    expect(a == b, false, reason: 'A new object was created');
    expect(a.id == b.id, false, reason: 'New object has a different GUID');

    expect(a.attributes.keys.length, b.attributes.keys.length,
        reason: 'Both objects have the same amount of attributes');
    // expect(
    // 	bufferAttributeEquals( a.getAttribute( 'attribute1' ), b.getAttribute( 'attribute1' ), null ),
    // 	true, reason: 'First attributes buffer is identical'
    // );
    // expect(
    // 	bufferAttributeEquals( a.getAttribute( 'attribute2' ), b.getAttribute( 'attribute2' ), null ),
    // 	true, reason: 'Second attributes buffer is identical'
    // );

    // expect( a.groups == b.groups, true, reason: 'Groups are identical' );

    expect(a.boundingBox!.equals(b.boundingBox!), true, reason: 'BoundingBoxes are equal');
    expect(a.boundingSphere!.equals(b.boundingSphere!), true, reason: 'BoundingSpheres are equal');

    expect(a.drawRange["start"] == b.drawRange["start"], true, reason: 'DrawRange start is identical');
    expect(a.drawRange["count"] == b.drawRange["count"], true, reason: 'DrawRange count is identical');
  });

  test('copy', () {
    var geometry = new BufferGeometry();
    geometry.setAttribute('attrName', new Float32BufferAttribute(new Float32Array.from([1, 2, 3, 4, 5, 6]), 3));
    geometry.setAttribute('attrName2', new Float32BufferAttribute(new Float32Array.from([0, 1, 3, 5, 6]), 1));

    var copy = new BufferGeometry().copy(geometry);

    expect(copy != geometry && geometry.id != copy.id, true, reason: 'new object was created');

    for (var key in geometry.attributes.keys) {
      var attribute = geometry.attributes[key];
      expect(attribute != null, true, reason: 'all attributes where copied');

      for (var i = 0; i < attribute.array.length; i++) {
        expect(attribute.array[i] == copy.attributes[key].array[i], true, reason: 'values of the attribute are equal');
      }
    }
  });
}
