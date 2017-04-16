part of nodes;

/// Iterates over 3 [ComponentTypeStore]s simultaneously and joins the component
/// values into [Node3] instances based on the entity IDs to which they are
/// associated.
class Join3Nodes<T0, T1, T2> extends IterableBase<Node3<T0, T1, T2>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<T0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<T1> store1;

  /// The third [ComponentTypeStore].
  final ComponentTypeStore<T2> store2;

  /// Creates a new [Join3Nodes] instance that joins [store0], [store1] and
  /// [store2].
  Join3Nodes(this.store0, this.store1, this.store2);

  Iterator<Node3<T0, T1, T2>> get iterator =>
      new _Join3NodesIterator<T0, T1, T2>(store0, store1, store2);
}

class _Join3NodesIterator<T0, T1, T2> implements Iterator<Node3<T0, T1, T2>> {
  final ComponentTypeStore<T0> store0;

  final ComponentTypeStore<T1> store1;

  final ComponentTypeStore<T2> store2;

  ComponentStoreIterator<T0> _store0Iterator;

  Node3<T0, T1, T2> _current;

  _Join3NodesIterator(this.store0, this.store1, this.store2) {
    _store0Iterator = store0.iterator;
  }

  Node3<T0, T1, T2> get current => _current;

  bool moveNext() {
    if (_store0Iterator.moveNext()) {
      final id = _store0Iterator.currentEntityId;
      final c0 = _store0Iterator.current;
      final c1 = store1[id];

      if (c1 == null) {
        return moveNext();
      }

      final c2 = store2[id];

      if (c2 == null) {
        return moveNext();
      }

      _current = new Node3<T0, T1, T2>(id, c0, c1, c2);

      return true;
    } else {
      return false;
    }
  }
}
