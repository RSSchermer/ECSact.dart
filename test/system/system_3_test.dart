import 'package:test/test.dart';

import 'package:ecsact/component_data.dart';
import 'package:ecsact/system.dart';
import 'package:ecsact/world.dart';

class A {}

class B {}

class C {}

void main() {
  group('System3', () {
    final seen = [];
    final aStore = new LinkedHashMapStore<A>();
    final bStore = new LinkedHashMapStore<B>();
    final cStore = new LinkedHashMapStore<C>();
    final registry = new TypeStoreRegistry()
      ..add<A>(A, aStore)
      ..add<B>(B, bStore)
      ..add<C>(C, cStore);
    final world = new World(registry);

    final a0 = new A();
    final a1 = new A();
    final a2 = new A();

    final b0 = new B();
    final b1 = new B();
    final b2 = new B();

    final c0 = new C();
    final c1 = new C();
    final c2 = new C();

    world.createEntity()..add<A>(a0)..add<B>(b0)..add<C>(c0);
    world.createEntity();
    world.createEntity()..add<A>(a1);
    world.createEntity()..add<B>(b1);
    world.createEntity()..add<C>(c1);
    world.createEntity()..add<A>(a2)..add<B>(b2)..add<C>(c2);

    final system = new System3<A, B, C>(world, (a, b, c, time) {
      seen.add([a, b, c]);
    });

    group('run', () {
      group('when component type stores for both type A, B and C are registered for the world', () {
        seen.clear();
        system.run(100);

        test('calls the operation the correct number of times with the correct arguments', () {
          expect(seen, unorderedEquals([
            [a0, b0, c0],
            [a2, b2, c2]
          ]));
        });
      });

      group('when a component type store for type A is not registered for the world', () {
        setUp(() {
          seen.clear();
          registry.remove<A>(A);
          system.run(100);
        });

        tearDown(() {
          registry.add<A>(A, aStore);
        });

        test('does not call the operation at all', () {
          expect(seen, isEmpty);
        });
      });

      group('when a component type store for type B is not registered for the world', () {
        setUp(() {
          seen.clear();
          registry.remove<B>(B);
          system.run(100);
        });

        tearDown(() {
          registry.add<B>(B, bStore);
        });

        test('does not call the operation at all', () {
          expect(seen, isEmpty);
        });
      });

      group('when a component type store for type C is not registered for the world', () {
        setUp(() {
          seen.clear();
          registry.remove<C>(C);
          system.run(100);
        });

        tearDown(() {
          registry.add<C>(C, cStore);
        });

        test('does not call the operation at all', () {
          expect(seen, isEmpty);
        });
      });
    });
  });
}
