/// Provides data structures for an entity-oriented view on component data.
library world;

import 'dart:async';
import 'dart:collection';

import 'package:observable/observable.dart';
import 'package:quiver/core.dart';

import 'component_data.dart';
import 'entity.dart';

/// A view on a [TypeStoreRegistry] as a collection of [Entity] instances.
///
/// Entities can be created by calling the [createEntity()] method on a [World].
/// Components can then be added to these entities via the `[]` operator:
///
///     final myEntity = world.createEntity()
///         ..add(new ComponentA())
///         ..add(new ComponentB());
///
/// Adding components to entities like this will update the [ComponentTypeStore]
/// that corresponds to the component type in the [World]'s [typeStoreRegistry].
/// This also means that you may only add components of a type for which a store
/// is currently registered with the [World]'s [typeStoreRegistry]; if no
/// matching store is currently registered, then an error will be thrown.
///
/// Changes to the [typeStoreRegistry] or any of its [ComponentTypeStore]s will
/// also lead the changes in the [World] and its entities. Adding a new
/// component value to a store for a certain entity ID may result either in the
/// creation of a new entity if no entity with this ID exists in the [World], or
/// adds the component value to the entity if it already existed. Removing a
/// component value for a certain entity ID from a store will remove the
/// component from the corresponding entity in the [World]. Updating a component
/// value for a certain entity ID on a store will update the component value for
/// this component type on the corresponding entity in the world. Removing all
/// component values for a certain entity ID from all stores will not remove the
/// corresponding entity from the [World]; the entity will still exist as an
/// empty (componentless) entity in the [World].
///
/// Note that both a [World] and its individual entities can be observed for
/// [changes]. Changes made via the [typeStoreRegistry] will propagate and
/// trigger the appropriate change notifications on the [World] and/or its
/// individual entities.
class World extends IterableBase<Entity> {
  /// The [TypeStoreRegistry] viewed by this [World].
  final TypeStoreRegistry typeStoreRegistry;

  final Map<int, _WorldEntityView> _entities = {};

  final ChangeNotifier<WorldChangeRecord> _changeNotifier =
      new ChangeNotifier();

  final Map<ComponentTypeStore, StreamSubscription> _storesSubscriptions = {};

  int _lastId = -1;

