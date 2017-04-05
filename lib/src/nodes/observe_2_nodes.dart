part of nodes;

/// Maintains a sequence of [Node2] instances by joining the component values in
/// 2 [ComponentTypeStore]s based on the entity IDs to which they are associated
/// and then observing them for subsequent changes.
///
/// Similar to [Join2Nodes], but rather than reconstruct the sequence of [Node2]
/// instances on every iteration, it maintains a sequence of [Node2] instances
/// by observing the [ComponentTypeStore]s.
class Observe2Nodes<C0, C1> extends IterableBase<Node2<C0, C1>> {
  /// The first [ComponentTypeStore].
  final ComponentTypeStore<C0> store0;

  /// The second [ComponentTypeStore].
  final ComponentTypeStore<C1> store1;

  final Map<int, Node2<C0, C1>> _entityIdsNodes = {};

  final Set<int> _potentialInserts = new Set();

  final Set<int> _potentialRemoves = new Set();

  /// Creates a new [Observe2Nodes] instance that joins [store0] and [store1].
  Observe2Nodes(this.store0, this.store1) {
    for (final node in new Join2Nodes(store0, store1)) {
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
            _entityIdsNodes[id] = new Node2(id, changeRecord.newValue, node.c1);
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
            _entityIdsNodes[id] = new Node2(id, node.c0, changeRecord.newValue);
          }
        }
      }
    });
  }

  Iterator<Node2<C0, C1>> get iterator {
    for (final id in _potentialInserts) {
      final c0 = store0[id];
      final c1 = store1[id];

      if (c0 != null && c1 != null) {
        _entityIdsNodes[id] = new Node2(id, c0, c1);
      }
    }

    for (final id in _potentialRemoves) {
      if (!store0.containsComponentFor(id) ||
          !store1.containsComponentFor(id)) {
        _entityIdsNodes.remove(id);
      }
    }

    return _entityIdsNodes.values.iterator;
  }
}
