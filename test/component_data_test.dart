import 'package:test/test.dart';
import 'helper.dart';

import 'package:ecsact/component_data.dart';

class A {}
class B {}

void main() {
  group('TypeStoreRegistry', () {
    group('getStore', () {
      final registry = new TypeStoreRegistry();
      final store = new LinkedHashMapStore<A>();

      registry.add<A>(A, store);

      test('with a type for which a store was registered return that store', () {
        expect(registry.getStore<A>(A), equals(store));
      });

      test('with a type for which no store is registered returns null', () {
        expect(registry.getStore<B>(B), isNull);
      });
    });

    group('add', () {
      group('with a store for a type for which no store was registered', () {
        final registry = new TypeStoreRegistry();
        final store = new LinkedHashMapStore<A>();

        final recorder = new ChangeRecorder(registry.changes);
        final recording = recorder.start();

        registry.add<A>(A, store);

        recorder.stop();

        test('triggers an insert event', () async {
          expect(await recording, equals([[new TypeStoreRegistryChangeRecord<A>.insert(A, store)]]));
        });
      });

      group('with a store for a type for which a store was already registered', () {
        final store0 = new LinkedHashMapStore<A>();
        final store1 = new LinkedHashMapStore<A>();
        final registry = new TypeStoreRegistry()..add<A>(A, store0);

        final recorder = new ChangeRecorder(registry.changes);
        final recording = recorder.start();

        registry.add<A>(A, store1);

        recorder.stop();

        test('triggers an update event', () async {
          expect(await recording, equals([[new TypeStoreRegistryChangeRecord<A>(A, store0, store1)]]));
        });
      });
    });

    group('remove', () {
      group('with a type for which no store is registered', () {
        final store = new LinkedHashMapStore<A>();
        final registry = new TypeStoreRegistry()..add<A>(A, store);

        final recorder = new ChangeRecorder(registry.changes);
        final recording = recorder.start();

        final result = registry.remove<B>(B);

        recorder.stop();

        test('returns null', () {
          expect(result, isNull);
        });

        test('does not trigger any change events', () async {
          expect(await recording, isEmpty);
        });
      });

      group('with a type for which a store is registered', () {
        final store = new LinkedHashMapStore<A>();
        final registry = new TypeStoreRegistry()..add<A>(A, store);

        final recorder = new ChangeRecorder(registry.changes);
        final recording = recorder.start();

        final result = registry.remove<A>(A);

        recorder.stop();

        test('returns the store', () {
          expect(result, equals(store));
        });

        test('triggers an remove event', () async {
          expect(await recording, equals([[new TypeStoreRegistryChangeRecord<A>.remove(A, store)]]));
        });
      });
    });
  });
}
