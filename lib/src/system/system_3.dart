part of system;

typedef void System3Operation<C0, C1, C2>(C0 c0, C1 c1, C2 c2, num deltaTime);

/// A [System] that runs on a entities that combine the 3 component types
/// identified by its type parameters ([C0], [C1] and [C2]).
///
/// See also [System1], [System2], [System4] and [System5].
class System3<C0, C1, C2> {
  /// The [World] this system is run on.
  final World world;

  /// The operation applied by this system.
  final System3Operation operation;

  Observe3Nodes<C0, C1, C2> _nodes;

  ComponentTypeStore<C0> _store0;

  ComponentTypeStore<C1> _store1;

  ComponentTypeStore<C2> _store2;

  /// Instantiates a new [System3].
  System3(this.world, this.operation) {
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

    _store0 = world.typeStoreRegistry.getStore<C0>(C0);
    _store1 = world.typeStoreRegistry.getStore<C1>(C1);
    _store2 = world.typeStoreRegistry.getStore<C2>(C2);

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
      }
    });
  }

  void run(num deltaTime) {
    if (_nodes != null) {
      for (final node in _nodes) {
        operation(node.c0, node.c1, node.c2, deltaTime);
      }
    }
  }

  void _refreshNodes() {
    if (_store0 != null && _store1 != null && _store2 != null) {
      _nodes = new Observe3Nodes<C0, C1, C2>(_store0, _store1, _store2);
    } else {
      _nodes = null;
    }
  }
}
