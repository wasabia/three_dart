part of three_animation;

class AnimationMixer with EventDispatcher {
  num time = 0.0;
  num timeScale = 1.0;

  dynamic _root;
  int _accuIndex = 0;

  late List _actions;
  late int _nActiveActions;
  late Map _actionsByClip;
  late List _bindings;
  late int _nActiveBindings;
  late Map _bindingsByRootAndName;
  late List _controlInterpolants;
  late int _nActiveControlInterpolants;

  final _controlInterpolantsResultBuffer = List<num>.filled(1, 0);

  AnimationMixer(root) {
    _root = root;
    _initMemoryManager();
  }

  _bindAction(action, prototypeAction) {
    var root = action._localRoot ?? _root,
        tracks = action._clip.tracks,
        nTracks = tracks.length,
        bindings = action._propertyBindings,
        interpolants = action._interpolants,
        rootUuid = root.uuid,
        bindingsByRoot = _bindingsByRootAndName;

    var bindingsByName = bindingsByRoot[rootUuid];

    if (bindingsByName == null) {
      bindingsByName = {};
      bindingsByRoot[rootUuid] = bindingsByName;
    }

    for (var i = 0; i != nTracks; ++i) {
      var track = tracks[i], trackName = track.name;

      var binding = bindingsByName[trackName];

      if (binding != null) {
        ++binding.referenceCount;
        bindings[i] = binding;
      } else {
        binding = bindings[i];

        if (binding != null) {
          // existing binding, make sure the cache knows

          if (binding._cacheIndex == null) {
            ++binding.referenceCount;
            _addInactiveBinding(binding, rootUuid, trackName);
          }

          continue;
        }

        var path = prototypeAction != null
            ? prototypeAction._propertyBindings[i].binding.parsedPath
            : null;

        binding = PropertyMixer(
            PropertyBinding.create(root, trackName, path),
            track.ValueTypeName,
            track.getValueSize());

        ++binding.referenceCount;
        _addInactiveBinding(binding, rootUuid, trackName);

        bindings[i] = binding;
      }

      interpolants[i].resultBuffer = binding.buffer;
    }
  }

  _activateAction(action) {
    if (!_isActiveAction(action)) {
      if (action._cacheIndex == null) {
        // this action has been forgotten by the cache, but the user
        // appears to be still using it -> rebind

        var rootUuid = (action._localRoot ?? _root).uuid,
            clipUuid = action._clip.uuid,
            actionsForClip = _actionsByClip[clipUuid];

        _bindAction(
            action, actionsForClip && actionsForClip.knownActions[0]);

        _addInactiveAction(action, clipUuid, rootUuid);
      }

      var bindings = action._propertyBindings;

      // increment reference counts / sort out state
      for (var i = 0, n = bindings.length; i != n; ++i) {
        var binding = bindings[i];

        if (binding.useCount++ == 0) {
          _lendBinding(binding);
          binding.saveOriginalState();
        }
      }

      _lendAction(action);
    }
  }

  _deactivateAction(action) {
    if (_isActiveAction(action)) {
      var bindings = action._propertyBindings;

      // decrement reference counts / sort out state
      for (var i = 0, n = bindings.length; i != n; ++i) {
        var binding = bindings[i];

        if (--binding.useCount == 0) {
          binding.restoreOriginalState();
          _takeBackBinding(binding);
        }
      }

      _takeBackAction(action);
    }
  }

  // Memory manager

  _initMemoryManager() {
    _actions = []; // 'nActiveActions' followed by inactive ones
    _nActiveActions = 0;

    _actionsByClip = {};
    // inside:
    // {
    // 	knownActions: Array< AnimationAction > - used as prototypes
    // 	actionByRoot: AnimationAction - lookup
    // }

    _bindings = []; // 'nActiveBindings' followed by inactive ones
    _nActiveBindings = 0;

    _bindingsByRootAndName = {}; // inside: Map< name, PropertyMixer >

    _controlInterpolants = []; // same game as above
    _nActiveControlInterpolants = 0;

    var scope = this;

    // this.stats = {

    // 	actions: {
    // 		get total() {

    // 			return scope._actions.length;

    // 		},
    // 		get inUse() {

    // 			return scope._nActiveActions;

    // 		}
    // 	},
    // 	bindings: {
    // 		get total() {

    // 			return scope._bindings.length;

    // 		},
    // 		get inUse() {

    // 			return scope._nActiveBindings;

    // 		}
    // 	},
    // 	controlInterpolants: {
    // 		get total() {

    // 			return scope._controlInterpolants.length;

    // 		},
    // 		get inUse() {

    // 			return scope._nActiveControlInterpolants;

    // 		}
    // 	}

    // };
  }

