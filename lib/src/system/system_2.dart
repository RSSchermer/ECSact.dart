part of system;

typedef void System2Operation<C0, C1>(C0 c0, C1 c1, num deltaTime);

/// A [System] that runs on a entities that combine the 2 component types
/// identified by its type parameters ([C0] and [C1]).
///
/// See also [System1], [System3], [System4] and [System5].
class System2<C0, C1> {
  /// The [World] this system is run on.
  final World world;

  /// The operation applied by this system.
  final System2Operation operation;

  Observe2Nodes<C0, C1> _nodes;

  ComponentTypeStore<C0> _store0;

  ComponentTypeStore<C1> _store1;

  /// Instantiates a new [System2].
  System2(this.world, this.operation) {
    if (C0 == dynamic) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C1 == dynamic) {
      throw new ArgumentError('The second type parameter must be specified and '
          'must not be `dynamic`.');
    }

    _store0 = world.typeStoreRegistry.getStore<C0>(C0);
    _store1 = world.typeStoreRegistry.getStore<C1>(C1);

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
      }
    });
  }

  void run(num deltaTime) {
    if (_nodes != null) {
      for (final node in _nodes) {
        operation(node.c0, node.c1, deltaTime);
      }
    }
  }

  void _refreshNodes() {
    if (_store0 != null && _store1 != null) {
      _nodes = new Observe2Nodes<C0, C1>(_store0, _store1);
    } else {
      _nodes = null;
    }
  }
}
