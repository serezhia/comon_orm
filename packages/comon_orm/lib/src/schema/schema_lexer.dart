/// Token types produced by [SchemaLexer].
enum TokenKind {
  /// ASCII identifier: `[a-zA-Z_][a-zA-Z0-9_]*` (or broader for error
  /// reporting — see [SchemaLexer]).
  identifier,

  /// Double-quoted or single-quoted string literal, quotes included.
  string,

  /// Integer literal.
  integer,

  /// `{`
  leftBrace,

  /// `}`
  rightBrace,

  /// `[`
  leftBracket,

  /// `]`
  rightBracket,

  /// `(`
  leftParen,

  /// `)`
  rightParen,

  /// `@@`
  doubleAt,

  /// `@` (single)
  at,

  /// `.`
  dot,

  /// `,`
  comma,

  /// `=`
  equal,

  /// `?`
  question,

  /// `:`
  colon,

  /// End-of-line (LF or CRLF).
  newline,

  /// Sentinel sent at end of token stream.
  eof,
}

/// A single lexer token with source position.
class Token {
  /// Creates a token.
  const Token(this.kind, this.value, this.line, this.column);

  /// Token category.
  final TokenKind kind;

  /// Raw source text of the token.
  final String value;

  /// One-based source line.
  final int line;

  /// One-based source column (character offset within the line).
  final int column;

  @override
  String toString() => 'Token($kind, "$value", $line:$column)';
}

/// Tokenizes a Prisma-style `schema.prisma` source into a flat [Token] list.
///
/// Rules:
/// - Horizontal whitespace (space, tab, carriage return) is skipped.
/// - `//` comments are discarded (not emitted).
/// - Newlines (`\n`) are emitted as [TokenKind.newline].
/// - `@@` is emitted as a single [TokenKind.doubleAt] token.
/// - Non-ASCII characters that are not whitespace are collected into
///   [TokenKind.identifier] tokens so the parser can emit a proper error.
class SchemaLexer {
  /// Creates a stateless lexer.
  const SchemaLexer();

  /// Tokenizes [source] and returns the resulting token list ending with an
  /// [TokenKind.eof] sentinel.
  List<Token> tokenize(String source) {
    final tokens = <Token>[];
    var pos = 0;
    var line = 1;
    var lineStart = 0;

    while (pos < source.length) {
      final startLine = line;
      final startCol = pos - lineStart + 1;
      final char = source[pos];

      // ── Whitespace (horizontal) ─────────────────────────────────────────
      if (char == ' ' || char == '\t' || char == '\r') {
        pos++;
        continue;
      }

      // ── Newline ─────────────────────────────────────────────────────────
      if (char == '\n') {
        tokens.add(Token(TokenKind.newline, '\n', startLine, startCol));
        pos++;
        line++;
        lineStart = pos;
        continue;
      }

      // ── Line comment ────────────────────────────────────────────────────
      if (char == '/' &&
          pos + 1 < source.length &&
          source[pos + 1] == '/') {
        while (pos < source.length && source[pos] != '\n') {
          pos++;
        }
        continue;
      }

      // ── String literal ──────────────────────────────────────────────────
      if (char == '"' || char == "'") {
        final quote = char;
        final buf = StringBuffer()..write(char);
        pos++;
        while (pos < source.length && source[pos] != quote) {
          if (source[pos] == '\\' && pos + 1 < source.length) {
            buf
              ..write(source[pos])
              ..write(source[pos + 1]);
            pos += 2;
          } else {
            buf.write(source[pos]);
            pos++;
          }
        }
        if (pos < source.length) {
          buf.write(source[pos]); // closing quote
          pos++;
        }
        tokens.add(Token(TokenKind.string, buf.toString(), startLine, startCol));
        continue;
      }

      // ── Integer literal ─────────────────────────────────────────────────
      if (_isDigit(char)) {
        final start = pos;
        while (pos < source.length && _isDigit(source[pos])) {
          pos++;
        }
        tokens.add(
          Token(TokenKind.integer, source.substring(start, pos), startLine, startCol),
        );
        continue;
      }

      // ── Double @@ ───────────────────────────────────────────────────────
      if (char == '@' &&
          pos + 1 < source.length &&
          source[pos + 1] == '@') {
        tokens.add(Token(TokenKind.doubleAt, '@@', startLine, startCol));
        pos += 2;
        continue;
      }

      // ── Identifier (ASCII or non-ASCII) ─────────────────────────────────
      // Collect any run of characters that are not known punctuation/whitespace
      // so that unicode identifiers become a single token and can be reported
      // as errors by the parser.
      if (_isIdentStartChar(char) || _isNonAscii(char)) {
        final start = pos;
        while (pos < source.length &&
            (_isIdentChar(source[pos]) || _isNonAscii(source[pos]))) {
          pos++;
        }
        tokens.add(
          Token(TokenKind.identifier, source.substring(start, pos), startLine, startCol),
        );
        continue;
      }

      // ── Single-character punctuation ────────────────────────────────────
      final kind = _singleCharKind(char);
      if (kind != null) {
        tokens.add(Token(kind, char, startLine, startCol));
        pos++;
        continue;
      }

      // ── Unknown character — skip silently ───────────────────────────────
      pos++;
    }

    final eofCol = pos - lineStart + 1;
    tokens.add(Token(TokenKind.eof, '', line, eofCol));
    return tokens;
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }

  static bool _isIdentStartChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || // A-Z
        (code >= 0x61 && code <= 0x7A) || // a-z
        code == 0x5F; // _
  }

  static bool _isIdentChar(String c) {
    return _isIdentStartChar(c) || _isDigit(c);
  }

  static bool _isNonAscii(String c) => c.codeUnitAt(0) > 0x7F;

  static TokenKind? _singleCharKind(String c) {
    switch (c) {
      case '{':
        return TokenKind.leftBrace;
      case '}':
        return TokenKind.rightBrace;
      case '[':
        return TokenKind.leftBracket;
      case ']':
        return TokenKind.rightBracket;
      case '(':
        return TokenKind.leftParen;
      case ')':
        return TokenKind.rightParen;
      case '@':
        return TokenKind.at;
      case '.':
        return TokenKind.dot;
      case ',':
        return TokenKind.comma;
      case '=':
        return TokenKind.equal;
      case '?':
        return TokenKind.question;
      case ':':
        return TokenKind.colon;
      default:
        return null;
    }
  }
}