  /// Instantiates a new [World] as a view on the given [typeStoreRegistry].
  World(this.typeStoreRegistry) {
    for (final store in typeStoreRegistry.stores) {
      for (final id in store.entityIds) {
        final entity = _entities[id];

        if (entity == null) {
          _entities[id] = new _WorldEntityView(this, id).._length = 1;

          if (id > _lastId) {
            _lastId = id;
          }
        } else {
          entity._length++;
        }
      }

      _storesSubscriptions[store] = store.changes.listen((changeRecords) {
        _handleComponentStoreChange(changeRecords);
      });
    }

    typeStoreRegistry.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        if (changeRecord.isInsert) {
          final store = changeRecord.newValue;

          for (final id in changeRecord.newValue.entityIds) {
            final entity = _entities[id];

            if (entity == null) {
              _createEntityInternal(id, 1);
            } else {
              entity._length++;

              entity._changeNotifier
                ..notifyChange(new EntityChangeRecord.add(store[id]))
                ..deliverChanges();
            }
          }

          _storesSubscriptions[store] = store.changes.listen((changeRecords) {
            _handleComponentStoreChange(changeRecords);
          });
        } else if (changeRecord.isRemove) {
          final iterator = changeRecord.oldValue.iterator;

          while (iterator.moveNext()) {
            final entity = _entities[iterator.currentEntityId];

            if (entity != null) {
              entity._length--;

              entity._changeNotifier
                ..notifyChange(new EntityChangeRecord.remove(iterator.current))
                ..deliverChanges();
            }
          }

          _storesSubscriptions[changeRecord.oldValue].cancel();
          _storesSubscriptions.remove(changeRecord.oldValue);
        } else {
          final oldStore = changeRecord.oldValue;
          final newStore = changeRecord.newValue;
          final oldIds = oldStore.entityIds.toSet();
          final newIds = newStore.entityIds.toSet();

          for (final id in newIds) {
            final entity = _entities[id];

            if (oldIds.contains(id)) {
              oldIds.remove(id);

              if (entity != null) {
                entity._changeNotifier
                  ..notifyChange(
                      new EntityChangeRecord(oldStore[id], newStore[id]))
                  ..deliverChanges();
              }
            } else {
              if (entity == null) {
                _createEntityInternal(id, 1);
              } else {
                entity._length++;

                entity._changeNotifier
                  ..notifyChange(new EntityChangeRecord.add(newStore[id]))
                  ..deliverChanges();
              }
            }
          }

          for (final id in oldIds) {
            final entity = _entities[id];

            if (entity != null) {
              entity._length--;

              entity._changeNotifier
                ..notifyChange(new EntityChangeRecord.remove(oldStore[id]))
                ..deliverChanges();
            }
          }

          _storesSubscriptions[oldStore].cancel();
          _storesSubscriptions.remove(oldStore);

          _storesSubscriptions[newStore] =
              newStore.changes.listen((changeRecords) {
            _handleComponentStoreChange(changeRecords);
          });
        }
      }
    });
  }

  /// A synchronous [Stream] of the changes that occur to this [World].
  Stream<List<WorldChangeRecord>> get changes => _changeNotifier.changes;

  Iterator<Entity> get iterator => _entities.values.iterator;

  int get length => _entities.length;

  bool get isEmpty => _entities.isEmpty;

  bool get isNotEmpty => _entities.isNotEmpty;

  bool contains(Object object) =>
      object is _WorldEntityView &&
      object.world == this &&
      _entities.containsKey(object.id);

  /// Creates a new empty (componentless) entity in this [World].
  Entity createEntity() => _createEntityInternal(_lastId + 1);

  /// Removes the given [entity] from this [World].
  ///
  /// This will also remove any component values associated with the [entity]'s
  /// ID in any of the [ComponentTypeStore]s registered with this [World]'s
  /// [typeStoreRegistry].
  ///
  /// Returns `true` if the [entity] was contained in this [World] and removed
  /// successfully, `false` otherwise.
  bool removeEntity(Entity entity) {
    if (entity is _WorldEntityView && entity.world == this) {
      return removeEntityById(entity.id);
    } else {
      return false;
    }
  }

  /// Removes the entity identified by the given [entityId] from this [World].
  ///
  /// This will also remove any component values associated with the [entityId]
  /// in any of the [ComponentTypeStore]s registered with this [World]'s
  /// [typeStoreRegistry].
  ///
  /// Returns `true` if an entity with the [entityId] was contained in this
  /// [World] and it was removed successfully, `false` otherwise.
  bool removeEntityById(int entityId) {
    final entity = _entities.remove(entityId);

    if (entity != null) {
      for (final store in typeStoreRegistry.stores) {
        store.remove(entityId);
      }

      _changeNotifier
        ..notifyChange(new WorldChangeRecord.remove(this, entity))
        ..deliverChanges();

      return true;
    } else {
      return false;
    }
  }

  /// Finds the entity identified by the given [id].
  ///
  /// Returns the entity identified by the [id] if this [World] contains an
  /// entity identified by the [id], `null` otherwise.
  Entity findEntity(int id) => _entities[id];

  Entity _createEntityInternal(int id, [int length = 0]) {
    final entity = new _WorldEntityView(this, id).._length = length;

    _entities[id] = entity;

    if (id > _lastId) {
      _lastId = id;
    }

    _changeNotifier
      ..notifyChange(new WorldChangeRecord.create(this, entity))
      ..deliverChanges();

    return entity;
  }

  void _handleComponentStoreChange(
      List<ComponentTypeStoreChangeRecord> changeRecords) {
    for (final changeRecord in changeRecords) {
      final entityId = changeRecord.entityId;
      final entity = _entities[entityId];

      if (entity == null) {
        if (changeRecord.isInsert) {
          _createEntityInternal(entityId, 1);
        }
      } else {
        if (changeRecord.isInsert) {
          entity._length++;

          entity._changeNotifier
            ..notifyChange(new EntityChangeRecord.add(changeRecord.newValue))
            ..deliverChanges();
        } else if (changeRecord.isRemove) {
          entity._length--;

          entity._changeNotifier
            ..notifyChange(new EntityChangeRecord.remove(changeRecord.oldValue))
            ..deliverChanges();
        } else {
          entity._changeNotifier
            ..notifyChange(new EntityChangeRecord(
                changeRecord.oldValue, changeRecord.newValue))
            ..deliverChanges();
        }
      }
    }
  }
}

