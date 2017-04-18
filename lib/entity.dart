library entity;

import 'dart:async';
import 'dart:collection';

import 'package:observable/observable.dart';
import 'package:quiver/core.dart';

/// A uniquely identifiable collection of components.
abstract class Entity extends Iterable<Object> {
  /// An integer that uniquely identifies this [Entity] in its world.
  int get id;

  /// Instantiates a new [Entity] identified by the given [id].
  ///
  /// This will return [Entity] instance that uses the default implementation
  /// backed by a [Map] that stores the components.
  factory Entity(int id) = _MapEntity;

  /// A synchronous stream the changes made to this entity.
  ///
  /// A change is triggered when a component value is added, removed or updated.
  ///
  /// See also [EntityChangeRecord].
  Stream<List<EntityChangeRecord>> get changes;

  /// Whether or not this [Entity] has a component of the given [type].
  bool hasComponentType(Type type);

  /// Adds the [component] to this [Entity].
  ///
  /// If this [Entity] already contains a component with the same runtime type,
  /// then this old component value is replaced with the [component].
  ///
  /// Returns the old component value if this [Entity] already contained a
  /// component of the [component]'s type, `null` otherwise.
  Object add<T>(T component);

  /// Adds the [component] to this [Entity] if it does not already contain a
  /// a component of the same runtime type.
  ///
  /// Returns `true` if this [Entity] did not yet contain a component of the
  /// [component]'s type, `false` if it did and the component was not added.
  bool addIfAbsent<T>(T component);

  /// Removes the component that matches the [componentType] from this [Entity].
  ///
  /// Does nothing if this [Entity] does not contain a component of the given
  /// [componentType].
  ///
  /// Returns the removed component value if the [Entity] contains a component
  /// of the given [componentType], `null` otherwise.
  T remove<T>(Type componentType);

  /// Removes all components from this [Entity].
  void clear();

  /// Returns the component that matches the given [componentType] or `null` if
  /// this [Entity] does not contain a component of the [componentType].
  T getComponent<T>(Type componentType);
}

class _MapEntity extends IterableBase<Object> implements Entity {
  final int id;

  final Map<Type, Object> _typeComponents = {};

  final ChangeNotifier<EntityChangeRecord> _changeNotifier =
      new ChangeNotifier();

  _MapEntity(this.id);

  Stream<List<EntityChangeRecord>> get changes => _changeNotifier.changes;

  int get length => _typeComponents.length;

  bool contains(Object value) => _typeComponents.containsValue(value);

  bool hasComponentType(Type type) => _typeComponents.containsKey(type);

  bool get isEmpty => _typeComponents.isEmpty;

  bool get isNotEmpty => _typeComponents.isNotEmpty;

  Iterator<Object> get iterator => _typeComponents.values.iterator;

  T add<T>(T component) {
    final type = T == dynamic ? component.runtimeType : T;
    final oldValue = _typeComponents[type] as T;

    _typeComponents[type] = component;

    if (!_changeNotifier.hasObservers) {
      return oldValue;
    } else {
      if (oldValue == null) {
        _changeNotifier
          ..notifyChange(new EntityChangeRecord<T>.add(component))
          ..deliverChanges();

        return null;
      } else {
        _changeNotifier
          ..notifyChange(new EntityChangeRecord<T>(oldValue, component))
          ..deliverChanges();

        return oldValue;
      }
    }
  }

  bool addIfAbsent<T>(T component) {
    final type = T == dynamic ? component.runtimeType : T;

    if (!_typeComponents.containsKey(type)) {
      _typeComponents[type] = component;

      _changeNotifier
        ..notifyChange(new EntityChangeRecord<T>.add(component))
        ..deliverChanges();

      return true;
    } else {
      return false;
    }
  }

  T remove<T>(Type componentType) {
    final component = _typeComponents.remove(componentType) as T;

    if (component != null) {
      _changeNotifier
        ..notifyChange(new EntityChangeRecord<T>.remove(component))
        ..deliverChanges();
    }

    return component;
  }

  void clear() {
    if (!_changeNotifier.hasObservers || isEmpty) {
      _typeComponents.clear();

      return;
    }

    for (final component in _typeComponents.values) {
      _changeNotifier.notifyChange(new EntityChangeRecord.remove(component));
    }

    _typeComponents.clear();
    _changeNotifier.deliverChanges();
  }

  T getComponent<T>(Type type) => _typeComponents[type] as T;
}

/// A [ChangeRecord] that denotes adding, removing, or updating an [Entity].
class EntityChangeRecord<T> implements ChangeRecord {
  /// The previous component value.
  ///
  /// Is always `null` if [isInsert].
  final T oldValue;

  /// The new component value.
  ///
  /// Is always `null` if [isRemove].
  final T newValue;

  /// True if this component value was added.
  final bool isAdd;

  /// True if this component value was removed.
  final bool isRemove;

  /// Create an update record of [entityId] from [oldValue] to [newValue].
  const EntityChangeRecord(this.oldValue, this.newValue)
      : isAdd = false,
        isRemove = false;

  /// Create an add record of [entityId] and [newValue].
  const EntityChangeRecord.add(this.newValue)
      : isAdd = true,
        isRemove = false,
        oldValue = null;

  /// Create a remove record of [entityId] with a former [oldValue].
  const EntityChangeRecord.remove(this.oldValue)
      : isAdd = false,
        isRemove = true,
        newValue = null;

  /// Apply this change record to the [componentStore].
  void apply(Entity entity) {
    if (isRemove) {
      entity.remove<T>(oldValue.runtimeType);
    } else {
      entity.add<T>(newValue);
    }
  }

  bool operator ==(Object o) =>
      identical(this, o) ||
      o is EntityChangeRecord<T> &&
          oldValue == o.oldValue &&
          newValue == o.newValue &&
          isAdd == o.isAdd &&
          isRemove == o.isRemove;

  int get hashCode => hash4(
        oldValue,
        newValue,
        isAdd,
        isRemove,
      );
}
