import 'package:three_dart/three3d/animation/animation_clip.dart';
import 'package:three_dart/three3d/animation/animation_mixer.dart';
import 'package:three_dart/three3d/animation/property_mixer.dart';
import 'package:three_dart/three3d/constants.dart';
import 'package:three_dart/three3d/core/index.dart';
import 'package:three_dart/three3d/math/index.dart';

class AnimationAction {
  late num time;
  late num timeScale;
  late AnimationMixer mixer;
  late AnimationClip clip;
  late Object3D? localRoot;
  late int blendMode;
  late Map _interpolantSettings;
  late List<Interpolant?> interpolants;
  late List<PropertyMixer?> propertyBindings;
  late dynamic cacheIndex;
  late dynamic byClipCacheIndex;
  late dynamic _timeScaleInterpolant;
  late dynamic _weightInterpolant;
  late int loop;
  late int _loopCount;
  late num? _startTime;
  late num _effectiveTimeScale;
  late num weight;
  late num _effectiveWeight;
  late num repetitions;
  late bool paused;
  late bool enabled;
  late bool clampWhenFinished;
  late bool zeroSlopeAtStart;
  late bool zeroSlopeAtEnd;

  AnimationAction(
    this.mixer,
    this.clip, {
    this.localRoot,
    int? blendMode,
  }) : blendMode = blendMode ?? clip.blendMode {
    var tracks = clip.tracks, nTracks = tracks.length;

    interpolants = List<Interpolant?>.filled(nTracks, null);

    var interpolantSettings = {"endingStart": ZeroCurvatureEnding, "endingEnd": ZeroCurvatureEnding};

    for (var i = 0; i != nTracks; ++i) {
      var interpolant = tracks[i].createInterpolant!(null);
      interpolants[i] = interpolant;
      interpolant.settings = interpolantSettings;
    }

    _interpolantSettings = interpolantSettings;

    // inside: PropertyMixer (managed by the mixer)
    propertyBindings = List<PropertyMixer?>.filled(nTracks, null);

    cacheIndex = null; // for the memory manager
    byClipCacheIndex = null; // for the memory manager

    _timeScaleInterpolant = null;
    _weightInterpolant = null;

    loop = LoopRepeat;
    _loopCount = -1;

    // global mixer time when the action is to be started
    // it's set back to 'null' upon start of the action
    _startTime = null;

    // scaled local time of the action
    // gets clamped or wrapped to 0..clip.duration according to loop
    time = 0;

    timeScale = 1;
    _effectiveTimeScale = 1;

    weight = 1;
    _effectiveWeight = 1;

    repetitions = double.infinity; // no. of repetitions when looping

    paused = false; // true -> zero effective time scale
    enabled = true; // false -> zero effective weight

    clampWhenFinished = false; // keep feeding the last frame?

    zeroSlopeAtStart = true; // for smooth interpolation w/o separate
    zeroSlopeAtEnd = true; // clips for start, loop and end
  }

  // State & Scheduling

  play() {
    mixer.activateAction(this);

    return this;
  }

  stop() {
    mixer.deactivateAction(this);

    return reset();
  }

  reset() {
    paused = false;
    enabled = true;

    time = 0; // restart clip
    _loopCount = -1; // forget previous loops
    _startTime = null; // forget scheduling

    return stopFading().stopWarping();
  }

  isRunning() {
    return enabled && !paused && timeScale != 0 && _startTime == null && mixer.isActiveAction(this);
  }

  // return true when play has been called
  isScheduled() {
    return mixer.isActiveAction(this);
  }

  startAt(time) {
    _startTime = time;

    return this;
  }

  setLoop(mode, repetitions) {
    loop = mode;
    this.repetitions = repetitions;

    return this;
  }

  // Weight

  // set the weight stopping any scheduled fading
  // although .enabled = false yields an effective weight of zero, this
  // method does *not* change .enabled, because it would be confusing
  setEffectiveWeight(weight) {
    this.weight = weight;

    // note: same logic as when updated at runtime
    _effectiveWeight = enabled ? weight : 0;

    return stopFading();
  }

  // return the weight considering fading and .enabled
  getEffectiveWeight() {
    return _effectiveWeight;
  }

  fadeIn(duration) {
    return _scheduleFading(duration, 0, 1);
  }

  fadeOut(duration) {
    return _scheduleFading(duration, 1, 0);
  }

