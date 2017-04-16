import 'package:test/test.dart';

import 'package:ecsact/component_data.dart';
import 'package:ecsact/nodes.dart';

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

class D {
  final int id;

  D(this.id);

  String toString() => 'D($id)';
}

class E {
  final int id;

  E(this.id);

  String toString() => 'E($id)';
}

void main() {
  group('Observe4Nodes', () {
    group('iterator', () {
      final store0 = new LinkedHashMapStore<A>();
      final store1 = new LinkedHashMapStore<B>();
      final store2 = new LinkedHashMapStore<C>();
      final store3 = new LinkedHashMapStore<D>();
      final store4 = new LinkedHashMapStore<E>();

      final a0 = new A(0);
      final a1 = new A(1);
      final a2 = new A(2);
      final a3 = new A(3);
      final a4 = new A(4);
      final a5 = new A(5);

      final b0 = new B(0);
      final b1 = new B(1);
      final b2 = new B(2);
      final b3 = new B(3);
      final b4 = new B(4);

      final c0 = new C(0);
      final c1 = new C(1);
      final c2 = new C(2);
      final c3 = new C(3);

      final d0 = new D(0);
      final d1 = new D(1);
      final d2 = new D(2);

      final e0 = new E(0);
      final e1 = new E(1);

      store0[0] = a0;
      store0[1] = a1;
      store0[2] = a2;
      store0[3] = a3;
      store0[4] = a4;

      store1[0] = b0;
      store1[2] = b1;
      store1[3] = b2;
      store1[4] = b3;

      store2[0] = c0;
      store2[3] = c1;
      store2[4] = c2;

      store3[0] = d0;
      store3[4] = d1;

      store4[0] = e0;

      final nodes = new Observe5Nodes<A, B, C, D, E>(store0, store1, store2, store3, store4);

      store0[5] = a5;
      store1[5] = b4;
      store2[5] = c3;
      store3[5] = d2;
      store4[5] = e1;

      final iterator = nodes.iterator;

      final values = [];
      var loopCount = 0;

      while (iterator.moveNext()) {
        values.add(iterator.current);

        loopCount++;
      }

      test('loops the correct number of times', () {
        expect(loopCount, equals(2));
      });

      test('returns the correct current value on each iteration', () {
        expect(values, equals([
          new Node5<A, B, C, D, E>(0, a0, b0, c0, d0, e0),
          new Node5<A, B, C, D, E>(5, a5, b4, c3, d2, e1)
        ]));
      });

      test('returns false on moveNext after iterating', () {
        expect(iterator.moveNext(), isFalse);
      });

      group('after removing a component value from a store', () {
        setUp(() {
          store0.remove(0);
        });

        test('returns the correct current value on each iteration', () {
          final values = nodes.toList();

          expect(values, equals([
            new Node5<A, B, C, D, E>(5, a5, b4, c3, d2, e1)
          ]));
        });

        group('after updating a component value for the node', () {
          final otherA = new A(99);

          setUp(() {
            store0[5] = otherA;
          });

          test('returns the correct current value on each iteration', () {
            final values = nodes.toList();

            expect(values, equals([
              new Node5<A, B, C, D, E>(5, otherA, b4, c3, d2, e1)
            ]));
          });
        });
      });
    });
  });
}
