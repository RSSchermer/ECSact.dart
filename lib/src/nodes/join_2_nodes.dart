part of nodes;

class Join2Nodes<C0, C1> extends IterableBase<Node2<C0, C1>> {
  final ComponentStore<C0> store0;

  final ComponentStore<C1> store1;

  Join2Nodes(this.store0, this.store1);

  Iterator<Node2<C0, C1>> get iterator =>
      new _Join2NodesIterator(store0, store1);
}

class _Join2NodesIterator<C0, C1> implements Iterator<Node2<C0, C1>> {
  final ComponentStore<C0> store0;

  final ComponentStore<C1> store1;

  ComponentStoreIterator<C0> _store0Iterator;

  Node2<C0, C1> _current;

  _Join2NodesIterator(this.store0, this.store1) {
    _store0Iterator = store0.iterator;
  }

  Node2<C0, C1> get current => _current;

  bool moveNext() {
    if (_store0Iterator.moveNext()) {
      final id = _store0Iterator.currentEntityId;
      final c0 = _store0Iterator.current;
      final c1 = store1[id];

      if (c1 == null) {
        return false;
      } else {
        _current = new Node2(id, c0, c1);

        return true;
      }
    } else {
      return false;
    }
  }
}