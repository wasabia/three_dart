library three_animation;

import 'package:flutter_gl/native-array/index.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';
import 'package:three_dart/three3d/objects/index.dart';
import 'package:three_dart/three3d/dart_helpers.dart';
import '../constants.dart';

part 'tracks/number_keyframe_track.dart';
part 'tracks/vector_keyframe_track.dart';
part 'tracks/quaternion_keyframe_track.dart';
part 'tracks/color_keyframe_track.dart';
part 'tracks/boolean_keyframe_track.dart';
part 'tracks/string_keyframe_track.dart';

part 'animation_action.dart';
part 'animation_mixer.dart';
part 'animation_clip.dart';
part 'animation_utils.dart';
part 'keyframe_track.dart';
part 'property_mixer.dart';
part 'property_binding.dart';
part 'animation_object_group.dart';
part 'sprite_animator.dart';
