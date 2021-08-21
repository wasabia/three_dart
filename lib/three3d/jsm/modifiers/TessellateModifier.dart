part of jsm_modifiers;


/**
 * Break faces with edges longer than maxEdgeLength
 */

class TessellateModifier {

  num maxEdgeLength = 0.1;
  num maxIterations = 6.0;
  num maxFaces = double.infinity;

  TessellateModifier( {maxEdgeLength = 0.1, maxIterations = 6, maxFaces = double.infinity} ) {
    this.maxEdgeLength = maxEdgeLength;
    this.maxIterations = maxIterations;
    this.maxFaces = maxFaces;
  }


  modify( BufferGeometry geometry ) {

		if ( geometry.index != null ) {

			geometry = geometry.toNonIndexed();

		}

		//

		var maxIterations = this.maxIterations;
		var maxEdgeLengthSquared = this.maxEdgeLength * this.maxEdgeLength;

		var va = new Vector3.init();
		var vb = new Vector3.init();
		var vc = new Vector3.init();
		var vm = new Vector3.init();
		var vs = [ va, vb, vc, vm ];

		var na = new Vector3.init();
		var nb = new Vector3.init();
		var nc = new Vector3.init();
		var nm = new Vector3.init();
		var ns = [ na, nb, nc, nm ];

		var ca = new Color(1,1,1);
		var cb = new Color(1,1,1);
		var cc = new Color(1,1,1);
		var cm = new Color(1,1,1);
		var cs = [ ca, cb, cc, cm ];

		var ua = new Vector2(null, null);
		var ub = new Vector2(null, null);
		var uc = new Vector2(null, null);
		var um = new Vector2(null, null);
		var us = [ ua, ub, uc, um ];

		var u2a = new Vector2(null, null);
		var u2b = new Vector2(null, null);
		var u2c = new Vector2(null, null);
		var u2m = new Vector2(null, null);
		var u2s = [ u2a, u2b, u2c, u2m ];

		var attributes = geometry.attributes;
		var hasNormals = attributes["normal"] != null;
		var hasColors = attributes["color"] != null;
		var hasUVs = attributes["uv"] != null;
		var hasUV2s = attributes["uv2"] != null;

		var positions = attributes["position"].array;
		var normals = hasNormals ? attributes["normal"].array : null;
		var colors = hasColors ? attributes["color"].array : null;
		var uvs = hasUVs ? attributes["uv"].array : null;
		var uv2s = hasUV2s ? attributes["uv2"].array : null;

		var positions2 = positions;
		var normals2 = normals;
		var colors2 = colors;
		var uvs2 = uvs;
		var uv2s2 = uv2s;

		var iteration = 0;
		var tessellating = true;

		Function addTriangle = ( a, b, c ) {

			var v1 = vs[ a ];
			var v2 = vs[ b ];
			var v3 = vs[ c ];

			positions2.push( v1.x, v1.y, v1.z );
			positions2.push( v2.x, v2.y, v2.z );
			positions2.push( v3.x, v3.y, v3.z );

			if ( hasNormals ) {

				var n1 = ns[ a ];
				var n2 = ns[ b ];
				var n3 = ns[ c ];

				normals2.push( n1.x, n1.y, n1.z );
				normals2.push( n2.x, n2.y, n2.z );
				normals2.push( n3.x, n3.y, n3.z );

			}

			if ( hasColors ) {

				var c1 = cs[ a ];
				var c2 = cs[ b ];
				var c3 = cs[ c ];

				colors2.push( c1.r, c1.g, c1.b );
				colors2.push( c2.r, c2.g, c2.b );
				colors2.push( c3.r, c3.g, c3.b );

			}

			if ( hasUVs ) {

				var u1 = us[ a ];
				var u2 = us[ b ];
				var u3 = us[ c ];

				uvs2.push( u1.x, u1.y );
				uvs2.push( u2.x, u2.y );
				uvs2.push( u3.x, u3.y );

			}

			if ( hasUV2s ) {

				var u21 = u2s[ a ];
				var u22 = u2s[ b ];
				var u23 = u2s[ c ];

				uv2s2.push( u21.x, u21.y );
				uv2s2.push( u22.x, u22.y );
				uv2s2.push( u23.x, u23.y );

			}

		};

		while ( tessellating && iteration < maxIterations ) {

			iteration ++;
			tessellating = false;

			positions = positions2;
			positions2 = [];

			if ( hasNormals ) {

				normals = normals2;
				normals2 = [];

			}

			if ( hasColors ) {

				colors = colors2;
				colors2 = [];

			}

			if ( hasUVs ) {

				uvs = uvs2;
				uvs2 = [];

			}

			if ( hasUV2s ) {

				uv2s = uv2s2;
				uv2s2 = [];

			}

			for ( var i = 0, i2 = 0, il = positions.length; i < il; i += 9, i2 += 6 ) {

				va.fromArray( positions, offset: i + 0 );
				vb.fromArray( positions, offset: i + 3 );
				vc.fromArray( positions, offset: i + 6 );

				if ( hasNormals ) {

					na.fromArray( normals, offset: i + 0 );
					nb.fromArray( normals, offset: i + 3 );
					nc.fromArray( normals, offset: i + 6 );

				}

				if ( hasColors ) {

					ca.fromArray( colors, offset: i + 0 );
					cb.fromArray( colors, offset: i + 3 );
					cc.fromArray( colors, offset: i + 6 );

				}

				if ( hasUVs ) {

					ua.fromArray( uvs, offset: i2 + 0 );
					ub.fromArray( uvs, offset: i2 + 2 );
					uc.fromArray( uvs, offset: i2 + 4 );

				}

				if ( hasUV2s ) {

					u2a.fromArray( uv2s, offset: i2 + 0 );
					u2b.fromArray( uv2s, offset: i2 + 2 );
					u2c.fromArray( uv2s, offset: i2 + 4 );

				}

				var dab = va.distanceToSquared( vb );
				var dbc = vb.distanceToSquared( vc );
				var dac = va.distanceToSquared( vc );

				if ( dab > maxEdgeLengthSquared || dbc > maxEdgeLengthSquared || dac > maxEdgeLengthSquared ) {

					tessellating = true;

					if ( dab >= dbc && dab >= dac ) {

						vm.lerpVectors( va, vb, 0.5 );
						if ( hasNormals ) nm.lerpVectors( na, nb, 0.5 );
						if ( hasColors ) cm.lerpColors( ca, cb, 0.5 );
						if ( hasUVs ) um.lerpVectors( ua, ub, 0.5 );
						if ( hasUV2s ) u2m.lerpVectors( u2a, u2b, 0.5 );

						addTriangle( 0, 3, 2 );
						addTriangle( 3, 1, 2 );

					} else if ( dbc >= dab && dbc >= dac ) {

						vm.lerpVectors( vb, vc, 0.5 );
						if ( hasNormals ) nm.lerpVectors( nb, nc, 0.5 );
						if ( hasColors ) cm.lerpColors( cb, cc, 0.5 );
						if ( hasUVs ) um.lerpVectors( ub, uc, 0.5 );
						if ( hasUV2s ) u2m.lerpVectors( u2b, u2c, 0.5 );

						addTriangle( 0, 1, 3 );
						addTriangle( 3, 2, 0 );

					} else {

						vm.lerpVectors( va, vc, 0.5 );
						if ( hasNormals ) nm.lerpVectors( na, nc, 0.5 );
						if ( hasColors ) cm.lerpColors( ca, cc, 0.5 );
						if ( hasUVs ) um.lerpVectors( ua, uc, 0.5 );
						if ( hasUV2s ) u2m.lerpVectors( u2a, u2c, 0.5 );

						addTriangle( 0, 1, 3 );
						addTriangle( 3, 1, 2 );

					}

				} else {

					addTriangle( 0, 1, 2 );

				}

			}

		}

		var geometry2 = new BufferGeometry();

		geometry2.setAttribute( 'position', new Float32BufferAttribute( positions2, 3, false ) );

		if ( hasNormals ) {

			geometry2.setAttribute( 'normal', new Float32BufferAttribute( normals2, 3, false ) );

		}

		if ( hasColors ) {

			geometry2.setAttribute( 'color', new Float32BufferAttribute( colors2, 3, false ) );

		}

		if ( hasUVs ) {

			geometry2.setAttribute( 'uv', new Float32BufferAttribute( uvs2, 2, false ) );

		}

		if ( hasUV2s ) {

			geometry2.setAttribute( 'uv2', new Float32BufferAttribute( uv2s2, 2, false ) );

		}

		return geometry2;

	}

  
  // Applies the "modify" pattern
  // modify( geometry ) {

