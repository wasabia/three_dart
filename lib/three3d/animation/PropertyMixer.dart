part of three_animation;

class PropertyMixer {
  late dynamic binding;
  late int valueSize;
  late Function _mixBufferRegion;
  late Function _mixBufferRegionAdditive;
  late Function _setIdentity;
  late int _origIndex;
  late int _addIndex;
  late int _workIndex;
  late int useCount;
  late int referenceCount;
  late int cumulativeWeight;
  late int cumulativeWeightAdditive;
  late List buffer;
  late int _cacheIndex;

  PropertyMixer(binding, typeName, valueSize) {
    this.binding = binding;
    this.valueSize = valueSize;

    var mixFunction, mixFunctionAdditive, setIdentity;

    // buffer layout: [ incoming | accu0 | accu1 | orig | addAccu | (optional work) ]
    //
    // interpolators can use .buffer as their .result
    // the data then goes to 'incoming'
    //
    // 'accu0' and 'accu1' are used frame-interleaved for
    // the cumulative result and are compared to detect
    // changes
    //
    // 'orig' stores the original state of the property
    //
    // 'add' is used for additive cumulative results
    //
    // 'work' is optional and is only present for quaternion types. It is used
    // to store intermediate quaternion multiplication results

    switch (typeName) {
      case 'quaternion':
        mixFunction = _slerp;
        mixFunctionAdditive = _slerpAdditive;
        setIdentity = _setAdditiveIdentityQuaternion;

        buffer = List<num>.filled(valueSize * 6, 0);
        _workIndex = 5;

        break;

      case 'string':
      case 'bool':
        mixFunction = _select;

        // Use the regular mix function and for additive on these types,
        // additive is not relevant for non-numeric types
        mixFunctionAdditive = _select;

        setIdentity = _setAdditiveIdentityOther;

        print("PropertyMixer  todo  typeName: $typeName");
        buffer = List<String?>.filled(valueSize * 5, null);
        // this.buffer = new Array( valueSize * 5 );

        break;

      default:
        mixFunction = _lerp;
        mixFunctionAdditive = _lerpAdditive;
        setIdentity = _setAdditiveIdentityNumeric;

        buffer = List<num>.filled(valueSize * 5, 0);
    }

    _mixBufferRegion = mixFunction;
    _mixBufferRegionAdditive = mixFunctionAdditive;
    _setIdentity = setIdentity;
    _origIndex = 3;
    _addIndex = 4;

    cumulativeWeight = 0;
    cumulativeWeightAdditive = 0;

    useCount = 0;
    referenceCount = 0;
  }

  // accumulate data in the 'incoming' region into 'accu<i>'
  accumulate(int accuIndex, int weight) {
    // note: happily accumulating nothing when weight = 0, the caller knows
    // the weight and shouldn't have made the call in the first place

    var buffer = this.buffer;

    int stride = valueSize;

    int offset = accuIndex * stride + stride;

    var currentWeight = cumulativeWeight;

    if (currentWeight == 0) {
      // accuN := incoming * weight

      for (var i = 0; i != stride; ++i) {
        buffer[offset + i] = buffer[i];
      }

      currentWeight = weight;
    } else {
      // accuN := accuN + incoming * weight

      currentWeight += weight;
      var mix = weight / currentWeight;
      _mixBufferRegion(buffer, offset, 0, mix, stride);
    }

    cumulativeWeight = currentWeight;
  }

  // accumulate data in the 'incoming' region into 'add'
  accumulateAdditive(int weight) {
    var buffer = this.buffer,
        stride = valueSize,
        offset = stride * _addIndex;

    if (cumulativeWeightAdditive == 0) {
      // add = identity

      _setIdentity();
    }

    // add := add + incoming * weight

    _mixBufferRegionAdditive(buffer, offset, 0, weight, stride);
    cumulativeWeightAdditive += weight;
  }

