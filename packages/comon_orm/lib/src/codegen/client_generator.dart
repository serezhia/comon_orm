import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../schema/implicit_many_to_many.dart';
import '../schema/schema_ast.dart';
import 'codegen_ir.dart';

part 'client_generator_provider_helpers.dart';
part 'client_generator_runtime_metadata.dart';
part 'client_generator_delegate_emitter.dart';
part 'client_generator_model_emitter.dart';
part 'client_generator_query_shape_emitter.dart';
part 'client_generator_aggregate_emitter.dart';
part 'client_generator_include_select_emitter.dart';
part 'client_generator_write_input_emitter.dart';
part 'client_generator_schema_helpers.dart';

/// Controls which SQLite-specific generated convenience helper is emitted.
enum SqliteClientHelperKind {
  /// Emits the VM `comon_orm_sqlite` helper.
  vm,

  /// Emits the Flutter `comon_orm_sqlite_flutter` helper.
  flutter,
}

/// Configuration for generated client runtime helper emission.
class ClientGeneratorOptions {
  /// Creates generator options.
  const ClientGeneratorOptions({
    this.sqliteHelperKind = SqliteClientHelperKind.vm,
  });

  /// Selects which SQLite helper flavor to emit for SQLite datasources.
  final SqliteClientHelperKind sqliteHelperKind;
}

/// Generates a typed Dart client from a validated schema AST.
class ClientGenerator {
  /// Creates a stateless generator.
  const ClientGenerator({this.options = const ClientGeneratorOptions()});

  /// Generator configuration that affects emitted helper surfaces.
  final ClientGeneratorOptions options;

