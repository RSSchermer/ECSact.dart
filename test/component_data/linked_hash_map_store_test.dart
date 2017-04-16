import 'package:test/test.dart';
import '../helper.dart';

import 'package:ecsact/component_data.dart';

class A {}

void main() {
  group('LinkedHashMapStore', () {
    group('containsComponentFor', () {
      final store = new LinkedHashMapStore<A>();

      store[10] = new A();

      test('with an entity ID for which a component is stored returns true', () {
        expect(store.containsComponentFor(10), isTrue);
      });

      test('with an entity ID for which no component is stored returns false', () {
        expect(store.containsComponentFor(11), isFalse);
      });
    });

    group('[] operator', () {
      final store = new LinkedHashMapStore<A>();
      final a = new A();

      store[10] = a;

      test('with an entity ID for which a component is stored returns the component', () {
        expect(store[10], equals(a));
      });

      test('with an entity ID for which no component is stored returns null', () {
        expect(store[11], isNull);
      });
    });

    group('[]= operator', () {
      group('with an entity id for which no value is currently stored', () {
        final store = new LinkedHashMapStore<A>();
        final a = new A();

        final recorder = new ChangeRecorder(store.changes);
        final recording = recorder.start();

        store[10] = a;

        recorder.stop();

        test('increases the length by 1', () {
          expect(store.length, equals(1));
        });

        test('triggers an insert change event', () async {
          expect(await recording, equals([[new ComponentTypeStoreChangeRecord.insert(10, a)]]));
        });
      });

      group('with an entity id for which a value is already stored', () {
        final store = new LinkedHashMapStore<A>();
        final a0 = new A();

        store[10] = a0;

        final recorder = new ChangeRecorder(store.changes);
        final recording = recorder.start();

        final a1 = new A();

        store[10] = a1;

        recorder.stop();

        test('does not increase the length', () {
          expect(store.length, equals(1));
        });

        test('triggers an update change event', () async {
          expect(await recording, equals([[new ComponentTypeStoreChangeRecord(10, a0, a1)]]));
        });
      });
    });

    group('remove', () {
      group('with an entity id for which no value is currently stored', () {
        final store = new LinkedHashMapStore<A>();
        final a = new A();

        store[10] = a;

        final recorder = new ChangeRecorder(store.changes);
        final recording = recorder.start();

        final result = store.remove(11);

        recorder.stop();

        test('returns null', () {
          expect(result, isNull);
        });

        test('does not decrease the length', () {
          expect(store.length, equals(1));
        });

        test('does not trigger any change events', () async {
          expect(await recording, isEmpty);
        });
      });

      group('with an entity id for which a value is currently stored', () {
        final store = new LinkedHashMapStore<A>();
        final a = new A();

        store[10] = a;

        final recorder = new ChangeRecorder(store.changes);
        final recording = recorder.start();

        final result = store.remove(10);

        recorder.stop();

        test('returns the value that was stored', () {
          expect(result, equals(a));
        });

        test('decreases the length by 1', () {
          expect(store.length, equals(0));
        });

        test('triggers an remove change event', () async {
          expect(await recording, equals([[new ComponentTypeStoreChangeRecord.remove(10, a)]]));
        });
      });
    });

    group('iterator', () {
      final store = new LinkedHashMapStore<A>();
      final a0 = new A();
      final a1 = new A();
      final a2 = new A();

      store[0] = a0;
      store[10] = a1;
      store[20] = a2;

      final iterator = store.iterator;
      final values = [];
      final ids = [];
      var loopCount = 0;

      while (iterator.moveNext()) {
        values.add(iterator.current);
        ids.add(iterator.currentEntityId);

        loopCount++;
      }

      test('loops the correct number of times', () {
        expect(loopCount, equals(3));
      });

      test('returns the correct current value on each iteration', () {
        expect(values[0], equals(a0));
        expect(values[1], equals(a1));
        expect(values[2], equals(a2));
      });

      test('returns the correct current entity id on each iteration', () {
        expect(ids[0], equals(0));
        expect(ids[1], equals(10));
        expect(ids[2], equals(20));
      });

      test('returns false on moveNext after iterating', () {
        expect(iterator.moveNext(), isFalse);
      });
    });
  });
}