  // Memory management for AnimationAction objects

  _isActiveAction(action) {
    var index = action._cacheIndex;
    return index != null && index < _nActiveActions;
  }

  _addInactiveAction(AnimationAction action, clipUuid, rootUuid) {
    var actions = _actions, actionsByClip = _actionsByClip;

    var actionsForClip = actionsByClip[clipUuid];

    if (actionsForClip == null) {
      actionsForClip = {
        "knownActions": [action],
        "actionByRoot": {}
      };

      action._byClipCacheIndex = 0;

      actionsByClip[clipUuid] = actionsForClip;
    } else {
      var knownActions = actionsForClip.knownActions;

      action._byClipCacheIndex = knownActions.length;
      knownActions.add(action);
    }

    action._cacheIndex = actions.length;
    actions.add(action);

    actionsForClip["actionByRoot"][rootUuid] = action;
  }

  _removeInactiveAction(AnimationAction action) {
    var actions = _actions,
        lastInactiveAction = actions[actions.length - 1],
        cacheIndex = action._cacheIndex;

    lastInactiveAction._cacheIndex = cacheIndex;
    actions[cacheIndex] = lastInactiveAction;
    pop(actions);

    action._cacheIndex = null;

    var clipUuid = action._clip.uuid,
        actionsByClip = _actionsByClip,
        actionsForClip = actionsByClip[clipUuid],
        knownActionsForClip = actionsForClip.knownActions,
        lastKnownAction = knownActionsForClip[knownActionsForClip.length - 1],
        byClipCacheIndex = action._byClipCacheIndex;

    lastKnownAction._byClipCacheIndex = byClipCacheIndex;
    knownActionsForClip[byClipCacheIndex] = lastKnownAction;
    knownActionsForClip.pop();

    action._byClipCacheIndex = null;

    Map actionByRoot = actionsForClip.actionByRoot;
    var rootUuid = (action._localRoot ?? _root).uuid;

    // delete actionByRoot[ rootUuid ];
    actionByRoot.remove(rootUuid);

    if (knownActionsForClip.length == 0) {
      // delete actionsByClip[ clipUuid ];
      actionsByClip.remove(clipUuid);
    }

    _removeInactiveBindingsForAction(action);
  }

  _removeInactiveBindingsForAction(action) {
    var bindings = action._propertyBindings;

    for (var i = 0, n = bindings.length; i != n; ++i) {
      var binding = bindings[i];

      if (--binding.referenceCount == 0) {
        _removeInactiveBinding(binding);
      }
    }
  }

  _lendAction(action) {
    // [ active actions |  inactive actions  ]
    // [  active actions >| inactive actions ]
    //                 s        a
    //                  <-swap->
    //                 a        s

    var actions = _actions,
        prevIndex = action._cacheIndex,
        lastActiveIndex = _nActiveActions++,
        firstInactiveAction = actions[lastActiveIndex];

    action._cacheIndex = lastActiveIndex;
    actions[lastActiveIndex] = action;

    firstInactiveAction._cacheIndex = prevIndex;
    actions[prevIndex] = firstInactiveAction;
  }

  _takeBackAction(action) {
    // [  active actions  | inactive actions ]
    // [ active actions |< inactive actions  ]
    //        a        s
    //         <-swap->
    //        s        a

    var actions = _actions,
        prevIndex = action._cacheIndex,
        firstInactiveIndex = --_nActiveActions,
        lastActiveAction = actions[firstInactiveIndex];

    action._cacheIndex = firstInactiveIndex;
    actions[firstInactiveIndex] = action;

    lastActiveAction._cacheIndex = prevIndex;
    actions[prevIndex] = lastActiveAction;
  }

  // Memory management for PropertyMixer objects

  _addInactiveBinding(binding, rootUuid, trackName) {
    var bindingsByRoot = _bindingsByRootAndName, bindings = _bindings;

    var bindingByName = bindingsByRoot[rootUuid];

    if (bindingByName == null) {
      bindingByName = {};
      bindingsByRoot[rootUuid] = bindingByName;
    }

    bindingByName[trackName] = binding;

    binding._cacheIndex = bindings.length;
    bindings.add(binding);
  }