  //   var isBufferGeometry = geometry.isBufferGeometry;

  //   if ( isBufferGeometry ) {

  //     geometry = new Geometry().fromBufferGeometry( geometry );

  //   } else {

  //     geometry = geometry.clone();

  //   }

  //   geometry.mergeVertices( precisionPoints: 6 );

  //   var finalized = false;
  //   var iteration = 0;
  //   var maxEdgeLengthSquared = this.maxEdgeLength * this.maxEdgeLength;

  //   var edge;

  //   while ( ! finalized && iteration < this.maxIterations && geometry.faces.length < this.maxFaces ) {

  //     List<Face3> faces = [];
  //     List<List<List<Vector2>>> faceVertexUvs = [];

  //     finalized = true;
  //     iteration ++;

  //     for ( var i = 0, il = geometry.faceVertexUvs.length; i < il; i ++ ) {
  //       faceVertexUvs.add([]);
  //     }

  //     for ( var i = 0, il = geometry.faces.length; i < il; i ++ ) {

  //       var face = geometry.faces[ i ];

  //       if ( face is Face3 ) {

  //         var a = face.a;
  //         var b = face.b;
  //         var c = face.c;

  //         var va = geometry.vertices[ a ];
  //         var vb = geometry.vertices[ b ];
  //         var vc = geometry.vertices[ c ];

