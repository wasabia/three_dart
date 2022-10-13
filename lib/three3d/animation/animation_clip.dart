part of three_animation;

class AnimationClip {
  late String name;
  late String uuid;
  late num duration;
  late int blendMode;
  late List<KeyframeTrack> tracks;
  late List results;

  AnimationClip(name, [num duration = -1, tracks, int blendMode = NormalAnimationBlendMode]) {
    this.name = name;
    this.tracks = tracks;
    this.duration = duration;
    this.blendMode = blendMode;

    uuid = MathUtils.generateUUID();

    // this means it should figure out its duration by scanning the tracks
    if (this.duration < 0) {
      resetDuration();
    }
  }

  resetDuration() {
    var tracks = this.tracks;
    num duration = 0;

    for (var i = 0, n = tracks.length; i != n; ++i) {
      var track = this.tracks[i];

      duration = Math.max(duration, track.times[track.times.length - 1]);
    }

    this.duration = duration;

    return this;
  }

  trim() {
    for (var i = 0; i < tracks.length; i++) {
      tracks[i].trim(0, duration);
    }

    return this;
  }

  validate() {
    var valid = true;

    for (var i = 0; i < tracks.length; i++) {
      valid = valid && tracks[i].validate();
    }

    return valid;
  }

  optimize() {
    for (var i = 0; i < tracks.length; i++) {
      tracks[i].optimize();
    }

    return this;
  }

  clone() {
    const tracks = [];

    for (var i = 0; i < this.tracks.length; i++) {
      tracks.add(this.tracks[i].clone());
    }

    return AnimationClip(name, duration, tracks, blendMode);
  }

  toJSON() {
    return AnimationClip.toJSON_static(this);
  }

  static parse(json) {
    var tracks = [];

    var jsonTracks = json.tracks, frameTime = 1.0 / (json.fps ?? 1.0);

    for (var i = 0, n = jsonTracks.length; i != n; ++i) {
      tracks.add(parseKeyframeTrack(jsonTracks[i]).scale(frameTime));
    }

    var clip = AnimationClip(json.name, json.duration, tracks, json.blendMode);
    clip.uuid = json.uuid;

    return clip;
  }

  static toJSON_static(clip) {
    var tracks = [], clipTracks = clip.tracks;

    var json = {
      'name': clip.name,
      'duration': clip.duration,
      'tracks': tracks,
      'uuid': clip.uuid,
      'blendMode': clip.blendMode
    };

    for (var i = 0, n = clipTracks.length; i != n; ++i) {
      tracks.add(KeyframeTrack.toJSON(clipTracks[i]));
    }

    return json;
  }

  static CreateFromMorphTargetSequence(name, morphTargetSequence, fps, noLoop) {
    var numMorphTargets = morphTargetSequence.length;
    var tracks = [];

    for (var i = 0; i < numMorphTargets; i++) {
      List<num> times = [];
      List<num> values = [];

      times.addAll([(i + numMorphTargets - 1) % numMorphTargets, i, (i + 1) % numMorphTargets]);

      values.addAll([0, 1, 0]);

      var order = AnimationUtils.getKeyframeOrder(times);
      times = AnimationUtils.sortedArray(times, 1, order);
      values = AnimationUtils.sortedArray(values, 1, order);

      // if there is a key at the first frame, duplicate it as the
      // last frame as well for perfect loop.
      if (!noLoop && times[0] == 0) {
        times.add(numMorphTargets);
        values.add(values[0]);
      }

      tracks.add(NumberKeyframeTrack('.morphTargetInfluences[${morphTargetSequence[i].name}]', times, values, null)
          .scale(1.0 / fps));
    }

    return AnimationClip(name, -1, tracks);
  }

  static findByName(List<AnimationClip> objectOrClipArray, name) {
    var clipArray = objectOrClipArray;

    if (objectOrClipArray is List<AnimationClip>) {
      print("AnimationClip.findByName todo  ");
      // var o = objectOrClipArray;
      // clipArray = o.geometry && o.geometry.animations || o.animations;

    }

    for (var i = 0; i < clipArray.length; i++) {
      if (clipArray[i].name == name) {
        return clipArray[i];
      }
    }

    return null;
  }

  static CreateClipsFromMorphTargetSequences(morphTargets, fps, noLoop) {
    var animationToMorphTargets = {};

    // tested with https://regex101.com/ on trick sequences
    // such flamingo_flyA_003, flamingo_run1_003, crdeath0059
    var pattern = RegExp(r"^([\w-]*?)([\d]+)$");

    // sort morph target names into animation groups based
    // patterns like Walk_001, Walk_002, Run_001, Run_002
    for (var i = 0, il = morphTargets.length; i < il; i++) {
      var morphTarget = morphTargets[i];
      var parts = morphTarget.name.match(pattern);

      if (parts && parts.length > 1) {
        var name = parts[1];

        var animationMorphTargets = animationToMorphTargets[name];

        if (animationMorphTargets == null) {
          animationToMorphTargets[name] = animationMorphTargets = [];
        }

        animationMorphTargets.add(morphTarget);
      }
    }

    var clips = [];

    // for ( var name in animationToMorphTargets ) {
    animationToMorphTargets.forEach((name, value) {
      clips.add(AnimationClip.CreateFromMorphTargetSequence(name, animationToMorphTargets[name], fps, noLoop));
    });

    return clips;
  }

