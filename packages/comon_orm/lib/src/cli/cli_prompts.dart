import 'dart:io';

import 'cli_output.dart';

/// Signature used to read a single line from the terminal.
typedef CliReadLine = String? Function();

/// Minimal terminal prompt helper for interactive CLI flows.
class CliPrompter {
  /// Creates a prompt helper with injectable input and output.
  CliPrompter({
    required StringSink out,
    CliReadLine? readLine,
    bool? interactive,
  }) : _out = out,
       _readLine = readLine ?? stdin.readLineSync,
       _interactive = interactive ?? stdin.hasTerminal;

  final StringSink _out;
  final CliReadLine _readLine;
  final bool _interactive;

  bool get _ansiEnabled => sinkSupportsAnsi(_out);

  /// Whether interactive stdin is available.
  bool get isInteractive => _interactive;

  /// Prompts the user for a non-empty string value.
  String promptRequired(
    String message, {
    String? defaultValue,
    String? errorMessage,
  }) {
    if (!_interactive) {
      throw FormatException(
        errorMessage ??
            'Interactive input is unavailable. Pass the required option explicitly.',
      );
    }

    while (true) {
      _out.write(
        cliInfo(
          defaultValue == null ? '$message: ' : '$message [$defaultValue]: ',
          ansiEnabled: _ansiEnabled,
        ),
      );
      final response = _readLine()?.trim();
      if (response != null && response.isNotEmpty) {
        return response;
      }
      if (defaultValue != null && defaultValue.isNotEmpty) {
        return defaultValue;
      }
    }
  }

  /// Prompts the user for a yes/no confirmation.
  bool confirm(String message, {bool defaultValue = false}) {
    if (!_interactive) {
      return false;
    }

    final suffix = defaultValue ? '[Y/n]' : '[y/N]';
    _out.write(cliWarning('$message $suffix ', ansiEnabled: _ansiEnabled));
    final response = _readLine()?.trim().toLowerCase();
    if (response == null || response.isEmpty) {
      return defaultValue;
    }
    return response == 'y' || response == 'yes';
  }
}
