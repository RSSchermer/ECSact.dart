part of system;

typedef void System4Operation<C0, C1, C2, C3>(
    C0 c0, C1 c1, C2 c2, C3 c3, num deltaTime);

class System4<C0, C1, C2, C3> {
  final TypeStoreRegistry typeStoreRegistry;

  final System4Operation operation;

  Observe4Nodes<C0, C1, C2, C3> _nodes;

  System4(this.typeStoreRegistry, this.operation) {
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

    if (C3 == dynamic) {
      throw new ArgumentError('The fourth type parameter must be specified and '
          'must not be `dynamic`.');
    }

    final store0 = typeStoreRegistry.getStore<C0>(C0);
    final store1 = typeStoreRegistry.getStore<C1>(C1);
    final store2 = typeStoreRegistry.getStore<C2>(C2);
    final store3 = typeStoreRegistry.getStore<C3>(C3);

    _nodes = new Observe4Nodes<C0, C1, C2, C3>(store0, store1, store2, store3);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, node.c2, node.c3, deltaTime);
    }
  }
}
