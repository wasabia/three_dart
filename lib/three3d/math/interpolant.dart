/// Abstract base class of interpolants over parametric samples.
///
/// The parameter domain is one dimensional, typically the time or a path
/// along a curve defined by the data.
///
/// The sample values can have any dimensionality and derived classes may
/// apply special interpretations to the data.
///
/// This class provides the interval seek in a Template Method, deferring
/// the actual interpolation to derived classes.
///
/// Time complexity is O(1) for linear access crossing at most two points
/// and O(log N) for random access, where N is the number of positions.
///
/// References:
///
/// 		http://www.oodesign.com/template-method-pattern.html
///

class Interpolant {
  late dynamic parameterPositions;
  int cachedIndex = 0;
  late dynamic resultBuffer;
  late dynamic sampleValues;
  late dynamic valueSize;
  late dynamic settings;

  // --- Protected interface

  dynamic DefaultSettings = {};

  Interpolant(this.parameterPositions, this.sampleValues, this.valueSize,
      this.resultBuffer);

  evaluate(double t) {
    var pp = parameterPositions;
    int i1 = cachedIndex;

    num? t1;
    num? t0;

    if (i1 < pp.length) {
      t1 = pp[i1];
    }
    if (i1 - 1 >= 0) {
      t0 = pp[i1 - 1];
    }

    validate_interval:
    {
      seek:
      {
        int right;

        linear_scan:
        {
          //- See http://jsperf.com/comparison-to-undefined/3
          //- slower code:
          //-
          //- 				if ( t >= t1 || t1 == null ) {
          forward_scan:
          if (t1 == null || t >= t1) {
            for (var giveUpAt = i1 + 2;;) {
              if (t1 == null) {
                if (t < t0!) break forward_scan;

                // after end

                i1 = pp.length;
                cachedIndex = i1;
                return copySampleValue_(i1 - 1);
              }

              if (i1 == giveUpAt) break; // this loop

              t0 = t1;

              int _idx = ++i1;

              if (_idx < pp.length) {
                t1 = pp[_idx];
              } else {
                t1 = null;
              }

              if (t1 != null && t < t1) {
                // we have arrived at the sought interval
                break seek;
              }
            }

            // prepare binary search on the right side of the index
            right = pp.length;
            break linear_scan;
          }

          //- slower code:
          //-					if ( t < t0 || t0 == null ) {
          if (t0 == null || !(t >= t0)) {
            // looping?

            var t1global = pp[1];

            if (t < t1global) {
              i1 = 2; // + 1, using the scan for the details
              t0 = t1global;
            }

            // linear reverse scan

            for (var giveUpAt = i1 - 2;;) {
              if (t0 == null) {
                // before start

                cachedIndex = 0;
                return copySampleValue_(0);
              }

              if (i1 == giveUpAt) break; // this loop

              t1 = t0;

              int iii = --i1 - 1;
              if (iii < 0) {
                t0 = null;
              } else {
                t0 = pp[iii];
              }

              if (t0 != null && t >= t0) {
                // we have arrived at the sought interval
                break seek;
              }
            }

            // prepare binary search on the left side of the index
            right = i1;
            i1 = 0;
            break linear_scan;
          }

          // the interval is valid

          break validate_interval;
        } // linear scan

        // binary search

        while (i1 < right) {
          var mid = (i1 + right) >> 1;

          // print(" Interpolant i1: ${i1} right: ${right} pp: ${pp.length} mid: ${mid} ");

          if (t < pp[mid]) {
            right = mid;
          } else {
            i1 = mid + 1;
          }
        }

        t1 = null;
        t0 = null;

        if (i1 < pp.length) {
          t1 = pp[i1];
        }
        if (i1 - 1 < pp.length) {
          t0 = pp[i1 - 1];
        }

        // check boundary cases, again

        if (t0 == null) {
          cachedIndex = 0;
          return copySampleValue_(0);
        }

        if (t1 == null) {
          i1 = pp.length;
          cachedIndex = i1;
          return copySampleValue_(i1 - 1);
        }
      } // seek

      cachedIndex = i1;

      intervalChanged(i1, t0, t1);
    } // validate_interval

    return interpolate(i1, t0, t, t1!);
  }

  getSettings() {
    return settings ?? DefaultSettings;
  }

  copySampleValue_(num index) {
    // copies a sample value to the result buffer

    var result = resultBuffer,
        values = sampleValues,
        stride = valueSize,
        offset = index * stride;

    for (var i = 0; i != stride; ++i) {
      result[i] = values[offset + i];
    }

    return result;
  }

  // Template methods for derived classes:

  interpolate(int i1, num t0, num t, num t1) {
    throw ('call to abstract method');
    // implementations shall return this.resultBuffer
  }

  intervalChanged(v1, v2, v3) {
    // empty
  }

}
