import 'dart:io';

/// Formats a CLI title line with a package emoji and accent color.
String cliTitle(String message, {required bool ansiEnabled}) {
  return _paint('📦 $message', code: '1;36', ansiEnabled: ansiEnabled);
}

/// Formats an informational CLI line.
String cliInfo(String message, {required bool ansiEnabled}) {
  return '${_paint('ℹ', code: '36', ansiEnabled: ansiEnabled)} $message';
}

/// Formats a success CLI line.
String cliSuccess(String message, {required bool ansiEnabled}) {
  return '${_paint('✅', code: '32', ansiEnabled: ansiEnabled)} $message';
}

/// Formats a warning CLI line.
String cliWarning(String message, {required bool ansiEnabled}) {
  return '${_paint('⚠', code: '33', ansiEnabled: ansiEnabled)} $message';
}

/// Formats an error CLI line.
String cliError(String message, {required bool ansiEnabled}) {
  return '${_paint('❌', code: '31', ansiEnabled: ansiEnabled)} $message';
}

/// Formats muted helper text such as usage strings.
String cliMuted(String message, {required bool ansiEnabled}) {
  return _paint(message, code: '2', ansiEnabled: ansiEnabled);
}

/// Returns whether the provided sink supports ANSI escapes.
bool sinkSupportsAnsi(StringSink sink) {
  if (identical(sink, stdout)) {
    return stdout.supportsAnsiEscapes;
  }
  if (identical(sink, stderr)) {
    return stderr.supportsAnsiEscapes;
  }
  return false;
}

String _paint(
  String message, {
  required String code,
  required bool ansiEnabled,
}) {
  if (!ansiEnabled) {
    return message;
  }
  return '\x1B[${code}m$message\x1B[0m';
}