  _removeInactiveBinding(binding) {
    var bindings = _bindings,
        propBinding = binding.binding,
        rootUuid = propBinding.rootNode.uuid,
        trackName = propBinding.path,
        bindingsByRoot = _bindingsByRootAndName,
        bindingByName = bindingsByRoot[rootUuid],
        lastInactiveBinding = bindings[bindings.length - 1],
        cacheIndex = binding._cacheIndex;

    lastInactiveBinding._cacheIndex = cacheIndex;
    bindings[cacheIndex] = lastInactiveBinding;
    pop(bindings);

    // delete bindingByName[ trackName ];
    bindingByName.remove(trackName);

    if (bindingByName.keys.length == 0) {
      // delete bindingsByRoot[ rootUuid ];
      bindingsByRoot.remove(rootUuid);
    }
  }

  _lendBinding(binding) {
    var bindings = _bindings,
        prevIndex = binding._cacheIndex,
        lastActiveIndex = _nActiveBindings++,
        firstInactiveBinding = bindings[lastActiveIndex];

    binding._cacheIndex = lastActiveIndex;
    bindings[lastActiveIndex] = binding;

    firstInactiveBinding._cacheIndex = prevIndex;
    bindings[prevIndex] = firstInactiveBinding;
  }

  _takeBackBinding(binding) {
    var bindings = _bindings,
        prevIndex = binding._cacheIndex,
        firstInactiveIndex = --_nActiveBindings,
        lastActiveBinding = bindings[firstInactiveIndex];

    binding._cacheIndex = firstInactiveIndex;
    bindings[firstInactiveIndex] = binding;

    lastActiveBinding._cacheIndex = prevIndex;
    bindings[prevIndex] = lastActiveBinding;
  }

  // Memory management of Interpolants for weight and time scale

  _lendControlInterpolant() {
    var interpolants = _controlInterpolants,
        lastActiveIndex = _nActiveControlInterpolants++;

    var interpolant = interpolants[lastActiveIndex];

    if (interpolant == null) {
      print(" AnimationMixer LinearInterpolant init todo   ");
      interpolant = LinearInterpolant(List<num>.filled(2, 0),
          List<num>.filled(2, 0), 1, _controlInterpolantsResultBuffer);

      interpolant.__cacheIndex = lastActiveIndex;
      interpolants[lastActiveIndex] = interpolant;
    }

    return interpolant;
  }

  _takeBackControlInterpolant(interpolant) {
    var interpolants = _controlInterpolants,
        prevIndex = interpolant.__cacheIndex,
        firstInactiveIndex = --_nActiveControlInterpolants,
        lastActiveInterpolant = interpolants[firstInactiveIndex];

    interpolant.__cacheIndex = firstInactiveIndex;
    interpolants[firstInactiveIndex] = interpolant;

    lastActiveInterpolant.__cacheIndex = prevIndex;
    interpolants[prevIndex] = lastActiveInterpolant;
  }

  // return an action for a clip optionally using a custom root target
  // object (this method allocates a lot of dynamic memory in case a
  // previously unknown clip/root combination is specified)
  clipAction(clip, [optionalRoot, blendMode]) {
    var root = optionalRoot ?? _root;
    var rootUuid = root.uuid;

    AnimationClip? clipObject =
        clip is String ? AnimationClip.findByName(root, clip) : clip;

    var clipUuid = clipObject != null ? clipObject.uuid : clip;

    var actionsForClip = _actionsByClip[clipUuid];
    var prototypeAction;

    if (blendMode == null) {
      if (clipObject != null) {
        blendMode = clipObject.blendMode;
      } else {
        blendMode = NormalAnimationBlendMode;
      }
    }

    if (actionsForClip != null) {
      var existingAction = actionsForClip.actionByRoot[rootUuid];

      if (existingAction != null && existingAction.blendMode == blendMode) {
        return existingAction;
      }

      // we know the clip, so we don't have to parse all
      // the bindings again but can just copy
      prototypeAction = actionsForClip.knownActions[0];

      // also, take the clip from the prototype action
      clipObject ??= prototypeAction._clip;
    }

    // clip must be known when specified via string
    if (clipObject == null) return null;

    // allocate all resources required to run it
    var newAction = AnimationAction(this, clipObject,
        localRoot: optionalRoot, blendMode: blendMode);

    _bindAction(newAction, prototypeAction);

    // and make the action known to the memory manager
    _addInactiveAction(newAction, clipUuid, rootUuid);

    return newAction;
  }

