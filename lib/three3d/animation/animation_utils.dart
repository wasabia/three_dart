import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/animation/index.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/dart_helpers.dart';
import 'package:three_dart/three3d/math/index.dart';

class AnimationUtils {
  // same as Array.prototype.slice, but also works on typed arrays
  static arraySlice(array, [int? from, int? to]) {
    // if ( AnimationUtils.isTypedArray( array ) ) {
    if (array! is List) {
      print(" AnimationUtils.arraySlice array: $array ");

      // 	// in ios9 array.subarray(from, null) will return empty array
      // 	// but array.subarray(from) or array.subarray(from, len) is correct
      // 	return new array.constructor( array.subarray( from, to != null ? to : array.length ) );

    }

    return array.slice(from, to);
  }

  // converts an array to a specific type
  static convertArray(array, String type, [bool forceClone = false]) {
    // var 'null' and 'null' pass
    // TODO runtimeType on web release mode will not same as debug
    if (array == null || !forceClone && array.runtimeType.toString() == type) {
      return array;
    }

    if (array is NativeArray && type == 'List<num>') {
      return array.toDartList();
    }

    if (type == 'List<num>') {
      // create typed array
      return List<num>.from(array);
    }

    return slice(array, 0); // create Array
  }

  static isTypedArray(object) {
    print("AnimationUtils isTypedArray object: $object");
    return false;

    // return ArrayBuffer.isView( object ) &&
    // 	! ( object instanceof DataView );
  }

  // returns an array by which times and values can be sorted
  static getKeyframeOrder(times) {
    compareTime(i, j) {
      return times[i] - times[j];
    }

    var n = times.length;
    var result = List<int>.filled(n, 0);
    for (var i = 0; i != n; ++i) {
      result[i] = i;
    }

    result.sort((a, b) {
      return compareTime(a, b);
    });

    return result;
  }

  // uses the array previously returned by 'getKeyframeOrder' to sort data
  static sortedArray(List<num> values, stride, order) {
    var nValues = values.length;
    var result = List<num>.filled(nValues, 0);

    for (var i = 0, dstOffset = 0; dstOffset != nValues; ++i) {
      var srcOffset = order[i] * stride;

      for (var j = 0; j != stride; ++j) {
        result[dstOffset++] = values[srcOffset + j];
      }
    }

    return result;
  }

  // function for parsing AOS keyframe formats
  static flattenJSON(jsonKeys, times, values, valuePropertyName) {
    var i = 1, key = jsonKeys[0];

    while (key != null && key[valuePropertyName] == null) {
      key = jsonKeys[i++];
    }

    if (key == null) return; // no data

    var value = key[valuePropertyName];
    if (value == null) return; // no data

    if (value is List) {
      do {
        value = key[valuePropertyName];

        if (value != null) {
          times.push(key.time);
          values.push.apply(values, value); // push all elements

        }

        key = jsonKeys[i++];
      } while (key != null);
    } else if (value.toArray != null) {
      // ...assume three.Math-ish

      do {
        value = key[valuePropertyName];

        if (value != null) {
          times.push(key.time);
          value.toArray(values, values.length);
        }

        key = jsonKeys[i++];
      } while (key != null);
    } else {
      // otherwise push as-is

      do {
        value = key[valuePropertyName];

        if (value != null) {
          times.push(key.time);
          values.push(value);
        }

        key = jsonKeys[i++];
      } while (key != null);
    }
  }

  subclip(sourceClip, name, startFrame, endFrame, {int fps = 30}) {
    var clip = sourceClip.clone();

    clip.name = name;

    var tracks = [];

    for (var i = 0; i < clip.tracks.length; ++i) {
      var track = clip.tracks[i];
      var valueSize = track.getValueSize();

      var times = [];
      var values = [];

      for (var j = 0; j < track.times.length; ++j) {
        var frame = track.times[j] * fps;

        if (frame < startFrame || frame >= endFrame) continue;

        times.add(track.times[j]);

        for (var k = 0; k < valueSize; ++k) {
          values.add(track.values[j * valueSize + k]);
        }
      }

      if (times.isEmpty) continue;

      track.times = AnimationUtils.convertArray(times, track.times.constructor);
      track.values = AnimationUtils.convertArray(values, track.values.constructor);

      tracks.add(track);
    }

    clip.tracks = tracks;

    // find minimum .times value across all tracks in the trimmed clip

    var minStartTime = double.infinity;

    for (var i = 0; i < clip.tracks.length; ++i) {
      if (minStartTime > clip.tracks[i].times[0]) {
        minStartTime = clip.tracks[i].times[0];
      }
    }

    // shift all tracks such that clip begins at t=0

    for (var i = 0; i < clip.tracks.length; ++i) {
      clip.tracks[i].shift(-1 * minStartTime);
    }

    clip.resetDuration();

    return clip;
  }