  /// Returns the generated client source for [schema].
  ///
  /// If [schemaSource] is provided, a `// schema-hash:` comment is embedded in
  /// the file header. The CLI uses this to skip re-writing the output file when
  /// the schema hasn't changed (incremental generation, see 5.3).
  String generateClient(SchemaDocument schema, {String? schemaSource}) {
    final effectiveSchema = schema.withoutIgnored();
    final datasourceProviders = effectiveSchema.datasources
        .map(_datasourceProvider)
        .whereType<String>()
        .toSet();
    final emitsSqliteVmHelper =
        datasourceProviders.contains('sqlite') &&
        options.sqliteHelperKind == SqliteClientHelperKind.vm;
    final emitsSqliteFlutterHelper =
        datasourceProviders.contains('sqlite') &&
        options.sqliteHelperKind == SqliteClientHelperKind.flutter;
    final imports = <String>[
      "import 'package:comon_orm/comon_orm.dart';",
      if (emitsSqliteVmHelper)
        "import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';",
      if (emitsSqliteFlutterHelper)
        "import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';",
      if (datasourceProviders.contains('postgresql'))
        "import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';",
      if (datasourceProviders.contains('postgresql'))
        "import 'package:postgres/postgres.dart' as pg;",
    ];
    final buffer = StringBuffer()
      ..writeln('// Generated code. Do not edit by hand.')
      ..writeln(
        '// ignore_for_file: unused_element, non_constant_identifier_names',
      );
    if (schemaSource != null) {
      final hash = sha256.convert(utf8.encode(schemaSource)).toString();
      buffer.writeln('// schema-hash: $hash');
    }
    buffer
      ..writeln(imports.join('\n'))
      ..writeln()
      ..writeln('class GeneratedComonOrmClient {')
      ..writeln('  GeneratedComonOrmClient({required DatabaseAdapter adapter})')
      ..writeln(
        '    : _client = ComonOrmClient(adapter: adapter, schemaView: runtimeSchemaView);',
      )
      ..writeln()
      ..writeln('  GeneratedComonOrmClient._fromClient(this._client);')
      ..writeln()
      ..writeln(
        '  static const GeneratedRuntimeSchema runtimeSchema = GeneratedComonOrmMetadata.schema;',
      )
      ..writeln()
      ..writeln('  static final RuntimeSchemaView runtimeSchemaView =')
      ..writeln('      runtimeSchemaViewFromGeneratedSchema(runtimeSchema);')
      ..writeln()
      ..writeln('  static InMemoryDatabaseAdapter createInMemoryAdapter() {')
      ..writeln('    return InMemoryDatabaseAdapter.fromGeneratedSchema(')
      ..writeln('      schema: runtimeSchema,')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  factory GeneratedComonOrmClient.openInMemory() {')
      ..writeln(
        '    return GeneratedComonOrmClient(adapter: createInMemoryAdapter());',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  final ComonOrmClient _client;');

    for (final model in effectiveSchema.models) {
      final delegateName = '${model.name}Delegate';
      final propertyName = _lowercaseFirst(model.name);
      buffer.writeln(
        '  late final $delegateName $propertyName = $delegateName._(_client);',
      );
    }

    buffer
      ..writeln()
      ..writeln('  Future<T> transaction<T>(')
      ..writeln('    Future<T> Function(GeneratedComonOrmClient tx) action,')
      ..writeln('  ) {')
      ..writeln(
        '    return _client.transaction((tx) => action(GeneratedComonOrmClient._fromClient(tx)));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<void> close() async {')
      ..writeln('    await _client.close();')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();

    _writeProviderHelpers(
      buffer,
      datasourceProviders,
      sqliteHelperKind: options.sqliteHelperKind,
    );

    _writeGeneratedRuntimeMetadata(buffer, effectiveSchema);

    for (final definition in effectiveSchema.enums) {
      _writeEnumClass(buffer, definition);
    }

    _writeScalarUpdateOperationHelpers(buffer);

    for (final model in effectiveSchema.models) {
      _writeModelClass(buffer, effectiveSchema, model);
    }

    for (final model in effectiveSchema.models) {
      _writeDelegate(buffer, effectiveSchema, model);
      _writeWhereInput(buffer, effectiveSchema, model);
      _writeWhereUniqueInput(buffer, effectiveSchema, model);
      _writeOrderByInput(buffer, effectiveSchema, model);
      _writeScalarFieldEnum(buffer, effectiveSchema, model);
      _writeAggregateInputClasses(buffer, effectiveSchema, model);
      _writeAggregateResultClasses(buffer, effectiveSchema, model);
      _writeGroupBySupportClasses(buffer, effectiveSchema, model);
      _writeInclude(buffer, effectiveSchema, model);
      _writeSelect(buffer, effectiveSchema, model);
      _writeCreateInput(buffer, effectiveSchema, model);
      _writeUpdateInput(buffer, effectiveSchema, model);
      _writeCreateWithoutInputs(buffer, effectiveSchema, model);
      _writeConnectOrCreateInputs(buffer, effectiveSchema, model);
      _writeNestedCreateInputs(buffer, effectiveSchema, model);
      _writeNestedUpdateInputs(buffer, effectiveSchema, model);
    }

    buffer
      ..writeln('DateTime? _asDateTime(Object? value) {')
      ..writeln('  if (value is DateTime) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is String) {')
      ..writeln('    return DateTime.tryParse(value);')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('double? _asDouble(Object? value) {')
      ..writeln('  if (value is num) {')
      ..writeln('    return value.toDouble();')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('List<int>? _asBytes(Object? value) {')
      ..writeln('  if (value is List<int>) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is List<Object?>) {')
      ..writeln('    return value.whereType<int>().toList(growable: false);')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('BigInt? _asBigInt(Object? value) {')
      ..writeln('  if (value is BigInt) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is int) {')
      ..writeln('    return BigInt.from(value);')
      ..writeln('  }')
      ..writeln('  if (value is String) {')
      ..writeln('    return BigInt.tryParse(value);')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('String? _enumName(Object? value) {')
      ..writeln('  if (value is Enum) {')
      ..writeln('    return value.name;')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('class _Undefined {')
      ..writeln('  const _Undefined();')
      ..writeln('}')
      ..writeln()
      ..writeln('const Object _undefined = _Undefined();')
      ..writeln()
      ..writeln('bool _deepEquals(Object? left, Object? right) {')
      ..writeln('  if (identical(left, right)) {')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln('  if (left is List<Object?> && right is List<Object?>) {')
      ..writeln('    if (left.length != right.length) {')
      ..writeln('      return false;')
      ..writeln('    }')
      ..writeln('    for (var index = 0; index < left.length; index++) {')
      ..writeln('      if (!_deepEquals(left[index], right[index])) {')
      ..writeln('        return false;')
      ..writeln('      }')
      ..writeln('    }')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln(
        '  if (left is Map<Object?, Object?> && right is Map<Object?, Object?>) {',
      )
      ..writeln('    if (left.length != right.length) {')
      ..writeln('      return false;')
      ..writeln('    }')
      ..writeln('    for (final entry in left.entries) {')
      ..writeln('      if (!right.containsKey(entry.key)) {')
      ..writeln('        return false;')
      ..writeln('      }')
      ..writeln('      if (!_deepEquals(entry.value, right[entry.key])) {')
      ..writeln('        return false;')
      ..writeln('      }')
      ..writeln('    }')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln('  return left == right;')
      ..writeln('}')
      ..writeln()
      ..writeln('int _deepHash(Object? value) {')
      ..writeln('  if (value is List<Object?>) {')
      ..writeln('    return Object.hashAll(value.map(_deepHash));')
      ..writeln('  }')
      ..writeln('  if (value is Map<Object?, Object?>) {')
      ..writeln('    final entries = value.entries')
      ..writeln(
        '        .map((entry) => Object.hash(_deepHash(entry.key), _deepHash(entry.value)))',
      )
      ..writeln('        .toList(growable: false)')
      ..writeln('      ..sort();')
      ..writeln('    return Object.hashAll(entries);')
      ..writeln('  }')
      ..writeln('  return value.hashCode;')
      ..writeln('}')
      ..writeln()
      ..writeln('Object? _jsonEncodable(Object? value) {')
      ..writeln(
        '  if (value == null || value is String || value is num || value is bool) {',
      )
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is DateTime) {')
      ..writeln('    return value.toIso8601String();')
      ..writeln('  }')
      ..writeln('  if (value is BigInt) {')
      ..writeln('    return value.toString();')
      ..writeln('  }')
      ..writeln('  if (value is Enum) {')
      ..writeln('    return value.name;')
      ..writeln('  }')
      ..writeln('  if (value is List<Object?>) {')
      ..writeln('    return value.map(_jsonEncodable).toList(growable: false);')
      ..writeln('  }')
      ..writeln('  if (value is Map<Object?, Object?>) {')
      ..writeln('    final json = <String, Object?>{};')
      ..writeln('    for (final entry in value.entries) {')
      ..writeln(
        '      json[entry.key.toString()] = _jsonEncodable(entry.value);',
      )
      ..writeln('    }')
      ..writeln('    return Map<String, Object?>.unmodifiable(json);')
      ..writeln('  }')
      ..writeln('  return value;')
      ..writeln('}')
      ..writeln()
      ..writeln('Object? _requireRecordValue(')
      ..writeln('  Map<String, Object?> record,')
      ..writeln('  String field,')
      ..writeln('  String context,')
      ..writeln(') {')
      ..writeln('  final value = record[field];')
      ..writeln('  if (value == null) {')
      ..writeln('    throw StateError(')
      ..writeln("      'Missing required key \"\$field\" for \$context.',")
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('  return value;')
      ..writeln('}')
      ..writeln()
      ..writeln('bool _isSkippableDuplicateError(Object error) {')
      ..writeln('  final code = _errorCode(error);')
      ..writeln("  if (code == '23505') {")
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln('  final normalized = error.toString().toLowerCase();')
      ..writeln(
        "  return normalized.contains('duplicate key value violates unique constraint') ||",
      )
      ..writeln("      normalized.contains('unique constraint failed') ||")
      ..writeln("      normalized.contains('unique violation');")
      ..writeln('}')
      ..writeln()
      ..writeln('String? _errorCode(Object error) {')
      ..writeln('  try {')
      ..writeln('    final dynamicError = error as dynamic;')
      ..writeln('    final code = dynamicError.code;')
      ..writeln('    return code is String ? code : null;')
      ..writeln('  } catch (_) {')
      ..writeln('    return null;')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  void _writeEnumClass(StringBuffer buffer, EnumDefinition definition) {
    buffer.writeln('enum ${definition.name} {');

    for (var index = 0; index < definition.values.length; index++) {
      final suffix = index == definition.values.length - 1 ? '' : ',';
      buffer.writeln('  ${definition.values[index]}$suffix');
    }

    buffer
      ..writeln('}')
      ..writeln();
  }
}
