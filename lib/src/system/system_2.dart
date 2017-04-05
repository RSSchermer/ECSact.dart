part of system;

typedef void System2Operation<C0, C1>(C0 c0, C1 c1, num deltaTime);

class System2<C0, C1> {
  final TypeStoreRegistry typeStoreRegistry;

  final System2Operation operation;

  Observe2Nodes<C0, C1> _nodes;

  System2(this.typeStoreRegistry, this.operation) {
    if (C0 == dynamic) {
      throw new ArgumentError('The first type parameter must be specified and '
          'must not be `dynamic`.');
    }

    if (C1 == dynamic) {
      throw new ArgumentError('The second type parameter must be specified and '
          'must not be `dynamic`.');
    }

    final store0 = typeStoreRegistry.get<C0>(C0);
    final store1 = typeStoreRegistry.get<C1>(C1);

    _nodes = new Observe2Nodes<C0, C1>(store0, store1);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, deltaTime);
    }
  }
}