  // get an existing action
  existingAction(clip, optionalRoot) {
    var root = optionalRoot ?? _root;
    var rootUuid = root.uuid;

    var clipObject = clip.runtimeType.toString() == 'String'
            ? AnimationClip.findByName(root, clip)
            : clip,
        clipUuid = clipObject ? clipObject.uuid : clip,
        actionsForClip = _actionsByClip[clipUuid];

    if (actionsForClip != null) {
      return actionsForClip.actionByRoot[rootUuid];
    }

    return null;
  }

  // deactivates all previously scheduled actions
  stopAllAction() {
    var actions = _actions, nActions = _nActiveActions;

    for (var i = nActions - 1; i >= 0; --i) {
      actions[i].stop();
    }

    return this;
  }

  // advance the time and update apply the animation
  update(deltaTime) {
    deltaTime *= timeScale;

    var actions = _actions,
        nActions = _nActiveActions,
        time = this.time += deltaTime,
        timeDirection = Math.sign(deltaTime),
        accuIndex = _accuIndex ^= 1;

    // run active actions

    for (var i = 0; i != nActions; ++i) {
      var action = actions[i];

      // print(" i: ${i} action: ${action} ");

      action._update(time, deltaTime, timeDirection, accuIndex);
    }

    // update scene graph

    var bindings = _bindings, nBindings = _nActiveBindings;

    for (var i = 0; i != nBindings; ++i) {
      var _binding = bindings[i];

      // print(" i: ${i} bindings: ${ _binding } ");
      // print( _binding.buffer );

      _binding.apply(accuIndex);
    }

    return this;
  }

  // Allows you to seek to a specific time in an animation.
  setTime(timeInSeconds) {
    time = 0; // Zero out time attribute for AnimationMixer object;
    for (var i = 0; i < _actions.length; i++) {
      _actions[i].time =
          0; // Zero out time attribute for all associated AnimationAction objects.

    }

    return update(
        timeInSeconds); // Update used to set exact time. Returns "this" AnimationMixer object.
  }

  // return this mixer's root target object
  getRoot() {
    return _root;
  }

  // free all resources specific to a particular clip
  uncacheClip(clip) {
    var actions = _actions,
        clipUuid = clip.uuid,
        actionsByClip = _actionsByClip,
        actionsForClip = actionsByClip[clipUuid];

    if (actionsForClip != null) {
      // note: just calling _removeInactiveAction would mess up the
      // iteration state and also require updating the state we can
      // just throw away

      var actionsToRemove = actionsForClip.knownActions;

      for (var i = 0, n = actionsToRemove.length; i != n; ++i) {
        var action = actionsToRemove[i];

        _deactivateAction(action);

        var cacheIndex = action._cacheIndex,
            lastInactiveAction = actions[actions.length - 1];

        action._cacheIndex = null;
        action._byClipCacheIndex = null;

        lastInactiveAction._cacheIndex = cacheIndex;
        actions[cacheIndex] = lastInactiveAction;
        pop(actions);

        _removeInactiveBindingsForAction(action);
      }

      // delete actionsByClip[ clipUuid ];
      actionsByClip.remove(clipUuid);
    }
  }

  // free all resources specific to a particular root target object
  uncacheRoot(root) {
    var rootUuid = root.uuid, actionsByClip = _actionsByClip;

    // for ( var clipUuid in actionsByClip ) {
    actionsByClip.forEach((clipUuid, value) {
      var actionByRoot = actionsByClip[clipUuid].actionByRoot,
          action = actionByRoot[rootUuid];

      if (action != null) {
        _deactivateAction(action);
        _removeInactiveAction(action);
      }
    });

    var bindingsByRoot = _bindingsByRootAndName,
        bindingByName = bindingsByRoot[rootUuid];

    if (bindingByName != null) {
      for (var trackName in bindingByName) {
        var binding = bindingByName[trackName];
        binding.restoreOriginalState();
        _removeInactiveBinding(binding);
      }
    }
  }

  // remove a targeted clip from the cache
  uncacheAction(clip, [optionalRoot]) {
    var action = existingAction(clip, optionalRoot);

    if (action != null) {
      _deactivateAction(action);
      _removeInactiveAction(action);
    }
  }
}
