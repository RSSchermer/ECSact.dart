part of system;

typedef void System1Operation<C0>(C0 c0, num deltaTime);

class System1<C0> {
  final World world;

  final System1Operation operation;

  System1(this.world, this.operation);

  void run(num deltaTime) {
    final c0Store = world.componentDatabase[C0];

    if (c0Store == null) {
      throw new StateError('Could not find a component store for type `${C0}` '
          'on this system\'s world.');
    }

    for (final component in c0Store.components) {
      operation(component, deltaTime);
    }
  }
}
