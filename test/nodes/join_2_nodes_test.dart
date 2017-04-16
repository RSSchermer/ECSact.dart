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
  group('Join2Nodes', () {
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
      store0[2] = a2;

      store1[0] = b0;
      store1[2] = b1;

      final iterator = new Join2Nodes<A, B>(store0, store1).iterator;
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
    });
  });
}
