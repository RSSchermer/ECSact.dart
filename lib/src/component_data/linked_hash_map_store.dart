part of component_data;

/// A [ComponentTypeStore] that internally uses a [LinkedHashMap] to store the
/// component values and associate them with entity IDs.
class LinkedHashMapStore<T> implements ComponentTypeStore<T> {
  final ChangeNotifier<ComponentTypeStoreChangeRecord<T>> _changeNotifier =
      new ChangeNotifier();

  final LinkedHashMap<int, T> _storage = new LinkedHashMap();

  int get length => _storage.length;

  bool get isEmpty => _storage.isEmpty;

  bool get isNotEmpty => _storage.isNotEmpty;

  Iterable<T> get components => _storage.values;

  Iterable<int> get entityIds => _storage.keys;

  Stream<List<ComponentTypeStoreChangeRecord<T>>> get changes =>
      _changeNotifier.changes;

  ComponentStoreIterator<T> get iterator =>
      new _LinkedHashMapStoreIterator(this);

  bool containsComponentFor(int entityId) => _storage.containsKey(entityId);

  void forEach(void f(int entityId, T component)) => _storage.forEach(f);

  T remove(int entityId) {
    final value = _storage.remove(entityId);

    if (value != null) {
      _changeNotifier
        ..notifyChange(
            new ComponentTypeStoreChangeRecord.remove(entityId, value))
        ..deliverChanges();
    }

    return value;
  }

  T operator [](int entityId) => _storage[entityId];

  void operator []=(int entityId, T component) {
    if (!_changeNotifier.hasObservers) {
      _storage[entityId] = component;

      return;
    }

    final oldValue = _storage[entityId];

    _storage[entityId] = component;

    if (oldValue == null) {
      _changeNotifier
        ..notifyChange(
            new ComponentTypeStoreChangeRecord.insert(entityId, component))
        ..deliverChanges();
    } else {
      _changeNotifier
        ..notifyChange(
            new ComponentTypeStoreChangeRecord(entityId, oldValue, component))
        ..deliverChanges();
    }
  }
}

class _LinkedHashMapStoreIterator<T> implements ComponentStoreIterator<T> {
  final Iterator<int> _idIterator;

  final Iterator<T> _componentIterator;

  _LinkedHashMapStoreIterator(LinkedHashMapStore<T> store)
      : _idIterator = store._storage.keys.iterator,
        _componentIterator = store._storage.values.iterator;

  int get currentEntityId => _idIterator.current;

  T get current => _componentIterator.current;

  bool moveNext() => _idIterator.moveNext() && _componentIterator.moveNext();
}