  // parse the animation.hierarchy format
  static parseAnimation(animation, bones) {
    if (!animation) {
      print('three.AnimationClip: No animation in JSONLoader data.');
      return null;
    }

    addNonemptyTrack(String trackType, trackName, animationKeys, propertyName, destTracks) {
      // only return track if there are actually keys.
      if (animationKeys.length != 0) {
        const times = [];
        const values = [];

        AnimationUtils.flattenJSON(animationKeys, times, values, propertyName);

        // empty keys are filtered out, so check again
        if (times.isNotEmpty) {
          if (trackType == "VectorKeyframeTrack") {
            destTracks.add(VectorKeyframeTrack(trackName, times, values, null));
          } else if (trackType == "QuaternionKeyframeTrack") {
            destTracks.add(QuaternionKeyframeTrack(trackName, times, values, null));
          } else {
            throw ("AnimationClip. addNonemptyTrack trackType: $trackType is not support ");
          }
        }
      }
    }

    var tracks = [];

    var clipName = animation.name ?? 'default';
    var fps = animation.fps ?? 30;
    var blendMode = animation.blendMode;

    // automatic length determination in AnimationClip.
    var duration = animation.length ?? -1;

    var hierarchyTracks = animation.hierarchy ?? [];

    for (var h = 0; h < hierarchyTracks.length; h++) {
      var animationKeys = hierarchyTracks[h].keys;

      // skip empty tracks
      if (!animationKeys || animationKeys.length == 0) continue;

      // process morph targets
      if (animationKeys[0].morphTargets) {
        // figure out all morph targets used in this track
        var morphTargetNames = {};

        int k;

        for (k = 0; k < animationKeys.length; k++) {
          if (animationKeys[k].morphTargets) {
            for (var m = 0; m < animationKeys[k].morphTargets.length; m++) {
              morphTargetNames[animationKeys[k].morphTargets[m]] = -1;
            }
          }
        }

        // create a track for each morph target with all zero
        // morphTargetInfluences except for the keys in which
        // the morphTarget is named.
        // for ( var morphTargetName in morphTargetNames ) {
        morphTargetNames.forEach((morphTargetName, value) {
          List<num> times = [];
          List<num> values = [];

          for (var m = 0; m != animationKeys[k].morphTargets.length; ++m) {
            var animationKey = animationKeys[k];

            times.add(animationKey.time);
            values.add((animationKey.morphTarget == morphTargetName) ? 1 : 0);
          }

          tracks.add(NumberKeyframeTrack('.morphTargetInfluence[$morphTargetName]', times, values, null));
        });

        duration = morphTargetNames.length * (fps ?? 1.0);
      } else {
        // ...assume skeletal animation

        var boneName = '.bones[' + bones[h].name + ']';

        addNonemptyTrack("VectorKeyframeTrack", boneName + '.position', animationKeys, 'pos', tracks);

        addNonemptyTrack("QuaternionKeyframeTrack", boneName + '.quaternion', animationKeys, 'rot', tracks);

        addNonemptyTrack("VectorKeyframeTrack", boneName + '.scale', animationKeys, 'scl', tracks);
      }
    }

    if (tracks.isEmpty) {
      return null;
    }

    var clip = AnimationClip(clipName, duration, tracks, blendMode);

    return clip;
  }
}

String getTrackTypeForValueTypeName(typeName) {
  switch (typeName.toLowerCase()) {
    case 'scalar':
    case 'double':
    case 'float':
    case 'number':
    case 'integer':
      return "NumberKeyframeTrack";

    case 'vector':
    case 'vector2':
    case 'vector3':
    case 'vector4':
      return "VectorKeyframeTrack";

    case 'color':
      return "ColorKeyframeTrack";

    case 'quaternion':
      return "QuaternionKeyframeTrack";

    case 'bool':
    case 'boolean':
      return "BooleanKeyframeTrack";

    case 'string':
      return "StringKeyframeTrack";
  }

  throw ('three.KeyframeTrack: Unsupported typeName: $typeName');
}

parseKeyframeTrack(json) {
  if (json.type == null) {
    throw ('three.KeyframeTrack: track type undefined, can not parse');
  }

  var trackType = getTrackTypeForValueTypeName(json.type);

  if (json.times == null) {
    const times = [], values = [];

    AnimationUtils.flattenJSON(json.keys, times, values, 'value');

    json.times = times;
    json.values = values;
  }

  // derived classes can define a static parse method
  // if ( trackType.parse != null ) {
  // 	return trackType.parse( json );
  // } else {
  // 	// by default, we assume a constructor compatible with the base
  // 	return new trackType( json.name, json.times, json.values, json.interpolation );
  // }

  if (trackType == "NumberKeyframeTrack") {
    return NumberKeyframeTrack(json.name, json.times, json.values, json.interpolation);
  } else if (trackType == "VectorKeyframeTrack") {
    return VectorKeyframeTrack(json.name, json.times, json.values, json.interpolation);
  } else if (trackType == "ColorKeyframeTrack") {
    return ColorKeyframeTrack(json.name, json.times, json.values, json.interpolation);
  } else if (trackType == "QuaternionKeyframeTrack") {
    return QuaternionKeyframeTrack(json.name, json.times, json.values, json.interpolation);
  } else if (trackType == "BooleanKeyframeTrack") {
    return BooleanKeyframeTrack(json.name, json.times, json.values, json.interpolation);
  } else if (trackType == "StringKeyframeTrack") {
    return StringKeyframeTrack(json.name, json.times, json.values, json.interpolation);
  } else {
    throw ("AnimationClip.parseKeyframeTrack trackType: $trackType ");
  }
}
