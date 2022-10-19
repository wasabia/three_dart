extension ListExtension on List {
  List splice(int index, [int howMany = 1, elements]) {
    var endIndex = index + howMany.truncate();
    removeRange(index, endIndex >= length ? length : endIndex);
    if (elements != null) insertAll(index, elements is List ? elements : [elements]);
    return this;
  }
}
