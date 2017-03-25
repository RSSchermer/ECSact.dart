part of component_store;

class LinkedHashMapStore<T> implements ComponentStore<T> {
  final ChangeNotifier<ComponentStoreChangeRecord<T>> _changeNotifier =
      new ChangeNotifier();

  final LinkedHashMap<int, T> _storage = new LinkedHashMap();

  int get length => _storage.length;

  bool get isEmpty => _storage.isEmpty;

  bool get isNotEmpty => _storage.isNotEmpty;

  Iterable<T> get components => _storage.values;

  Iterable<int> get entityIds => _storage.keys;

  Stream<List<ComponentStoreChangeRecord<T>>> get changes =>
      _changeNotifier.changes;

  ComponentStoreIterator<T> get iterator =>
      new _LinkedHashMapStoreIterator(this);

  bool containsComponentFor(int entityId) => _storage.containsKey(entityId);

  void forEach(void f(int entityId, T component)) => _storage.forEach(f);

  T remove(int entityId) {
    final value = _storage.remove(entityId);

    if (value != null) {
      _changeNotifier
          .notifyChange(new ComponentStoreChangeRecord.remove(entityId, value));
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

    if (oldValue != null) {
      _changeNotifier.notifyChange(
          new ComponentStoreChangeRecord.insert(entityId, component));
    } else {
      _changeNotifier.notifyChange(
          new ComponentStoreChangeRecord(entityId, oldValue, component));
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
