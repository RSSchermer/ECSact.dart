part of system;

typedef void System4Operation<C0, C1, C2, C3>(
    C0 c0, C1 c1, C2 c2, C3 c3, num deltaTime);

class System4<C0, C1, C2, C3> {
  final World world;

  final System4Operation operation;

  Observe4Nodes<C0, C1, C2, C3> _nodes;

  System4(this.world, this.operation) {
    _nodes = new Observe4Nodes<C0, C1, C2, C3>(world);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, node.c2, node.c3, deltaTime);
    }
  }
}
