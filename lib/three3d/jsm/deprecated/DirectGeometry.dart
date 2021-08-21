part of jsm_deprecated;


class DirectGeometry {
  late int id;
  late String uuid;
  late String name;
  late String type;

  List<Vector3> vertices = [];
  List<Vector3> normals = [];
  List<Color> colors = [];
  List<Vector2> uvs = [];
  List<Vector2> uvs2 = [];
  List<Map<String, int>> groups = [];
  Map<String, dynamic> morphTargets = Map<String, dynamic>();
  List<Vector4> skinWeights = [];
  List<Vector4> skinIndices = [];
  Box3? boundingBox;
  Sphere? boundingSphere;

  bool verticesNeedUpdate = false;
	bool normalsNeedUpdate = false;
	bool colorsNeedUpdate = false;
	bool uvsNeedUpdate = false;
	bool groupsNeedUpdate = false;
  bool lineDistancesNeedUpdate = false;

	DirectGeometry() {

	}

	computeGroups( geometry ) {

		List<Map<String, int>> groups = [];

		Map<String, int>? group;
    var i;
		var materialIndex = null;

		var faces = geometry.faces;

		for ( i = 0; i < faces.length; i ++ ) {

			var face = faces[ i ];

			// materials

			if ( face.materialIndex != materialIndex ) {

				materialIndex = face.materialIndex;

				if ( group != null ) {

					group["count"] = ( i * 3 ) - group["start"];
					groups.add( group );

				}

				group = {
					"start": i * 3,
					"materialIndex": materialIndex
				};

			}

		}

		if ( group != null ) {

			group["count"] = ( i * 3 ) - group["start"];
			groups.add( group );

		}

		this.groups = groups;

	}

	fromGeometry( Geometry geometry ) {

		var faces = geometry.faces;
		var vertices = geometry.vertices;
		var faceVertexUvs = geometry.faceVertexUvs;

		var hasFaceVertexUv = faceVertexUvs != null && faceVertexUvs[ 0 ] != null && faceVertexUvs[ 0 ].length > 0;
		var hasFaceVertexUv2 = faceVertexUvs != null && faceVertexUvs.length >= 2 && faceVertexUvs[ 1 ] != null && faceVertexUvs[ 1 ].length > 0;

		// morphs

		var morphTargets = geometry.morphTargets;
		var morphTargetsLength = morphTargets.length;

		var morphTargetsPosition;

		if ( morphTargetsLength > 0 ) {

			morphTargetsPosition = [];

			for ( var i = 0; i < morphTargetsLength; i ++ ) {

				morphTargetsPosition.add(
          {
            "name": morphTargets[ i ].name,
            "data": []
          }
        );

			}

			this.morphTargets["position"] = morphTargetsPosition;

		}

		var morphNormals = geometry.morphNormals;
		var morphNormalsLength = morphNormals.length;

		var morphTargetsNormal;

		if ( morphNormalsLength > 0 ) {

			morphTargetsNormal = [];

			for ( var i = 0; i < morphNormalsLength; i ++ ) {

				morphTargetsNormal[ i ] = {
					"name": morphNormals[ i ].name,
				 	"data": []
				};

			}

			this.morphTargets["normal"] = morphTargetsNormal;

		}

		// skins

		var skinIndices = geometry.skinIndices;
		var skinWeights = geometry.skinWeights;

		var hasSkinIndices = skinIndices.length == vertices.length;
		var hasSkinWeights = skinWeights.length == vertices.length;

		//

		if ( vertices.length > 0 && faces.length == 0 ) {

			print( 'THREE.DirectGeometry: Faceless geometries are not supported.' );

		}

		for ( var i = 0; i < faces.length; i ++ ) {

			var face = faces[ i ];

			this.vertices.addAll( [vertices[ face.a ], vertices[ face.b ], vertices[ face.c ]] );

			var vertexNormals = face.vertexNormals;

			if ( vertexNormals.length == 3 ) {

				this.normals.addAll( [vertexNormals[ 0 ], vertexNormals[ 1 ], vertexNormals[ 2 ]] );

			} else {

				var normal = face.normal;

				this.normals.addAll( [normal, normal, normal] );

			}

			var vertexColors = face.vertexColors;

			if ( vertexColors.length == 3 ) {

				this.colors.addAll( [vertexColors[ 0 ], vertexColors[ 1 ], vertexColors[ 2 ]] );

			} else {

				var color = face.color;

				this.colors.addAll( [color, color, color] );

			}

			if ( hasFaceVertexUv == true ) {

				var vertexUvs = faceVertexUvs[ 0 ][ i ];

				if ( vertexUvs != null ) {

					this.uvs.addAll( [vertexUvs[ 0 ], vertexUvs[ 1 ], vertexUvs[ 2 ]] );

				} else {

					print( 'THREE.DirectGeometry.fromGeometry(): null vertexUv ${i}' );

					this.uvs.addAll( [new Vector2(null, null), new Vector2(null, null), new Vector2(null, null)] );

				}

			}

			if ( hasFaceVertexUv2 == true ) {

				var vertexUvs = faceVertexUvs[ 1 ][ i ];

				if ( vertexUvs != null ) {

					this.uvs2.addAll( [vertexUvs[ 0 ], vertexUvs[ 1 ], vertexUvs[ 2 ]] );

				} else {

					print( 'THREE.DirectGeometry.fromGeometry(): null vertexUv2 ${i}' );

					this.uvs2.addAll( [new Vector2(null,null), new Vector2(null,null), new Vector2(null,null)] );

				}

			}

			// morphs

			for ( var j = 0; j < morphTargetsLength; j ++ ) {

				var morphTarget = morphTargets[ j ].vertices;

				morphTargetsPosition[ j ]["data"].addAll( [morphTarget[ face.a ], morphTarget[ face.b ], morphTarget[ face.c ]] );

			}

			for ( var j = 0; j < morphNormalsLength; j ++ ) {

				var morphNormal = morphNormals[ j ].vertexNormals[ i ];

				morphTargetsNormal[ j ]["data"].addAll( [morphNormal.a, morphNormal.b, morphNormal.c] );
  

			}

			// skins

			if ( hasSkinIndices ) {

				this.skinIndices.addAll( [skinIndices[ face.a ], skinIndices[ face.b ], skinIndices[ face.c ]] );

			}

			if ( hasSkinWeights ) {

				this.skinWeights.addAll( [skinWeights[ face.a ], skinWeights[ face.b ], skinWeights[ face.c ]] );

			}

		}

		this.computeGroups( geometry );

		this.verticesNeedUpdate = geometry.verticesNeedUpdate;
		this.normalsNeedUpdate = geometry.normalsNeedUpdate;
		this.colorsNeedUpdate = geometry.colorsNeedUpdate;
		this.uvsNeedUpdate = geometry.uvsNeedUpdate;
		this.groupsNeedUpdate = geometry.groupsNeedUpdate;

		if ( geometry.boundingSphere != null ) {

			this.boundingSphere = geometry.boundingSphere!.clone();

		}

		if ( geometry.boundingBox != null ) {

			this.boundingBox = geometry.boundingBox!.clone();

		}

		return this;

	}

}

