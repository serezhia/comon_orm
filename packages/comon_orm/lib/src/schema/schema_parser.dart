import 'schema_ast.dart';
import 'schema_lexer.dart';

/// Error thrown when `schema.prisma` source cannot be parsed.
class SchemaParseException implements Exception {
  /// Creates a parse exception.
  const SchemaParseException(this.message, {this.line, this.column});

  /// Human-readable parse error.
  final String message;

  /// One-based line number where parsing failed, if known.
  final int? line;

  /// One-based column number where parsing failed, if known.
  final int? column;

  @override
  String toString() {
    if (line != null && column != null) {
      return 'SchemaParseException($line:$column): $message';
    }
    if (line == null) {
      return 'SchemaParseException: $message';
    }

    return 'SchemaParseException(line $line): $message';
  }
}

/// A single parse error returned by [SchemaParser.parseResult].
class SchemaParseError {
  /// Creates a parse error.
  const SchemaParseError(this.message, {this.line, this.column});

  /// Human-readable description of the error.
  final String message;

  /// One-based source line, if known.
  final int? line;

  /// One-based source column within the line, if known.
  final int? column;

  @override
  String toString() {
    if (line != null && column != null) {
      return 'SchemaParseError($line:$column): $message';
    }
    if (line != null) {
      return 'SchemaParseError(line $line): $message';
    }
    return 'SchemaParseError: $message';
  }
}

/// Result of a tolerant parse via [SchemaParser.parseResult].
class SchemaParseResult {
  /// Creates a parse result.
  const SchemaParseResult({required this.document, required this.errors});

  /// Partially or fully constructed schema document.
  final SchemaDocument document;

  /// All parse errors collected during parsing.
  final List<SchemaParseError> errors;

  /// `true` when at least one error was recorded.
  bool get hasErrors => errors.isNotEmpty;
}

/// Parses Prisma-inspired schema source into a [SchemaDocument].
///
/// The parser is built on [SchemaLexer] and uses a recursive descent approach.
/// Two entry points are provided:
/// - [parse] — strict mode, throws [SchemaParseException] on the first error.
/// - [parseResult] — tolerant mode, collects all errors and returns a partial
///   document alongside the [SchemaParseError] list.
class SchemaParser {
  /// Creates a stateless parser.
  const SchemaParser();

  /// Parses raw schema [source] and returns a [SchemaDocument].
  ///
  /// Throws [SchemaParseException] if any parse error is encountered.
  SchemaDocument parse(String source) {
    final result = parseResult(source);
    if (result.hasErrors) {
      final first = result.errors.first;
      throw SchemaParseException(
        first.message,
        line: first.line,
        column: first.column,
      );
    }
    return result.document;
  }

  /// Parses raw schema [source] tolerantly.
  ///
  /// Collects all parse errors without throwing. The returned [SchemaParseResult]
  /// contains both the (possibly partial) [SchemaDocument] and every
  /// [SchemaParseError] encountered.
  SchemaParseResult parseResult(String source) {
    final tokens = const SchemaLexer().tokenize(source);
    final state = _ParserState(tokens);
    return state.parseDocument();
  }
}

// ── Internal recursive descent parser ───────────────────────────────────────

class _ParserState {
  _ParserState(this._tokens);

  final List<Token> _tokens;
  int _pos = 0;
  final List<SchemaParseError> _errors = [];

  // ── Navigation helpers ─────────────────────────────────────────────────

  Token get _current => _tokens[_pos];

  Token _peek(int offset) {
    final idx = _pos + offset;
    return idx < _tokens.length ? _tokens[idx] : _tokens.last;
  }

  bool _at(TokenKind kind) => _current.kind == kind;

  bool _atEof() => _current.kind == TokenKind.eof;

  Token _advance() {
    final tok = _current;
    if (_pos < _tokens.length - 1) _pos++;
    return tok;
  }

  void _skipNewlines() {
    while (_at(TokenKind.newline)) {
      _advance();
    }
  }

