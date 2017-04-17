part of system;

typedef void System1Operation<C0>(C0 c0, num deltaTime);

/// A [System] that runs on a entities that contain the component type
/// identified by its type parameter ([C0]).
///
/// See also [System2], [System3], [System4] and [System5].
class System1<C0> {
  /// The [World] this system is run on.
  final World world;

  /// The operation applied by this system.
  final System1Operation operation;

  /// Instantiates a new [System1].
  System1(this.world, this.operation) {
    if (C0 == dynamic) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic`.');
    }
  }

  void run(num deltaTime) {
    final c0Store = world.typeStoreRegistry.getStore<C0>(C0);

    if (c0Store != null) {
      for (final component in c0Store.components) {
        operation(component, deltaTime);
      }
    }
  }
}
