part of system;

typedef void System1Operation<C0>(C0 c0, num deltaTime);

class System1<C0> {
  final TypeStoreRegistry typeStoreRegistry;

  final System1Operation operation;

  System1(this.typeStoreRegistry, this.operation) {
    if (C0 == dynamic) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic`.');
    }
  }

  void run(num deltaTime) {
    final c0Store = typeStoreRegistry.getStore<C0>(C0);

    if (c0Store != null) {
      for (final component in c0Store.components) {
        operation(component, deltaTime);
      }
    }
  }
}
