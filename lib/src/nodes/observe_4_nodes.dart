part of nodes;

class Observe4Nodes<C0, C1, C2, C3>
    extends IterableBase<Node4<C0, C1, C2, C3>> {
  final World world;

  ComponentStore<C0> _store0;

  ComponentStore<C1> _store1;

  ComponentStore<C2> _store2;

  ComponentStore<C3> _store3;

  final Map<int, Node4<C0, C1, C2, C3>> _entityIdsNodes = {};

  final Set<int> _potentialInserts = new Set();

  final Set<int> _potentialRemoves = new Set();

  Observe4Nodes(this.world) {
    if (C0 == dynamic || C0 == Object) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic` or `Object`.');
    }

    if (C1 == dynamic || C1 == Object) {
      throw new ArgumentError('The second type parameter must be specified and '
          'must not be `dynamic` or `Object`.');
    }

    if (C2 == dynamic || C2 == Object) {
      throw new ArgumentError('The third type parameter must be specified and '
          'must not be `dynamic` or `Object`.');
    }

    if (C3 == dynamic || C3 == Object) {
      throw new ArgumentError('The fourth type parameter must be specified and '
          'must not be `dynamic` or `Object`.');
    }

    _store0 = world.componentDatabase[C0] as ComponentStore<C0>;

    if (_store0 == null) {
      throw new StateError('Could not find a store on the given world for '
          'component type `$C0`.');
    }

    _store1 = world.componentDatabase[C1] as ComponentStore<C1>;

    if (_store1 == null) {
      throw new StateError('Could not find a store on the given world for '
          'component type `$C1`.');
    }

    _store2 = world.componentDatabase[C2] as ComponentStore<C2>;

    if (_store2 == null) {
      throw new StateError('Could not find a store on the given world for '
          'component type `$C2`.');
    }

    _store3 = world.componentDatabase[C3] as ComponentStore<C3>;

    if (_store3 == null) {
      throw new StateError('Could not find a store on the given world for '
          'component type `$C3`.');
    }

    for (final node in new Join4Nodes(_store0, _store1, _store2, _store3)) {
      _entityIdsNodes[node.entityId] = node;
    }

    _store0.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final id = changeRecord.entityId;

        if (changeRecord.isInsert) {
          _potentialInserts.add(id);
        } else if (changeRecord.isRemove) {
          _potentialRemoves.add(id);
        } else {
          final node = _entityIdsNodes[id];

          if (node != null) {
            _entityIdsNodes[id] =
                new Node4(id, changeRecord.newValue, node.c1, node.c2, node.c3);
          }
        }
      }
    });

    _store1.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final id = changeRecord.entityId;

        if (changeRecord.isInsert) {
          _potentialInserts.add(id);
        } else if (changeRecord.isRemove) {
          _potentialRemoves.add(id);
        } else {
          final node = _entityIdsNodes[id];

          if (node != null) {
            _entityIdsNodes[id] =
                new Node4(id, node.c0, changeRecord.newValue, node.c2, node.c3);
          }
        }
      }
    });

    _store2.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final id = changeRecord.entityId;

        if (changeRecord.isInsert) {
          _potentialInserts.add(id);
        } else if (changeRecord.isRemove) {
          _potentialRemoves.add(id);
        } else {
          final node = _entityIdsNodes[id];

          if (node != null) {
            _entityIdsNodes[id] =
                new Node4(id, node.c0, node.c1, changeRecord.newValue, node.c3);
          }
        }
      }
    });

    _store3.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final id = changeRecord.entityId;

        if (changeRecord.isInsert) {
          _potentialInserts.add(id);
        } else if (changeRecord.isRemove) {
          _potentialRemoves.add(id);
        } else {
          final node = _entityIdsNodes[id];

          if (node != null) {
            _entityIdsNodes[id] =
                new Node4(id, node.c0, node.c1, node.c2, changeRecord.newValue);
          }
        }
      }
    });
  }

  Iterator<Node4<C0, C1, C2, C3>> get iterator {
    for (final id in _potentialInserts) {
      final c0 = _store0[id];
      final c1 = _store1[id];
      final c2 = _store2[id];
      final c3 = _store3[id];

      if (c0 != null && c1 != null && c2 != null && c3 != null) {
        _entityIdsNodes[id] = new Node4(id, c0, c1, c2, c3);
      }
    }

    for (final id in _potentialRemoves) {
      if (!_store0.containsComponentFor(id) ||
          !_store1.containsComponentFor(id) ||
          !_store2.containsComponentFor(id) ||
          !_store3.containsComponentFor(id)) {
        _entityIdsNodes.remove(id);
      }
    }

    return _entityIdsNodes.values.iterator;
  }
}
