library component_store;

import 'dart:async';
import 'dart:collection';

import 'package:observable/observable.dart';
import 'package:quiver/core.dart';

part 'src/component_store/linked_hash_map_store.dart';

abstract class ComponentStore<T> {
  Stream<List<ComponentStoreChangeRecord<T>>> get changes;

  int get length;

  bool get isEmpty;

  bool get isNotEmpty;

  Iterable<T> get components;

  Iterable<int> get entityIds;

  ComponentStoreIterator<T> get iterator;

  void forEach(void f(int entityId, T component));

  bool containsComponentFor(int entityId);

  T remove(int entityId);

  T operator [](int entityId);

  void operator []=(int entityId, T component);
}

abstract class ComponentStoreIterator<T> extends Iterator<T> {
  int get currentEntityId;

  T get current;

  bool moveNext();
}

/// A [ChangeRecord] that denotes adding, removing, or updating a [ComponentStore].
class ComponentStoreChangeRecord<T> implements ChangeRecord {
  /// The entity id for which a component changed.
  final int entityId;

  /// The previous component value associated with this key.
  ///
  /// Is always `null` if [isInsert].
  final T oldValue;

  /// The new component value associated with this key.
  ///
  /// Is always `null` if [isRemove].
  final T newValue;

  /// True if this component value was inserted.
  final bool isInsert;

  /// True if this component value was removed.
  final bool isRemove;

  /// Create an update record of [entityId] from [oldValue] to [newValue].
  const ComponentStoreChangeRecord(this.entityId, this.oldValue, this.newValue)
      : isInsert = false,
        isRemove = false;

  /// Create an insert record of [entityId] and [newValue].
  const ComponentStoreChangeRecord.insert(this.entityId, this.newValue)
      : isInsert = true,
        isRemove = false,
        oldValue = null;

  /// Create a remove record of [entityId] with a former [oldValue].
  const ComponentStoreChangeRecord.remove(this.entityId, this.oldValue)
      : isInsert = false,
        isRemove = true,
        newValue = null;

  /// Apply this change record to the [componentStore].
  void apply(ComponentStore<T> componentStore) {
    if (isRemove) {
      componentStore.remove(entityId);
    } else {
      componentStore[entityId] = newValue;
    }
  }

  bool operator ==(Object o) =>
      identical(this, o) ||
      o is ComponentStoreChangeRecord<T> &&
          entityId == o.entityId &&
          oldValue == o.oldValue &&
          newValue == o.newValue &&
          isInsert == o.isInsert &&
          isRemove == o.isRemove;

  int get hashCode => hashObjects([
        entityId,
        oldValue,
        newValue,
        isInsert,
        isRemove,
      ]);
}
