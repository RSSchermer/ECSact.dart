part of nodes;

/// Iterates over 2 [ComponentTypeStore]s simultaneously and joins the component
/// values into [Node2] instances based on the entity IDs to which they are
/// associated.
class Join2Nodes<T0, T1> extends IterableBase<Node2<T0, T1>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<T0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<T1> store1;

  /// Creates a new [Join2Nodes] instance that joins [store0] and [store1].
  Join2Nodes(this.store0, this.store1);

  Iterator<Node2<T0, T1>> get iterator =>
      new _Join2NodesIterator<T0, T1>(store0, store1);
}

class _Join2NodesIterator<T0, T1> implements Iterator<Node2<T0, T1>> {
  final ComponentTypeStore<T0> store0;

  final ComponentTypeStore<T1> store1;

  ComponentStoreIterator<T0> _store0Iterator;

  Node2<T0, T1> _current;

  _Join2NodesIterator(this.store0, this.store1) {
    _store0Iterator = store0.iterator;
  }

  Node2<T0, T1> get current => _current;

  bool moveNext() {
    if (_store0Iterator.moveNext()) {
      final id = _store0Iterator.currentEntityId;
      final c0 = _store0Iterator.current;
      final c1 = store1[id];

      if (c1 == null) {
        return moveNext();
      } else {
        _current = new Node2<T0, T1>(id, c0, c1);

        return true;
      }
    } else {
      return false;
    }
  }
}
