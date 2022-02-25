part of renderer_nodes;

var Skinning = ShaderNode( ( inputs, builder ) {

	var position = inputs.position;
  var normal = inputs.normal;
  var index = inputs.index;
  var weight = inputs.weight;
  var bindMatrix = inputs.bindMatrix;
  var bindMatrixInverse = inputs.bindMatrixInverse;
  var boneMatrices = inputs.boneMatrices;

	var boneMatX = element( boneMatrices, index.x );
	var boneMatY = element( boneMatrices, index.y );
	var boneMatZ = element( boneMatrices, index.z );
	var boneMatW = element( boneMatrices, index.w );

	// POSITION

	var skinVertex = mul( bindMatrix, position );

	var skinned = add(
		mul( mul( boneMatX, skinVertex ), weight.x ),
		mul( mul( boneMatY, skinVertex ), weight.y ),
		mul( mul( boneMatZ, skinVertex ), weight.z ),
		mul( mul( boneMatW, skinVertex ), weight.w )
	);

	var skinPosition = mul( bindMatrixInverse, skinned ).xyz;

	// NORMAL

	var skinMatrix = add(
		mul( weight.x, boneMatX ),
		mul( weight.y, boneMatY ),
		mul( weight.z, boneMatZ ),
		mul( weight.w, boneMatW )
	);

	skinMatrix = mul( mul( bindMatrixInverse, skinMatrix ), bindMatrix );

	var skinNormal = transformDirection( skinMatrix, normal ).xyz;

	// ASSIGNS

	assign( position, skinPosition ).build( builder );
	assign( normal, skinNormal ).build( builder );

} );

class SkinningNode extends Node {

  late dynamic skinnedMesh;
  late dynamic skinIndexNode;
  late dynamic skinWeightNode;
  late dynamic bindMatrixNode;
  late dynamic bindMatrixInverseNode;
  late dynamic boneMatricesNode;

	SkinningNode( skinnedMesh ) : super( 'void' ) {

		

		this.skinnedMesh = skinnedMesh;

		this.updateType = NodeUpdateType.Object;

		//

		this.skinIndexNode = new AttributeNode( 'skinIndex', 'uvec4' );
		this.skinWeightNode = new AttributeNode( 'skinWeight', 'vec4' );

		this.bindMatrixNode = new Matrix4Node( skinnedMesh.bindMatrix );
		this.bindMatrixInverseNode = new Matrix4Node( skinnedMesh.bindMatrixInverse );
		this.boneMatricesNode = new BufferNode( skinnedMesh.skeleton.boneMatrices, 'mat4', skinnedMesh.skeleton.bones.length );

	}

	generate( [builder, output] ) {

		// inout nodes
		var position = new PositionNode( PositionNode.LOCAL );
		var normal = new NormalNode( NormalNode.LOCAL );

		var index = this.skinIndexNode;
		var weight = this.skinWeightNode;
		var bindMatrix = this.bindMatrixNode;
		var bindMatrixInverse = this.bindMatrixInverseNode;
		var boneMatrices = this.boneMatricesNode;

		Skinning( {
			position,
			normal,
			index,
			weight,
			bindMatrix,
			bindMatrixInverse,
			boneMatrices
		}, builder );

	}

	update([frame]) {

		this.skinnedMesh.skeleton.update();

	}

}

