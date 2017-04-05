/// Provides data structures to help iterate over entities with specific
/// components safely.
library nodes;

import 'dart:collection';

import 'package:quiver/core.dart';

import 'component_data.dart';

part 'src/nodes/join_2_nodes.dart';
part 'src/nodes/join_3_nodes.dart';
part 'src/nodes/join_4_nodes.dart';
part 'src/nodes/join_5_nodes.dart';
part 'src/nodes/observe_2_nodes.dart';
part 'src/nodes/observe_3_nodes.dart';
part 'src/nodes/observe_4_nodes.dart';
part 'src/nodes/observe_5_nodes.dart';

/// Combines two of an entity's component values of types [T0] and [T1].
class Node2<T0, T1> {
  /// The ID of the entity to which these component values belong.
  final int entityId;

  /// The first component value of type [T0].
  final T0 c0;

  /// The second component value of type [T1].
  final T1 c1;

  /// Instantiates a new [Node2] for an entity identified by the given
  /// [entityId] with component values [c0] and [c1].
  const Node2(this.entityId, this.c0, this.c1);

  int get hashCode => hash3(entityId, c0, c1);

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node2 &&
          other.entityId == entityId &&
          other.c0 == c0 &&
          other.c1 == c1;
}

/// Combines three of an entity's component values of types [T0], [T1] and [T2].
class Node3<T0, T1, T2> {
  /// The ID of the entity to which these component values belong.
  final int entityId;

  /// The first component value of type [T0].
  final T0 c0;

  /// The second component value of type [T1].
  final T1 c1;

  /// The third component value of type [T2].
  final T2 c2;

  /// Instantiates a new [Node3] for an entity identified by the given
  /// [entityId] with component values [c0], [c1] and [c2].
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

/// Combines four of an entity's component values of types [T0], [T1], [T2] and
/// [T3].
class Node4<T0, T1, T2, T3> {
  /// The ID of the entity to which these component values belong.
  final int entityId;

  /// The first component value of type [T0].
  final T0 c0;

  /// The second component value of type [T1].
  final T1 c1;

  /// The third component value of type [T2].
  final T2 c2;

  /// The fourth component value of type [T3].
  final T3 c3;

  /// Instantiates a new [Node4] for an entity identified by the given
  /// [entityId] with component values [c0], [c1], [c2] and [c3].
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

/// Combines five of an entity's component values of types [T0], [T1], [T2],
/// [T3] and [T4].
class Node5<T0, T1, T2, T3, T4> {
  /// The ID of the entity to which these component values belong.
  final int entityId;

  /// The first component value of type [T0].
  final T0 c0;

  /// The second component value of type [T1].
  final T1 c1;

  /// The third component value of type [T2].
  final T2 c2;

  /// The fourth component value of type [T3].
  final T3 c3;

  /// The fifth component value of type [T4].
  final T4 c4;

  /// Instantiates a new [Node5] for an entity identified by the given
  /// [entityId] with component values [c0], [c1], [c2], [c3] and [c4].
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
