import 'package:three_dart/three3d/animation/keyframe_track.dart';

/// A Track of numeric keyframe values.

class NumberKeyframeTrack extends KeyframeTrack {
  NumberKeyframeTrack(name, times, values, [interpolation]) : super(name, times, values, interpolation) {
    valueTypeName = "number";
  }
}