  crossFadeFrom(fadeOutAction, duration, warp) {
    fadeOutAction.fadeOut(duration);
    fadeIn(duration);

    if (warp) {
      var fadeInDuration = clip.duration,
          fadeOutDuration = fadeOutAction.clip.duration,
          startEndRatio = fadeOutDuration / fadeInDuration,
          endStartRatio = fadeInDuration / fadeOutDuration;

      fadeOutAction.warp(1.0, startEndRatio, duration);
      this.warp(endStartRatio, 1.0, duration);
    }

    return this;
  }

  crossFadeTo(fadeInAction, duration, warp) {
    return fadeInAction.crossFadeFrom(this, duration, warp);
  }

  stopFading() {
    var weightInterpolant = _weightInterpolant;

    if (weightInterpolant != null) {
      _weightInterpolant = null;
      mixer.takeBackControlInterpolant(weightInterpolant);
    }

    return this;
  }

  // Time Scale Control

  // set the time scale stopping any scheduled warping
  // although .paused = true yields an effective time scale of zero, this
  // method does *not* change .paused, because it would be confusing
  setEffectiveTimeScale(timeScale) {
    this.timeScale = timeScale;
    _effectiveTimeScale = paused ? 0 : timeScale;

    return stopWarping();
  }

  // return the time scale considering warping and .paused
  getEffectiveTimeScale() {
    return _effectiveTimeScale;
  }

  setDuration(duration) {
    timeScale = clip.duration / duration;

    return stopWarping();
  }

  syncWith(action) {
    time = action.time;
    timeScale = action.timeScale;

    return stopWarping();
  }

  halt(duration) {
    return warp(_effectiveTimeScale, 0, duration);
  }

  warp(startTimeScale, endTimeScale, duration) {
    var now = mixer.time, timeScale = this.timeScale;

    var interpolant = _timeScaleInterpolant;

    if (interpolant == null) {
      interpolant = mixer.lendControlInterpolant();
      _timeScaleInterpolant = interpolant;
    }

    var times = interpolant.parameterPositions, values = interpolant.sampleValues;

    times[0] = now;
    times[1] = now + duration;

    values[0] = startTimeScale / timeScale;
    values[1] = endTimeScale / timeScale;

    return this;
  }

  stopWarping() {
    var timeScaleInterpolant = _timeScaleInterpolant;

    if (timeScaleInterpolant != null) {
      _timeScaleInterpolant = null;
      mixer.takeBackControlInterpolant(timeScaleInterpolant);
    }

    return this;
  }

  // Object Accessors

  getMixer() {
    return mixer;
  }

  getClip() {
    return clip;
  }

  getRoot() {
    return localRoot ?? mixer.root;
  }

  // Interna

  update(time, deltaTime, timeDirection, accuIndex) {
    // called by the mixer

    if (!enabled) {
      // call ._updateWeight() to update ._effectiveWeight

      _updateWeight(time);
      return;
    }

    var startTime = _startTime;

    if (startTime != null) {
      // check for scheduled start of action

      var timeRunning = (time - startTime) * timeDirection;
      if (timeRunning < 0 || timeDirection == 0) {
        return; // yet to come / don't decide when delta = 0

      }

      // start

      _startTime = null; // unschedule
      deltaTime = timeDirection * timeRunning;
    }

    // apply time scale and advance time

    deltaTime *= _updateTimeScale(time);
    var clipTime = _updateTime(deltaTime);

    // note: _updateTime may disable the action resulting in
    // an effective weight of 0

    var weight = _updateWeight(time);

    if (weight > 0) {
      var propertyMixers = propertyBindings;

      switch (blendMode) {
        case AdditiveAnimationBlendMode:
          for (var j = 0, m = interpolants.length; j != m; ++j) {
            // print("AnimationAction j: ${j} ${interpolants[ j ]} ${propertyMixers[ j ]} ");

            interpolants[j]!.evaluate(clipTime);
            propertyMixers[j]!.accumulateAdditive(weight);
          }

          break;

        case NormalAnimationBlendMode:
        default:
          for (var j = 0, m = interpolants.length; j != m; ++j) {
            // print("AnimationAction22 j: ${j} ${interpolants[ j ]} ${propertyMixers[ j ]} ");

            interpolants[j]!.evaluate(clipTime);

            //  print("AnimationAction22 j: ${j} ----- ");

            propertyMixers[j]!.accumulate(accuIndex, weight);
          }
      }
    }
  }

  _updateWeight(time) {
    num weight = 0;

    if (enabled) {
      weight = this.weight;
      var interpolant = _weightInterpolant;

      if (interpolant != null) {
        var interpolantValue = interpolant.evaluate(time)[0];

        weight *= interpolantValue;

        if (time > interpolant.parameterPositions[1]) {
          stopFading();

          if (interpolantValue == 0) {
            // faded out, disable
            enabled = false;
          }
        }
      }
    }

    _effectiveWeight = weight;
    return weight;
  }