/// A [ChangeRecord] that denotes the creation or removal of entities from a
/// [World].
class WorldChangeRecord implements ChangeRecord {
  /// The [World] to which the change applies.
  final World world;

  /// Whether the change concerns the removal of the [entity].
  final bool isRemove;

  /// The entity that was created or removed in the operation.
  final Entity entity;

  /// Creates a new [WorldChangRecord] that represents the creation of a new
  /// entity,
  const WorldChangeRecord.create(this.world, this.entity) : isRemove = false;

  /// Creates a new [WorldChangeRecord] that represents the removal of an
  /// entity.
  const WorldChangeRecord.remove(this.world, this.entity) : isRemove = true;

  /// Whether the change concerns the creation of the [entity].
  bool get isCreate => !isRemove;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldChangeRecord &&
          world == other.world &&
          entity == other.entity &&
          isRemove == other.isRemove;

  int get hashCode => hash3(world, entity, isRemove);

  String toString() {
    if (isRemove) {
      return 'WorldChangeRecord.remove($entity)';
    } else {
      return 'WorldChangeRecord.create($entity)';
    }
  }
}

class _WorldEntityView extends IterableBase<Object> implements Entity {
  final World world;

  final int id;

  int _length = 0;

  final ChangeNotifier<EntityChangeRecord> _changeNotifier =
      new ChangeNotifier();

  _WorldEntityView(this.world, this.id);

  Stream<List<EntityChangeRecord>> get changes => _changeNotifier.changes;

  int get length => _length;

  bool contains(Object value) {
    final store = world.typeStoreRegistry.getStore(value.runtimeType);

    if (store == null) {
      return false;
    } else {
      return store[id] == value;
    }
  }

  bool hasComponentType(Type type) {
    final store = world.typeStoreRegistry.getStore(type);

    if (store == null) {
      return false;
    } else {
      return store.containsComponentFor(id);
    }
  }

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  Iterator<Object> get iterator => new _WorldEntityViewIterator(this);

  T add<T>(T component, [Type componentType]) {
    final type = T == dynamic ? (componentType ?? component.runtimeType) : T;
    final store = world.typeStoreRegistry.getStore(type);

    if (store == null) {
      throw new ArgumentError('Tried to add a component of type `$type`, but '
          'no store of that type was registered with the type store registry.');
    } else {
      final oldValue = store[id];

      store[id] = component;

      return oldValue;
    }
  }

  bool addIfAbsent<T>(T component) {
    final type = T == dynamic ? component.runtimeType : T;
    final store = world.typeStoreRegistry.getStore(type);

    if (store == null) {
      throw new ArgumentError('Tried to add a component of type `$type`, but '
          'no store of that type was registered with the type store registry.');
    } else {
      if (!store.containsComponentFor(id)) {
        store[id] = component;

        return true;
      } else {
        return false;
      }
    }
  }

  T remove<T>([Type componentType = T]) {
    final store = world.typeStoreRegistry.getStore<T>(componentType);

    if (store == null) {
      return null;
    } else {
      return store.remove(id);
    }
  }

  void clear() {
    for (final store in world.typeStoreRegistry.stores) {
      store.remove(id);
    }
  }

  T getComponent<T>([Type componentType = T]) {
    final store = world.typeStoreRegistry.getStore<T>(componentType);

    if (store == null) {
      return null;
    } else {
      return store[id];
    }
  }

  String toString() => 'Entity(id: $id)';
}

class _WorldEntityViewIterator implements Iterator<Object> {
  final _WorldEntityView entity;

  Iterator<ComponentTypeStore> _storesIterator;

  int _entityId;

  Object _current;

  _WorldEntityViewIterator(this.entity) {
    _entityId = entity.id;
    _storesIterator = entity.world.typeStoreRegistry.stores.iterator;
  }

  Object get current => _storesIterator.current[_entityId];

  bool moveNext() {
    if (_storesIterator.moveNext()) {
      _current = _storesIterator.current[_entityId];

      while (_current == null) {
        if (!_storesIterator.moveNext()) {
          return false;
        }

        _current = _storesIterator.current[_entityId];
      }

      return true;
    } else {
      return false;
    }
  }
}