  /// Advance past tokens until a newline or `}` is reached (inclusive stop,
  /// but the stopping token is NOT consumed).
  void _skipToEol() {
    while (!_atEof() && !_at(TokenKind.newline) && !_at(TokenKind.rightBrace)) {
      _advance();
    }
  }

  /// Advance past tokens until the next top-level `}` is reached, leaving the
  /// cursor on the `}`.
  void _skipToRightBrace() {
    var depth = 0;
    while (!_atEof()) {
      if (_at(TokenKind.leftBrace)) {
        depth++;
        _advance();
      } else if (_at(TokenKind.rightBrace)) {
        if (depth == 0) break;
        depth--;
        _advance();
      } else {
        _advance();
      }
    }
  }

  void _recordError(String message, Token tok) {
    _errors.add(SchemaParseError(message, line: tok.line, column: tok.column));
  }

  // ── Document ───────────────────────────────────────────────────────────

  SchemaParseResult parseDocument() {
    final models = <ModelDefinition>[];
    final enums = <EnumDefinition>[];
    final datasources = <DatasourceDefinition>[];
    final generators = <GeneratorDefinition>[];

    _skipNewlines();
    while (!_atEof()) {
      if (!_at(TokenKind.identifier)) {
        _recordError(
          'Expected a block keyword (model/enum/datasource/generator), '
          'got "${_current.value}".',
          _current,
        );
        _skipToRightBrace();
        if (_at(TokenKind.rightBrace)) _advance();
        _skipNewlines();
        continue;
      }

      final keyword = _current;
      switch (keyword.value) {
        case 'model':
          _advance();
          final model = _parseModel(keyword);
          if (model != null) models.add(model);
        case 'enum':
          _advance();
          final enumDef = _parseEnum(keyword);
          if (enumDef != null) enums.add(enumDef);
        case 'datasource':
          _advance();
          final ds = _parseDatasource(keyword);
          if (ds != null) datasources.add(ds);
        case 'generator':
          _advance();
          final gen = _parseGenerator(keyword);
          if (gen != null) generators.add(gen);
        default:
          _recordError(
            'Expected a model, enum, datasource, or generator declaration, '
            'got "${keyword.value}".',
            keyword,
          );
          _skipToRightBrace();
          if (_at(TokenKind.rightBrace)) _advance();
      }
      _skipNewlines();
    }

    return SchemaParseResult(
      document: SchemaDocument(
        models: List<ModelDefinition>.unmodifiable(models),
        enums: List<EnumDefinition>.unmodifiable(enums),
        datasources: List<DatasourceDefinition>.unmodifiable(datasources),
        generators: List<GeneratorDefinition>.unmodifiable(generators),
      ),
      errors: List<SchemaParseError>.unmodifiable(_errors),
    );
  }

  // ── Model block ────────────────────────────────────────────────────────

  ModelDefinition? _parseModel(Token keyword) {
    if (!_at(TokenKind.identifier)) {
      _recordError('Expected model name after "model".', _current);
      _skipToRightBrace();
      if (_at(TokenKind.rightBrace)) _advance();
      return null;
    }
    final nameTok = _advance();
    final name = nameTok.value;

    if (!_at(TokenKind.leftBrace)) {
      _recordError(
        'Invalid model declaration. Expected "model $name {".',
        _current,
      );
      _skipToEol();
      return null;
    }
    _advance(); // consume {
    _skipNewlines();

    final fields = <FieldDefinition>[];
    final attrs = <ModelAttribute>[];

    while (!_atEof() && !_at(TokenKind.rightBrace)) {
      if (_at(TokenKind.doubleAt)) {
        final attr = _parseModelAttribute();
        if (attr != null) attrs.add(attr);
      } else if (_at(TokenKind.identifier)) {
        final field = _parseField();
        if (field != null) fields.add(field);
      } else {
        _recordError(
          'Unexpected token "${_current.value}" in model body.',
          _current,
        );
        _skipToEol();
      }
      _skipNewlines();
    }

    if (_at(TokenKind.rightBrace)) {
      _advance();
    } else {
      _recordError('Model "$name" is not closed.', _current);
    }

    return ModelDefinition(
      name: name,
      fields: List<FieldDefinition>.unmodifiable(fields),
      attributes: List<ModelAttribute>.unmodifiable(attrs),
      line: keyword.line,
      column: keyword.column,
    );
  }