  _updateTimeScale(time) {
    num timeScale = 0;

    if (!paused) {
      timeScale = this.timeScale;

      var interpolant = _timeScaleInterpolant;

      if (interpolant != null) {
        var interpolantValue = interpolant.evaluate(time)[0];

        timeScale *= interpolantValue;

        if (time > interpolant.parameterPositions[1]) {
          stopWarping();

          if (timeScale == 0) {
            // motion has halted, pause
            paused = true;
          } else {
            // warp done - apply final time scale
            this.timeScale = timeScale;
          }
        }
      }
    }

    _effectiveTimeScale = timeScale;
    return timeScale;
  }

  _updateTime(deltaTime) {
    var duration = clip.duration;
    var loop = this.loop;

    var time = this.time + deltaTime;
    var loopCount = _loopCount;

    var pingPong = (loop == LoopPingPong);

    if (deltaTime == 0) {
      if (loopCount == -1) return time;

      return (pingPong && (loopCount & 1) == 1) ? duration - time : time;
    }

    if (loop == LoopOnce) {
      if (loopCount == -1) {
        // just started

        _loopCount = 0;
        _setEndings(true, true, false);
      }

      handle_stop:
      {
        if (time >= duration) {
          time = duration;
        } else if (time < 0) {
          time = 0;
        } else {
          this.time = time;

          break handle_stop;
        }

        if (clampWhenFinished) {
          paused = true;
        } else {
          enabled = false;
        }

        this.time = time;

        mixer.dispatchEvent(Event({"type": 'finished', "action": this, "direction": deltaTime < 0 ? -1 : 1}));
      }
    } else {
      // repetitive Repeat or PingPong

      if (loopCount == -1) {
        // just started

        if (deltaTime >= 0) {
          loopCount = 0;

          _setEndings(true, repetitions == 0, pingPong);
        } else {
          // when looping in reverse direction, the initial
          // transition through zero counts as a repetition,
          // so leave loopCount at -1

          _setEndings(repetitions == 0, true, pingPong);
        }
      }

      if (time >= duration || time < 0) {
        // wrap around

        print(" duration: $duration ");

        int loopDelta = Math.floor(time / duration); // signed
        time -= duration * loopDelta;

        loopCount += loopDelta.abs();

        var pending = repetitions - loopCount;

        if (pending <= 0) {
          // have to stop (switch state, clamp time, fire event)

          if (clampWhenFinished) {
            paused = true;
          } else {
            enabled = false;
          }

          time = deltaTime > 0 ? duration : 0;

          this.time = time;

          mixer.dispatchEvent(Event({"type": 'finished', "action": this, "direction": deltaTime > 0 ? 1 : -1}));
        } else {
          // keep running

          if (pending == 1) {
            // entering the last round

            var atStart = deltaTime < 0;
            _setEndings(atStart, !atStart, pingPong);
          } else {
            _setEndings(false, false, pingPong);
          }

          _loopCount = loopCount;

          this.time = time;

          mixer.dispatchEvent(Event({"type": 'loop', "action": this, "loopDelta": loopDelta}));
        }
      } else {
        this.time = time;
      }

      if (pingPong && (loopCount & 1) == 1) {
        // invert time for the "pong round"

        return duration - time;
      }
    }

    return time;
  }

  _setEndings(atStart, atEnd, pingPong) {
    var settings = _interpolantSettings;

    if (pingPong) {
      settings["endingStart"] = ZeroSlopeEnding;
      settings["endingEnd"] = ZeroSlopeEnding;
    } else {
      // assuming for LoopOnce atStart == atEnd == true

      if (atStart) {
        settings["endingStart"] = zeroSlopeAtStart ? ZeroSlopeEnding : ZeroCurvatureEnding;
      } else {
        settings["endingStart"] = WrapAroundEnding;
      }

      if (atEnd) {
        settings["endingEnd"] = zeroSlopeAtEnd ? ZeroSlopeEnding : ZeroCurvatureEnding;
      } else {
        settings["endingEnd"] = WrapAroundEnding;
      }
    }
  }

  _scheduleFading(duration, weightNow, weightThen) {
    var now = mixer.time;
    var interpolant = _weightInterpolant;

    if (interpolant == null) {
      interpolant = mixer.lendControlInterpolant();
      _weightInterpolant = interpolant;
    }

    var times = interpolant.parameterPositions, values = interpolant.sampleValues;

    times[0] = now;
    values[0] = weightNow;
    times[1] = now + duration;
    values[1] = weightThen;

    return this;
  }
}
