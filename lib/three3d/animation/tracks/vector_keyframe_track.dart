import 'package:three_dart/three3d/animation/keyframe_track.dart';

/// A Track of vectored keyframe values.

class VectorKeyframeTrack extends KeyframeTrack {
  VectorKeyframeTrack(name, times, values, [interpolation]) : super(name, times, values, interpolation) {
    valueTypeName = 'vector';
  }
}
