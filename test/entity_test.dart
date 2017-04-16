import 'package:test/test.dart';
import 'helper.dart';

import 'package:ecsact/entity.dart';

class A {}
class B {}

void main() {
  group('Entity default implementation', () {
    group('add', () {
      group('with a component of a type that was not present on the entity', () {
        final entity = new Entity(0);
        final a = new A();

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        final result = entity.add<A>(a);

        recorder.stop();

        test('returns null', () {
          expect(result, isNull);
        });

        test('triggers an add change event', () async {
          expect(await recording, equals([[new EntityChangeRecord.add(a)]]));
        });

        test('increases the length by 1', () {
          expect(entity.length, equals(1));
        });
      });

      group('with a component of a type that was already present on the entity', () {
        final a0 = new A();
        final a1 = new A();
        final entity = new Entity(0)..add<A>(a0);

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        final result = entity.add<A>(a1);

        recorder.stop();

        test('returns the old value', () {
          expect(result, equals(a0));
        });

        test('triggers an update change event', () async {
          expect(await recording, equals([[new EntityChangeRecord(a0, a1)]]));
        });

        test('does not increase the length', () {
          expect(entity.length, equals(1));
        });
      });
    });

    group('addIfAbsent', () {
      group('with a component of a type that was not present on the entity', () {
        final entity = new Entity(0);
        final a = new A();

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        final result = entity.addIfAbsent<A>(a);

        recorder.stop();

        test('returns true', () {
          expect(result, isTrue);
        });

        test('triggers an add change event', () async {
          expect(await recording, equals([[new EntityChangeRecord.add(a)]]));
        });

        test('increases the length by 1', () {
          expect(entity.length, equals(1));
        });
      });

      group('with a component of a type that was already present on the entity', () {
        final a0 = new A();
        final a1 = new A();
        final entity = new Entity(0)..add<A>(a0);

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        final result = entity.addIfAbsent<A>(a1);

        recorder.stop();

        test('returns false', () {
          expect(result, isFalse);
        });

        test('does not trigger any change events', () async {
          expect(await recording, isEmpty);
        });

        test('does not increase the length', () {
          expect(entity.length, equals(1));
        });
      });
    });

    group('remove', () {
      group('with a type that is present on the entity', () {
        final a = new A();
        final entity = new Entity(0)..add<A>(a);

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        final result = entity.remove<A>(A);

        recorder.stop();

        test('returns the component value for the type', () {
          expect(result, equals(a));
        });

        test('triggers a remove change event', () async {
          expect(await recording, equals([[new EntityChangeRecord.remove(a)]]));
        });

        test('reduces the length by 1', () {
          expect(entity.length, equals(0));
        });
      });

      group('with a type that is not present on the entity', () {
        final a = new A();
        final entity = new Entity(0)..add<A>(a);

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        final result = entity.remove<B>(B);

        recorder.stop();

        test('returns null', () {
          expect(result, isNull);
        });

        test('does not trigger any change events', () async {
          expect(await recording, isEmpty);
        });

        test('does not reduce the length', () {
          expect(entity.length, equals(1));
        });
      });
    });

    group('clear', () {
      group('on an entity with 2 components', () {
        final a = new A();
        final b = new B();
        final entity = new Entity(0)..add<A>(a)..add<B>(b);

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        entity.clear();

        recorder.stop();

        test('triggers a remove change event', () async {
          expect(await recording, equals([[
            new EntityChangeRecord.remove(a),
            new EntityChangeRecord.remove(b)
          ]]));
        });

        test('reduces the length to 0', () {
          expect(entity.length, equals(0));
        });
      });

      group('on an entity without components', () {
        final entity = new Entity(0);

        final recorder = new ChangeRecorder(entity.changes);
        final recording = recorder.start();

        entity.clear();

        recorder.stop();

        test('does not trigger any change events', () async {
          expect(await recording, isEmpty);
        });
      });
    });

    group('getComponent', () {
      group('with a type that is present on the entity', () {
        final entity = new Entity(0);
        final a = new A();

        entity.add<A>(a);

        test('returns the component value for the type', () {
          expect(entity.getComponent<A>(A), equals(a));
        });
      });

      group('with a type that is not present on the entity', () {
        final entity = new Entity(0);
        final a = new A();

        entity.add<A>(a);

        test('returns null', () {
          expect(entity.getComponent<B>(B), isNull);
        });
      });
    });

    group('isEmpty', () {
      test('with a fresh instancereturns true', () {
        final entity = new Entity(0);

        expect(entity.isEmpty, isTrue);
      });

      test('after adding a component return false', () {
        final entity = new Entity(0)..add<A>(new A());

        expect(entity.isEmpty, isFalse);
      });
    });

    group('isNotEmpty', () {
      test('with a fresh instance returns false', () {
        final entity = new Entity(0);

        expect(entity.isNotEmpty, isFalse);
      });

      test('after adding a component return true', () {
        final entity = new Entity(0)..add<A>(new A());

        expect(entity.isNotEmpty, isTrue);
      });
    });

    group('contains', () {
      final a = new A();
      final entity = new Entity(0)..add<A>(a);

      test('with a value that was added returns true', () {
        expect(entity.contains(a), isTrue);
      });

      test('with a value that was not added returns false', () {
        expect(entity.contains(new A()), isFalse);
      });
    });

    group('hasComponentType', () {
      final a = new A();
      final entity = new Entity(0)..add<A>(a);

      test('with a type of which a value was added returns true', () {
        expect(entity.hasComponentType(A), isTrue);
      });

      test('with a type of which a value was not added returns false', () {
        expect(entity.hasComponentType(B), isFalse);
      });
    });
  });
}
