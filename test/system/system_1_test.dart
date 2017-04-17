import 'package:test/test.dart';

import 'package:ecsact/component_data.dart';
import 'package:ecsact/system.dart';
import 'package:ecsact/world.dart';

class A {}

void main() {
  group('System1', () {
    final seen = [];
    final registry = new TypeStoreRegistry()
      ..add<A>(A, new LinkedHashMapStore<A>());
    final world = new World(registry);

    final a0 = new A();
    final a1 = new A();

    world.createEntity()..add(a0);
    world.createEntity();
    world.createEntity()..add(a1);

    final system = new System1<A>(world, (a, time) {
      seen.add(a);
    });

    group('run', () {
      group('when a component type store for type A is registered for the world', () {
        seen.clear();
        system.run(100);

        test('calls the operation the correct number of times with the correct arguments', () {
          expect(seen, unorderedEquals([a0, a1]));
        });
      });

      group('when a component type store for type A is not registered for the world', () {
        setUp(() {
          seen.clear();
          registry.remove<A>(A);
          system.run(100);
        });

        tearDown(() {
          registry.add<A>(A, new LinkedHashMapStore<A>());
        });

        test('does not call the operation at all', () {
          expect(seen, isEmpty);
        });
      });
    });
  });
}