  makeClipAdditive(AnimationClip targetClip, {int referenceFrame = 0, AnimationClip? referenceClip, int fps = 30}) {
    referenceClip ??= targetClip;

    if (fps <= 0) fps = 30;

    var numTracks = referenceClip.tracks.length;
    var referenceTime = referenceFrame / fps;

    // Make each track's values relative to the values at the reference frame
    for (var i = 0; i < numTracks; ++i) {
      var referenceTrack = referenceClip.tracks[i];
      var referenceTrackType = referenceTrack.valueTypeName;

      // Skip this track if it's non-numeric
      if (referenceTrackType == 'bool' || referenceTrackType == 'string') {
        continue;
      }

      // Find the track in the target clip whose name and type matches the reference track
      var targetTrack = targetClip.tracks.cast<KeyframeTrack?>().firstWhere((track) {
        return track?.name == referenceTrack.name && track?.valueTypeName == referenceTrackType;
      }, orElse: () => null);

      if (targetTrack == null) continue;

      var referenceOffset = 0;
      var referenceValueSize = referenceTrack.getValueSize();

      print("AnimationUtils isInterpolantFactoryMethodGLTFCubicSpline todo ");
      // if ( referenceTrack.createInterpolant.isInterpolantFactoryMethodGLTFCubicSpline ) {
      // 	referenceOffset = referenceValueSize / 3;
      // }

      var targetOffset = 0;
      var targetValueSize = targetTrack.getValueSize();

      print("AnimationUtils isInterpolantFactoryMethodGLTFCubicSpline todo ");
      // if ( targetTrack.createInterpolant.isInterpolantFactoryMethodGLTFCubicSpline ) {
      // 	targetOffset = targetValueSize / 3;
      // }

      var lastIndex = referenceTrack.times.length - 1;
      List<num> referenceValue;

      // Find the value to subtract out of the track
      if (referenceTime <= referenceTrack.times[0]) {
        // Reference frame is earlier than the first keyframe, so just use the first keyframe
        var startIndex = referenceOffset;
        var endIndex = referenceValueSize - referenceOffset;
        referenceValue = AnimationUtils.arraySlice(referenceTrack.values, startIndex, endIndex);
      } else if (referenceTime >= referenceTrack.times[lastIndex]) {
        // Reference frame is after the last keyframe, so just use the last keyframe
        int startIndex = (lastIndex * referenceValueSize + referenceOffset).toInt();
        int endIndex = (startIndex + referenceValueSize - referenceOffset).toInt();
        referenceValue = AnimationUtils.arraySlice(referenceTrack.values, startIndex, endIndex);
      } else {
        // Interpolate to the reference value
        var interpolant = referenceTrack.createInterpolant!();
        var startIndex = referenceOffset;
        var endIndex = referenceValueSize - referenceOffset;
        interpolant.evaluate(referenceTime);
        referenceValue = AnimationUtils.arraySlice(interpolant.resultBuffer, startIndex, endIndex);
      }

      // Conjugate the quaternion
      if (referenceTrackType == 'quaternion') {
        var referenceQuat = Quaternion().fromArray(referenceValue).normalize().conjugate();
        referenceQuat.toArray(referenceValue);
      }

      // Subtract the reference value from all of the track values

      var numTimes = targetTrack.times.length;
      for (var j = 0; j < numTimes; ++j) {
        int valueStart = (j * targetValueSize + targetOffset).toInt();

        if (referenceTrackType == 'quaternion') {
          // Multiply the conjugate for quaternion track types
          Quaternion.multiplyQuaternionsFlat(
              targetTrack.values, valueStart, referenceValue, 0, targetTrack.values, valueStart);
        } else {
          var valueEnd = targetValueSize - targetOffset * 2;

          // Subtract each value for all other numeric track types
          for (var k = 0; k < valueEnd; ++k) {
            targetTrack.values[valueStart + k] -= referenceValue[k];
          }
        }
      }
    }

    targetClip.blendMode = AdditiveAnimationBlendMode;

    return targetClip;
  }
}
