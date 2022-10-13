library three_animation;

import 'package:flutter_gl/native-array/index.dart';
import 'package:three_dart/three/core/index.dart';
import 'package:three_dart/three/math/index.dart';
import 'package:three_dart/three/objects/index.dart';
import 'package:three_dart/three/dart_helpers.dart';
import '../constants.dart';

part './tracks/NumberKeyframeTrack.dart';
part './tracks/VectorKeyframeTrack.dart';
part './tracks/QuaternionKeyframeTrack.dart';
part './tracks/ColorKeyframeTrack.dart';
part './tracks/BooleanKeyframeTrack.dart';
part './tracks/StringKeyframeTrack.dart';

part './AnimationAction.dart';
part './AnimationMixer.dart';
part './AnimationClip.dart';
part './AnimationUtils.dart';
part './KeyframeTrack.dart';
part './PropertyMixer.dart';
part './PropertyBinding.dart';
part './AnimationObjectGroup.dart';
part './SpriteAnimator.dart';
