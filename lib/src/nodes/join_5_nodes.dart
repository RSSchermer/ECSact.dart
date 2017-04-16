part of nodes;

/// Iterates over 5 [ComponentTypeStore]s simultaneously and joins the component
/// values into [Node5] instances based on the entity IDs to which they are
/// associated.
class Join5Nodes<T0, T1, T2, T3, T4>
    extends IterableBase<Node5<T0, T1, T2, T3, T4>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<T0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<T1> store1;

  /// The third [ComponentTypeStore].
  final ComponentTypeStore<T2> store2;

  /// The fourth [ComponentTypeStore].
  final ComponentTypeStore<T3> store3;

  /// The fifth [ComponentTypeStore].
  final ComponentTypeStore<T4> store4;

  /// Creates a new [Join5Nodes] instance that joins [store0], [store1],
  /// [store2], [store3] and [store4].
  Join5Nodes(this.store0, this.store1, this.store2, this.store3, this.store4);

  Iterator<Node5<T0, T1, T2, T3, T4>> get iterator =>
      new _Join5NodesIterator<T0, T1, T2, T3, T4>(
          store0, store1, store2, store3, store4);
}

class _Join5NodesIterator<T0, T1, T2, T3, T4>
    implements Iterator<Node5<T0, T1, T2, T3, T4>> {
  final ComponentTypeStore<T0> store0;

  final ComponentTypeStore<T1> store1;

  final ComponentTypeStore<T2> store2;

  final ComponentTypeStore<T3> store3;

  final ComponentTypeStore<T4> store4;

  ComponentStoreIterator<T0> _store0Iterator;

  Node5<T0, T1, T2, T3, T4> _current;

  _Join5NodesIterator(
      this.store0, this.store1, this.store2, this.store3, this.store4) {
    _store0Iterator = store0.iterator;
  }

  Node5<T0, T1, T2, T3, T4> get current => _current;

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

      final c3 = store3[id];

      if (c3 == null) {
        return moveNext();
      }

      final c4 = store4[id];

      if (c4 == null) {
        return moveNext();
      }

      _current = new Node5<T0, T1, T2, T3, T4>(id, c0, c1, c2, c3, c4);

      return true;
    } else {
      return false;
    }
  }
}