  //         var dab = va.distanceToSquared( vb );
  //         var dbc = vb.distanceToSquared( vc );
  //         var dac = va.distanceToSquared( vc );

  //         var limitReached = ( faces.length + il - i ) >= this.maxFaces;

  //         var vm;

  //         if ( ! limitReached && ( dab > maxEdgeLengthSquared || dbc > maxEdgeLengthSquared || dac > maxEdgeLengthSquared ) ) {

  //           finalized = false;

  //           var m = geometry.vertices.length;

  //           var triA = face.clone();
  //           var triB = face.clone();

  //           if ( dab >= dbc && dab >= dac ) {

  //             vm = va.clone();
  //             vm.lerp( vb, 0.5 );

  //             triA.a = a;
  //             triA.b = m;
  //             triA.c = c;

  //             triB.a = m;
  //             triB.b = b;
  //             triB.c = c;

  //             if ( face.vertexNormals.length == 3 ) {

  //               var vnm = face.vertexNormals[ 0 ].clone();
  //               vnm.lerp( face.vertexNormals[ 1 ], 0.5 );

  //               triA.vertexNormals[ 1 ].copy( vnm );
  //               triB.vertexNormals[ 0 ].copy( vnm );

  //             }

  //             if ( face.vertexColors.length == 3 ) {

  //               var vcm = face.vertexColors[ 0 ].clone();
  //               vcm.lerp( face.vertexColors[ 1 ], 0.5 );

  //               triA.vertexColors[ 1 ].copy( vcm );
  //               triB.vertexColors[ 0 ].copy( vcm );

  //             }

  //             edge = 0;

  //           } else if ( dbc >= dab && dbc >= dac ) {

  //             vm = vb.clone();
  //             vm.lerp( vc, 0.5 );

  //             triA.a = a;
  //             triA.b = b;
  //             triA.c = m;

  //             triB.a = m;
  //             triB.b = c;
  //             triB.c = a;

  //             if ( face.vertexNormals.length == 3 ) {

  //               var vnm = face.vertexNormals[ 1 ].clone();
  //               vnm.lerp( face.vertexNormals[ 2 ], 0.5 );

  //               triA.vertexNormals[ 2 ].copy( vnm );

