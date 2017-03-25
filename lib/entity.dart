library entity;

import 'dart:async';

import 'package:observable/observable.dart';
import 'package:quiver/core.dart';

class Entity {
  final int id;

  final Map<Type, Object> _typeComponents = {};

  final ChangeNotifier<EntityChangeRecord> _changeNotifier =
      new ChangeNotifier();

  Entity([this.id]);

  Stream<List<EntityChangeRecord>> get changes => _changeNotifier.changes;

  int get length => _typeComponents.length;

  bool contains(Object value) => _typeComponents.containsValue(value);

  bool containsType(Type type) => _typeComponents.containsKey(type);

  bool get isEmpty => _typeComponents.isEmpty;

  bool get isNotEmpty => _typeComponents.isNotEmpty;

  Iterable<Type> get types => _typeComponents.keys;

  bool add(Object component) {
    if (!_changeNotifier.hasObservers) {
      return _typeComponents[component.runtimeType] = component;
    } else {
      final oldValue = _typeComponents[component.runtimeType];

      if (oldValue == null) {
        _changeNotifier.notifyChange(
            new EntityChangeRecord.add(component.runtimeType, component));

        return true;
      } else {
        _changeNotifier.notifyChange(
            new EntityChangeRecord(component.runtimeType, oldValue, component));

        return false;
      }
    }
  }

  bool addIfAbsent(Object component) {
    if (!_typeComponents.containsKey(component.runtimeType)) {
      _typeComponents[component.runtimeType] = component;

      _changeNotifier.notifyChange(
          new EntityChangeRecord.add(component.runtimeType, component));

      return true;
    } else {
      return false;
    }
  }

  Object remove(Type componentType) {
    final component = _typeComponents.remove(componentType);

    if (component != null) {
      _changeNotifier.notifyChange(
          new EntityChangeRecord.remove(componentType, component));
    }

    return component;
  }

  void clear() {
    if (!_changeNotifier.hasObservers || isEmpty) {
      _typeComponents.clear();

      return;
    }

    _typeComponents.forEach((type, component) {
      _changeNotifier
          .notifyChange(new EntityChangeRecord.remove(type, component));
    });

    _typeComponents.clear();
  }

  void forEach(void f(Object component)) {
    _typeComponents.forEach((type, component) => f(component));
  }

  Object operator [](Type type) => _typeComponents[type];
}

/// A [ChangeRecord] that denotes adding, removing, or updating an [Entity].
class EntityChangeRecord<T> implements ChangeRecord {
  /// The component type for which the value changed.
  final Type componentType;

  /// The previous component value associated with the [componentType].
  ///
  /// Is always `null` if [isInsert].
  final T oldValue;

  /// The new component value associated with the [componentType].
  ///
  /// Is always `null` if [isRemove].
  final T newValue;

  /// True if this component value was added.
  final bool isAdd;

  /// True if this component value was removed.
  final bool isRemove;

  /// Create an update record of [entityId] from [oldValue] to [newValue].
  const EntityChangeRecord(this.componentType, this.oldValue, this.newValue)
      : isAdd = false,
        isRemove = false;

  /// Create an add record of [entityId] and [newValue].
  const EntityChangeRecord.add(this.componentType, this.newValue)
      : isAdd = true,
        isRemove = false,
        oldValue = null;

  /// Create a remove record of [entityId] with a former [oldValue].
  const EntityChangeRecord.remove(this.componentType, this.oldValue)
      : isAdd = false,
        isRemove = true,
        newValue = null;

  /// Apply this change record to the [componentStore].
  void apply(Entity entity) {
    if (isRemove) {
      entity.remove(componentType);
    } else {
      entity.add(newValue);
    }
  }

  bool operator ==(Object o) =>
      identical(this, o) ||
      o is EntityChangeRecord<T> &&
          componentType == o.componentType &&
          oldValue == o.oldValue &&
          newValue == o.newValue &&
          isAdd == o.isAdd &&
          isRemove == o.isRemove;

  int get hashCode => hashObjects([
        componentType,
        oldValue,
        newValue,
        isAdd,
        isRemove,
      ]);
}
