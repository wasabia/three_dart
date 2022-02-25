library renderer_nodes;

import 'package:flutter/scheduler.dart';
import 'package:three_dart/three3d/WeakMap.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/materials/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/extra/console.dart';
import 'package:three_dart/extra/performance.dart';
import 'package:three_dart/three3d/renderers/webgpu/index.dart';

part './core/constants.dart';

part './core/Node.dart';
part './core/InputNode.dart';
part './core/CodeNode.dart';
part './inputs/ColorNode.dart';
part './materials/MeshBasicNodeMaterial.dart';
part './core/NodeBuilder.dart';
part './core/NodeKeywords.dart';
part './core/NodeAttribute.dart';
part './core/NodeParser.dart';


part './parsers/WGSLNodeParser.dart';
part './parsers/WGSLNodeFunction.dart';
part './core/NodeFunction.dart';
part './core/NodeFunctionInput.dart';
part './core/NodeFrame.dart';
part './core/NodeVary.dart';
part './core/NodeUniform.dart';
part './core/NodeVar.dart';
part './core/NodeCode.dart';
part './accessors/PositionNode.dart';
part './core/AttributeNode.dart';
part './core/VaryNode.dart';
part './math/MathNode.dart';
part './core/TempNode.dart';
part './utils/JoinNode.dart';
part './utils/SplitNode.dart';
part './core/ExpressionNode.dart';
part './math/OperatorNode.dart';
part './core/BypassNode.dart';
part './accessors/SkinningNode.dart';
part './accessors/Object3DNode.dart';
part './accessors/ModelNode.dart';
part './inputs/Matrix3Node.dart';
part './inputs/Matrix4Node.dart';
part './inputs/Vector3Node.dart';
part './inputs/BufferNode.dart';
part './accessors/NormalNode.dart';
part './accessors/CameraNode.dart';
part './ShaderNode.dart';
part './utils/ArrayElementNode.dart';
part './core/VarNode.dart';
part './core/PropertyNode.dart';
part './inputs/FloatNode.dart';
part './utils/ConvertNode.dart';
part './inputs/Vector2Node.dart';
part './inputs/Vector4Node.dart';
part './math/CondNode.dart';
part './core/ContextNode.dart';
part './accessors/ModelViewProjectionNode.dart';
part './accessors/MaterialNode.dart';
part './accessors/MaterialReferenceNode.dart';
part './accessors/ReferenceNode.dart';
part './inputs/TextureNode.dart';
part './accessors/UVNode.dart';
part './functions/PhysicalMaterialFunctions.dart';
part './lights/LightContextNode.dart';
part './functions/BSDFs.dart';
part './display/ColorSpaceNode.dart';
part './core/ArrayInputNode.dart';



