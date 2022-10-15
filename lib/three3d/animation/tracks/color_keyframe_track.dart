
import 'package:three_dart/three3d/animation/keyframe_track.dart';

/// A Track of keyframe values that represent color.

class ColorKeyframeTrack extends KeyframeTrack {
  @override
  var ValueTypeName = 'color';

  ColorKeyframeTrack(name, times, values, interpolation)
      : super(name, times, values, interpolation);
}
