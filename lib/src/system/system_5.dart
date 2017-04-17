part of system;

typedef void System5Operation<C0, C1, C2, C3, C4>(
    C0 c0, C1 c1, C2 c2, C3 c3, C4 c4, num deltaTime);

/// A [System] that runs on a entities that combine the 5 component types
/// identified by its type parameters ([C0], [C1], [C2], [C3] and [C4]).
///
/// See also [System1], [System2], [System3] and [System4].
class System5<C0, C1, C2, C3, C4> {
  /// The [World] this system is run on.
  final World world;

  /// The operation applied by this system.
  final System5Operation operation;

  Observe5Nodes<C0, C1, C2, C3, C4> _nodes;

  ComponentTypeStore<C0> _store0;

  ComponentTypeStore<C1> _store1;

  ComponentTypeStore<C2> _store2;

  ComponentTypeStore<C3> _store3;

  ComponentTypeStore<C4> _store4;

  /// Instantiates a new [System5].
  System5(this.world, this.operation) {
    if (C0 == dynamic) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C1 == dynamic) {
      throw new ArgumentError('The second type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C2 == dynamic) {
      throw new ArgumentError('The third type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C2 == dynamic) {
      throw new ArgumentError('The fourth type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C2 == dynamic) {
      throw new ArgumentError('The fifth type parameter must be specified and '
          'must not be `dynamic`.');
    }

    _store0 = world.typeStoreRegistry.getStore<C0>(C0);
    _store1 = world.typeStoreRegistry.getStore<C1>(C1);
    _store2 = world.typeStoreRegistry.getStore<C2>(C2);
    _store3 = world.typeStoreRegistry.getStore<C3>(C3);
    _store4 = world.typeStoreRegistry.getStore<C4>(C4);

    _refreshNodes();

    world.typeStoreRegistry.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        // TODO: first check may not be necessary in future versions of Dart.
        if (changeRecord.type == C0 &&
            changeRecord is TypeStoreRegistryChangeRecord<C0>) {
          if (changeRecord.isRemove) {
            _store0 = null;
          } else {
            _store0 = changeRecord.newValue;
          }

          _refreshNodes();
        }

        // TODO: first check may not be necessary in future versions of Dart.
        if (changeRecord.type == C1 &&
            changeRecord is TypeStoreRegistryChangeRecord<C1>) {
          if (changeRecord.isRemove) {
            _store1 = null;
          } else {
            _store1 = changeRecord.newValue;
          }

          _refreshNodes();
        }

        // TODO: first check may not be necessary in future versions of Dart.
        if (changeRecord.type == C2 &&
            changeRecord is TypeStoreRegistryChangeRecord<C2>) {
          if (changeRecord.isRemove) {
            _store2 = null;
          } else {
            _store2 = changeRecord.newValue;
          }

          _refreshNodes();
        }

        // TODO: first check may not be necessary in future versions of Dart.
        if (changeRecord.type == C3 &&
            changeRecord is TypeStoreRegistryChangeRecord<C3>) {
          if (changeRecord.isRemove) {
            _store3 = null;
          } else {
            _store3 = changeRecord.newValue;
          }

          _refreshNodes();
        }

        // TODO: first check may not be necessary in future versions of Dart.
        if (changeRecord.type == C4 &&
            changeRecord is TypeStoreRegistryChangeRecord<C4>) {
          if (changeRecord.isRemove) {
            _store4 = null;
          } else {
            _store4 = changeRecord.newValue;
          }

          _refreshNodes();
        }
      }
    });
  }

  void run(num deltaTime) {
    if (_nodes != null) {
      for (final node in _nodes) {
        operation(node.c0, node.c1, node.c2, node.c3, node.c4, deltaTime);
      }
    }
  }

  void _refreshNodes() {
    if (_store0 != null &&
        _store1 != null &&
        _store2 != null &&
        _store3 != null &&
        _store4 != null) {
      _nodes = new Observe5Nodes<C0, C1, C2, C3, C4>(
          _store0, _store1, _store2, _store3, _store4);
    } else {
      _nodes = null;
    }
  }
}