  // ── Field ──────────────────────────────────────────────────────────────

  FieldDefinition? _parseField() {
    final nameTok = _advance(); // identifier already checked by caller
    final name = nameTok.value;

    if (!_isAsciiIdentifier(name)) {
      _recordError(
        'Invalid field name "$name". Expected a single ASCII identifier.',
        nameTok,
      );
      _skipToEol();
      return null;
    }

    if (!_at(TokenKind.identifier)) {
      _recordError('Expected field type after "$name".', _current);
      _skipToEol();
      return null;
    }

    final typeTok = _advance();
    final type = typeTok.value;

    if (!_isAsciiIdentifier(type)) {
      _recordError(
        'Invalid field type "$type". Expected a valid ASCII identifier.',
        typeTok,
      );
      _skipToEol();
      return null;
    }

    var isList = false;
    var isNullable = false;

    if (_at(TokenKind.leftBracket)) {
      _advance();
      if (_at(TokenKind.rightBracket)) {
        _advance();
        isList = true;
      } else {
        _recordError('Expected "]" to close list type.', _current);
        _skipToEol();
        return null;
      }
    } else if (_at(TokenKind.question)) {
      _advance();
      isNullable = true;
    }

    final fieldAttrs = <FieldAttribute>[];
    while (_at(TokenKind.at)) {
      final attr = _parseFieldAttr();
      if (attr != null) fieldAttrs.add(attr);
    }

    return FieldDefinition(
      name: name,
      type: type,
      isList: isList,
      isNullable: isNullable,
      attributes: List<FieldAttribute>.unmodifiable(fieldAttrs),
      line: nameTok.line,
      column: nameTok.column,
    );
  }

  // ── Field attribute (@…) ───────────────────────────────────────────────

  FieldAttribute? _parseFieldAttr() {
    final atTok = _advance(); // consume @

    if (!_at(TokenKind.identifier)) {
      _recordError('Expected attribute name after "@".', _current);
      _skipToEol();
      return null;
    }

    var name = _advance().value;

    // Handle dotted attribute names like @db.VarChar
    while (_at(TokenKind.dot)) {
      _advance(); // consume .
      if (!_at(TokenKind.identifier)) {
        _recordError(
          'Expected identifier after "." in attribute name.',
          _current,
        );
        break;
      }
      name = '$name.${_advance().value}';
    }

    final args = _at(TokenKind.leftParen)
        ? _parseAttrArgMap()
        : const <String, String>{};

    return FieldAttribute(
      name: name,
      arguments: args,
      line: atTok.line,
      column: atTok.column,
    );
  }

  // ── Model-level attribute (@@…) ────────────────────────────────────────

  ModelAttribute? _parseModelAttribute() {
    final tok = _advance(); // consume @@

    if (!_at(TokenKind.identifier)) {
      _recordError('Expected model attribute name after "@@".', _current);
      _skipToEol();
      return null;
    }

    final name = _advance().value;

    final args = _at(TokenKind.leftParen)
        ? _parseAttrArgMap()
        : const <String, String>{};

    return ModelAttribute(
      name: name,
      arguments: args,
      line: tok.line,
      column: tok.column,
    );
  }

  // ── Attribute argument map: `(key: value, …)` ─────────────────────────

