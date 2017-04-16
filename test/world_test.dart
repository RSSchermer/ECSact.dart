import 'package:test/test.dart';
import 'helper.dart';

import 'package:ecsact/component_data.dart';
import 'package:ecsact/entity.dart';
import 'package:ecsact/world.dart';

class A {
  final int id;

  A(this.id);

  String toString() => 'A($id)';
}

class B {
  final int id;

  B(this.id);

  String toString() => 'B($id)';
}

class C {
  final int id;

  C(this.id);

  String toString() => 'C($id)';
}

void main() {
  group('World', () {
    group('as a view on post-populated component stores', () {
      final store0 = new LinkedHashMapStore<A>();
      final store1 = new LinkedHashMapStore<B>();
      final registry = new TypeStoreRegistry()..add<A>(A, store0)..add<B>(B, store1);

      final world = new World(registry);

      final a0 = new A(0);
      final a1 = new A(1);
      final a2 = new A(2);

      final b0 = new B(0);
      final b1 = new B(1);

      final recorder = new ChangeRecorder(world.changes);
      final recording = recorder.start();

      store0[0] = a0;
      store0[1] = a1;
      store0[2] = a2;

      store1[0] = b0;
      store1[2] = b1;

      recorder.stop();

      test('produces a world of the right length', () {
        expect(world.length, equals(3));
      });

      test('triggers the correct creation events on the world', () async {
        expect(await recording, equals([
          [new WorldChangeRecord.create(world, world.findEntity(0))],
          [new WorldChangeRecord.create(world, world.findEntity(1))],
          [new WorldChangeRecord.create(world, world.findEntity(2))],
        ]));
      });

      group('entity 0', () {
        final entity = world.findEntity(0);

        test('length returns the correct value', () {
          expect(entity.length, equals(2));
        });

        test('contains the correct component values', () {
          expect(entity.toList(), unorderedEquals([a0, b0]));
        });

        test('isEmpty returns false', () {
          expect(entity.isEmpty, isFalse);
        });

        test('isNotEmpty returns true', () {
          expect(entity.isNotEmpty, isTrue);
        });

        group('contains', () {
          test('with a component value that is not contained on the entity returns false', () {
            expect(entity.contains(new A(99)), isFalse);
          });

          test('with a component value that is contained on the entity returns true', () {
            expect(entity.contains(a0), isTrue);
          });
        });

        group('hasComponentType', () {
          test('with a component type that is not contained on the entity returns false', () {
            expect(entity.hasComponentType(C), isFalse);
          });

          test('with a component type that is contained on the entity returns true', () {
            expect(entity.hasComponentType(A), isTrue);
          });
        });

        group('getComponent', () {
          test('with a type that is not contained on the entity returns null', () {
            expect(entity.getComponent<C>(C), isNull);
          });

          test('with a type that is contained on the entity returns the component value', () {
            expect(entity.getComponent<A>(A), equals(a0));
          });
        });

        group('add', () {
          group('with a component of a type that is not yet contained on the entity', () {
            var recording;
            var store;
            var result;
            final c = new C(99);

            setUp(() {
              store = new LinkedHashMapStore<C>();
              registry.add<C>(C, store);

              final recorder = new ChangeRecorder(entity.changes);
              recording = recorder.start();

              result = entity.add<C>(c);

              recorder.stop();
            });

            tearDown(() {
              registry.remove<C>(C);
            });

            test('returns null', () {
              expect(result, isNull);
            });

            test('increases the length of the entity by 1', () {
              expect(entity.length, equals(3));
            });

            test('adds the component value to the store', () {
              expect(store[0], equals(c));
            });

            test('triggers an add event on the entity', () async {
              expect(await recording, equals([[new EntityChangeRecord.add(c)]]));
            });
          });

          group('with a component type that is already contained on the entity', () {
            var recording;
            var result;
            final newA = new A(99);

            setUp(() {
              final recorder = new ChangeRecorder(entity.changes);
              recording = recorder.start();

              result = entity.add<A>(newA);

              recorder.stop();
            });

            tearDown(() {
              store0[0] = a0;
            });

            test('returns the old value', () {
              expect(result, equals(a0));
            });

            test('does not increase the length of the entity', () {
              expect(entity.length, equals(2));
            });

            test('updates the component value in the store', () {
              expect(store0[0], equals(newA));
            });

            test('triggers an update event on the entity', () async {
              expect(await recording, equals([[new EntityChangeRecord(a0, newA)]]));
            });
          });
        });

        group('addIfAbsent', () {
          group('with a component of a type that is not yet contained on the entity', () {
            var recording;
            var store;
            var result;
            final c = new C(99);

            setUp(() {
              store = new LinkedHashMapStore<C>();
              registry.add<C>(C, store);

              final recorder = new ChangeRecorder(entity.changes);
              recording = recorder.start();

              result = entity.addIfAbsent<C>(c);

              recorder.stop();
            });

            tearDown(() {
              registry.remove<C>(C);
            });

            test('returns true', () {
              expect(result, isTrue);
            });

            test('increases the length of the entity by 1', () {
              expect(entity.length, equals(3));
            });

            test('adds the component value to the store', () {
              expect(store[0], equals(c));
            });

            test('triggers an add event on the entity', () async {
              expect(await recording, equals([[new EntityChangeRecord.add(c)]]));
            });
          });

          group('with a component type that is already contained on the entity', () {
            var recording;
            var result;
            final newA = new A(99);

            setUp(() {
              final recorder = new ChangeRecorder(entity.changes);
              recording = recorder.start();

              result = entity.addIfAbsent<A>(newA);

              recorder.stop();
            });

            tearDown(() {
              store0[0] = a0;
            });

            test('returns false', () {
              expect(result, false);
            });

            test('does not change the length of the entity', () {
              expect(entity.length, equals(2));
            });

            test('does not update the component value in the store', () {
              expect(store0[0], equals(a0));
            });

            test('does not trigger any events on the entity', () async {
              expect(await recording, isEmpty);
            });
          });
        });

        group('remove', () {
          group('with a type that is contained on the entity', () {
            var recording;
            var result;

            setUp(() {
              final recorder = new ChangeRecorder(entity.changes);
              recording = recorder.start();

              result = entity.remove<B>(B);

              recorder.stop();
            });

            tearDown(() {
              store1[0] = b0;
            });

            test('returns the component value', () {
              expect(result, equals(b0));
            });

            test('decreases the length of the entity by 1', () {
              expect(entity.length, equals(1));
            });

            test('removes the component value from the component store', () {
              expect(store1[0], isNull);
            });

            test('triggers a remove event on the entity', () async {
              expect(await recording, equals([[new EntityChangeRecord.remove(b0)]]));
            });
          });

          group('with a type that is not contained on the entity', () {
            var recording;
            var result;

            setUp(() {
              final recorder = new ChangeRecorder(entity.changes);
              recording = recorder.start();

              result = entity.remove<C>(C);

              recorder.stop();
            });

            test('returns null', () {
              expect(result, isNull);
            });

            test('does not decrease the length of the entity', () {
              expect(entity.length, equals(2));
            });

            test('does not trigger any events on the entity', () async {
              expect(await recording, isEmpty);
            });
          });
        });

        group('clear', () {
          var recording;

          setUp(() {
            final recorder = new ChangeRecorder(entity.changes);
            recording = recorder.start();

            entity.clear();

            recorder.stop();
          });

          tearDown(() {
            store0[0] = a0;
            store1[0] = b0;
          });

          test('reduces the length to 0', () {
            expect(entity.length, equals(0));
          });

          test('isEmpty returns true', () {
            expect(entity.isEmpty, isTrue);
          });

          test('isNotEmpty returns false', () {
            expect(entity.isNotEmpty, isFalse);
          });

          test('removes component A from its store', () {
            expect(store0[0], isNull);
          });

          test('removes component B from its store', () {
            expect(store1[0], isNull);
          });

          test('triggers 2 remove events on the entity', () async {
            expect(await recording, equals([
              [new EntityChangeRecord.remove(a0)],
              [new EntityChangeRecord.remove(b0)]
            ]));
          });
        });

        group('after updating a component value on a component store', () {
          final updatedA = new A(99);
          var recording;

          setUp(() {
            final recorder = new ChangeRecorder(entity.changes);
            recording = recorder.start();

            store0[0] = updatedA;

            recorder.stop();
          });

          tearDown(() {
            store0[0] = a0;
          });

          test('has the correct length', () {
            expect(entity.length, equals(2));
          });

          test('contains the correct component values', () {
            expect(entity.toList(), unorderedEquals([updatedA, b0]));
          });

          test('triggers an update event on the entity', () async {
            expect(await recording, equals([[new EntityChangeRecord(a0, updatedA)]]));
          });
        });

        group('after removing a component value from a component store', () {
          var recording;

          setUp(() {
            final recorder = new ChangeRecorder(entity.changes);
            recording = recorder.start();

            store0.remove(0);

            recorder.stop();
          });

          tearDown(() {
            store0[0] = a0;
          });

          test('has the correct length', () {
            expect(entity.length, equals(1));
          });

          test('contains the correct component values', () {
            expect(entity.toList(), unorderedEquals([b0]));
          });

          test('triggers a remove event on the entity', () async {
            expect(await recording, equals([[new EntityChangeRecord.remove(a0)]]));
          });
        });
      });

      group('entity 1', () {
        final entity = world.findEntity(1);

        test('has the correct length', () {
          expect(entity.length, equals(1));
        });

        test('contains the correct component values', () {
          expect(entity.toList(), unorderedEquals([a1]));
        });

        group('after adding a component value to a component store', () {
          final newB = new B(99);
          var recording;

          setUp(() {
            final recorder = new ChangeRecorder(entity.changes);
            recording = recorder.start();

            store1[1] = newB;

            recorder.stop();
          });

          tearDown(() {
            store1.remove(1);
          });

          test('has the correct length', () {
            expect(entity.length, equals(2));
          });

          test('contains the correct component values', () {
            expect(entity.toList(), unorderedEquals([a1, newB]));
          });

          test('triggers an addition event on the entity', () async {
            expect(await recording, equals([[new EntityChangeRecord.add(newB)]]));
          });
        });
      });

      group('entity 2', () {
        final entity = world.findEntity(2);

        test('has the correct length', () {
          expect(entity.length, equals(2));
        });

        test('contains the correct component values', () {
          expect(entity.toList(), unorderedEquals([a2, b1]));
        });
      });

      group('createEntity', () {
        var newEntity;
        var recording;

        setUp(() {
          final recorder = new ChangeRecorder(world.changes);

          recording = recorder.start();
          newEntity = world.createEntity();
          recorder.stop();
        });

        tearDown(() {
          world.removeEntity(newEntity);
        });

        test('increases the world length by 1', () {
          expect(world.length, equals(4));
        });

        test('returns an entity without any components', () {
          expect(newEntity.toList(), isEmpty);
        });

        test('triggers an creation event on the world', () async {
          expect(await recording, equals([[new WorldChangeRecord.create(world, newEntity)]]));
        });
      });

      group('removeEntity', () {
        group('with an entity that is contained in the world', () {
          var entity;
          var recording;
          var result;

          setUp(() {
            entity = world.findEntity(1);
            final recorder = new ChangeRecorder(world.changes);
            recording = recorder.start();

            result = world.removeEntity(entity);

            recorder.stop();
          });

          tearDown(() {
            store0[1] = a1;
          });

          test('decreases the world length by 1', () {
            expect(world.length, equals(2));
          });

          test('returns true', () {
            expect(result, isTrue);
          });

          test('triggers a remove event on the world', () async {
            expect(await recording, equals([[new WorldChangeRecord.remove(world, entity)]]));
          });
        });

        group('with an entity that is not contained in the world', () {
          final recorder = new ChangeRecorder(world.changes);
          final recording = recorder.start();

          final result = world.removeEntity(new Entity(99));

          recorder.stop();


          test('does not decrease the length of the world', () {
            expect(world.length, equals(3));
          });

          test('returns false', () {
            expect(result, isFalse);
          });

          test('does not trigger any events on the world', () async {
            expect(await recording, isEmpty);
          });
        });
      });

      group('removeEntityById', () {
        group('with an ID that is contained in the world', () {
          var entity;
          var recording;
          var result;

          setUp(() {
            entity = world.findEntity(1);
            final recorder = new ChangeRecorder(world.changes);
            recording = recorder.start();

            result = world.removeEntityById(1);

            recorder.stop();
          });

          tearDown(() {
            store0[1] = a1;
          });

          test('decreases the world length by 1', () {
            expect(world.length, equals(2));
          });

          test('returns true', () {
            expect(result, isTrue);
          });

          test('triggers a remove event on the world', () async {
            expect(await recording, equals([[new WorldChangeRecord.remove(world, entity)]]));
          });
        });

        group('with an ID that is not contained in the world', () {
          final recorder = new ChangeRecorder(world.changes);
          final recording = recorder.start();

          final result = world.removeEntityById(99);

          recorder.stop();

          test('does not decrease the length of the world', () {
            expect(world.length, equals(3));
          });

          test('returns false', () {
            expect(result, isFalse);
          });

          test('does not trigger any events on the world', () async {
            expect(await recording, isEmpty);
          });
        });
      });

      group('findEntity', () {
        test('with an ID that is not contained in the world returns null', () {
          expect(world.findEntity(99), isNull);
        });

        test('with an ID that is contained in the world returns an entity with the correct ID', () {
          expect(world.findEntity(1)?.id, equals(1));
        });
      });

      group('removing a component store from the registry', () {
        var worldRecording;
        var entity0Recording;
        var entity1Recording;
        var entity2Recording;

        setUp(() {
          final worldRecorder = new ChangeRecorder(world.changes);
          final entity0Recorder = new ChangeRecorder(world.findEntity(0).changes);
          final entity1Recorder = new ChangeRecorder(world.findEntity(1).changes);
          final entity2Recorder = new ChangeRecorder(world.findEntity(2).changes);

          worldRecording = worldRecorder.start();
          entity0Recording = entity0Recorder.start();
          entity1Recording = entity1Recorder.start();
          entity2Recording = entity2Recorder.start();

          registry.remove<A>(A);

          worldRecorder.stop();
          entity0Recorder.stop();
          entity1Recorder.stop();
          entity2Recorder.stop();
        });

        tearDown(() {
          registry.add<A>(A, store0);
        });

        test('does not decrease the length of the world', () {
          expect(world.length, equals(3));
        });

        test('does not trigger any change events on the world', () async {
          expect(await worldRecording, isEmpty);
        });

        test('triggers the correct change events on entity 0', () async {
          expect(await entity0Recording, equals([[new EntityChangeRecord.remove(a0)]]));
        });

        test('triggers the correct change events on entity 1', () async {
          expect(await entity1Recording, equals([[new EntityChangeRecord.remove(a1)]]));
        });

        test('triggers the correct change events on entity 2', () async {
          expect(await entity2Recording, equals([[new EntityChangeRecord.remove(a2)]]));
        });

        group('entity 0', () {
          test('has the correct length', () {
            expect(world.findEntity(0).length, equals(1));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(0).toList(), unorderedEquals([b0]));
          });
        });

        group('entity 1', () {
          test('has the correct length', () {
            expect(world.findEntity(1).length, equals(0));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(1).toList(), isEmpty);
          });
        });

        group('entity 2', () {
          test('has the correct length', () {
            expect(world.findEntity(2).length, equals(1));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(2).toList(), unorderedEquals([b1]));
          });
        });
      });

      group('replacing a store in the registry', () {
        final alternativeStore = new LinkedHashMapStore<B>();

        final b2 = new B(2);
        final b3 = new B(3);
        final b4 = new B(4);

        alternativeStore[0] = b2;
        alternativeStore[1] = b3;
        alternativeStore[3] = b4;

        var worldRecording;
        var entity0Recording;
        var entity1Recording;
        var entity2Recording;

        setUp(() {
          final worldRecorder = new ChangeRecorder(world.changes);
          final entity0Recorder = new ChangeRecorder(world.findEntity(0).changes);
          final entity1Recorder = new ChangeRecorder(world.findEntity(1).changes);
          final entity2Recorder = new ChangeRecorder(world.findEntity(2).changes);

          worldRecording = worldRecorder.start();
          entity0Recording = entity0Recorder.start();
          entity1Recording = entity1Recorder.start();
          entity2Recording = entity2Recorder.start();

          registry.add<B>(B, alternativeStore);

          worldRecorder.stop();
          entity0Recorder.stop();
          entity1Recorder.stop();
          entity2Recorder.stop();
        });

        tearDown(() {
          registry.add<B>(B, store1);
          world.removeEntityById(3);
        });

        test('increases the world length by to 4', () {
          expect(world.length, equals(4));
        });

        test('triggers a create events on the world', () async {
          expect(await worldRecording, equals([[new WorldChangeRecord.create(world, world.findEntity(3))]]));
        });

        test('triggers the correct change events on entity 0', () async {
          expect(await entity0Recording, equals([[new EntityChangeRecord(b0, b2)]]));
        });

        test('triggers the correct change events on entity 1', () async {
          expect(await entity1Recording, equals([[new EntityChangeRecord.add(b3)]]));
        });

        test('triggers the correct change events on entity 2', () async {
          expect(await entity2Recording, equals([[new EntityChangeRecord.remove(b1)]]));
        });

        group('entity 0', () {
          test('has the correct length', () {
            expect(world.findEntity(0).length, equals(2));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(0).toList(), unorderedEquals([a0, b2]));
          });
        });

        group('entity 1', () {
          test('has the correct length', () {
            expect(world.findEntity(1).length, equals(2));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(1).toList(), unorderedEquals([a1, b3]));
          });
        });

        group('entity 2', () {
          test('has the correct length', () {
            expect(world.findEntity(2).length, equals(1));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(2).toList(), unorderedEquals([a2]));
          });
        });

        group('entity 3', () {
          test('has the correct length', () {
            expect(world.findEntity(3).length, equals(1));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(3).toList(), unorderedEquals([b4]));
          });
        });
      });

      group('adding an additional store to the registry', () {
        final additionalStore = new LinkedHashMapStore<C>();
        final c0 = new C(0);
        final c1 = new C(1);

        additionalStore[1] = c0;
        additionalStore[3] = c1;

        var worldRecording;
        var entity0Recording;
        var entity1Recording;
        var entity2Recording;

        setUp(() {
          final worldRecorder = new ChangeRecorder(world.changes);
          final entity0Recorder = new ChangeRecorder(world.findEntity(0).changes);
          final entity1Recorder = new ChangeRecorder(world.findEntity(1).changes);
          final entity2Recorder = new ChangeRecorder(world.findEntity(2).changes);

          worldRecording = worldRecorder.start();
          entity0Recording = entity0Recorder.start();
          entity1Recording = entity1Recorder.start();
          entity2Recording = entity2Recorder.start();

          registry.add<C>(C, additionalStore);

          worldRecorder.stop();
          entity0Recorder.stop();
          entity1Recorder.stop();
          entity2Recorder.stop();
        });

        tearDown(() {
          registry.remove<C>(C);
          world.removeEntityById(3);
        });

        test('increases the world length by to 4', () {
          expect(world.length, equals(4));
        });

        test('triggers a create events on the world', () async {
          expect(await worldRecording, equals([[new WorldChangeRecord.create(world, world.findEntity(3))]]));
        });

        test('triggers the correct change events on entity 0', () async {
          expect(await entity0Recording, isEmpty);
        });

        test('triggers the correct change events on entity 1', () async {
          expect(await entity1Recording, equals([[new EntityChangeRecord.add(c0)]]));
        });

        test('triggers the correct change events on entity 2', () async {
          expect(await entity2Recording, isEmpty);
        });

        group('entity 0', () {
          test('has the correct length', () {
            expect(world.findEntity(0).length, equals(2));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(0).toList(), unorderedEquals([a0, b0]));
          });
        });

        group('entity 1', () {
          test('has the correct length', () {
            expect(world.findEntity(1).length, equals(2));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(1).toList(), unorderedEquals([a1, c0]));
          });
        });

        group('entity 2', () {
          test('has the correct length', () {
            expect(world.findEntity(2).length, equals(2));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(2).toList(), unorderedEquals([a2, b1]));
          });
        });

        group('entity 3', () {
          test('has the correct length', () {
            expect(world.findEntity(3).length, equals(1));
          });

          test('contains the correct component values', () {
            expect(world.findEntity(3).toList(), unorderedEquals([c1]));
          });
        });
      });
    });

    group('as a view on a pre-populated component stores', () {
      final store0 = new LinkedHashMapStore<A>();
      final store1 = new LinkedHashMapStore<B>();
      final registry = new TypeStoreRegistry()..add<A>(A, store0)..add<B>(B, store1);

      final a0 = new A(0);
      final a1 = new A(1);
      final a2 = new A(2);

      final b0 = new B(0);
      final b1 = new B(1);

      store0[0] = a0;
      store0[1] = a1;
      store0[2] = a2;

      store1[0] = b0;
      store1[2] = b1;

      final world = new World(registry);

      test('produces a world of the right length', () {
        expect(world.length, equals(3));
      });

      group('entity 0', () {
        test('has the correct length', () {
          expect(world.findEntity(0).length, equals(2));
        });

        test('contains the correct component values', () {
          expect(world.findEntity(0).toList(), unorderedEquals([a0, b0]));
        });
      });

      group('entity 1', () {
        test('has the correct length', () {
          expect(world.findEntity(1).length, equals(1));
        });

        test('contains the correct component values', () {
          expect(world.findEntity(1).toList(), unorderedEquals([a1]));
        });
      });

      group('entity 2', () {
        test('has the correct length', () {
          expect(world.findEntity(2).length, equals(2));
        });

        test('contains the correct component values', () {
          expect(world.findEntity(2).toList(), unorderedEquals([a2, b1]));
        });
      });

      group('createEntity', () {
        var newEntity;

        setUp(() {
          newEntity = world.createEntity();
        });

        tearDown(() {
          world.removeEntity(newEntity);
        });

        test('increases the world length by 1', () {
          expect(world.length, equals(4));
        });

        test('returns an entity without any components', () {
          expect(newEntity.toList(), isEmpty);
        });
      });
    });
  });
}
