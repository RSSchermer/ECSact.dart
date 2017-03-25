part of system;

typedef void System3Operation<C0, C1, C2>(C0 c0, C1 c1, C2 c2, num deltaTime);

class System3<C0, C1, C2> {
  final World world;

  final System3Operation operation;

  Observe3Nodes<C0, C1, C2> _nodes;

  System3(this.world, this.operation) {
    _nodes = new Observe3Nodes<C0, C1, C2>(world);
  }

  void run(num deltaTime) {
    for (final node in _nodes) {
      operation(node.c0, node.c1, node.c2, deltaTime);
    }
  }
}
