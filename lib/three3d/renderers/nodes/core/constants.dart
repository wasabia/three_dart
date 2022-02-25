part of renderer_nodes;

class NodeShaderStage {
	static const String Vertex = 'vertex';
	static const String Fragment = 'fragment';
}

enum NodeUpdateType {
	None,
	Frame,
	Object
}

// export const NodeType = {
// 	Boolean: 'bool',
// 	Integer: 'int',
// 	Float: 'float',
// 	Vector2: 'vec2',
// 	Vector3: 'vec3',
// 	Vector4: 'vec4',
// 	Matrix3: 'mat3',
// 	Matrix4: 'mat4'
// };
