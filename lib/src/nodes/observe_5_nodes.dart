part of nodes;

/// Maintains a sequence of [Node5] instances by joining the component values in
/// 5 [ComponentTypeStore]s based on the entity IDs to which they are associated
/// and then observing them for subsequent changes.
///
/// Similar to [Join5Nodes], but rather than reconstruct the sequence of [Node5]
/// instances on every iteration, it maintains a sequence of [Node5] instances
/// by observing the [ComponentTypeStore]s.
class Observe5Nodes<T0, T1, T2, T3, T4>
    extends IterableBase<Node5<T0, T1, T2, T3, T4>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<T0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<T1> store1;

  /// The third [ComponentTypeStore].
  final ComponentTypeStore<T2> store2;

  /// The fourth [ComponentTypeStore].
  final ComponentTypeStore<T3> store3;

  /// The fifth [ComponentTypeStore].
  final ComponentTypeStore<T4> store4;

  final Map<int, Node5<T0, T1, T2, T3, T4>> _entityIdsNodes =
      <int, Node5<T0, T1, T2, T3, T4>>{};

  final Set<int> _potentialInserts = new Set();

  final Set<int> _potentialRemoves = new Set();

  /// Creates a new [Observe5Nodes] instance that joins [store0], [store1],
  /// [store2], [store3] and [store4].
  Observe5Nodes(
      this.store0, this.store1, this.store2, this.store3, this.store4) {
    for (final node in new Join5Nodes(store0, store1, store2, store3, store4)) {
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
            _entityIdsNodes[id] = new Node5<T0, T1, T2, T3, T4>(
                id, changeRecord.newValue, node.c1, node.c2, node.c3, node.c4);
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
            _entityIdsNodes[id] = new Node5<T0, T1, T2, T3, T4>(
                id, node.c0, changeRecord.newValue, node.c2, node.c3, node.c4);
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
            _entityIdsNodes[id] = new Node5<T0, T1, T2, T3, T4>(
                id, node.c0, node.c1, changeRecord.newValue, node.c3, node.c4);
          }
        }
      }
    });

    store3.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final id = changeRecord.entityId;

        if (changeRecord.isInsert) {
          _potentialInserts.add(id);
        } else if (changeRecord.isRemove) {
          _potentialRemoves.add(id);
        } else {
          final node = _entityIdsNodes[id];

          if (node != null) {
            _entityIdsNodes[id] = new Node5<T0, T1, T2, T3, T4>(
                id, node.c0, node.c1, node.c2, changeRecord.newValue, node.c4);
          }
        }
      }
    });

    store4.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final id = changeRecord.entityId;

        if (changeRecord.isInsert) {
          _potentialInserts.add(id);
        } else if (changeRecord.isRemove) {
          _potentialRemoves.add(id);
        } else {
          final node = _entityIdsNodes[id];

          if (node != null) {
            _entityIdsNodes[id] = new Node5<T0, T1, T2, T3, T4>(
                id, node.c0, node.c1, node.c2, node.c3, changeRecord.newValue);
          }
        }
      }
    });
  }

  Iterator<Node5<T0, T1, T2, T3, T4>> get iterator {
    for (final id in _potentialInserts) {
      final c0 = store0[id];
      final c1 = store1[id];
      final c2 = store2[id];
      final c3 = store3[id];
      final c4 = store4[id];

      if (c0 != null && c1 != null && c2 != null && c3 != null && c4 != null) {
        _entityIdsNodes[id] =
            new Node5<T0, T1, T2, T3, T4>(id, c0, c1, c2, c3, c4);
      }
    }

    for (final id in _potentialRemoves) {
      if (!store0.containsComponentFor(id) ||
          !store1.containsComponentFor(id) ||
          !store2.containsComponentFor(id) ||
          !store3.containsComponentFor(id) ||
          !store4.containsComponentFor(id)) {
        _entityIdsNodes.remove(id);
      }
    }

    return _entityIdsNodes.values.iterator;
  }
}