  Map<String, String> _parseAttrArgMap() {
    _advance(); // consume (

    if (_at(TokenKind.rightParen)) {
      _advance();
      return const <String, String>{};
    }

    final args = <String, String>{};
    var first = true;

    while (!_atEof() && !_at(TokenKind.rightParen)) {
      if (!first) {
        if (_at(TokenKind.comma)) {
          _advance();
        } else {
          break;
        }
      }
      first = false;

      if (_at(TokenKind.rightParen) || _atEof()) break;

      // Named argument: identifier followed by ':'
      final String key;
      if (_at(TokenKind.identifier) && _peek(1).kind == TokenKind.colon) {
        key = _advance().value; // identifier
        _advance(); // colon
      } else {
        key = 'value';
      }

      final value = _parseRawValue();

      // Positional 'value' key wins first time; skip duplicates.
      if (!args.containsKey(key)) {
        args[key] = value;
      }
    }

    if (_at(TokenKind.rightParen)) {
      _advance();
    } else {
      _recordError('Expected ")" to close attribute arguments.', _current);
    }

    return Map<String, String>.unmodifiable(args);
  }

  // ── Raw value reconstruction ───────────────────────────────────────────

  /// Parses the next value token(s) and returns them as a raw string that
  /// is compatible with the format expected by [SchemaDocument] consumers
  /// (e.g. `[field1, field2]`, `"string"`, `autoincrement()`).
  String _parseRawValue() {
    // List literal: [element, …]
    if (_at(TokenKind.leftBracket)) {
      final buf = StringBuffer('[');
      _advance(); // [
      var firstItem = true;
      while (!_atEof() && !_at(TokenKind.rightBracket)) {
        if (!firstItem) {
          if (_at(TokenKind.comma)) _advance();
          buf.write(', ');
        }
        firstItem = false;
        buf.write(_parseRawValue());
      }
      if (_at(TokenKind.rightBracket)) _advance();
      buf.write(']');
      return buf.toString();
    }

    // String literal — value already includes surrounding quotes.
    if (_at(TokenKind.string)) {
      return _advance().value;
    }

    // Integer literal.
    if (_at(TokenKind.integer)) {
      return _advance().value;
    }

    // Identifier — possibly followed by a function call `(…)`.
    if (_at(TokenKind.identifier)) {
      final ident = _advance().value;
      if (_at(TokenKind.leftParen)) {
        final args = StringBuffer('(');
        _advance(); // (
        var firstArg = true;
        while (!_atEof() && !_at(TokenKind.rightParen)) {
          if (!firstArg) {
            if (_at(TokenKind.comma)) _advance();
            args.write(', ');
          }
          firstArg = false;
          args.write(_parseRawValue());
        }
        if (_at(TokenKind.rightParen)) _advance();
        args.write(')');
        return '$ident$args';
      }
      return ident;
    }

    // Unexpected token — record and return empty so parsing can continue.
    _recordError('Expected a value, got "${_current.value}".', _current);
    return '';
  }

  // ── Enum block ─────────────────────────────────────────────────────────

  EnumDefinition? _parseEnum(Token keyword) {
    if (!_at(TokenKind.identifier)) {
      _recordError('Expected enum name after "enum".', _current);
      _skipToRightBrace();
      if (_at(TokenKind.rightBrace)) _advance();
      return null;
    }
    final nameTok = _advance();
    final name = nameTok.value;

    if (!_at(TokenKind.leftBrace)) {
      _recordError(
        'Invalid enum declaration. Expected "enum $name {".',
        _current,
      );
      _skipToEol();
      return null;
    }
    _advance(); // {
    _skipNewlines();

    final values = <String>[];
    final attrs = <ModelAttribute>[];

    while (!_atEof() && !_at(TokenKind.rightBrace)) {
      if (_at(TokenKind.doubleAt)) {
        final attr = _parseModelAttribute();
        if (attr != null) attrs.add(attr);
      } else if (_at(TokenKind.identifier)) {
        final valTok = _advance();
        final val = valTok.value;
        if (!_isAsciiIdentifier(val)) {
          _recordError(
            'Invalid enum value declaration. Expected a single identifier.',
            valTok,
          );
          _skipToEol();
        } else {
          values.add(val);
        }
      } else {
        _recordError(
          'Unexpected token "${_current.value}" in enum body.',
          _current,
        );
        _skipToEol();
      }
      _skipNewlines();
    }

    if (_at(TokenKind.rightBrace)) {
      _advance();
    } else {
      _recordError('Enum "$name" is not closed.', _current);
    }

    return EnumDefinition(
      name: name,
      values: List<String>.unmodifiable(values),
      attributes: List<ModelAttribute>.unmodifiable(attrs),
      line: keyword.line,
      column: keyword.column,
    );
  }

