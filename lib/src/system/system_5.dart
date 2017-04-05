part of system;

typedef void System5Operation<C0, C1, C2, C3, C4>(
    C0 c0, C1 c1, C2 c2, C3 c3, C4 c4, num deltaTime);

class System5<C0, C1, C2, C3, C4> {
  final TypeStoreRegistry typeStoreRegistry;

  final System5Operation operation;

  Observe5Nodes<C0, C1, C2, C3, C4> _nodes;

  System5(this.typeStoreRegistry, this.operation) {
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

    if (C4 == dynamic) {
      throw new ArgumentError('The fifth type parameter must be specified and '
          'must not be `dynamic`.');
    }

    final store0 = typeStoreRegistry.get<C0>(C0);
    final store1 = typeStoreRegistry.get<C1>(C1);
    final store2 = typeStoreRegistry.get<C2>(C2);
    final store3 = typeStoreRegistry.get<C3>(C3);
    final store4 = typeStoreRegistry.get<C4>(C4);

    _nodes = new Observe5Nodes<C0, C1, C2, C3, C4>(
        store0, store1, store2, store3, store4);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, node.c2, node.c3, node.c4, deltaTime);
    }
  }
}
