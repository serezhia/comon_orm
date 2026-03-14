import 'schema_ast.dart';

/// Error thrown when `schema.prisma` source cannot be parsed.
class SchemaParseException implements Exception {
  /// Creates a parse exception.
  const SchemaParseException(this.message, {this.line});

  /// Human-readable parse error.
  final String message;

  /// One-based line number where parsing failed, if known.
  final int? line;

  @override
  String toString() {
    if (line == null) {
      return 'SchemaParseException: $message';
    }

    return 'SchemaParseException(line $line): $message';
  }
}

/// Parses Prisma-inspired schema source into a [SchemaDocument].
class SchemaParser {
  /// Creates a stateless parser.
  const SchemaParser();

  /// Parses raw schema [source].
  SchemaDocument parse(String source) {
    final lines = source.split(RegExp(r'\r?\n'));
    final models = <ModelDefinition>[];
    final enums = <EnumDefinition>[];
    final datasources = <DatasourceDefinition>[];
    final generators = <GeneratorDefinition>[];
    String? currentModelName;
    int? currentModelLine;
    String? currentEnumName;
    int? currentEnumLine;
    String? currentDatasourceName;
    int? currentDatasourceLine;
    String? currentGeneratorName;
    int? currentGeneratorLine;
    final currentFields = <FieldDefinition>[];
    final currentModelAttributes = <ModelAttribute>[];
    final currentEnumValues = <String>[];
    final currentEnumAttributes = <ModelAttribute>[];
    final currentBlockProperties = <String, String>{};

    for (var index = 0; index < lines.length; index++) {
      final lineNumber = index + 1;
      final trimmed = _stripComment(lines[index]).trim();
      if (trimmed.isEmpty) {
        continue;
      }

      if (currentModelName == null &&
          currentEnumName == null &&
          currentDatasourceName == null &&
          currentGeneratorName == null) {
        if (trimmed.startsWith('model ')) {
          currentModelName = _parseModelDeclaration(trimmed, lineNumber);
          currentModelLine = lineNumber;
          currentFields.clear();
          currentModelAttributes.clear();
          continue;
        }

        if (trimmed.startsWith('enum ')) {
          currentEnumName = _parseEnumDeclaration(trimmed, lineNumber);
          currentEnumLine = lineNumber;
          currentEnumValues.clear();
          currentEnumAttributes.clear();
          continue;
        }

        if (trimmed.startsWith('datasource ')) {
          currentDatasourceName = _parseDatasourceDeclaration(
            trimmed,
            lineNumber,
          );
          currentDatasourceLine = lineNumber;
          currentBlockProperties.clear();
          continue;
        }

        if (trimmed.startsWith('generator ')) {
          currentGeneratorName = _parseGeneratorDeclaration(
            trimmed,
            lineNumber,
          );
          currentGeneratorLine = lineNumber;
          currentBlockProperties.clear();
          continue;
        }

        throw SchemaParseException(
          'Expected a model, enum, datasource, or generator declaration, got "$trimmed".',
          line: lineNumber,
        );
      }

      if (trimmed == '}') {
        if (currentModelName != null) {
          models.add(
            ModelDefinition(
              name: currentModelName,
              fields: List<FieldDefinition>.unmodifiable(currentFields),
              attributes: List<ModelAttribute>.unmodifiable(
                currentModelAttributes,
              ),
              line: currentModelLine,
            ),
          );
          currentModelName = null;
          currentModelLine = null;
          currentFields.clear();
          currentModelAttributes.clear();
        } else {
          if (currentEnumName != null) {
            enums.add(
              EnumDefinition(
                name: currentEnumName,
                values: List<String>.unmodifiable(currentEnumValues),
                attributes: List<ModelAttribute>.unmodifiable(
                  currentEnumAttributes,
                ),
                line: currentEnumLine,
              ),
            );
            currentEnumName = null;
            currentEnumLine = null;
            currentEnumValues.clear();
            currentEnumAttributes.clear();
          } else if (currentDatasourceName != null) {
            datasources.add(
              DatasourceDefinition(
                name: currentDatasourceName,
                properties: Map<String, String>.unmodifiable(
                  Map<String, String>.from(currentBlockProperties),
                ),
                line: currentDatasourceLine,
              ),
            );
            currentDatasourceName = null;
            currentDatasourceLine = null;
            currentBlockProperties.clear();
          } else {
            generators.add(
              GeneratorDefinition(
                name: currentGeneratorName!,
                properties: Map<String, String>.unmodifiable(
                  Map<String, String>.from(currentBlockProperties),
                ),
                line: currentGeneratorLine,
              ),
            );
            currentGeneratorName = null;
            currentGeneratorLine = null;
            currentBlockProperties.clear();
          }
        }
        continue;
      }

      if (currentModelName != null) {
        if (trimmed.startsWith('@@')) {
          currentModelAttributes.add(_parseModelAttribute(trimmed, lineNumber));
          continue;
        }
        currentFields.add(_parseField(trimmed, lineNumber));
      } else if (currentEnumName != null) {
        if (trimmed.startsWith('@@')) {
          currentEnumAttributes.add(_parseModelAttribute(trimmed, lineNumber));
        } else {
          currentEnumValues.add(_parseEnumValue(trimmed, lineNumber));
        }
      } else {
        final entry = _parseBlockProperty(trimmed, lineNumber);
        currentBlockProperties[entry.key] = entry.value;
      }
    }

    if (currentModelName != null) {
      throw SchemaParseException(
        'Model "$currentModelName" is not closed.',
        line: lines.length,
      );
    }

    if (currentEnumName != null) {
      throw SchemaParseException(
        'Enum "$currentEnumName" is not closed.',
        line: lines.length,
      );
    }

    if (currentDatasourceName != null) {
      throw SchemaParseException(
        'Datasource "$currentDatasourceName" is not closed.',
        line: lines.length,
      );
    }

    if (currentGeneratorName != null) {
      throw SchemaParseException(
        'Generator "$currentGeneratorName" is not closed.',
        line: lines.length,
      );
    }

    return SchemaDocument(
      models: List<ModelDefinition>.unmodifiable(models),
      enums: List<EnumDefinition>.unmodifiable(enums),
      datasources: List<DatasourceDefinition>.unmodifiable(datasources),
      generators: List<GeneratorDefinition>.unmodifiable(generators),
    );
  }

