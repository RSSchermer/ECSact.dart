library system;

import 'nodes.dart';
import 'world.dart';

part 'src/system/system_1.dart';
part 'src/system/system_2.dart';
part 'src/system/system_3.dart';
part 'src/system/system_4.dart';
part 'src/system/system_5.dart';

abstract class System {
  void run(num deltaTime);
}
