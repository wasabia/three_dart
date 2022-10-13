/// A WeakMap lets you garbage-collect its keys.
/// Please note: The **[key]** can be garbage-collected, not the [value].
///
/// This means if you use some object as a key to a map-entry, this alone
/// will not prevent Dart to garbage-collect this object. In other words,
/// after all other references to that object have been destroyed, its entry
/// (key and value) may be removed automatically from the map at any moment.
///
/// To create a map:
/// ```
/// var map = WeakMap();
/// ```
///
/// To add and retrieve a value:
/// ```
/// map["John"] = 42;
/// var age = map["John"];
/// ```
///
/// The following map methods work as expected:
/// ```
/// map.remove("John")
/// map.clear()
/// map.contains("John"))
/// ```
///
/// However, adding some null value to the map is the same as removing the key:
/// ```
/// map["John"] = null; // Same as map.remove("John")
/// ```
///
/// Notes:
///
/// 1. If you use null, a number, a boolean, a String, or a const type as the
/// map key, it will act like a regular map, because these types are never
/// garbage-collected. All other types of object may be garbage-collected.
///
/// 2. To retrieve a value added to the map, you can use the equivalent
/// syntax `var y = map[x]` or `var y = map.get(x)`.
///
class WeakMap<K, V> {
  final Map<K, V> _map;
  Expando _expando;
  final List<K> _keys = [];

  WeakMap()
      : _map = {},
        _expando = Expando();

  static bool _allowedInExpando(Object? value) =>
      value is! String && value is! num && value is! bool && value != null;

  void operator []=(K key, V value) => add(key: key, value: value);

  get keys => _keys;

  V? operator [](K key) => get(key);

  void set(key, value) {
    add(key: key, value: value);
  }

  void add({required K key, required V value}) {
    if (_allowedInExpando(key)) {
      _expando[key!] = value;
    } else {
      _map[key] = value;
    }

    if (!contains(key)) {
      _keys.add(key);
    }
  }

  bool contains(K key) => get(key) != null;

  bool has(K key) => contains(key);

  V? get(K key) => _map.containsKey(key)
      ? //
      _map[key]
      : (_allowedInExpando(key) ? _expando[key!] as V : null);

  void remove(K key) {
    _map.remove(key);

    if (_allowedInExpando(key)) {
      _expando[key!] = null;
    }
  }

  void delete(K key) {
    remove(key);
    _keys.remove(key);
  }

  void clear() {
    _map.clear();
    _expando = Expando();
    _keys.clear();
  }
}
