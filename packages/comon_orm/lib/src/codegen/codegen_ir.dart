/// Intermediate representation (IR) nodes for Dart code generation.
///
/// The IR layer decouples schema-to-structure transformation from string
/// rendering, enabling each emitter to be tested structurally rather than
/// through string matching.
library;

import 'package:meta/meta.dart';

/// A model of a generated Dart source file, containing zero or more classes.
///
/// Useful for testing that a generator produces the expected class structure
/// without relying on rendered string output.
@immutable
class CodeUnit {
  /// Creates a code unit with the given [classes].
  const CodeUnit({required this.classes});

  /// Ordered list of class declarations to emit into the file.
  final List<CodeClass> classes;
}

// ── Data nodes ───────────────────────────────────────────────────────────────

/// A field declaration inside a class: `final Type name;` or similar.
@immutable
class CodeField {
  /// Creates a field node.
  const CodeField({
    required this.name,
    required this.type,
    this.isFinal = true,
    this.defaultValue,
  });

  /// Field name as it will appear in Dart source.
  final String name;

  /// Dart type string, e.g. `'bool'`, `'int?'`, `'SortOrder?'`.
  final String type;

  /// Whether the field carries a `final` modifier.
  final bool isFinal;

  /// Optional literal default value string, e.g. `'false'`, `'null'`.
  final String? defaultValue;
}

/// A constructor parameter, either positional or named.
@immutable
class CodeParameter {
  /// Creates a parameter node.
  const CodeParameter({
    required this.name,
    this.type,
    this.isNamed = true,
    this.isThis = false,
    this.defaultValue,
  });

  /// Parameter name.
  final String name;

  /// Explicit Dart type string; omitted when [isThis] is true.
  final String? type;

  /// Whether the parameter is a named parameter (`{name}`).
  final bool isNamed;

  /// Whether the parameter uses the `this.` initializer shorthand.
  final bool isThis;

  /// Default value literal, e.g. `'false'`, `'null'`.
  final String? defaultValue;
}

/// A constructor declaration for a class.
@immutable
class CodeConstructor {
  /// Creates a constructor node.
  const CodeConstructor({
    required this.className,
    this.parameters = const <CodeParameter>[],
    this.isConst = true,
    this.bodyLines = const <String>[],
  });

  /// Class name used in the constructor declaration.
  final String className;

  /// Parameter list.
  final List<CodeParameter> parameters;

  /// Whether the constructor is declared `const`.
  final bool isConst;

  /// Raw body source lines (empty means no body, just `;`).
  final List<String> bodyLines;
}

/// A method declaration inside a class.
@immutable
class CodeMethod {
  /// Creates a method node.
  const CodeMethod({
    required this.name,
    required this.returnType,
    this.parameters = const <CodeParameter>[],
    this.bodyLines = const <String>[],
    this.isAsync = false,
  });

  /// Method name.
  final String name;

  /// Return type string, e.g. `'void'`, `'Set<String>'`.
  final String returnType;

  /// Formal parameter list.
  final List<CodeParameter> parameters;

  /// Raw body source lines — each is indented by the renderer.
  final List<String> bodyLines;

  /// Whether the method carries an `async` modifier.
  final bool isAsync;
}

/// A full Dart class declaration.
@immutable
class CodeClass {
  /// Creates a class node.
  const CodeClass({
    required this.name,
    this.fields = const <CodeField>[],
    this.constructors = const <CodeConstructor>[],
    this.methods = const <CodeMethod>[],
  });

  /// Class name.
  final String name;

  /// Field declarations (in order of appearance).
  final List<CodeField> fields;

  /// Constructor declarations.
  final List<CodeConstructor> constructors;

  /// Method declarations.
  final List<CodeMethod> methods;
}

// ── Renderer ─────────────────────────────────────────────────────────────────

/// Renders [CodeClass] IR nodes to Dart source strings.
///
/// The default two-space indentation matches the rest of the generated client.
class CodeRenderer {
  /// Creates a renderer.
  const CodeRenderer({this.indent = '  '});

  /// Indentation string used at each nesting level.
  final String indent;

  /// Renders [cls] to a Dart class declaration string ending with a blank line.
  String renderClass(CodeClass cls) {
    final buf = StringBuffer();
    buf.writeln('class ${cls.name} {');

    // ── Constructors ──────────────────────────────────────────────────────
    for (final ctor in cls.constructors) {
      _renderConstructor(buf, ctor);
    }

    if (cls.constructors.isNotEmpty &&
        (cls.fields.isNotEmpty || cls.methods.isNotEmpty)) {
      buf.writeln();
    }

    // ── Fields ────────────────────────────────────────────────────────────
    for (final field in cls.fields) {
      _renderField(buf, field);
    }

    if (cls.fields.isNotEmpty && cls.methods.isNotEmpty) {
      buf.writeln();
    }

    // ── Methods ───────────────────────────────────────────────────────────
    for (var i = 0; i < cls.methods.length; i++) {
      _renderMethod(buf, cls.methods[i]);
      if (i < cls.methods.length - 1) buf.writeln();
    }

    buf
      ..writeln('}')
      ..writeln();
    return buf.toString();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  void _renderField(StringBuffer buf, CodeField field) {
    final modifier = field.isFinal ? 'final ' : '';
    if (field.defaultValue != null) {
      buf.writeln(
        '$indent$modifier${field.type} ${field.name} = ${field.defaultValue};',
      );
    } else {
      buf.writeln('$indent$modifier${field.type} ${field.name};');
    }
  }

  void _renderConstructor(StringBuffer buf, CodeConstructor ctor) {
    final constKw = ctor.isConst ? 'const ' : '';
    final params = ctor.parameters.map(_renderParam).join(', ');
    final wrapParams = ctor.parameters.isNotEmpty;

    if (ctor.bodyLines.isEmpty) {
      if (wrapParams) {
        buf
          ..write('$indent$constKw${ctor.className}({')
          ..write(params)
          ..writeln('});');
      } else {
        buf.writeln('$indent$constKw${ctor.className}();');
      }
    } else {
      if (wrapParams) {
        buf
          ..write('$indent$constKw${ctor.className}({')
          ..write(params)
          ..writeln('}) {');
      } else {
        buf.writeln('$indent$constKw${ctor.className}() {');
      }
      for (final line in ctor.bodyLines) {
        buf.writeln('$indent$indent$line');
      }
      buf.writeln('$indent}');
    }
  }

  void _renderMethod(StringBuffer buf, CodeMethod method) {
    final asyncKw = method.isAsync ? ' async' : '';
    final params = method.parameters.map(_renderParam).join(', ');
    final wrapParams = method.parameters.isNotEmpty;

    if (wrapParams) {
      buf
        ..write('$indent${method.returnType} ${method.name}({')
        ..write(params)
        ..writeln('})$asyncKw {');
    } else {
      buf.writeln('$indent${method.returnType} ${method.name}()$asyncKw {');
    }

    for (final line in method.bodyLines) {
      buf.writeln('$indent$indent$line');
    }

    buf.writeln('$indent}');
  }

  static String _renderParam(CodeParameter p) {
    final nameStr = p.isThis ? 'this.${p.name}' : p.name;
    final typeStr = (!p.isThis && p.type != null)
        ? '${p.type} $nameStr'
        : nameStr;
    final defaultStr = p.defaultValue != null ? ' = ${p.defaultValue}' : '';
    return '$typeStr$defaultStr';
  }
}