  //               triB.vertexNormals[ 0 ].copy( vnm );
  //               triB.vertexNormals[ 1 ].copy( face.vertexNormals[ 2 ] );
  //               triB.vertexNormals[ 2 ].copy( face.vertexNormals[ 0 ] );

  //             }

  //             if ( face.vertexColors.length == 3 ) {

  //               var vcm = face.vertexColors[ 1 ].clone();
  //               vcm.lerp( face.vertexColors[ 2 ], 0.5 );

  //               triA.vertexColors[ 2 ].copy( vcm );

  //               triB.vertexColors[ 0 ].copy( vcm );
  //               triB.vertexColors[ 1 ].copy( face.vertexColors[ 2 ] );
  //               triB.vertexColors[ 2 ].copy( face.vertexColors[ 0 ] );

  //             }

  //             edge = 1;

  //           } else {

  //             vm = va.clone();
  //             vm.lerp( vc, 0.5 );

  //             triA.a = a;
  //             triA.b = b;
  //             triA.c = m;

  //             triB.a = m;
  //             triB.b = b;
  //             triB.c = c;

  //             if ( face.vertexNormals.length == 3 ) {

  //               var vnm = face.vertexNormals[ 0 ].clone();
  //               vnm.lerp( face.vertexNormals[ 2 ], 0.5 );

  //               triA.vertexNormals[ 2 ].copy( vnm );
  //               triB.vertexNormals[ 0 ].copy( vnm );

  //             }

  //             if ( face.vertexColors.length == 3 ) {

  //               var vcm = face.vertexColors[ 0 ].clone();
  //               vcm.lerp( face.vertexColors[ 2 ], 0.5 );

  //               triA.vertexColors[ 2 ].copy( vcm );
  //               triB.vertexColors[ 0 ].copy( vcm );

  //             }

  //             edge = 2;

  //           }

  //           faces.addAll( [triA, triB] );
  //           geometry.vertices.add( vm );

  //           for ( var j = 0, jl = geometry.faceVertexUvs.length; j < jl; j ++ ) {

  //             if ( geometry.faceVertexUvs[ j ].length > 0 ) {

  //               var uvs = geometry.faceVertexUvs[ j ][ i ];

  //               var uvA = uvs[ 0 ];
  //               var uvB = uvs[ 1 ];
  //               var uvC = uvs[ 2 ];

  //               List<Vector2> uvsTriA;
  //               List<Vector2> uvsTriB;

  //               // AB

  //               if ( edge == 0 ) {

  //                 var uvM = uvA.clone();
  //                 uvM.lerp( uvB, 0.5 );

  //                 uvsTriA = [ uvA.clone(), uvM.clone(), uvC.clone() ];
  //                 uvsTriB = [ uvM.clone(), uvB.clone(), uvC.clone() ];

  //                 // BC

  //               } else if ( edge == 1 ) {

  //                 var uvM = uvB.clone();
  //                 uvM.lerp( uvC, 0.5 );

  //                 uvsTriA = [ uvA.clone(), uvB.clone(), uvM.clone() ];
  //                 uvsTriB = [ uvM.clone(), uvC.clone(), uvA.clone() ];

  //                 // AC

  //               } else {

  //                 var uvM = uvA.clone();
  //                 uvM.lerp( uvC, 0.5 );

  //                 uvsTriA = [ uvA.clone(), uvB.clone(), uvM.clone() ];
  //                 uvsTriB = [ uvM.clone(), uvB.clone(), uvC.clone() ];

  //               }

  //               faceVertexUvs[ j ].addAll( [uvsTriA, uvsTriB] );

  //             }

  //           }

  //         } else {

  //           faces.add( face );

  //           for ( var j = 0, jl = geometry.faceVertexUvs.length; j < jl; j ++ ) {

  //             faceVertexUvs[ j ].add( geometry.faceVertexUvs[ j ][ i ] );

  //           }

  //         }

  //       }

  //     }

  //     geometry.faces = faces;
  //     geometry.faceVertexUvs = faceVertexUvs;

  //   }

  //   if ( isBufferGeometry ) {

  //     return new BufferGeometry().fromGeometry( geometry );

  //   } else {

  //     return geometry;

  //   }

  // }

}
