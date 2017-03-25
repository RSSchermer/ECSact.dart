part of nodes;

class Join3Nodes<C0, C1, C2> extends IterableBase<Node3<C0, C1, C2>> {
  final ComponentStore<C0> store0;

  final ComponentStore<C1> store1;

  final ComponentStore<C2> store2;

  Join3Nodes(this.store0, this.store1, this.store2);

  Iterator<Node3<C0, C1, C2>> get iterator =>
      new _Join3NodesIterator(store0, store1, store2);
}

class _Join3NodesIterator<C0, C1, C2> implements Iterator<Node3<C0, C1, C2>> {
  final ComponentStore<C0> store0;

  final ComponentStore<C1> store1;

  final ComponentStore<C2> store2;

  ComponentStoreIterator<C0> _store0Iterator;

  Node3<C0, C1, C2> _current;

  _Join3NodesIterator(this.store0, this.store1, this.store2) {
    _store0Iterator = store0.iterator;
  }

  Node3<C0, C1, C2> get current => _current;

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

      _current = new Node3(id, c0, c1, c2);

      return true;
    } else {
      return false;
    }
  }
}
