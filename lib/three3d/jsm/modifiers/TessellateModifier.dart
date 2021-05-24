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

  
  // Applies the "modify" pattern
  modify( geometry ) {

    var isBufferGeometry = geometry.isBufferGeometry;

    if ( isBufferGeometry ) {

      geometry = new Geometry().fromBufferGeometry( geometry );

    } else {

      geometry = geometry.clone();

    }

    geometry.mergeVertices( precisionPoints: 6 );

    var finalized = false;
    var iteration = 0;
    var maxEdgeLengthSquared = this.maxEdgeLength * this.maxEdgeLength;

    var edge;

    while ( ! finalized && iteration < this.maxIterations && geometry.faces.length < this.maxFaces ) {

      List<Face3> faces = [];
      List<List<List<Vector2>>> faceVertexUvs = [];

      finalized = true;
      iteration ++;

      for ( var i = 0, il = geometry.faceVertexUvs.length; i < il; i ++ ) {
        faceVertexUvs.add([]);
      }

      for ( var i = 0, il = geometry.faces.length; i < il; i ++ ) {

        var face = geometry.faces[ i ];

        if ( face is Face3 ) {

          var a = face.a;
          var b = face.b;
          var c = face.c;

          var va = geometry.vertices[ a ];
          var vb = geometry.vertices[ b ];
          var vc = geometry.vertices[ c ];

          var dab = va.distanceToSquared( vb );
          var dbc = vb.distanceToSquared( vc );
          var dac = va.distanceToSquared( vc );

          var limitReached = ( faces.length + il - i ) >= this.maxFaces;

          var vm;

          if ( ! limitReached && ( dab > maxEdgeLengthSquared || dbc > maxEdgeLengthSquared || dac > maxEdgeLengthSquared ) ) {

            finalized = false;

            var m = geometry.vertices.length;

            var triA = face.clone();
            var triB = face.clone();

            if ( dab >= dbc && dab >= dac ) {

              vm = va.clone();
              vm.lerp( vb, 0.5 );

              triA.a = a;
              triA.b = m;
              triA.c = c;

              triB.a = m;
              triB.b = b;
              triB.c = c;

              if ( face.vertexNormals.length == 3 ) {

                var vnm = face.vertexNormals[ 0 ].clone();
                vnm.lerp( face.vertexNormals[ 1 ], 0.5 );

                triA.vertexNormals[ 1 ].copy( vnm );
                triB.vertexNormals[ 0 ].copy( vnm );

              }

              if ( face.vertexColors.length == 3 ) {

                var vcm = face.vertexColors[ 0 ].clone();
                vcm.lerp( face.vertexColors[ 1 ], 0.5 );

                triA.vertexColors[ 1 ].copy( vcm );
                triB.vertexColors[ 0 ].copy( vcm );

              }

              edge = 0;

            } else if ( dbc >= dab && dbc >= dac ) {

              vm = vb.clone();
              vm.lerp( vc, 0.5 );

              triA.a = a;
              triA.b = b;
              triA.c = m;

              triB.a = m;
              triB.b = c;
              triB.c = a;

              if ( face.vertexNormals.length == 3 ) {

                var vnm = face.vertexNormals[ 1 ].clone();
                vnm.lerp( face.vertexNormals[ 2 ], 0.5 );

                triA.vertexNormals[ 2 ].copy( vnm );

                triB.vertexNormals[ 0 ].copy( vnm );
                triB.vertexNormals[ 1 ].copy( face.vertexNormals[ 2 ] );
                triB.vertexNormals[ 2 ].copy( face.vertexNormals[ 0 ] );

              }

              if ( face.vertexColors.length == 3 ) {

                var vcm = face.vertexColors[ 1 ].clone();
                vcm.lerp( face.vertexColors[ 2 ], 0.5 );

                triA.vertexColors[ 2 ].copy( vcm );

                triB.vertexColors[ 0 ].copy( vcm );
                triB.vertexColors[ 1 ].copy( face.vertexColors[ 2 ] );
                triB.vertexColors[ 2 ].copy( face.vertexColors[ 0 ] );

              }

              edge = 1;

            } else {

              vm = va.clone();
              vm.lerp( vc, 0.5 );

              triA.a = a;
              triA.b = b;
              triA.c = m;

              triB.a = m;
              triB.b = b;
              triB.c = c;

              if ( face.vertexNormals.length == 3 ) {

                var vnm = face.vertexNormals[ 0 ].clone();
                vnm.lerp( face.vertexNormals[ 2 ], 0.5 );

                triA.vertexNormals[ 2 ].copy( vnm );
                triB.vertexNormals[ 0 ].copy( vnm );

              }

              if ( face.vertexColors.length == 3 ) {

                var vcm = face.vertexColors[ 0 ].clone();
                vcm.lerp( face.vertexColors[ 2 ], 0.5 );

                triA.vertexColors[ 2 ].copy( vcm );
                triB.vertexColors[ 0 ].copy( vcm );

              }

              edge = 2;

            }

            faces.addAll( [triA, triB] );
            geometry.vertices.add( vm );

            for ( var j = 0, jl = geometry.faceVertexUvs.length; j < jl; j ++ ) {

              if ( geometry.faceVertexUvs[ j ].length > 0 ) {

                var uvs = geometry.faceVertexUvs[ j ][ i ];

                var uvA = uvs[ 0 ];
                var uvB = uvs[ 1 ];
                var uvC = uvs[ 2 ];

                List<Vector2> uvsTriA;
                List<Vector2> uvsTriB;

                // AB

                if ( edge == 0 ) {

                  var uvM = uvA.clone();
                  uvM.lerp( uvB, 0.5 );

                  uvsTriA = [ uvA.clone(), uvM.clone(), uvC.clone() ];
                  uvsTriB = [ uvM.clone(), uvB.clone(), uvC.clone() ];

                  // BC

                } else if ( edge == 1 ) {

                  var uvM = uvB.clone();
                  uvM.lerp( uvC, 0.5 );

                  uvsTriA = [ uvA.clone(), uvB.clone(), uvM.clone() ];
                  uvsTriB = [ uvM.clone(), uvC.clone(), uvA.clone() ];

                  // AC

                } else {

                  var uvM = uvA.clone();
                  uvM.lerp( uvC, 0.5 );

                  uvsTriA = [ uvA.clone(), uvB.clone(), uvM.clone() ];
                  uvsTriB = [ uvM.clone(), uvB.clone(), uvC.clone() ];

                }

                faceVertexUvs[ j ].addAll( [uvsTriA, uvsTriB] );

              }

            }

          } else {

            faces.add( face );

            for ( var j = 0, jl = geometry.faceVertexUvs.length; j < jl; j ++ ) {

              faceVertexUvs[ j ].add( geometry.faceVertexUvs[ j ][ i ] );

            }

          }

        }

      }

      geometry.faces = faces;
      geometry.faceVertexUvs = faceVertexUvs;

    }

    if ( isBufferGeometry ) {

      return new BufferGeometry().fromGeometry( geometry );

    } else {

      return geometry;

    }

  }

}
