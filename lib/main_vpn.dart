import 'config/flavor_config.dart';
import 'main.dart' as entry;

void main() {
  FlavorConfig.current = AppFlavor.vpn;
  entry.main();
}
