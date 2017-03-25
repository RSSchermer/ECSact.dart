part of nodes;

class Observe2Nodes<C0, C1> extends IterableBase<Node2<C0, C1>> {
  final World world;

  ComponentStore<C0> _store0;

  ComponentStore<C1> _store1;

  final Map<int, Node2<C0, C1>> _entityIdsNodes = {};

  final Set<int> _potentialInserts = new Set();

  final Set<int> _potentialRemoves = new Set();

  Observe2Nodes(this.world) {
    if (C0 == dynamic || C0 == Object) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic` or `Object`.');
    }

    if (C1 == dynamic || C1 == Object) {
      throw new ArgumentError('The second type parameter must be specified and '
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

    for (final node in new Join2Nodes(_store0, _store1)) {
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
            _entityIdsNodes[id] = new Node2(id, changeRecord.newValue, node.c1);
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
            _entityIdsNodes[id] = new Node2(id, node.c0, changeRecord.newValue);
          }
        }
      }
    });
  }

  Iterator<Node2<C0, C1>> get iterator {
    for (final id in _potentialInserts) {
      final c0 = _store0[id];
      final c1 = _store1[id];

      if (c0 != null && c1 != null) {
        _entityIdsNodes[id] = new Node2(id, c0, c1);
      }
    }

    for (final id in _potentialRemoves) {
      if (!_store0.containsComponentFor(id) ||
          !_store1.containsComponentFor(id)) {
        _entityIdsNodes.remove(id);
      }
    }

    return _entityIdsNodes.values.iterator;
  }
}
