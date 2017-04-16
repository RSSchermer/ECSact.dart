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

void main() {
  group('Join3Nodes', () {
    group('iterator', () {
      final store0 = new LinkedHashMapStore<A>();
      final store1 = new LinkedHashMapStore<B>();
      final store2 = new LinkedHashMapStore<C>();

      final a0 = new A(0);
      final a1 = new A(1);
      final a2 = new A(2);
      final a3 = new A(3);

      final b0 = new B(0);
      final b1 = new B(1);
      final b2 = new B(2);

      final c0 = new C(0);
      final c1 = new C(1);

      store0[0] = a0;
      store0[1] = a1;
      store0[2] = a2;
      store0[3] = a3;

      store1[0] = b0;
      store1[2] = b1;
      store1[3] = b2;

      store2[0] = c0;
      store2[3] = c1;

      final iterator = new Join3Nodes<A, B, C>(store0, store1, store2).iterator;
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
          new Node3<A, B, C>(0, a0, b0, c0),
          new Node3<A, B, C>(3, a3, b2, c1)
        ]));
      });

      test('returns false on moveNext after iterating', () {
        expect(iterator.moveNext(), isFalse);
      });
    });
  });
}
