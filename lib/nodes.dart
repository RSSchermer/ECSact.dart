library nodes;

import 'dart:collection';

import 'package:quiver/core.dart';

import 'component_store.dart';
import 'world.dart';

part 'src/nodes/join_2_nodes.dart';
part 'src/nodes/join_3_nodes.dart';
part 'src/nodes/join_4_nodes.dart';
part 'src/nodes/join_5_nodes.dart';
part 'src/nodes/observe_2_nodes.dart';
part 'src/nodes/observe_3_nodes.dart';
part 'src/nodes/observe_4_nodes.dart';
part 'src/nodes/observe_5_nodes.dart';

class Node2<T0, T1> {
  final int entityId;

  final T0 c0;

  final T1 c1;

  const Node2(this.entityId, this.c0, this.c1);

  int get hashCode => hash3(entityId, c0, c1);

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node2 &&
          other.entityId == entityId &&
          other.c0 == c0 &&
          other.c1 == c1;
}

class Node3<T0, T1, T2> {
  final int entityId;

  final T0 c0;

  final T1 c1;

  final T2 c2;

  const Node3(this.entityId, this.c0, this.c1, this.c2);

  int get hashCode => hash4(entityId, c0, c1, c2);

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node3 &&
          other.entityId == entityId &&
          other.c0 == c0 &&
          other.c1 == c1 &&
          other.c2 == c2;
}

class Node4<T0, T1, T2, T3> {
  final int entityId;

  final T0 c0;

  final T1 c1;

  final T2 c2;

  final T3 c3;

  const Node4(this.entityId, this.c0, this.c1, this.c2, this.c3);

  int get hashCode => hashObjects([entityId, c0, c1, c2, c3]);

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node4 &&
          other.entityId == entityId &&
          other.c0 == c0 &&
          other.c1 == c1 &&
          other.c2 == c2 &&
          other.c3 == c3;
}

class Node5<T0, T1, T2, T3, T4> {
  final int entityId;

  final T0 c0;

  final T1 c1;

  final T2 c2;

  final T3 c3;

  final T4 c4;

  const Node5(this.entityId, this.c0, this.c1, this.c2, this.c3, this.c4);

  int get hashCode => hashObjects([entityId, c0, c1, c2, c3, c4]);

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node5 &&
          other.entityId == entityId &&
          other.c0 == c0 &&
          other.c1 == c1 &&
          other.c2 == c2 &&
          other.c3 == c3 &&
          other.c4 == c4;
}