  String _parseModelDeclaration(String line, int lineNumber) {
    final match = RegExp(r'^model\s+(\w+)\s*\{$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid model declaration. Expected "model Name {".',
        line: lineNumber,
      );
    }

    return match.group(1)!;
  }

  String _parseEnumDeclaration(String line, int lineNumber) {
    final match = RegExp(r'^enum\s+(\w+)\s*\{$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid enum declaration. Expected "enum Name {".',
        line: lineNumber,
      );
    }

    return match.group(1)!;
  }

  String _parseDatasourceDeclaration(String line, int lineNumber) {
    final match = RegExp(r'^datasource\s+(\w+)\s*\{$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid datasource declaration. Expected "datasource name {".',
        line: lineNumber,
      );
    }

    return match.group(1)!;
  }

  String _parseGeneratorDeclaration(String line, int lineNumber) {
    final match = RegExp(r'^generator\s+(\w+)\s*\{$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid generator declaration. Expected "generator name {".',
        line: lineNumber,
      );
    }

    return match.group(1)!;
  }

  FieldDefinition _parseField(String line, int lineNumber) {
    final match = RegExp(r'^(\w+)\s+([^\s]+)(?:\s+(.*))?$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid field declaration. Expected at least name and type.',
        line: lineNumber,
      );
    }

    final fieldName = match.group(1)!;
    final rawType = match.group(2)!;
    final rawAttributes = match.group(3)?.trim() ?? '';
    final isList = rawType.endsWith('[]');
    final isNullable = !isList && rawType.endsWith('?');
    final type = isList
        ? rawType.substring(0, rawType.length - 2)
        : isNullable
        ? rawType.substring(0, rawType.length - 1)
        : rawType;

    return FieldDefinition(
      name: fieldName,
      type: type,
      isList: isList,
      isNullable: isNullable,
      attributes: List<FieldAttribute>.unmodifiable(
        _parseAttributes(rawAttributes, lineNumber),
      ),
      line: lineNumber,
    );
  }

  List<FieldAttribute> _parseAttributes(String rawAttributes, int lineNumber) {
    if (rawAttributes.isEmpty) {
      return const <FieldAttribute>[];
    }

    final attributes = <FieldAttribute>[];
    var offset = 0;

    while (offset < rawAttributes.length) {
      while (offset < rawAttributes.length &&
          rawAttributes[offset].trim().isEmpty) {
        offset++;
      }

      if (offset >= rawAttributes.length) {
        break;
      }

      if (rawAttributes[offset] != '@') {
        throw SchemaParseException(
          'Unexpected token "${rawAttributes.substring(offset)}" in field declaration.',
          line: lineNumber,
        );
      }

      final start = offset;
      offset++;
      while (offset < rawAttributes.length &&
          RegExp(r'[\w.]').hasMatch(rawAttributes[offset])) {
        offset++;
      }

      if (offset < rawAttributes.length && rawAttributes[offset] == '(') {
        var depth = 1;
        offset++;
        while (offset < rawAttributes.length && depth > 0) {
          if (rawAttributes[offset] == '(') {
            depth++;
          } else if (rawAttributes[offset] == ')') {
            depth--;
          }
          offset++;
        }

        if (depth != 0) {
          throw SchemaParseException(
            'Unclosed attribute in field declaration.',
            line: lineNumber,
          );
        }
      }

      attributes.add(
        _parseAttribute(rawAttributes.substring(start, offset), lineNumber),
      );
    }

    return attributes;
  }

  FieldAttribute _parseAttribute(String token, int lineNumber) {
    final match = RegExp(r'^@([\w.]+)(?:\((.*)\))?$').firstMatch(token);
    if (match == null) {
      throw SchemaParseException(
        'Invalid attribute syntax: "$token".',
        line: lineNumber,
      );
    }

    final name = match.group(1)!;
    final rawArguments = match.group(2);
    if (rawArguments == null || rawArguments.trim().isEmpty) {
      return FieldAttribute(
        name: name,
        arguments: const <String, String>{},
        line: lineNumber,
      );
    }

    final arguments = <String, String>{};
    for (final segment in _splitArguments(rawArguments)) {
      final parts = segment.split(':');
      if (parts.length == 1) {
        arguments['value'] = parts[0].trim();
        continue;
      }

      final key = parts.first.trim();
      final value = parts.sublist(1).join(':').trim();
      arguments[key] = value;
    }

    return FieldAttribute(
      name: name,
      arguments: Map<String, String>.unmodifiable(arguments),
      line: lineNumber,
    );
  }

  ModelAttribute _parseModelAttribute(String token, int lineNumber) {
    final match = RegExp(r'^@@(\w+)(?:\((.*)\))?$').firstMatch(token);
    if (match == null) {
      throw SchemaParseException(
        'Invalid model attribute syntax: "$token".',
        line: lineNumber,
      );
    }

    final name = match.group(1)!;
    final rawArguments = match.group(2);
    if (rawArguments == null || rawArguments.trim().isEmpty) {
      return ModelAttribute(
        name: name,
        arguments: const <String, String>{},
        line: lineNumber,
      );
    }

    final arguments = <String, String>{};
    for (final segment in _splitArguments(rawArguments)) {
      final parts = segment.split(':');
      if (parts.length == 1) {
        arguments['value'] = parts[0].trim();
        continue;
      }

      final key = parts.first.trim();
      final value = parts.sublist(1).join(':').trim();
      arguments[key] = value;
    }

    return ModelAttribute(
      name: name,
      arguments: Map<String, String>.unmodifiable(arguments),
      line: lineNumber,
    );
  }

  String _parseEnumValue(String line, int lineNumber) {
    final match = RegExp(r'^(\w+)$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid enum value declaration. Expected a single identifier.',
        line: lineNumber,
      );
    }

    return match.group(1)!;
  }

  MapEntry<String, String> _parseBlockProperty(String line, int lineNumber) {
    final match = RegExp(r'^(\w+)\s*=\s*(.+)$').firstMatch(line);
    if (match == null) {
      throw SchemaParseException(
        'Invalid block property syntax. Expected "key = value".',
        line: lineNumber,
      );
    }

    return MapEntry<String, String>(match.group(1)!, match.group(2)!.trim());
  }

  List<String> _splitArguments(String input) {
    final items = <String>[];
    final buffer = StringBuffer();
    var bracketDepth = 0;

    for (final codeUnit in input.codeUnits) {
      final character = String.fromCharCode(codeUnit);
      if (character == '[') {
        bracketDepth++;
      } else if (character == ']') {
        bracketDepth--;
      }

      if (character == ',' && bracketDepth == 0) {
        items.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }

      buffer.write(character);
    }

    if (buffer.isNotEmpty) {
      items.add(buffer.toString().trim());
    }

    return items.where((item) => item.isNotEmpty).toList(growable: false);
  }

  String _stripComment(String line) {
    var inSingleQuote = false;
    var inDoubleQuote = false;

    for (var index = 0; index < line.length - 1; index++) {
      final current = line[index];
      final next = line[index + 1];

      if (current == '"' && !inSingleQuote && !_isEscaped(line, index)) {
        inDoubleQuote = !inDoubleQuote;
      } else if (current == '\'' &&
          !inDoubleQuote &&
          !_isEscaped(line, index)) {
        inSingleQuote = !inSingleQuote;
      }

      if (!inSingleQuote && !inDoubleQuote && current == '/' && next == '/') {
        return line.substring(0, index);
      }
    }

    return line;
  }

  bool _isEscaped(String value, int index) {
    var backslashCount = 0;
    for (var cursor = index - 1; cursor >= 0; cursor--) {
      if (value[cursor] != r'\') {
        break;
      }
      backslashCount++;
    }
    return backslashCount.isOdd;
  }
}
