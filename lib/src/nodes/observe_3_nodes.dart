part of nodes;

/// Maintains a sequence of [Node3] instances by joining the component values in
/// 3 [ComponentTypeStore]s based on the entity IDs to which they are associated
/// and then observing them for subsequent changes.
///
/// Similar to [Join3Nodes], but rather than reconstruct the sequence of [Node3]
/// instances on every iteration, it maintains a sequence of [Node3] instances
/// by observing the [ComponentTypeStore]s.
class Observe3Nodes<C0, C1, C2> extends IterableBase<Node3<C0, C1, C2>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<C0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<C1> store1;

  /// The third [ComponentTypeStore].
  final ComponentTypeStore<C2> store2;

  final Map<int, Node3<C0, C1, C2>> _entityIdsNodes = {};

  final Set<int> _potentialInserts = new Set();

  final Set<int> _potentialRemoves = new Set();

  /// Creates a new [Observe3Nodes] instance that joins [store0], [store1] and
  /// [store2].
  Observe3Nodes(this.store0, this.store1, this.store2) {
    for (final node in new Join3Nodes(store0, store1, store2)) {
      _entityIdsNodes[node.entityId] = node;
    }

    store0.changes.listen((changeRecords) {
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
                new Node3(id, changeRecord.newValue, node.c1, node.c2);
          }
        }
      }
    });

    store1.changes.listen((changeRecords) {
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
                new Node3(id, node.c0, changeRecord.newValue, node.c2);
          }
        }
      }
    });

    store2.changes.listen((changeRecords) {
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
                new Node3(id, node.c0, node.c1, changeRecord.newValue);
          }
        }
      }
    });
  }

  Iterator<Node3<C0, C1, C2>> get iterator {
    for (final id in _potentialInserts) {
      final c0 = store0[id];
      final c1 = store1[id];
      final c2 = store2[id];

      if (c0 != null && c1 != null && c2 != null) {
        _entityIdsNodes[id] = new Node3(id, c0, c1, c2);
      }
    }

    for (final id in _potentialRemoves) {
      if (!store0.containsComponentFor(id) ||
          !store1.containsComponentFor(id) ||
          !store2.containsComponentFor(id)) {
        _entityIdsNodes.remove(id);
      }
    }

    return _entityIdsNodes.values.iterator;
  }
}
