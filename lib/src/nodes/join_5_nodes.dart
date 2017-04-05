part of nodes;

/// Iterates over 5 [ComponentTypeStore]s simultaneously and joins the component
/// values into [Node5] instances based on the entity IDs to which they are
/// associated.
class Join5Nodes<C0, C1, C2, C3, C4>
    extends IterableBase<Node5<C0, C1, C2, C3, C4>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<C0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<C1> store1;

  /// The third [ComponentTypeStore].
  final ComponentTypeStore<C2> store2;

  /// The fourth [ComponentTypeStore].
  final ComponentTypeStore<C3> store3;

  /// The fifth [ComponentTypeStore].
  final ComponentTypeStore<C4> store4;

  /// Creates a new [Join5Nodes] instance that joins [store0], [store1],
  /// [store2], [store3] and [store4].
  Join5Nodes(this.store0, this.store1, this.store2, this.store3, this.store4);

  Iterator<Node5<C0, C1, C2, C3, C4>> get iterator =>
      new _Join5NodesIterator(store0, store1, store2, store3, store4);
}

class _Join5NodesIterator<C0, C1, C2, C3, C4>
    implements Iterator<Node5<C0, C1, C2, C3, C4>> {
  final ComponentTypeStore<C0> store0;

  final ComponentTypeStore<C1> store1;

  final ComponentTypeStore<C2> store2;

  final ComponentTypeStore<C3> store3;

  final ComponentTypeStore<C4> store4;

  ComponentStoreIterator<C0> _store0Iterator;

  Node5<C0, C1, C2, C3, C4> _current;

  _Join5NodesIterator(
      this.store0, this.store1, this.store2, this.store3, this.store4) {
    _store0Iterator = store0.iterator;
  }

  Node5<C0, C1, C2, C3, C4> get current => _current;

  bool moveNext() {
    if (_store0Iterator.moveNext()) {
      final id = _store0Iterator.currentEntityId;
      final c0 = _store0Iterator.current;
      final c1 = store1[id];

      if (c1 == null) {
        return false;
      }

      final c2 = store2[id];

      if (c2 == null) {
        return false;
      }

      final c3 = store3[id];

      if (c3 == null) {
        return false;
      }

      final c4 = store4[id];

      if (c4 == null) {
        return false;
      }

      _current = new Node5(id, c0, c1, c2, c3, c4);

      return true;
    } else {
      return false;
    }
  }
}
