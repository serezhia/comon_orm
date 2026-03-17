part of 'client_generator.dart';

extension on ClientGenerator {
  void _writeDelegate(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final delegateName = '${model.name}Delegate';
    final modelClassName = model.name;
    final whereInputName = '${model.name}WhereInput';
    final whereUniqueInputName = '${model.name}WhereUniqueInput';
    final orderByName = '${model.name}OrderByInput';
    final scalarFieldName = '${model.name}ScalarField';
    final countAggregateInputName = '${model.name}CountAggregateInput';
    final avgAggregateInputName = '${model.name}AvgAggregateInput';
    final sumAggregateInputName = '${model.name}SumAggregateInput';
    final minAggregateInputName = '${model.name}MinAggregateInput';
    final maxAggregateInputName = '${model.name}MaxAggregateInput';
    final aggregateResultName = '${model.name}AggregateResult';
    final groupByOrderByName = '${model.name}GroupByOrderByInput';
    final groupByHavingName = '${model.name}GroupByHavingInput';
    final groupByRowName = '${model.name}GroupByRow';
    final includeName = '${model.name}Include';
    final selectName = '${model.name}Select';
    final createInputName = '${model.name}CreateInput';
    final updateInputName = '${model.name}UpdateInput';
    final hasNumericFields = _numericAggregateFields(schema, model).isNotEmpty;
    final hasGroupBy = _scalarFields(schema, model).length > 1;
    final relationFields = _relationFields(schema, model);
    final primaryKeyFields = model.fields
        .where((field) => field.isId)
        .toList(growable: false);
    final effectivePrimaryKeyFields = primaryKeyFields.isNotEmpty
        ? primaryKeyFields
        : model.primaryKeyFields
              .map((name) => model.findField(name))
              .whereType<FieldDefinition>()
              .toList(growable: false);

    buffer
      ..writeln('class $delegateName {')
      ..writeln('  const $delegateName._(this._client);')
      ..writeln()
      ..writeln('  final ComonOrmClient _client;')
      ..writeln(
        '  ModelDelegate get _delegate => _client.model(${_stringLiteral(model.name)});',
      )
      ..writeln()
      ..writeln('  Future<$modelClassName?> findUnique({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.findUnique(')
      ..writeln('      FindUniqueQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('      ),')
      ..writeln(
        '    ).then((record) => record == null ? null : $modelClassName.fromRecord(record));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName?> findFirst({')
      ..writeln('    $whereInputName? where,')
      ..writeln('    $whereUniqueInputName? cursor,')
      ..writeln('    List<$orderByName>? orderBy,')
      ..writeln('    List<$scalarFieldName>? distinct,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('    int? skip,')
      ..writeln('  }) async {')
      ..writeln(
        '    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];',
      )
      ..writeln(
        '    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];',
      )
      ..writeln(
        '    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};',
      )
      ..writeln('    final queryInclude = include?.toQueryInclude();')
      ..writeln('    final querySelect = select?.toQuerySelect();')
      ..writeln('    return _delegate.findFirst(')
      ..writeln('      FindFirstQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: predicates,')
      ..writeln('        cursor: cursor?.toQueryCursor(),')
      ..writeln('        orderBy: queryOrderBy,')
      ..writeln('        distinct: queryDistinct,')
      ..writeln('        include: queryInclude,')
      ..writeln('        select: querySelect,')
      ..writeln('        skip: skip,')
      ..writeln('      ),')
      ..writeln(
        '    ).then((record) => record == null ? null : $modelClassName.fromRecord(record));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<List<$modelClassName>> findMany({')
      ..writeln('    $whereInputName? where,')
      ..writeln('    $whereUniqueInputName? cursor,')
      ..writeln('    List<$orderByName>? orderBy,')
      ..writeln('    List<$scalarFieldName>? distinct,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('    int? skip,')
      ..writeln('    int? take,')
      ..writeln('  }) async {')
      ..writeln(
        '    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];',
      )
      ..writeln(
        '    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];',
      )
      ..writeln(
        '    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};',
      )
      ..writeln('    final queryInclude = include?.toQueryInclude();')
      ..writeln('    final querySelect = select?.toQuerySelect();')
      ..writeln('    return _delegate.findMany(')
      ..writeln('      FindManyQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: predicates,')
      ..writeln('        cursor: cursor?.toQueryCursor(),')
      ..writeln('        orderBy: queryOrderBy,')
      ..writeln('        distinct: queryDistinct,')
      ..writeln('        include: queryInclude,')
      ..writeln('        select: querySelect,')
      ..writeln('        skip: skip,')
      ..writeln('        take: take,')
      ..writeln('      ),')
      ..writeln(
        '    ).then((records) => records.map($modelClassName.fromRecord).toList(growable: false));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> count({$whereInputName? where}) {')
      ..writeln('    return _delegate.count(')
      ..writeln('      CountQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$aggregateResultName> aggregate({')
      ..writeln('    $whereInputName? where,')
      ..writeln('    List<$orderByName>? orderBy,')
      ..writeln('    int? skip,')
      ..writeln('    int? take,')
      ..writeln('    $countAggregateInputName? count,');
    if (hasNumericFields) {
      buffer
        ..writeln('    $avgAggregateInputName? avg,')
        ..writeln('    $sumAggregateInputName? sum,');
    }
    buffer
      ..writeln('    $minAggregateInputName? min,')
      ..writeln('    $maxAggregateInputName? max,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.aggregate(')
      ..writeln('      AggregateQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln(
        '        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],',
      )
      ..writeln('        skip: skip,')
      ..writeln('        take: take,')
      ..writeln(
        '        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),',
      );
    if (hasNumericFields) {
      buffer
        ..writeln('        avg: avg?.toFields() ?? const <String>{},')
        ..writeln('        sum: sum?.toFields() ?? const <String>{},');
    } else {
      buffer
        ..writeln('        avg: const <String>{},')
        ..writeln('        sum: const <String>{},');
    }
    buffer
      ..writeln('        min: min?.toFields() ?? const <String>{},')
      ..writeln('        max: max?.toFields() ?? const <String>{},')
      ..writeln('      ),')
      ..writeln('    ).then($aggregateResultName.fromQueryResult);')
      ..writeln('  }')
      ..writeln();
    if (hasGroupBy) {
      buffer
        ..writeln('  Future<List<$groupByRowName>> groupBy({')
        ..writeln('    required List<$scalarFieldName> by,')
        ..writeln('    $whereInputName? where,')
        ..writeln('    List<$groupByOrderByName>? orderBy,');
      if (hasNumericFields) {
        buffer.writeln('    $groupByHavingName? having,');
      }
      buffer
        ..writeln('    int? skip,')
        ..writeln('    int? take,')
        ..writeln('    $countAggregateInputName? count,');
      if (hasNumericFields) {
        buffer
          ..writeln('    $avgAggregateInputName? avg,')
          ..writeln('    $sumAggregateInputName? sum,');
      }
      buffer
        ..writeln('    $minAggregateInputName? min,')
        ..writeln('    $maxAggregateInputName? max,')
        ..writeln('  }) {')
        ..writeln('    return _delegate.groupBy(')
        ..writeln('      GroupByQuery(')
        ..writeln('        model: ${_stringLiteral(model.name)},')
        ..writeln(
          '        by: by.map((field) => field.name).toList(growable: false),',
        )
        ..writeln(
          '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
        );
      if (hasNumericFields) {
        buffer.writeln(
          '        having: having?.toAggregatePredicates() ?? const <QueryAggregatePredicate>[],',
        );
      } else {
        buffer.writeln('        having: const <QueryAggregatePredicate>[],');
      }
      buffer
        ..writeln(
          '        orderBy: orderBy?.expand((entry) => entry.toGroupByOrderBy()).toList(growable: false) ?? const <GroupByOrderBy>[],',
        )
        ..writeln('        skip: skip,')
        ..writeln('        take: take,')
        ..writeln(
          '        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),',
        );
      if (hasNumericFields) {
        buffer
          ..writeln('        avg: avg?.toFields() ?? const <String>{},')
          ..writeln('        sum: sum?.toFields() ?? const <String>{},');
      } else {
        buffer
          ..writeln('        avg: const <String>{},')
          ..writeln('        sum: const <String>{},');
      }
      buffer
        ..writeln('        min: min?.toFields() ?? const <String>{},')
        ..writeln('        max: max?.toFields() ?? const <String>{},')
        ..writeln('      ),')
        ..writeln(
          '    ).then((rows) => rows.map($groupByRowName.fromQueryResultRow).toList(growable: false));',
        )
        ..writeln('  }')
        ..writeln();
    }
    buffer
      ..writeln('  Future<$modelClassName> create({')
      ..writeln('    required $createInputName data,')
      ..writeln('    $includeName? include,')
      ..writeln('  }) {')
      ..writeln('    final queryInclude = include?.toQueryInclude();')
      ..writeln('    return _client.transaction((txClient) async {')
      ..writeln(
        '      final tx = GeneratedComonOrmClient._fromClient(txClient);',
      )
      ..writeln('      return _performCreateWithRelationWrites(')
      ..writeln('        tx: tx,')
      ..writeln('        data: data,')
      ..writeln('        include: queryInclude,')
      ..writeln('      );')
      ..writeln('    });')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> createMany({')
      ..writeln('    required List<$createInputName> data,')
      ..writeln('    bool skipDuplicates = false,')
      ..writeln('  }) {')
      ..writeln('    if (data.isEmpty) {')
      ..writeln('      return Future<int>.value(0);')
      ..writeln('    }')
      ..writeln('    return _client.transaction((txClient) async {')
      ..writeln(
        '      final tx = GeneratedComonOrmClient._fromClient(txClient);',
      )
      ..writeln(
        '      final txDelegate = tx._client.model(${_stringLiteral(model.name)});',
      )
      ..writeln('      var createdCount = 0;')
      ..writeln('      for (final entry in data) {')
      ..writeln('        if (skipDuplicates) {')
      ..writeln('          var duplicateFound = false;')
      ..writeln(
        '          for (final selector in entry.toUniqueSelectorPredicates()) {',
      )
      ..writeln('            final existing = await txDelegate.findUnique(')
      ..writeln('              FindUniqueQuery(')
      ..writeln('                model: ${_stringLiteral(model.name)},')
      ..writeln('                where: selector,')
      ..writeln('              ),')
      ..writeln('            );')
      ..writeln('            if (existing != null) {')
      ..writeln('              duplicateFound = true;')
      ..writeln('              break;')
      ..writeln('            }')
      ..writeln('          }')
      ..writeln('          if (duplicateFound) {')
      ..writeln('            continue;')
      ..writeln('          }')
      ..writeln('        }')
      ..writeln('        try {')
      ..writeln('          if (entry.hasDeferredRelationWrites) {')
      ..writeln('            await _performCreateWithRelationWrites(')
      ..writeln('              tx: tx,')
      ..writeln('              data: entry,')
      ..writeln('            );')
      ..writeln('          } else {')
      ..writeln('            await txDelegate.create(')
      ..writeln('              CreateQuery(')
      ..writeln('                model: ${_stringLiteral(model.name)},')
      ..writeln('                data: entry.toData(),')
      ..writeln('                nestedCreates: entry.toNestedCreates(),')
      ..writeln('              ),')
      ..writeln('            );')
      ..writeln('          }')
      ..writeln('        } on Object catch (error) {')
      ..writeln(
        '          if (skipDuplicates && _isSkippableDuplicateError(error)) {',
      )
      ..writeln('            continue;')
      ..writeln('          }')
      ..writeln('          rethrow;')
      ..writeln('        }')
      ..writeln('        createdCount++;')
      ..writeln('      }')
      ..writeln('      return createdCount;')
      ..writeln('    });')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName> update({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    required $updateInputName data,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    final predicates = where.toPredicates();')
      ..writeln('    final queryInclude = include?.toQueryInclude();')
      ..writeln('    final querySelect = select?.toQuerySelect();')
      ..writeln('    return _client.transaction((txClient) async {')
      ..writeln(
        '      final tx = GeneratedComonOrmClient._fromClient(txClient);',
      )
      ..writeln(
        '      final txDelegate = tx._client.model(${_stringLiteral(model.name)});',
      )
      ..writeln('      final existing = await txDelegate.findUnique(')
      ..writeln('        FindUniqueQuery(')
      ..writeln('          model: ${_stringLiteral(model.name)},')
      ..writeln('          where: predicates,')
      ..writeln('        ),')
      ..writeln('      );')
      ..writeln('      if (existing == null) {')
      ..writeln(
        '        throw StateError(${_stringLiteral('No record found for update in ${model.name}.')});',
      )
      ..writeln('      }')
      ..writeln('      return _performUpdateWithRelationWrites(')
      ..writeln('        tx: tx,')
      ..writeln('        predicates: predicates,')
      ..writeln('        existing: existing,')
      ..writeln('        data: data,')
      ..writeln('        include: queryInclude,')
      ..writeln('        select: querySelect,')
      ..writeln('      );')
      ..writeln('    });')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName> upsert({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    required $createInputName create,')
      ..writeln('    required $updateInputName update,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    final predicates = where.toPredicates();')
      ..writeln('    final queryInclude = include?.toQueryInclude();')
      ..writeln('    final querySelect = select?.toQuerySelect();')
      ..writeln('    return _client.transaction((txClient) async {')
      ..writeln(
        '      final tx = GeneratedComonOrmClient._fromClient(txClient);',
      )
      ..writeln(
        '      final txDelegate = tx._client.model(${_stringLiteral(model.name)});',
      )
      ..writeln('      final existing = await txDelegate.findUnique(')
      ..writeln('        FindUniqueQuery(')
      ..writeln('          model: ${_stringLiteral(model.name)},')
      ..writeln('          where: predicates,')
      ..writeln('        ),')
      ..writeln('      );')
      ..writeln('      if (existing != null) {')
      ..writeln('        return _performUpdateWithRelationWrites(')
      ..writeln('          tx: tx,')
      ..writeln('          predicates: predicates,')
      ..writeln('          existing: existing,')
      ..writeln('          data: update,')
      ..writeln('          include: queryInclude,')
      ..writeln('          select: querySelect,')
      ..writeln('        );')
      ..writeln('      }')
      ..writeln('      return _performCreateWithRelationWrites(')
      ..writeln('        tx: tx,')
      ..writeln('        data: create,')
      ..writeln('        include: queryInclude,')
      ..writeln('        select: querySelect,')
      ..writeln('      );')
      ..writeln('    });')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> updateMany({')
      ..writeln('    required $whereInputName where,')
      ..writeln('    required $updateInputName data,')
      ..writeln('  }) {')
      ..writeln('    final predicates = where.toPredicates();')
      ..writeln(
        '    if (data.hasComputedOperators || data.hasRelationWrites) {',
      )
      ..writeln('      return _client.transaction((txClient) async {')
      ..writeln(
        '        final tx = GeneratedComonOrmClient._fromClient(txClient);',
      )
      ..writeln(
        '        final txDelegate = tx._client.model(${_stringLiteral(model.name)});',
      )
      ..writeln('        final existingRecords = await txDelegate.findMany(')
      ..writeln('          FindManyQuery(')
      ..writeln('            model: ${_stringLiteral(model.name)},')
      ..writeln('            where: predicates,')
      ..writeln('          ),')
      ..writeln('        );')
      ..writeln('        var updatedCount = 0;')
      ..writeln('        for (final record in existingRecords) {')
      ..writeln('          await _performUpdateWithRelationWrites(')
      ..writeln('            tx: tx,')
      ..writeln(
        '            predicates: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),',
      )
      ..writeln('            existing: record,')
      ..writeln('            data: data,')
      ..writeln('          );')
      ..writeln('          updatedCount++;')
      ..writeln('        }')
      ..writeln('        return updatedCount;')
      ..writeln('      });')
      ..writeln('    }')
      ..writeln('    return _delegate.updateMany(')
      ..writeln('      UpdateManyQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: predicates,')
      ..writeln('        data: data.toData(),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln();

    buffer
      ..writeln('  Future<$modelClassName> _performCreateWithRelationWrites({')
      ..writeln('    required GeneratedComonOrmClient tx,')
      ..writeln('    required $createInputName data,')
      ..writeln('    QueryInclude? include,')
      ..writeln('    QuerySelect? select,')
      ..writeln('  }) async {')
      ..writeln(
        '    final txDelegate = tx._client.model(${_stringLiteral(model.name)});',
      )
      ..writeln('    final created = await txDelegate.create(')
      ..writeln('      CreateQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        data: data.toData(),')
      ..writeln('        nestedCreates: data.toNestedCreates(),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln(
        '    final predicates = _primaryKeyWhereUniqueFromRecord(created).toPredicates();',
      )
      ..writeln('    if (data.hasDeferredRelationWrites) {')
      ..writeln('      await _applyNestedRelationWrites(')
      ..writeln('        tx: tx,')
      ..writeln('        predicates: predicates,')
      ..writeln('        existing: created,')
      ..writeln('        data: data.toDeferredRelationUpdateInput(),')
      ..writeln('      );')
      ..writeln('    }')
      ..writeln(
        '    if (include == null && select == null && !data.hasDeferredRelationWrites) {',
      )
      ..writeln('      return $modelClassName.fromRecord(created);')
      ..writeln('    }')
      ..writeln('    final projected = await txDelegate.findUnique(')
      ..writeln('      FindUniqueQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: predicates,')
      ..writeln('        include: include,')
      ..writeln('        select: select,')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('    if (projected == null) {')
      ..writeln(
        '      throw StateError(${_stringLiteral('${model.name} create branch could not reload the created record by primary key.')});',
      )
      ..writeln('    }')
      ..writeln('    return $modelClassName.fromRecord(projected);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  $whereUniqueInputName _primaryKeyWhereUniqueFromRecord(')
      ..writeln('    Map<String, Object?> record,')
      ..writeln('  ) {');

    if (effectivePrimaryKeyFields.length == 1) {
      final field = effectivePrimaryKeyFields.single;
      buffer.writeln(
        '    return $whereUniqueInputName(${field.name}: (${_fromScalarRecordExpression(schema, field, "record[${_stringLiteral(field.name)}]")})!);',
      );
    } else if (effectivePrimaryKeyFields.length > 1) {
      final selectorName = _compoundUniqueSelectorName(
        effectivePrimaryKeyFields
            .map((field) => field.name)
            .toList(growable: false),
      );
      final compoundClassName = _compoundUniqueInputClassName(
        model,
        effectivePrimaryKeyFields
            .map((field) => field.name)
            .toList(growable: false),
      );
      buffer
        ..writeln('    return $whereUniqueInputName(')
        ..writeln('      $selectorName: $compoundClassName(');

      for (final field in effectivePrimaryKeyFields) {
        buffer.writeln(
          '        ${field.name}: (${_fromScalarRecordExpression(schema, field, "record[${_stringLiteral(field.name)}]")})!,',
        );
      }

      buffer
        ..writeln('      ),')
        ..writeln('    );');
    } else {
      buffer.writeln(
        '    throw StateError(${_stringLiteral('${model.name}.findMany(cursor: ...) requires a primary key to reload paged records.')});',
      );
    }

    buffer
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName> _performUpdateWithRelationWrites({')
      ..writeln('    required GeneratedComonOrmClient tx,')
      ..writeln('    required List<QueryPredicate> predicates,')
      ..writeln('    required Map<String, Object?> existing,')
      ..writeln('    required $updateInputName data,')
      ..writeln('    QueryInclude? include,')
      ..writeln('    QuerySelect? select,')
      ..writeln('  }) async {')
      ..writeln(
        '    final txDelegate = tx._client.model(${_stringLiteral(model.name)});',
      )
      ..writeln('    await txDelegate.update(')
      ..writeln('      UpdateQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: predicates,')
      ..writeln('        data: data.resolveDataAgainstRecord(existing),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('    await _applyNestedRelationWrites(')
      ..writeln('      tx: tx,')
      ..writeln('      predicates: predicates,')
      ..writeln('      existing: existing,')
      ..writeln('      data: data,')
      ..writeln('    );')
      ..writeln('    final projected = await txDelegate.findUnique(')
      ..writeln('      FindUniqueQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: predicates,')
      ..writeln('        include: include,')
      ..writeln('        select: select,')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('    if (projected == null) {')
      ..writeln(
        '      throw StateError(${_stringLiteral('${model.name} update branch could not reload the updated record for the provided unique selector.')});',
      )
      ..writeln('    }')
      ..writeln('    return $modelClassName.fromRecord(projected);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<void> _applyNestedRelationWrites({')
      ..writeln('    required GeneratedComonOrmClient tx,')
      ..writeln('    required List<QueryPredicate> predicates,')
      ..writeln('    required Map<String, Object?> existing,')
      ..writeln('    required $updateInputName data,')
      ..writeln('  }) async {');

    if (relationFields.isEmpty) {
      buffer.writeln('    return;');
    } else {
      for (final relationField in relationFields) {
        final targetModel = _targetModel(schema, relationField);
        final targetDelegateName = _lowercaseFirst(targetModel.name);

        buffer
          ..writeln('    if (data.${relationField.name} == null) {')
          ..writeln('      // No nested writes for ${relationField.name}.')
          ..writeln('    } else {')
          ..writeln('      final nested = data.${relationField.name}!;');

        if (_isImplicitManyToManyRelation(schema, model, relationField)) {
          final relationLiteral = _relationLiteral(
            schema,
            model,
            relationField,
          );
          final sourceKeyFields = _implicitManyToManyKeyFields(model);
          final targetKeyFields = _implicitManyToManyKeyFields(targetModel);
          final relationContext =
              'nested implicit many-to-many write on ${model.name}.${relationField.name}';

          buffer
            ..writeln('      final relation = $relationLiteral;')
            ..writeln('      final parentKeyValues = <String, Object?>{');

          for (final fieldName in sourceKeyFields) {
            buffer.writeln(
              '        ${_stringLiteral(fieldName)}: _requireRecordValue(existing, ${_stringLiteral(fieldName)}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('      };')
            ..writeln(
              '      if (nested.set != null && (nested.connect.isNotEmpty || nested.disconnect.isNotEmpty || nested.connectOrCreate.isNotEmpty)) {',
            )
            ..writeln(
              '        throw StateError(${_stringLiteral('Only set or connect/disconnect/connectOrCreate may be provided for $updateInputName.${relationField.name}.')});',
            )
            ..writeln('      }')
            ..writeln('      if (nested.set != null) {')
            ..writeln(
              '        await tx._client.model(${_stringLiteral(model.name)}).removeImplicitManyToManyLinks(',
            )
            ..writeln('          relation: relation,')
            ..writeln('          sourceKeyValues: parentKeyValues,')
            ..writeln('        );')
            ..writeln('        for (final selector in nested.set!) {')
            ..writeln(
              '          final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('            FindUniqueQuery(')
            ..writeln(
              '              model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln('              where: selector.toPredicates(),')
            ..writeln('            ),')
            ..writeln('          );')
            ..writeln('          if (related == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested set on ${model.name}.${relationField.name}.')});',
            )
            ..writeln('          }')
            ..writeln('          final targetKeyValues = <String, Object?>{');

          for (final fieldName in targetKeyFields) {
            buffer.writeln(
              '            ${_stringLiteral(fieldName)}: _requireRecordValue(related, ${_stringLiteral(fieldName)}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('          };')
            ..writeln(
              '          await tx._client.model(${_stringLiteral(model.name)}).addImplicitManyToManyLink(',
            )
            ..writeln('            relation: relation,')
            ..writeln('            sourceKeyValues: parentKeyValues,')
            ..writeln('            targetKeyValues: targetKeyValues,')
            ..writeln('          );')
            ..writeln('        }')
            ..writeln('      }')
            ..writeln('      for (final selector in nested.connect) {')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: selector.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        if (related == null) {')
            ..writeln(
              '          throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested connect on ${model.name}.${relationField.name}.')});',
            )
            ..writeln('        }')
            ..writeln('        final targetKeyValues = <String, Object?>{');

          for (final fieldName in targetKeyFields) {
            buffer.writeln(
              '          ${_stringLiteral(fieldName)}: _requireRecordValue(related, ${_stringLiteral(fieldName)}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('        };')
            ..writeln(
              '        await tx._client.model(${_stringLiteral(model.name)}).addImplicitManyToManyLink(',
            )
            ..writeln('          relation: relation,')
            ..writeln('          sourceKeyValues: parentKeyValues,')
            ..writeln('          targetKeyValues: targetKeyValues,')
            ..writeln('        );')
            ..writeln('      }')
            ..writeln('      for (final entry in nested.connectOrCreate) {')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: entry.where.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        final relatedRecord = related ??')
            ..writeln(
              '            await tx.$targetDelegateName._delegate.create(',
            )
            ..writeln('              CreateQuery(')
            ..writeln(
              '                model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln('                data: entry.create.toData(),')
            ..writeln(
              '                nestedCreates: entry.create.toNestedCreates(),',
            )
            ..writeln('              ),')
            ..writeln('            );')
            ..writeln('        final targetKeyValues = <String, Object?>{');

          for (final fieldName in targetKeyFields) {
            buffer.writeln(
              '          ${_stringLiteral(fieldName)}: _requireRecordValue(relatedRecord, ${_stringLiteral(fieldName)}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('        };')
            ..writeln(
              '        await tx._client.model(${_stringLiteral(model.name)}).addImplicitManyToManyLink(',
            )
            ..writeln('          relation: relation,')
            ..writeln('          sourceKeyValues: parentKeyValues,')
            ..writeln('          targetKeyValues: targetKeyValues,')
            ..writeln('        );')
            ..writeln('      }')
            ..writeln('      for (final selector in nested.disconnect) {')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: selector.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        if (related == null) {')
            ..writeln(
              '          throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested disconnect on ${model.name}.${relationField.name}.')});',
            )
            ..writeln('        }')
            ..writeln('        final targetKeyValues = <String, Object?>{');

          for (final fieldName in targetKeyFields) {
            buffer.writeln(
              '          ${_stringLiteral(fieldName)}: _requireRecordValue(related, ${_stringLiteral(fieldName)}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('        };')
            ..writeln(
              '        await tx._client.model(${_stringLiteral(model.name)}).removeImplicitManyToManyLinks(',
            )
            ..writeln('          relation: relation,')
            ..writeln('          sourceKeyValues: parentKeyValues,')
            ..writeln('          targetKeyValues: targetKeyValues,')
            ..writeln('        );')
            ..writeln('      }');
        } else if (relationField.isList) {
          final foreignKeyFields = _owningRelationForeignKeyFieldNames(
            schema,
            model,
            relationField,
          );
          final referenceFields = _owningRelationReferenceFieldNames(
            schema,
            model,
            relationField,
          );
          final relationContext =
              'nested direct relation write on ${model.name}.${relationField.name}';

          buffer.writeln(
            '      final parentReferenceValues = <String, Object?>{',
          );

          for (var index = 0; index < foreignKeyFields.length; index++) {
            buffer.writeln(
              '        ${_stringLiteral(foreignKeyFields[index])}: _requireRecordValue(existing, ${_stringLiteral(referenceFields[index])}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('      };')
            ..writeln(
              '      if (nested.set != null && (nested.connect.isNotEmpty || nested.disconnect.isNotEmpty || nested.connectOrCreate.isNotEmpty)) {',
            )
            ..writeln(
              '        throw StateError(${_stringLiteral('Only set or connect/disconnect/connectOrCreate may be provided for $updateInputName.${relationField.name}.')});',
            )
            ..writeln('      }');

          final targetPrimaryKeyFields = targetModel.fields
              .where((field) => field.isId)
              .toList(growable: false);
          final effectiveTargetPrimaryKeyFields =
              targetPrimaryKeyFields.isNotEmpty
              ? targetPrimaryKeyFields
              : targetModel.primaryKeyFields
                    .map((name) => targetModel.findField(name))
                    .whereType<FieldDefinition>()
                    .toList(growable: false);

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('      if (nested.set != null) {')
              ..writeln(
                '        await tx.$targetDelegateName._delegate.updateMany(',
              )
              ..writeln('          UpdateManyQuery(')
              ..writeln(
                '            model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('            where: <QueryPredicate>[');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '              QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
              );
            }

            buffer
              ..writeln('            ],')
              ..writeln('            data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '              ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('            },')
              ..writeln('          ),')
              ..writeln('        );')
              ..writeln('        for (final selector in nested.set!) {')
              ..writeln(
                '          await tx.$targetDelegateName._delegate.update(',
              )
              ..writeln('            UpdateQuery(')
              ..writeln(
                '              model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('              where: selector.toPredicates(),')
              ..writeln('              data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
              );
            }

            buffer
              ..writeln('              },')
              ..writeln('            ),')
              ..writeln('          );')
              ..writeln('        }')
              ..writeln('      }');
          } else {
            buffer
              ..writeln(
                '      final currentRelatedRecords = await tx.$targetDelegateName._delegate.findMany(',
              )
              ..writeln('        FindManyQuery(')
              ..writeln('          model: ${_stringLiteral(targetModel.name)},')
              ..writeln('          where: <QueryPredicate>[');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '            QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
              );
            }

            buffer
              ..writeln('          ],')
              ..writeln('        ),')
              ..writeln('      );')
              ..writeln('      if (nested.set != null) {')
              ..writeln(
                '        final targetRecords = <Map<String, Object?>>[];',
              )
              ..writeln('        for (final selector in nested.set!) {')
              ..writeln(
                '          final related = await tx.$targetDelegateName._delegate.findUnique(',
              )
              ..writeln('            FindUniqueQuery(')
              ..writeln(
                '              model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('              where: selector.toPredicates(),')
              ..writeln('            ),')
              ..writeln('          );')
              ..writeln('          if (related == null) {')
              ..writeln(
                '            throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested set on ${model.name}.${relationField.name}.')});',
              )
              ..writeln('          }')
              ..writeln('          targetRecords.add(related);')
              ..writeln('        }')
              ..writeln(
                '        for (final current in currentRelatedRecords) {',
              )
              ..writeln(
                '          final stillIncluded = targetRecords.any((target) {',
              );

            for (
              var index = 0;
              index < effectiveTargetPrimaryKeyFields.length;
              index++
            ) {
              final field = effectiveTargetPrimaryKeyFields[index];
              final prefix = index == 0
                  ? '            return '
                  : '                && ';
              buffer.writeln(
                "${prefix}current[${_stringLiteral(field.name)}] == target[${_stringLiteral(field.name)}]",
              );
            }

            buffer
              ..writeln('          ;')
              ..writeln('          });')
              ..writeln('          if (!stillIncluded) {')
              ..writeln(
                '            throw StateError(${_stringLiteral('Nested set is not supported for required relation ${model.name}.${relationField.name} when it would disconnect already attached required related records.')});',
              )
              ..writeln('          }')
              ..writeln('        }')
              ..writeln('        for (final related in targetRecords) {')
              ..writeln(
                '          await tx.$targetDelegateName._delegate.update(',
              )
              ..writeln('            UpdateQuery(')
              ..writeln(
                '              model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln(
                '              where: tx.$targetDelegateName._primaryKeyWhereUniqueFromRecord(related).toPredicates(),',
              )
              ..writeln('              data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
              );
            }

            buffer
              ..writeln('              },')
              ..writeln('            ),')
              ..writeln('          );')
              ..writeln('        }')
              ..writeln('      }');
          }

          buffer
            ..writeln('      for (final selector in nested.connect) {')
            ..writeln('        await tx.$targetDelegateName._delegate.update(')
            ..writeln('          UpdateQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: selector.toPredicates(),')
            ..writeln('            data: <String, Object?>{');

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '              ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
            );
          }

          buffer
            ..writeln('            },')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('      }');

          buffer
            ..writeln('      for (final entry in nested.connectOrCreate) {')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: entry.where.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        if (related == null) {')
            ..writeln(
              '          await tx.$targetDelegateName._delegate.create(',
            )
            ..writeln('            CreateQuery(')
            ..writeln(
              '              model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln(
              '              data: <String, Object?>{...entry.create.toData(),',
            );

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '                ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
            );
          }

          buffer
            ..writeln('              },')
            ..writeln(
              '              nestedCreates: entry.create.toNestedCreates(),',
            )
            ..writeln('            ),')
            ..writeln('          );')
            ..writeln('        } else {')
            ..writeln(
              '          await tx.$targetDelegateName._delegate.update(',
            )
            ..writeln('            UpdateQuery(')
            ..writeln(
              '              model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln('              where: entry.where.toPredicates(),')
            ..writeln('              data: <String, Object?>{');

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '                ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
            );
          }

          buffer
            ..writeln('              },')
            ..writeln('            ),')
            ..writeln('          );')
            ..writeln('        }')
            ..writeln('      }');

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('      for (final selector in nested.disconnect) {')
              ..writeln(
                '        await tx.$targetDelegateName._delegate.update(',
              )
              ..writeln('          UpdateQuery(')
              ..writeln(
                '            model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('            where: selector.toPredicates(),')
              ..writeln('            data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '              ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('            },')
              ..writeln('          ),')
              ..writeln('        );')
              ..writeln('      }');
          } else {
            buffer
              ..writeln('      for (final selector in nested.disconnect) {')
              ..writeln(
                '        final related = await tx.$targetDelegateName._delegate.findUnique(',
              )
              ..writeln('          FindUniqueQuery(')
              ..writeln(
                '            model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('            where: selector.toPredicates(),')
              ..writeln('          ),')
              ..writeln('        );')
              ..writeln('        if (related == null) {')
              ..writeln(
                '          throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested disconnect on ${model.name}.${relationField.name}.')});',
              )
              ..writeln('        }')
              ..writeln(
                '        final isCurrentlyAttached = currentRelatedRecords.any((current) {',
              );

            for (
              var index = 0;
              index < effectiveTargetPrimaryKeyFields.length;
              index++
            ) {
              final field = effectiveTargetPrimaryKeyFields[index];
              final prefix = index == 0
                  ? '          return '
                  : '              && ';
              buffer.writeln(
                "${prefix}current[${_stringLiteral(field.name)}] == related[${_stringLiteral(field.name)}]",
              );
            }

            buffer
              ..writeln('        ;')
              ..writeln('        });')
              ..writeln('        if (isCurrentlyAttached) {')
              ..writeln(
                '          throw StateError(${_stringLiteral('Nested disconnect is not supported for required relation ${model.name}.${relationField.name} when it would disconnect already attached required related records.')});',
              )
              ..writeln('        }')
              ..writeln('      }');
          }
        } else if (_relationOwnsForeignKey(relationField)) {
          final foreignKeyFields = _owningRelationForeignKeyFieldNames(
            schema,
            model,
            relationField,
          );
          final referenceFields = _owningRelationReferenceFieldNames(
            schema,
            model,
            relationField,
          );
          final relationContext =
              'nested direct relation write on ${model.name}.${relationField.name}';

          buffer
            ..writeln('      final nestedWriteCount =')
            ..writeln('          (nested.connect != null ? 1 : 0) +')
            ..writeln('          (nested.connectOrCreate != null ? 1 : 0) +')
            ..writeln('          (nested.disconnect ? 1 : 0);')
            ..writeln('      if (nestedWriteCount > 1) {')
            ..writeln(
              '        throw StateError(${_stringLiteral('Only one of connect, connectOrCreate or disconnect may be provided for $updateInputName.${relationField.name}.')});',
            )
            ..writeln('      }')
            ..writeln('      if (nested.connect != null) {')
            ..writeln('        final selector = nested.connect!;')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: selector.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        if (related == null) {')
            ..writeln(
              '          throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested connect on ${model.name}.${relationField.name}.')});',
            )
            ..writeln('        }')
            ..writeln(
              '        await tx._client.model(${_stringLiteral(model.name)}).update(',
            )
            ..writeln('          UpdateQuery(')
            ..writeln('            model: ${_stringLiteral(model.name)},')
            ..writeln('            where: predicates,')
            ..writeln('            data: <String, Object?>{');

          for (var index = 0; index < foreignKeyFields.length; index++) {
            buffer.writeln(
              '              ${_stringLiteral(foreignKeyFields[index])}: _requireRecordValue(related, ${_stringLiteral(referenceFields[index])}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('            },')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('      }');

          buffer
            ..writeln('      if (nested.connectOrCreate != null) {')
            ..writeln('        final entry = nested.connectOrCreate!;')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: entry.where.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        final relatedRecord = related ??')
            ..writeln(
              '            await tx.$targetDelegateName._delegate.create(',
            )
            ..writeln('              CreateQuery(')
            ..writeln(
              '                model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln('                data: entry.create.toData(),')
            ..writeln(
              '                nestedCreates: entry.create.toNestedCreates(),',
            )
            ..writeln('              ),')
            ..writeln('            );')
            ..writeln(
              '        await tx._client.model(${_stringLiteral(model.name)}).update(',
            )
            ..writeln('          UpdateQuery(')
            ..writeln('            model: ${_stringLiteral(model.name)},')
            ..writeln('            where: predicates,')
            ..writeln('            data: <String, Object?>{');

          for (var index = 0; index < foreignKeyFields.length; index++) {
            buffer.writeln(
              '              ${_stringLiteral(foreignKeyFields[index])}: _requireRecordValue(relatedRecord, ${_stringLiteral(referenceFields[index])}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('            },')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('      }');

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('      if (nested.disconnect) {')
              ..writeln(
                '        await tx._client.model(${_stringLiteral(model.name)}).update(',
              )
              ..writeln('          UpdateQuery(')
              ..writeln('            model: ${_stringLiteral(model.name)},')
              ..writeln('            where: predicates,')
              ..writeln('            data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '              ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('            },')
              ..writeln('          ),')
              ..writeln('        );')
              ..writeln('      }');
          } else {
            buffer
              ..writeln('      if (nested.disconnect) {')
              ..writeln(
                '        throw StateError(${_stringLiteral('Nested disconnect is not supported for required relation ${model.name}.${relationField.name}.')});',
              )
              ..writeln('      }');
          }
        } else {
          final foreignKeyFields = _owningRelationForeignKeyFieldNames(
            schema,
            model,
            relationField,
          );
          final referenceFields = _owningRelationReferenceFieldNames(
            schema,
            model,
            relationField,
          );
          final relationContext =
              'nested inverse one-to-one relation write on ${model.name}.${relationField.name}';
          final foreignKeyFieldLabel = foreignKeyFields.join(', ');

          buffer.writeln(
            '      final parentReferenceValues = <String, Object?>{',
          );

          for (var index = 0; index < foreignKeyFields.length; index++) {
            buffer.writeln(
              '        ${_stringLiteral(foreignKeyFields[index])}: _requireRecordValue(existing, ${_stringLiteral(referenceFields[index])}, ${_stringLiteral(relationContext)}),',
            );
          }

          buffer
            ..writeln('      };')
            ..writeln(
              '      final currentRelated = await tx.$targetDelegateName._delegate.findFirst(',
            )
            ..writeln('        FindFirstQuery(')
            ..writeln('          model: ${_stringLiteral(targetModel.name)},')
            ..writeln('          where: <QueryPredicate>[');

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '            QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
            );
          }

          buffer
            ..writeln('          ],')
            ..writeln('        ),')
            ..writeln('      );')
            ..writeln('      final nestedWriteCount =')
            ..writeln('          (nested.connect != null ? 1 : 0) +')
            ..writeln('          (nested.connectOrCreate != null ? 1 : 0) +')
            ..writeln('          (nested.disconnect ? 1 : 0);')
            ..writeln('      if (nestedWriteCount > 1) {')
            ..writeln(
              '        throw StateError(${_stringLiteral('Only one of connect, connectOrCreate or disconnect may be provided for $updateInputName.${relationField.name}.')});',
            )
            ..writeln('      }')
            ..writeln('      if (nested.connect != null) {')
            ..writeln('        final selector = nested.connect!;')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: selector.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        if (related == null) {')
            ..writeln(
              '          throw StateError(${_stringLiteral('No related ${targetModel.name} record found for nested connect on inverse one-to-one relation ${model.name}.${relationField.name}.')});',
            )
            ..writeln('        }')
            ..writeln('        final alreadyConnected =');

          for (var index = 0; index < foreignKeyFields.length; index++) {
            final foreignKeyField = foreignKeyFields[index];
            final prefix = index == 0 ? '            ' : '            && ';
            buffer.writeln(
              "${prefix}related[${_stringLiteral(foreignKeyField)}] == parentReferenceValues[${_stringLiteral(foreignKeyField)}]",
            );
          }

          buffer.writeln('        ;');
          buffer.writeln('        if (!alreadyConnected) {');

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('          if (currentRelated != null) {')
              ..writeln(
                '            await tx.$targetDelegateName._delegate.updateMany(',
              )
              ..writeln('              UpdateManyQuery(')
              ..writeln(
                '                model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('                where: <QueryPredicate>[');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                  QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
              );
            }

            buffer
              ..writeln('                ],')
              ..writeln('                data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                  ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('                },')
              ..writeln('              ),')
              ..writeln('            );')
              ..writeln('          }');
          } else {
            buffer
              ..writeln('          if (currentRelated != null) {')
              ..writeln(
                '            throw StateError(${_stringLiteral('Nested connect cannot replace the existing inverse one-to-one relation ${model.name}.${relationField.name} because ${targetModel.name}.$foreignKeyFieldLabel is required.')});',
              )
              ..writeln('          }');
          }

          buffer
            ..writeln(
              '          await tx.$targetDelegateName._delegate.update(',
            )
            ..writeln('            UpdateQuery(')
            ..writeln(
              '              model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln('              where: selector.toPredicates(),')
            ..writeln('              data: <String, Object?>{');

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '                ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
            );
          }

          buffer
            ..writeln('              },')
            ..writeln('            ),')
            ..writeln('          );')
            ..writeln('        }')
            ..writeln('      }')
            ..writeln('      if (nested.connectOrCreate != null) {')
            ..writeln('        final entry = nested.connectOrCreate!;')
            ..writeln(
              '        final related = await tx.$targetDelegateName._delegate.findUnique(',
            )
            ..writeln('          FindUniqueQuery(')
            ..writeln('            model: ${_stringLiteral(targetModel.name)},')
            ..writeln('            where: entry.where.toPredicates(),')
            ..writeln('          ),')
            ..writeln('        );')
            ..writeln('        if (related != null) {')
            ..writeln('          final alreadyConnected =');

          for (var index = 0; index < foreignKeyFields.length; index++) {
            final foreignKeyField = foreignKeyFields[index];
            final prefix = index == 0 ? '              ' : '              && ';
            buffer.writeln(
              "${prefix}related[${_stringLiteral(foreignKeyField)}] == parentReferenceValues[${_stringLiteral(foreignKeyField)}]",
            );
          }

          buffer.writeln('          ;');
          buffer.writeln('          if (!alreadyConnected) {');

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('            if (currentRelated != null) {')
              ..writeln(
                '              await tx.$targetDelegateName._delegate.updateMany(',
              )
              ..writeln('                UpdateManyQuery(')
              ..writeln(
                '                  model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('                  where: <QueryPredicate>[');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                    QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
              );
            }

            buffer
              ..writeln('                  ],')
              ..writeln('                  data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                    ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('                  },')
              ..writeln('                ),')
              ..writeln('              );')
              ..writeln('            }');
          } else {
            buffer
              ..writeln('            if (currentRelated != null) {')
              ..writeln(
                '              throw StateError(${_stringLiteral('Nested connectOrCreate cannot replace the existing inverse one-to-one relation ${model.name}.${relationField.name} because ${targetModel.name}.$foreignKeyFieldLabel is required.')});',
              )
              ..writeln('            }');
          }

          buffer
            ..writeln(
              '            await tx.$targetDelegateName._delegate.update(',
            )
            ..writeln('              UpdateQuery(')
            ..writeln(
              '                model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln('                where: entry.where.toPredicates(),')
            ..writeln('                data: <String, Object?>{');

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '                  ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
            );
          }

          buffer
            ..writeln('                },')
            ..writeln('              ),')
            ..writeln('            );')
            ..writeln('          }')
            ..writeln('        } else {');

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('          if (currentRelated != null) {')
              ..writeln(
                '            await tx.$targetDelegateName._delegate.updateMany(',
              )
              ..writeln('              UpdateManyQuery(')
              ..writeln(
                '                model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('                where: <QueryPredicate>[');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                  QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
              );
            }

            buffer
              ..writeln('                ],')
              ..writeln('                data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '                  ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('                },')
              ..writeln('              ),')
              ..writeln('            );')
              ..writeln('          }');
          } else {
            buffer
              ..writeln('          if (currentRelated != null) {')
              ..writeln(
                '            throw StateError(${_stringLiteral('Nested connectOrCreate cannot create a new inverse one-to-one relation ${model.name}.${relationField.name} because ${targetModel.name}.$foreignKeyFieldLabel is required and already attached.')});',
              )
              ..writeln('          }');
          }

          buffer
            ..writeln(
              '          await tx.$targetDelegateName._delegate.create(',
            )
            ..writeln('            CreateQuery(')
            ..writeln(
              '              model: ${_stringLiteral(targetModel.name)},',
            )
            ..writeln(
              '              data: <String, Object?>{...entry.create.toData(),',
            );

          for (final foreignKeyField in foreignKeyFields) {
            buffer.writeln(
              '                ${_stringLiteral(foreignKeyField)}: parentReferenceValues[${_stringLiteral(foreignKeyField)}],',
            );
          }

          buffer
            ..writeln('              },')
            ..writeln(
              '              nestedCreates: entry.create.toNestedCreates(),',
            )
            ..writeln('            ),')
            ..writeln('          );')
            ..writeln('        }')
            ..writeln('      }');

          if (_relationSupportsDisconnect(schema, model, relationField)) {
            buffer
              ..writeln('      if (nested.disconnect) {')
              ..writeln(
                '        await tx.$targetDelegateName._delegate.updateMany(',
              )
              ..writeln('          UpdateManyQuery(')
              ..writeln(
                '            model: ${_stringLiteral(targetModel.name)},',
              )
              ..writeln('            where: <QueryPredicate>[');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '              QueryPredicate(field: ${_stringLiteral(foreignKeyField)}, operator: ${_stringLiteral('equals')}, value: parentReferenceValues[${_stringLiteral(foreignKeyField)}]),',
              );
            }

            buffer
              ..writeln('            ],')
              ..writeln('            data: <String, Object?>{');

            for (final foreignKeyField in foreignKeyFields) {
              buffer.writeln(
                '              ${_stringLiteral(foreignKeyField)}: null,',
              );
            }

            buffer
              ..writeln('            },')
              ..writeln('          ),')
              ..writeln('        );')
              ..writeln('      }');
          } else {
            buffer
              ..writeln('      if (nested.disconnect) {')
              ..writeln('        if (currentRelated != null) {')
              ..writeln(
                '        throw StateError(${_stringLiteral('Nested disconnect is not supported for required inverse one-to-one relation ${model.name}.${relationField.name}.')});',
              )
              ..writeln('        }')
              ..writeln('      }');
          }
        }

        buffer.writeln('    }');
      }
    }

    buffer
      ..writeln('  }')
      ..writeln()
      ..writeln()
      ..writeln('  Future<$modelClassName> delete({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.delete(')
      ..writeln('      DeleteQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('      ),')
      ..writeln('    ).then($modelClassName.fromRecord);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> deleteMany({')
      ..writeln('    required $whereInputName where,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.deleteMany(')
      ..writeln('      DeleteManyQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }
}
