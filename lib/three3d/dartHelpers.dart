// 支持List 自动扩展长度
Function listSetter = (List list, int idx, dynamic? value) {
  if (list.length > idx) {
    list[idx] = value;
  } else if (list.length == idx) {
    list.add(value);
  } else {
    list.addAll(List<num>.filled(idx + 1 - list.length, 0));
    list[idx] = value;
  }
};

// https://github.com/dartist/node_shims/blob/master/lib/src/js.dart

/// JS Patterns
dynamic or(value, defaultValue) => falsey(value)
    ? defaultValue is Function
        ? defaultValue()
        : defaultValue
    : value;

bool falsey(value) =>
    value == null ||
    value == false ||
    value == '' ||
    value == 0 ||
    value == double.nan;

bool truthy(value) => !falsey(value);

/// Arrays
List splice(List list, int index, [num howMany = 0, dynamic elements]) {
  var endIndex = index + howMany.truncate();
  list.removeRange(index, endIndex >= list.length ? list.length : endIndex);
  if (elements != null) {
    list.insertAll(index, elements is List ? elements : <String>[elements]);
  }
  return list;
}

List concat(List lists) {
  var ret = [];
  for (var item in lists) {
    if (item is Iterable) {
      ret.addAll(item);
    } else {
      ret.add(item);
    }
  }
  return ret;
}

dynamic pop(List list) => list.removeLast();

int push(List list, item) {
  list.add(item);
  return list.length;
}

List reverse(List list) => list = list.reversed.toList();

dynamic shift(List list) => list.removeAt(0);

int unshift(List list, item) {
  list.insert(0, item);
  return list.length;
}

List slice(List list, int begin, [int? end]) => list
    .getRange(
        begin,
        end == null
            ? list.length
            : end < 0
                ? list.length + end
                : end)
    .toList();

bool every(List list, dynamic Function(dynamic e) fn) =>
    list.every((x) => truthy(fn(x)));

bool some(List list, dynamic Function(dynamic e) fn) =>
    list.any((x) => truthy(fn(x)));

List filter(List list, dynamic Function(dynamic e) fn) =>
    list.where((x) => truthy(fn(x))).toList();

dynamic reduce(List list,
    dynamic Function(dynamic prev, dynamic curr, int index, List list) fn,
    [initialValue]) {
  var index = 0;
  var value;
  var isValueSet = false;
  if (1 < list.length) {
    value = initialValue;
    isValueSet = true;
  }
  for (; list.length > index; ++index) {
    if (isValueSet) {
      value = fn(value, list[index], index, list);
    } else {
      value = list[index];
      isValueSet = true;
    }
  }
  if (!isValueSet) {
    throw TypeError(); //'Reduce of empty array with no initial value'
  }
  return value;
}

dynamic reduceRight(List list,
    dynamic Function(dynamic prev, dynamic curr, int index, List list) fn,
    [initialValue]) {
  var length = list.length;
  var index = length - 1;
  var value;
  var isValueSet = false;
  if (1 < list.length) {
    value = initialValue;
    isValueSet = true;
  }
  for (; -1 < index; --index) {
    if (isValueSet) {
      value = fn(value, list[index], index, list);
    } else {
      value = list[index];
      isValueSet = true;
    }
  }
  if (!isValueSet) {
    throw TypeError(); //'Reduce of empty array with no initial value'
  }
  return value;
}

/// Strings
String charAt(String str, int atPos) => str.substring(atPos, atPos + 1);

int charCodeAt(String str, int atPos) => str.codeUnitAt(atPos);

String quote(String str) => '"$str"';

String replace(String str, pattern) => str.replaceAll(str, pattern);

int search(String str, RegExp pattern) => str.indexOf(pattern);

String substr(String str, int start, [int? length]) {
  if (start < 0) {
    start = str.length + start;
  }
  if (start < 0) {
    start = 0;
  }
  if (start > str.length) {
    start = str.length;
  }
  var end = length == null
      ? str.length
      : start + length > str.length
          ? str.length
          : start + length;
  return str.substring(start, end);
}

String trimLeft(String str) => str.replaceAll(RegExp(r'^\s+'), '');

String trimRight(String str) => str.replaceAll(RegExp(r'\s+$'), '');

String escapeHtml(String html) => html
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// RegEx
List<String?>? exec(RegExp regex, String str) {
  var m = regex.firstMatch(str);
  if (m == null) {
    return null;
  }

  var groups = <int>[];
  for (var i = 0; i <= m.groupCount; i++) {
    groups.add(i);
  }

  var retVal = m.groups(groups);
  return retVal;
}

String toFixed(num x, int l) {
  return x.toStringAsFixed(l);
}

double parseFloat(String n) {
  return double.parse(n);
}

setList(List target, List source) {
  int tlen = target.length;
  int slen = source.length;

  for (var i = 0; i < slen; i++) {
    if (i >= tlen) {
      break;
    }
    target[i] = source[i];
  }
}
