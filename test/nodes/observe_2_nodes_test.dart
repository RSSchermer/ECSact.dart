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

void main() {
  group('Observe2Nodes', () {
    group('iterator', () {
      final store0 = new LinkedHashMapStore<A>();
      final store1 = new LinkedHashMapStore<B>();

      final a0 = new A(0);
      final a1 = new A(1);
      final a2 = new A(2);

      final b0 = new B(0);
      final b1 = new B(1);

      store0[0] = a0;
      store0[1] = a1;

      store1[0] = b0;

      final nodes = new Observe2Nodes<A, B>(store0, store1);

      store0[2] = a2;
      store1[2] = b1;

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
          new Node2<A, B>(0, a0, b0),
          new Node2<A, B>(2, a2, b1)
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
            new Node2<A, B>(2, a2, b1)
          ]));
        });

        group('after updating a component value for the node', () {
          final otherA = new A(99);

          setUp(() {
            store0[2] = otherA;
          });

          test('returns the correct current value on each iteration', () {
            final values = nodes.toList();

            expect(values, equals([
              new Node2<A, B>(2, otherA, b1)
            ]));
          });
        });
      });
    });
  });
}
