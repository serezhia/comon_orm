import 'dart:io';

/// Returns the process environment for IO-backed runtimes.
Map<String, String> provideRuntimeEnvironment() {
  return Platform.environment;
}