  // ── Datasource block ───────────────────────────────────────────────────

  DatasourceDefinition? _parseDatasource(Token keyword) {
    if (!_at(TokenKind.identifier)) {
      _recordError('Expected datasource name after "datasource".', _current);
      _skipToRightBrace();
      if (_at(TokenKind.rightBrace)) _advance();
      return null;
    }
    final nameTok = _advance();
    final name = nameTok.value;

    if (!_at(TokenKind.leftBrace)) {
      _recordError(
        'Invalid datasource declaration. Expected "datasource $name {".',
        _current,
      );
      _skipToEol();
      return null;
    }
    _advance(); // {
    _skipNewlines();

    final properties = <String, String>{};

    while (!_atEof() && !_at(TokenKind.rightBrace)) {
      if (_at(TokenKind.identifier)) {
        final entry = _parseBlockProperty();
        if (entry != null) properties[entry.key] = entry.value;
      } else {
        _recordError(
          'Unexpected token "${_current.value}" in datasource body.',
          _current,
        );
        _skipToEol();
      }
      _skipNewlines();
    }

    if (_at(TokenKind.rightBrace)) {
      _advance();
    } else {
      _recordError('Datasource "$name" is not closed.', _current);
    }

    return DatasourceDefinition(
      name: name,
      properties: Map<String, String>.unmodifiable(properties),
      line: keyword.line,
      column: keyword.column,
    );
  }

  // ── Generator block ────────────────────────────────────────────────────

  GeneratorDefinition? _parseGenerator(Token keyword) {
    if (!_at(TokenKind.identifier)) {
      _recordError('Expected generator name after "generator".', _current);
      _skipToRightBrace();
      if (_at(TokenKind.rightBrace)) _advance();
      return null;
    }
    final nameTok = _advance();
    final name = nameTok.value;

    if (!_at(TokenKind.leftBrace)) {
      _recordError(
        'Invalid generator declaration. Expected "generator $name {".',
        _current,
      );
      _skipToEol();
      return null;
    }
    _advance(); // {
    _skipNewlines();

    final properties = <String, String>{};

    while (!_atEof() && !_at(TokenKind.rightBrace)) {
      if (_at(TokenKind.identifier)) {
        final entry = _parseBlockProperty();
        if (entry != null) properties[entry.key] = entry.value;
      } else {
        _recordError(
          'Unexpected token "${_current.value}" in generator body.',
          _current,
        );
        _skipToEol();
      }
      _skipNewlines();
    }

    if (_at(TokenKind.rightBrace)) {
      _advance();
    } else {
      _recordError('Generator "$name" is not closed.', _current);
    }

    return GeneratorDefinition(
      name: name,
      properties: Map<String, String>.unmodifiable(properties),
      line: keyword.line,
      column: keyword.column,
    );
  }

  // ── Block property: `key = value` ──────────────────────────────────────

  MapEntry<String, String>? _parseBlockProperty() {
    final keyTok = _advance(); // identifier already verified by caller
    final key = keyTok.value;

    if (!_at(TokenKind.equal)) {
      _recordError(
        'Invalid block property syntax. Expected "$key = value".',
        _current,
      );
      _skipToEol();
      return null;
    }
    _advance(); // consume =

    if (_at(TokenKind.newline) || _at(TokenKind.rightBrace) || _atEof()) {
      _recordError('Expected a value for property "$key".', _current);
      return MapEntry<String, String>(key, '');
    }

    final value = _parseRawValue();
    return MapEntry<String, String>(key, value);
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static bool _isAsciiIdentifier(String value) =>
      RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value);
}
