/// Provides data structures for storing component data.
library component_data;

import 'dart:async';
import 'dart:collection';

import 'package:observable/observable.dart';
import 'package:quiver/core.dart';

part 'src/component_data/linked_hash_map_store.dart';

/// Registers [ComponentTypesStores] for component types.
///
/// Stores
class TypeStoreRegistry {
  final Map<Type, ComponentTypeStore> _typesStores = {};

  final ChangeNotifier<TypeStoreRegistryChangeRecord> _changeNotifier =
      new ChangeNotifier();

  /// A synchronous stream of the changes made to this [TypeStoreRegistry].
  ///
  /// A change is triggered when a [ComponentTypeStore] is added, removed or
  /// changed.
  Stream<List<TypeStoreRegistryChangeRecord>> get changes =>
      _changeNotifier.changes;

  /// The [ComponentTypeStore]s registered with this [TypeStoreRegistry].
  Iterable<ComponentTypeStore> get stores => _typesStores.values;

  /// The types for which [ComponentTypeStore]s are registered with this
  /// [TypeStoreRegistry].
  Iterable<Type> get types => _typesStores.keys;

  /// Whether or not this [TypeStoreRegistry] contains a [ComponentTypeStore]
  /// for the [type].
  bool hasStore(Type type) => _typesStores.containsKey(type);

  /// Returns the [ComponentTypeStore] registered for the [type] or `null` if
  /// no [ComponentTypeStore] is currently registered for the [type].
  ComponentTypeStore<T> getStore<T>([Type type = T]) => _typesStores[type]
      as ComponentTypeStore<T>;

  /// Registers the [store] for type [type].
  ///
  /// If another [ComponentTypeStore] was already registered for the [type],
  /// then this other store is replaced with the [store].
  void add<T>(Type type, ComponentTypeStore<T> store) {
    final oldStore = _typesStores[type] as ComponentTypeStore<T>;

    _typesStores[type] = store;

    if (oldStore == null) {
      _changeNotifier
        ..notifyChange(new TypeStoreRegistryChangeRecord<T>.insert(type, store))
        ..deliverChanges();
    } else {
      _changeNotifier
        ..notifyChange(new TypeStoreRegistryChangeRecord<T>(type, oldStore, store))
        ..deliverChanges();
    }
  }

  /// Removes the [ComponentTypeStore] associated with the [type] from this
  /// [TypeStoreRegistry].
  ComponentTypeStore<T> remove<T>([Type type = T]) {
    final store = _typesStores[type] as ComponentTypeStore<T>;

    if (store != null) {
      _typesStores.remove(type);
      _changeNotifier
        ..notifyChange(new TypeStoreRegistryChangeRecord<T>.remove(type, store))
        ..deliverChanges();

      return store;
    } else {
      return null;
    }
  }
}

/// Stores component values of type [T] and associates them with entity IDs.
abstract class ComponentTypeStore<T> {
  /// Instantiates a new [ComponentTypeStore] using the default implementation,
  /// [LinkedHashMapStore].
  factory ComponentTypeStore() = LinkedHashMapStore<T>;

  /// A synchronous stream of the changes made to this [ComponentTypeStore].
  ///
  /// A change is triggered when a component value is added, when a component
  /// value is removed, or when a component value is updated.
  ///
  /// See also [ComponentTypeStoreChangeRecord].
  Stream<List<ComponentTypeStoreChangeRecord<T>>> get changes;

  /// The number of component values currently stored in this
  /// [ComponentTypeStore].
  int get length;

  /// Whether this [ComponentTypeStore] is currently empty.
  bool get isEmpty;

  /// Whether there is currently at least 1 component value in this
  /// [ComponentTypeStore].
  bool get isNotEmpty;

  /// The component values currently stored in this [ComponentTypeStore].
  Iterable<T> get components;

  /// The entity IDs for which a component value is currently stored in this
  /// [ComponentTypeStore].
  Iterable<int> get entityIds;

  /// Returns a [ComponentStoreIterator] over this [ComponentTypeStore].
  ComponentStoreIterator<T> get iterator;

