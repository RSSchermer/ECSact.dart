part of nodes;

/// Iterates over 4 [ComponentTypeStore]s simultaneously and joins the component
/// values into [Node4] instances based on the entity IDs to which they are
/// associated.
class Join4Nodes<C0, C1, C2, C3> extends IterableBase<Node4<C0, C1, C2, C3>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<C0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<C1> store1;

  /// The third [ComponentTypeStore].
  final ComponentTypeStore<C2> store2;

  /// The fourth [ComponentTypeStore].
  final ComponentTypeStore<C3> store3;

  /// Creates a new [Join4Nodes] instance that joins [store0], [store1],
  /// [store2] and [store3].
  Join4Nodes(this.store0, this.store1, this.store2, this.store3);

  Iterator<Node4<C0, C1, C2, C3>> get iterator =>
      new _Join4NodesIterator(store0, store1, store2, store3);
}

class _Join4NodesIterator<C0, C1, C2, C3>
    implements Iterator<Node4<C0, C1, C2, C3>> {
  final ComponentTypeStore<C0> store0;

  final ComponentTypeStore<C1> store1;

  final ComponentTypeStore<C2> store2;

  final ComponentTypeStore<C3> store3;

  ComponentStoreIterator<C0> _store0Iterator;

  Node4<C0, C1, C2, C3> _current;

  _Join4NodesIterator(this.store0, this.store1, this.store2, this.store3) {
    _store0Iterator = store0.iterator;
  }

  Node4<C0, C1, C2, C3> get current => _current;

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

      _current = new Node4(id, c0, c1, c2, c3);

      return true;
    } else {
      return false;
    }
  }
}
