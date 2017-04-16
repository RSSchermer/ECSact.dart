part of system;

typedef void System3Operation<C0, C1, C2>(C0 c0, C1 c1, C2 c2, num deltaTime);

class System3<C0, C1, C2> {
  final TypeStoreRegistry typeStoreRegistry;

  final System3Operation operation;

  Observe3Nodes<C0, C1, C2> _nodes;

  System3(this.typeStoreRegistry, this.operation) {
    if (C0 == dynamic) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C1 == dynamic) {
      throw new ArgumentError('The second type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C2 == dynamic) {
      throw new ArgumentError('The third type parameter must be specified and '
          'must not be `dynamic`.');
    }

    final store0 = typeStoreRegistry.getStore<C0>(C0);
    final store1 = typeStoreRegistry.getStore<C1>(C1);
    final store2 = typeStoreRegistry.getStore<C2>(C2);

    _nodes = new Observe3Nodes<C0, C1, C2>(store0, store1, store2);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, node.c2, deltaTime);
    }
  }
}
