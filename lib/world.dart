library world;

import 'dart:async';
import 'dart:collection';

import 'package:observable/observable.dart';
import 'package:quiver/core.dart';

import 'component_store.dart';
import 'entity.dart';

class World extends IterableBase<Entity> {
  final Map<Type, ComponentStore> _typesStores = {};

  final Map<int, _WorldEntityView> _entities = {};

  final ChangeNotifier<WorldChangeRecord> _changeNotifier =
      new ChangeNotifier();

  ComponentDatabase _componentDatabase;

  int _lastId = -1;

  World() {
    _componentDatabase = new ComponentDatabase(this);
  }

  ComponentDatabase get componentDatabase => _componentDatabase;

  Stream<List<WorldChangeRecord>> get changes => _changeNotifier.changes;

  Iterator<Entity> get iterator => _entities.values.iterator;

  Entity createEntity() => _createEntityInternal(_lastId++);

  bool removeEntity(Entity entity) => removeEntityById(entity.id);

  bool removeEntityById(int entityId) {
    final entity = _entities.remove(entityId);

    if (entity != null) {
      _changeNotifier.notifyChange(new WorldChangeRecord.remove(this, entity));

      for (final store in componentDatabase.stores) {
        store.remove(entityId);
      }

      return true;
    } else {
      return false;
    }
  }

  Entity findEntity(int id) => _entities[id];

  Entity _createEntityInternal(int id, [int length = 0]) {
    final entity = new _WorldEntityView(this, id).._length = length;

    _entities[id] = entity;
    _changeNotifier.notifyChange(new WorldChangeRecord.add(this, entity));

    return entity;
  }
}

class ComponentDatabase {
  final World world;

  final Map<Type, ComponentStore> _typesStores = {};

  final Map<ComponentStore, StreamSubscription> _storesSubscriptions = {};

  ComponentDatabase(this.world);

  Iterable<ComponentStore> get stores => _typesStores.values;

  Iterable<Type> get types => _typesStores.keys;

  bool containsStore(ComponentStore store) => _typesStores.containsValue(store);

  bool containsType(Type type) => _typesStores.containsKey(type);

  bool remove(Type type) {
    final store = _typesStores[type];

    if (store != null) {
      _storesSubscriptions[store].cancel();
      _storesSubscriptions.remove(store);
      _typesStores.remove(type);

      return true;
    } else {
      return false;
    }
  }

  void forEach(void f(Type type, ComponentStore store)) => _typesStores.forEach(f);

  ComponentStore operator [](Type type) => _typesStores[type];

  void operator []=(Type type, ComponentStore store) {
    if (_typesStores.containsKey(type)) {
      remove(type);
    }

    _typesStores[type] = store;

    for (final entityId in store.entityIds) {
      if (!world._entities.containsKey(entityId)) {
        world._createEntityInternal(entityId, 1);
      }
    }

    _storesSubscriptions[store] = store.changes.listen((changeRecords) {
      for (final changeRecord in changeRecords) {
        final entityId = changeRecord.entityId;
        final entity = world._entities[entityId];

        if (entity == null) {
          if (changeRecord.isInsert) {
            world._createEntityInternal(entityId, 1);
          }
        } else {
          if (changeRecord.isInsert) {
            entity._changeNotifier.notifyChange(
                new EntityChangeRecord.add(type, changeRecord.newValue));

            entity._length++;
          } else if (changeRecord.isRemove) {
            entity._changeNotifier.notifyChange(
                new EntityChangeRecord.remove(type, changeRecord.oldValue));
            entity._length--;
          } else {
            entity._changeNotifier.notifyChange(new EntityChangeRecord(
                type, changeRecord.oldValue, changeRecord.newValue));
          }
        }
      }
    });
  }
}

/// A [ChangeRecord] that denotes the creation or removal of entities from a
/// [World].
class WorldChangeRecord implements ChangeRecord {
  final World world;

  /// Whether the change concerns the removal of the [entity].
  final bool isRemove;

  /// The entity that was created or removed in the operation.
  final Entity entity;

  const WorldChangeRecord.add(this.world, this.entity) : isRemove = false;
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
}

class _WorldEntityView implements Entity {
  final World world;

  final int id;

  int _length = 0;

  final ChangeNotifier<EntityChangeRecord> _changeNotifier =
      new ChangeNotifier();

  _WorldEntityView(this.world, this.id);

  Stream<List<EntityChangeRecord>> get changes => _changeNotifier.changes;

  int get length => _length;

  bool contains(Object value) {
    final store = world.componentDatabase[value.runtimeType];

    if (store == null) {
      return false;
    } else {
      return store[id] == value;
    }
  }

  bool containsType(Type type) {
    final store = world.componentDatabase[type];

    if (store == null) {
      return false;
    } else {
      return store.containsComponentFor(id);
    }
  }

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  Iterable<Type> get types {
    final types = <Type>[];

    world.componentDatabase.forEach((type, store) {
      if (store.containsComponentFor(id)) {
        types.add(type);
      }
    });

    return types;
  }

  bool add(Object component) {
    final store = world.componentDatabase[component.runtimeType];

    if (store == null) {
      throw new ArgumentError('Could not add component `$component` of runtime '
          'type `${component.runtimeType}`, because no store exists for this '
          'type on this entities world.');
    } else {
      final oldLength = store.length;

      store[id] = component;

      // No need to call the change notifier here or update _length, the world
      // is listening to changes on the component store and will take care of
      // both of these things.

      return oldLength < store.length;
    }
  }

  bool addIfAbsent(Object component) {
    final store = world.componentDatabase[component.runtimeType];

    if (store == null) {
      throw new ArgumentError('Could not add component `$component` of runtime '
          'type `${component.runtimeType}`, because no store exists for this '
          'type on this entities world.');
    } else {
      if (!store.containsComponentFor(id)) {
        store[id] = component;

        // No need to call the change notifier here or update _length, the world
        // is listening to changes on the component store and will take care of
        // both of these things.

        return true;
      } else {
        return false;
      }
    }
  }

  Object remove(Type componentType) {
    final store = world.componentDatabase[componentType];

    if (store == null) {
      return false;
    } else {
      // No need to call the change notifier here or update _length, the world
      // is listening to changes on the component store and will take care of
      // both of these things.

      return store.remove(id);
    }
  }

  void clear() {}

  void forEach(void f(Object component)) {
    for (final store in world.componentDatabase.stores) {
      if (store.containsComponentFor(id)) {
        f(store[id]);
      }
    }
  }

  Object operator [](Type type) {
    final store = world.componentDatabase[type];

    if (store != null) {
      return store[id];
    } else {
      return null;
    }
  }
}
