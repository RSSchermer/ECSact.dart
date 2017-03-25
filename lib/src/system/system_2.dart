part of system;

typedef void System2Operation<C0, C1>(C0 c0, C1 c1, num deltaTime);

class System2<C0, C1> {
  final World world;

  final System2Operation operation;

  Observe2Nodes<C0, C1> _nodes;

  System2(this.world, this.operation) {
    _nodes = new Observe2Nodes<C0, C1>(world);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, deltaTime);
    }
  }
}
