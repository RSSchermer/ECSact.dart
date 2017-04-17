/// Data structures that help define simple systems.
library system;

import 'component_data.dart';
import 'nodes.dart';
import 'world.dart';

part 'src/system/system_1.dart';
part 'src/system/system_2.dart';
part 'src/system/system_3.dart';
part 'src/system/system_4.dart';
part 'src/system/system_5.dart';

/// The basic interface for a system.
abstract class System {
  /// Runs this system.
  ///
  /// Systems that advance the state of the world should use [deltaTime] to
  /// decide how much to advance the state.
  void run(num deltaTime);
}
