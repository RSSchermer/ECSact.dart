part of system;

typedef void System5Operation<C0, C1, C2, C3, C4>(
    C0 c0, C1 c1, C2 c2, C3 c3, C4 c4, num deltaTime);

class System5<C0, C1, C2, C3, C4> {
  final World world;

  final System5Operation operation;

  Observe5Nodes<C0, C1, C2, C3, C4> _nodes;

  System5(this.world, this.operation) {
    _nodes = new Observe5Nodes<C0, C1, C2, C3, C4>(world);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, node.c2, node.c3, node.c4, deltaTime);
    }
  }
}
