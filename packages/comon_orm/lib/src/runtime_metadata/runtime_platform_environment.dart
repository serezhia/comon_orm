import 'runtime_platform_environment_web.dart'
    if (dart.library.io) 'runtime_platform_environment_io.dart';

/// Returns the current process environment when the platform exposes one.
Map<String, String>? defaultRuntimeEnvironment() {
  return provideRuntimeEnvironment();
}