  // apply the state of 'accu<i>' to the binding when accus differ
  apply(accuIndex) {
    var stride = valueSize,
        buffer = this.buffer,
        offset = accuIndex * stride + stride,
        weight = cumulativeWeight,
        weightAdditive = cumulativeWeightAdditive,
        binding = this.binding;

    cumulativeWeight = 0;
    cumulativeWeightAdditive = 0;

    if (weight < 1) {
      // accuN := accuN + original * ( 1 - cumulativeWeight )

      var originalValueOffset = stride * _origIndex;

      _mixBufferRegion(
          buffer, offset, originalValueOffset, 1 - weight, stride);
    }

    if (weightAdditive > 0) {
      // accuN := accuN + additive accuN

      _mixBufferRegionAdditive(
          buffer, offset, _addIndex * stride, 1, stride);
    }

    for (var i = stride, e = stride + stride; i != e; ++i) {
      if (buffer[i] != buffer[i + stride]) {
        // value has changed -> update scene graph

        binding.setValue(buffer, offset);
        break;
      }
    }
  }

  // remember the state of the bound property and copy it to both accus
  saveOriginalState() {
    var binding = this.binding;

    var buffer = this.buffer,
        stride = valueSize,
        originalValueOffset = stride * _origIndex;

    binding.getValue(buffer, originalValueOffset);

    // accu[0..1] := orig -- initially detect changes against the original
    for (var i = stride, e = originalValueOffset; i != e; ++i) {
      buffer[i] = buffer[originalValueOffset + (i % stride)];
    }

    // Add to identity for additive
    _setIdentity();

    cumulativeWeight = 0;
    cumulativeWeightAdditive = 0;
  }

  // apply the state previously taken via 'saveOriginalState' to the binding
  restoreOriginalState() {
    var originalValueOffset = valueSize * 3;
    binding.setValue(buffer, originalValueOffset);
  }

  _setAdditiveIdentityNumeric() {
    var startIndex = _addIndex * valueSize;
    var endIndex = startIndex + valueSize;

    for (var i = startIndex; i < endIndex; i++) {
      buffer[i] = 0;
    }
  }

  _setAdditiveIdentityQuaternion() {
    _setAdditiveIdentityNumeric();
    buffer[_addIndex * valueSize + 3] = 1;
  }

  _setAdditiveIdentityOther() {
    var startIndex = _origIndex * valueSize;
    var targetIndex = _addIndex * valueSize;

    for (var i = 0; i < valueSize; i++) {
      buffer[targetIndex + i] = buffer[startIndex + i];
    }
  }

  // mix functions

  _select(buffer, dstOffset, srcOffset, t, stride) {
    if (t >= 0.5) {
      for (var i = 0; i != stride; ++i) {
        buffer[dstOffset + i] = buffer[srcOffset + i];
      }
    }
  }

  _slerp(buffer, dstOffset, srcOffset, t) {
    Quaternion.slerpFlat(
        buffer, dstOffset, buffer, dstOffset, buffer, srcOffset, t);
  }

  _slerpAdditive(buffer, dstOffset, srcOffset, t, stride) {
    var workOffset = _workIndex * stride;

    // Store result in intermediate buffer offset
    Quaternion.multiplyQuaternionsFlat(
        buffer, workOffset, buffer, dstOffset, buffer, srcOffset);

    // Slerp to the intermediate result
    Quaternion.slerpFlat(
        buffer, dstOffset, buffer, dstOffset, buffer, workOffset, t);
  }

  _lerp(buffer, dstOffset, srcOffset, t, stride) {
    var s = 1 - t;

    for (var i = 0; i != stride; ++i) {
      var j = dstOffset + i;

      buffer[j] = buffer[j] * s + buffer[srcOffset + i] * t;
    }
  }

  _lerpAdditive(buffer, dstOffset, srcOffset, t, stride) {
    for (var i = 0; i != stride; ++i) {
      var j = dstOffset + i;

      buffer[j] = buffer[j] + buffer[srcOffset + i] * t;
    }
  }
}
