import 'package:three_dart/three3d/animation/keyframe_track.dart';

/// A Track of vectored keyframe values.

class VectorKeyframeTrack extends KeyframeTrack {
  @override
  var valueTypeName = 'vector';

  VectorKeyframeTrack(name, times, values, [interpolation]) : super(name, times, values, interpolation);
}