  /// Executes the given function [f] for each ([entityId], [component]) pair
  /// stored in this [ComponentTypeStore].
  void forEach(void f(int entityId, T component));

  /// Whether or not this [ComponentTypeStore] contains a component value for
  /// the [entityId].
  bool containsComponentFor(int entityId);

  /// Removes the component value associated with the [entityId] from this
  /// [ComponentTypeStore].
  ///
  /// Does nothing if this [ComponentTypeStore] does not contain a component
  /// value for the [entityId].
  ///
  /// Returns the component value if this [ComponentTypeStore] did contain a
  /// component value for the [entityId], or `null` otherwise.
  T remove(int entityId);

  /// Returns the value associated with the [entityId] or `null` if this
  /// [ComponentTypeStore] does not currently contain a value for the
  /// [entityId].
  T operator [](int entityId);

  /// Associated the given [component] value with the [entityId] and stores it
  /// in this [ComponentTypeStore].
  void operator []=(int entityId, T component);
}

/// An iterator over a [ComponentTypeStore].
///
/// Extends an ordinary [Iterator] by also exposing the [currentEntityId] that
/// is associated with the [current] component value.
abstract class ComponentStoreIterator<T> extends Iterator<T> {
  int get currentEntityId;
}

/// A [ChangeRecord] that denotes adding, removing, or updating a
/// [ComponentTypeStore].
class ComponentTypeStoreChangeRecord<T> implements ChangeRecord {
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
  const ComponentTypeStoreChangeRecord(
      this.entityId, this.oldValue, this.newValue)
      : isInsert = false,
        isRemove = false;

  /// Create an insert record of [entityId] and [newValue].
  const ComponentTypeStoreChangeRecord.insert(this.entityId, this.newValue)
      : isInsert = true,
        isRemove = false,
        oldValue = null;

  /// Create a remove record of [entityId] with a former [oldValue].
  const ComponentTypeStoreChangeRecord.remove(this.entityId, this.oldValue)
      : isInsert = false,
        isRemove = true,
        newValue = null;

  /// Apply this change record to the [componentStore].
  void apply(ComponentTypeStore<T> componentStore) {
    if (isRemove) {
      componentStore.remove(entityId);
    } else {
      componentStore[entityId] = newValue;
    }
  }

  bool operator ==(Object o) =>
      identical(this, o) ||
      o is ComponentTypeStoreChangeRecord<T> &&
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

class TypeStoreRegistryChangeRecord<T> extends ChangeRecord {
  /// The component type for which the store changed.
  final Type type;

  /// The previous store associated with the [type].
  ///
  /// Is always `null` if [isInsert].
  final ComponentTypeStore<T> oldValue;

  /// The new value associated with the [type].
  ///
  /// Is always `null` if [isRemove].
  final ComponentTypeStore<T> newValue;

  /// Whether or not this change concerns an insertion.
  final bool isInsert;

  /// Whether or not this change concerns a removal.
  final bool isRemove;

  /// Create an update record for [type] from [oldValue] to [newValue].
  const TypeStoreRegistryChangeRecord(this.type, this.oldValue, this.newValue)
      : isInsert = false,
        isRemove = false;

  /// Create an insert record for [type] and [newValue].
  const TypeStoreRegistryChangeRecord.insert(this.type, this.newValue)
      : isInsert = true,
        isRemove = false,
        oldValue = null;

  /// Create a remove record for [type] with a former [oldValue].
  const TypeStoreRegistryChangeRecord.remove(this.type, this.oldValue)
      : isInsert = false,
        isRemove = true,
        newValue = null;

  /// Apply this change record to the [typeStoreRegistry].
  void apply(TypeStoreRegistry typeStoreRegistry) {
    if (isRemove) {
      typeStoreRegistry.remove(type);
    } else {
      typeStoreRegistry.add(type, newValue);
    }
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeStoreRegistryChangeRecord<T> &&
          type == other.type &&
          oldValue == other.oldValue &&
          newValue == other.newValue &&
          isInsert == other.isInsert &&
          isRemove == other.isRemove;

  int get hashCode => hashObjects([
        type,
        oldValue,
        newValue,
        isInsert,
        isRemove,
      ]);
}
