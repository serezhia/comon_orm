import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('ClientGenerator', () {
    test('emits typed client, delegates, inputs and nested create helpers', () {
      const source = '''
model User {
  id           Int    @id @default(autoincrement())
  name         String
  email        String @unique
  country      String?
  profileViews Int?
  posts        Post[]
}

model Post {
  id        Int     @id @default(autoincrement())
  title     String
  content   String?
  published Boolean @default(false)
  userId    Int
  user      User    @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(output, contains('class GeneratedComonOrmClient {'));
      expect(
        output,
        contains(
          'static const GeneratedRuntimeSchema runtimeSchema = GeneratedComonOrmMetadata.schema;',
        ),
      );
      expect(
        output,
        contains('static final RuntimeSchemaView runtimeSchemaView ='),
      );
      expect(
        output,
        contains('static InMemoryDatabaseAdapter createInMemoryAdapter() {'),
      );
      expect(
        output,
        contains('factory GeneratedComonOrmClient.openInMemory() {'),
      );
      expect(output, isNot(contains('class GeneratedComonOrmClientSqlite {')));
      expect(
        output,
        isNot(contains('class GeneratedComonOrmClientPostgresql {')),
      );
      expect(output, contains('Future<void> close() async {'));
      expect(output, contains('class GeneratedComonOrmMetadata {'));
      expect(
        output,
        contains('late final UserDelegate user = UserDelegate._(_client);'),
      );
      expect(output, contains('class UserDelegate {'));
      expect(output, contains('class User {'));
      expect(
        output,
        contains('factory User.fromRecord(Map<String, Object?> record) {'),
      );
      expect(
        output,
        contains('factory User.fromJson(Map<String, Object?> json) {'),
      );
      expect(output, contains('User copyWith({'));
      expect(output, contains('Map<String, Object?> toJson() {'));
      expect(output, contains('bool operator ==(Object other) {'));
      expect(output, contains('int get hashCode => Object.hashAll(<Object?>['));
      expect(output, contains("String toString() => 'User("));
      expect(output, contains('class UserWhereInput {'));
      expect(output, contains('class UserWhereUniqueInput {'));
      expect(output, contains('class UserOrderByInput {'));
      expect(output, contains('final List<UserWhereInput> AND;'));
      expect(output, contains('final List<UserWhereInput> OR;'));
      expect(output, contains('final List<UserWhereInput> NOT;'));
      expect(output, contains('final StringFilter? emailFilter;'));
      expect(output, contains('final IntFilter? idFilter;'));
      expect(output, contains('final PostWhereInput? postsSome;'));
      expect(output, contains('final PostWhereInput? postsNone;'));
      expect(output, contains('final PostWhereInput? postsEvery;'));
      expect(output, contains('final UserWhereInput? userIs;'));
      expect(output, contains('final UserWhereInput? userIsNot;'));
      expect(output, contains("operator: 'logicalAnd'"));
      expect(output, contains("operator: 'logicalOr'"));
      expect(output, contains("operator: 'logicalNot'"));
      expect(output, contains("operator: 'relationSome'"));
      expect(output, contains("operator: 'relationNone'"));
      expect(output, contains("operator: 'relationEvery'"));
      expect(output, contains("operator: 'relationIs'"));
      expect(output, contains("operator: 'relationIsNot'"));
      expect(output, contains('class UserCreateInput {'));
      expect(output, contains('class UserUpdateInput {'));
      expect(output, contains('class PostCreateNestedManyWithoutUserInput {'));
      expect(output, contains('class PostCreateWithoutUserInput {'));
      expect(
        output,
        contains(
          'const PostCreateNestedManyWithoutUserInput({this.create = const <PostCreateWithoutUserInput>[], this.connect = const <PostWhereUniqueInput>[], this.disconnect = const <PostWhereUniqueInput>[], this.connectOrCreate = const <PostConnectOrCreateWithoutUserInput>[], this.set});',
        ),
      );
      expect(
        output,
        contains(
          'const UserCreateNestedOneWithoutPostsInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});',
        ),
      );
      expect(output, contains('class PostConnectOrCreateWithoutUserInput {'));
      expect(output, contains('class UserConnectOrCreateWithoutPostsInput {'));
      expect(output, contains('class PostUpdateNestedManyWithoutUserInput {'));
      expect(output, contains('class UserUpdateNestedOneWithoutPostsInput {'));
      expect(output, contains('final List<PostWhereUniqueInput> disconnect;'));
      expect(
        output,
        contains(
          'final List<PostConnectOrCreateWithoutUserInput> connectOrCreate;',
        ),
      );
      expect(output, contains('final List<PostWhereUniqueInput>? set;'));
      expect(
        output,
        contains(
          'return PostUpdateNestedManyWithoutUserInput(connect: connect, disconnect: disconnect, connectOrCreate: connectOrCreate, set: set);',
        ),
      );
      expect(output, contains('final List<PostWhereUniqueInput> connect;'));
      expect(
        output,
        contains(
          'final UserConnectOrCreateWithoutPostsInput? connectOrCreate;',
        ),
      );
      expect(output, contains('final bool disconnect;'));
      expect(output, contains('final List<PostWhereUniqueInput>? set;'));
      expect(
        output,
        contains(
          'return UserUpdateNestedOneWithoutPostsInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);',
        ),
      );
      expect(
        output,
        contains('final PostUpdateNestedManyWithoutUserInput? posts;'),
      );
      expect(
        output,
        contains('final UserUpdateNestedOneWithoutPostsInput? user;'),
      );
      expect(output, contains('bool get hasRelationWrites {'));
      expect(output, contains('Future<User?> findUnique({'));
      expect(output, contains('required UserWhereUniqueInput where,'));
      expect(output, contains('Future<User?> findFirst({'));
      expect(output, contains('UserWhereUniqueInput? cursor,'));
      expect(output, contains('List<UserOrderByInput>? orderBy,'));
      expect(output, contains('List<UserScalarField>? distinct,'));
      expect(
        output,
        contains(
          'final queryDistinct = distinct?.map((field) => field.name).toSet()',
        ),
      );
      expect(output, contains('if (cursor != null) {'));
      expect(output, contains('final records = await _findManyWithCursor('));
      expect(output, contains('distinct: queryDistinct,'));
      expect(output, contains('take: 1,'));
      expect(output, contains('Future<int> count({'));
      expect(output, contains('Future<User> create({'));
      expect(output, contains('Future<int> createMany({'));
      expect(output, contains('required List<UserCreateInput> data,'));
      expect(output, contains('bool skipDuplicates = false,'));
      expect(
        output,
        contains('if (skipDuplicates && _isSkippableDuplicateError(error)) {'),
      );
      expect(
        output,
        contains('bool _isSkippableDuplicateError(Object error) {'),
      );
      expect(output, contains("if (code == '23505') {"));
      expect(output, contains('Object? _requireRecordValue('));
      expect(output, contains('return Future<int>.value(0);'));
      expect(
        output,
        contains('List<List<QueryPredicate>> toUniqueSelectorPredicates() {'),
      );
      expect(
        output,
        contains(
          'for (final selector in entry.toUniqueSelectorPredicates()) {',
        ),
      );
      expect(output, contains('class IntFieldUpdateOperationsInput {'));
      expect(output, contains('class StringFieldUpdateOperationsInput {'));
      expect(
        output,
        contains('final IntFieldUpdateOperationsInput? profileViewsOps;'),
      );
      expect(
        output,
        contains(
          'Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {',
        ),
      );
      expect(output, contains('data.hasComputedOperators'));
      expect(output, contains('Future<User> update({'));
      expect(output, contains('Future<User> upsert({'));
      expect(output, contains('return _client.transaction((txClient) async {'));
      expect(output, contains('final predicates = where.toPredicates();'));
      expect(
        output,
        contains('final tx = GeneratedComonOrmClient._fromClient(txClient);'),
      );
      expect(
        output,
        contains('if (data.hasComputedOperators || data.hasRelationWrites) {'),
      );
      expect(output, contains('Future<void> _applyNestedRelationWrites({'));
      expect(output, contains('await _performUpdateWithRelationWrites('));
      expect(
        output,
        contains(
          'Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.posts.',
        ),
      );
      expect(output, contains('Future<int> updateMany({'));
      expect(output, contains('Future<User> delete({'));
      expect(output, contains('Future<int> deleteMany({'));
      expect(output, contains('List<UserScalarField>? distinct,'));
      expect(output, contains('Future<UserAggregateResult> aggregate({'));
      expect(output, contains('Future<List<UserGroupByRow>> groupBy({'));
      expect(output, contains('bool get hasDeferredRelationWrites {'));
      expect(
        output,
        contains('UserUpdateInput toDeferredRelationUpdateInput() {'),
      );
      expect(output, contains('enum UserScalarField {'));
      expect(output, contains('class UserCountAggregateInput {'));
      expect(output, contains('class UserAggregateResult {'));
      expect(output, contains('class UserGroupByOrderByInput {'));
      expect(output, contains('class UserGroupByRow {'));
      expect(
        output,
        contains(
          'final queryDistinct = distinct?.map((field) => field.name).toSet()',
        ),
      );
      expect(output, contains('distinct: queryDistinct,'));
      expect(output, contains('GroupByQuery('));
      expect(output, contains('AggregateQuery('));
      expect(
        output,
        contains('orderBy?.expand((entry) => entry.toQueryOrderBy())'),
      );
      expect(output, contains('CreateQuery('));
      expect(output, contains('nestedCreates: data.toNestedCreates(),'));
      expect(
        output,
        contains('Future<User> _performCreateWithRelationWrites({'),
      );
      expect(
        output,
        contains(
          'Exactly one unique selector must be provided for UserWhereUniqueInput.',
        ),
      );
      expect(
        output,
        contains('bool matchesRecord(Map<String, Object?> record) {'),
      );
      expect(output, contains('return _findManyWithCursor('));
      expect(output, contains('Future<List<User>> _findManyWithCursor({'));
      expect(output, contains('final effectiveSkip = skip ?? 0;'));
      expect(output, contains('} else if (take >= 0) {'));
      expect(
        output,
        contains('final endExclusive = cursorIndex + 1 - effectiveSkip;'),
      );
      expect(
        output,
        contains('_primaryKeyWhereUniqueFromRecord(record).toPredicates()'),
      );
    });

    test('emits compiled runtime metadata for datasources enums and relations', () {
      const source = '''
datasource db {
  provider = "sqlite"
  url = env("DATABASE_URL")
}

enum UserRole {
  admin
  member

  @@map("user_role")
}

model User {
  id     Int      @id @default(autoincrement())
  role   UserRole
  posts  Post[]   @relation("UserPosts")
  groups Group[]

  @@map("users")
}

model Post {
  id       Int  @id
  authorId Int
  author   User @relation("UserPosts", fields: [authorId], references: [id])
}

model Group {
  id    Int    @id
  users User[]
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains(
          'static const GeneratedRuntimeSchema schema = GeneratedRuntimeSchema(',
        ),
      );
      expect(output, contains('GeneratedDatasourceMetadata('));
      expect(
        output,
        contains(
          'GeneratedDatasourceUrl(kind: GeneratedDatasourceUrlKind.env, value: \'DATABASE_URL\')',
        ),
      );
      expect(
        output,
        contains("import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';"),
      );
      expect(output, contains('class GeneratedComonOrmClientSqlite {'));
      expect(output, contains('static Future<GeneratedComonOrmClient> open({'));
      expect(output, isNot(contains('String schemaPath = \'schema.prisma\'')));
      expect(
        output,
        contains(
          'final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(',
        ),
      );
      expect(output, isNot(contains('schemaPath: schemaPath,')));
      expect(output, contains('GeneratedEnumMetadata('));
      expect(output, contains('databaseName: \'user_role\''));
      expect(output, contains('GeneratedModelMetadata('));
      expect(output, contains('databaseName: \'users\''));
      expect(output, contains('GeneratedFieldMetadata('));
      expect(output, contains('kind: GeneratedRuntimeFieldKind.enumeration'));
      expect(output, contains('GeneratedRelationMetadata('));
      expect(
        output,
        contains('storageKind: GeneratedRuntimeRelationStorageKind.direct'),
      );
      expect(
        output,
        contains(
          'storageKind: GeneratedRuntimeRelationStorageKind.implicitManyToMany',
        ),
      );
      expect(output, contains('storageTableName: \'_comon_orm_m2m__'));
    });

    test('emits compound unique input helpers for compound selectors', () {
      const source = '''
model Membership {
  tenantId Int
  slug     String
  role     String
  email    String @unique

  @@id([tenantId, slug])
  @@unique([tenantId, role])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(output, contains('class MembershipWhereUniqueInput {'));
      expect(output, contains('final String? email;'));
      expect(
        output,
        contains(
          'final MembershipTenantIdSlugCompoundUniqueInput? tenantId_slug;',
        ),
      );
      expect(
        output,
        contains(
          'final MembershipTenantIdRoleCompoundUniqueInput? tenantId_role;',
        ),
      );
      expect(
        output,
        contains('class MembershipTenantIdSlugCompoundUniqueInput {'),
      );
      expect(
        output,
        contains('class MembershipTenantIdRoleCompoundUniqueInput {'),
      );
    });

    test('emits postgresql generated client helper for postgresql schemas', () {
      const source = '''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains(
          "import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';",
        ),
      );
      expect(output, contains('class GeneratedComonOrmClientPostgresql {'));
      expect(
        output,
        contains(
          'final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(',
        ),
      );
      expect(output, isNot(contains('String schemaPath = \'schema.prisma\'')));
      expect(output, isNot(contains('schemaPath: schemaPath,')));
    });

    test('emits flutter sqlite generated client helper when configured', () {
      const source = '''
datasource db {
  provider = "sqlite"
  url = "file:app.db"
}

model Todo {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator(
        options: ClientGeneratorOptions(
          sqliteHelperKind: SqliteClientHelperKind.flutter,
        ),
      ).generateClient(schema);

      expect(
        output,
        contains(
          "import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';",
        ),
      );
      expect(output, contains('class GeneratedComonOrmClientFlutterSqlite {'));
      expect(output, isNot(contains('class GeneratedComonOrmClientSqlite {')));
      expect(output, contains('DatabaseFactory? databaseFactory,'));
      expect(
        output,
        contains(
          'final adapter = await SqliteFlutterDatabaseAdapter.openFromGeneratedSchema(',
        ),
      );
      expect(output, isNot(contains('schemaPath: schemaPath,')));
    });

    test('emits Dart enums and enum-aware model fields', () {
      const source = '''
enum TodoStatus {
  pending
  done
}

model Todo {
  id     Int        @id
  title  String
  status TodoStatus
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(output, contains('enum TodoStatus {'));
      expect(output, contains('final TodoStatus? status;'));
      expect(
        output,
        contains(
          'status: record[\'status\'] == null ? null : TodoStatus.values.byName(record[\'status\'] as String),',
        ),
      );
      expect(output, contains('data[\'status\'] = _enumName(status);'));
      expect(output, contains('value: _enumName(status)'));
    });

    test('emits copyWith, equality and json helpers for models', () {
      const source = '''
model Asset {
  id        Int      @id
  createdAt DateTime
  bytes     Bytes
  amount    BigInt
  metadata  Json
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains('factory Asset.fromJson(Map<String, Object?> json) {'),
      );
      expect(output, contains('Asset copyWith({'));
      expect(output, contains("createdAt: _asDateTime(json['createdAt']),"));
      expect(output, contains("bytes: _asBytes(json['bytes']),"));
      expect(output, contains("amount: _asBigInt(json['amount']),"));
      expect(
        output,
        contains("json['createdAt'] = createdAt!.toIso8601String();"),
      );
      expect(output, contains("json['amount'] = amount!.toString();"));
      expect(output, contains("json['metadata'] = _jsonEncodable(metadata);"));
      expect(output, contains('bool operator ==(Object other) {'));
      expect(output, contains('int get hashCode => Object.hashAll(<Object?>['));
      expect(output, contains("String toString() => 'Asset("));
      expect(output, contains('class _Undefined {'));
      expect(
        output,
        contains('bool _deepEquals(Object? left, Object? right) {'),
      );
      expect(output, contains('Object? _jsonEncodable(Object? value) {'));
    });

    test('treats updatedAt field as optional in create input', () {
      const source = '''
model User {
  id        Int      @id
  name      String
  updatedAt DateTime @updatedAt
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(output, contains('class UserCreateInput {'));
      expect(output, contains('this.updatedAt,'));
      expect(output, contains('final DateTime? updatedAt;'));
      expect(output, isNot(contains('required this.updatedAt')));
    });

    test('resolves opposite relation fields for named multiple relations', () {
      const source = '''
model User {
  id            Int    @id
  writtenPosts  Post[] @relation("WrittenPosts")
  reviewedPosts Post[] @relation("ReviewedPosts")
}

model Post {
  id          Int  @id
  title       String
  authorId    Int
  reviewerId  Int
  author      User @relation("WrittenPosts", fields: [authorId], references: [id])
  reviewer    User @relation("ReviewedPosts", fields: [reviewerId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains('class PostCreateNestedManyWithoutAuthorInput {'),
      );
      expect(
        output,
        contains('class PostCreateNestedManyWithoutReviewerInput {'),
      );
      expect(output, contains('class PostCreateWithoutAuthorInput {'));
      expect(output, contains('class PostCreateWithoutReviewerInput {'));
    });

    test(
      'resolves opposite relation fields when only one side declares relation name',
      () {
        const source = '''
model User {
  id    Int    @id
  posts Post[] @relation("Posts")
}

model Post {
  id     Int  @id
  title  String
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

        final schema = const SchemaParser().parse(source);
        final output = const ClientGenerator().generateClient(schema);

        expect(
          output,
          contains('class PostCreateNestedManyWithoutUserInput {'),
        );
        expect(output, contains('class PostCreateWithoutUserInput {'));
        expect(
          output,
          contains('class UserCreateNestedOneWithoutPostsInput {'),
        );
        expect(output, contains('class UserCreateWithoutPostsInput {'));
      },
    );

    test('resolves opposite relation fields for named self relations', () {
      const source = '''
model User {
  id         Int    @id
  managerId  Int?
  mentorId   Int?
  manager    User?  @relation("ManagerChain", fields: [managerId], references: [id])
  reports    User[] @relation("ManagerChain")
  mentor     User?  @relation("MentorChain", fields: [mentorId], references: [id])
  mentees    User[] @relation("MentorChain")
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains('class UserCreateNestedOneWithoutReportsInput {'),
      );
      expect(
        output,
        contains('class UserUpdateNestedOneWithoutReportsInput {'),
      );
      expect(
        output,
        contains('class UserCreateNestedManyWithoutManagerInput {'),
      );
      expect(
        output,
        contains('class UserUpdateNestedManyWithoutManagerInput {'),
      );
      expect(
        output,
        contains('class UserCreateNestedOneWithoutMenteesInput {'),
      );
      expect(
        output,
        contains('class UserUpdateNestedOneWithoutMenteesInput {'),
      );
      expect(
        output,
        contains('class UserCreateNestedManyWithoutMentorInput {'),
      );
      expect(
        output,
        contains('class UserUpdateNestedManyWithoutMentorInput {'),
      );
      expect(output, contains('class UserCreateWithoutReportsInput {'));
      expect(output, contains('class UserCreateWithoutManagerInput {'));
      expect(output, contains('class UserCreateWithoutMenteesInput {'));
      expect(output, contains('class UserCreateWithoutMentorInput {'));
      expect(
        output,
        contains(
          "QueryRelation(field: 'manager', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'managerId', targetKeyField: 'id', localKeyFields: const <String>['managerId'], targetKeyFields: const <String>['id'])",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'reports', targetModel: 'User', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'managerId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['managerId'])",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'mentor', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'mentorId', targetKeyField: 'id', localKeyFields: const <String>['mentorId'], targetKeyFields: const <String>['id'])",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'mentees', targetModel: 'User', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'mentorId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['mentorId'])",
        ),
      );
    });

    test('emits inverse one-to-one nested update handling', () {
      const source = '''
model User {
  id      Int      @id
  profile Profile?
}

model Profile {
  id     Int   @id
  userId Int?  @unique
  user   User? @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains('class ProfileUpdateNestedOneWithoutUserInput {'),
      );
      expect(
        output,
        contains(
          'Only one of connect, connectOrCreate or disconnect may be provided for UserUpdateInput.profile.',
        ),
      );
      expect(
        output,
        contains(
          'final currentRelated = await tx.profile._delegate.findFirst(',
        ),
      );
      expect(
        output,
        contains(
          "QueryPredicate(field: 'userId', operator: 'equals', value: parentReferenceValues['userId'])",
        ),
      );
      expect(
        output,
        isNot(
          contains(
            'Nested relation writes are not supported for inverse one-to-one relation User.profile yet.',
          ),
        ),
      );
    });

    test('emits orphan-aware required direct-list handling', () {
      const source = '''
model User {
  id    Int    @id
  posts Post[]
}

model Post {
  id     Int  @id
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains(
          'final currentRelatedRecords = await tx.post._delegate.findMany(',
        ),
      );
      expect(
        output,
        contains(
          'Nested set is not supported for required relation User.posts when it would disconnect already attached required related records.',
        ),
      );
      expect(
        output,
        contains(
          'Nested disconnect is not supported for required relation User.posts when it would disconnect already attached required related records.',
        ),
      );
      expect(
        output,
        isNot(
          contains(
            'Nested set is not supported for required relation User.posts.',
          ),
        ),
      );
    });

    test('emits compound required inverse one-to-one replacement guardrails', () {
      const source = '''
model Account {
  tenantId Int
  slug     String
  profile  AccountProfile?

  @@id([tenantId, slug])
}

model AccountProfile {
  id          Int     @id
  tenantId    Int
  accountSlug String
  account     Account @relation(fields: [tenantId, accountSlug], references: [tenantId, slug])

  @@unique([tenantId, accountSlug])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains(
          'Nested connect cannot replace the existing inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required.',
        ),
      );
      expect(
        output,
        contains(
          'Nested connectOrCreate cannot replace the existing inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required.',
        ),
      );
      expect(
        output,
        contains(
          'Nested connectOrCreate cannot create a new inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required and already attached.',
        ),
      );
    });

    test('emits metadata for implicit many-to-many relations', () {
      const source = '''
model User {
  id   Int    @id
  tags Tag[]
}

model Tag {
  id    Int    @id
  users User[]
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains(
          "QueryRelation(field: 'tags', targetModel: 'Tag', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'id', localKeyFields: const <String>['id'], targetKeyFields: const <String>['id'], storageKind: QueryRelationStorageKind.implicitManyToMany, sourceModel: 'User', inverseField: 'users')",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'users', targetModel: 'User', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'id', localKeyFields: const <String>['id'], targetKeyFields: const <String>['id'], storageKind: QueryRelationStorageKind.implicitManyToMany, sourceModel: 'Tag', inverseField: 'tags')",
        ),
      );
      expect(output, contains('class TagCreateNestedManyWithoutUsersInput {'));
      expect(output, contains('class UserCreateNestedManyWithoutTagsInput {'));
      expect(output, contains('.addImplicitManyToManyLink('));
      expect(output, contains('.removeImplicitManyToManyLinks('));
    });

    test('emits metadata for implicit many-to-many with compound ids', () {
      const source = '''
model User {
  tenantId Int
  slug     String
  tags     Tag[]

  @@id([tenantId, slug])
}

model Tag {
  id    Int    @id
  users User[]
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains(
          "QueryRelation(field: 'tags', targetModel: 'Tag', cardinality: QueryRelationCardinality.many, localKeyField: 'tenantId', targetKeyField: 'id', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['id'], storageKind: QueryRelationStorageKind.implicitManyToMany, sourceModel: 'User', inverseField: 'users')",
        ),
      );
    });

    test('routes updateMany relation writes through per-record updates', () {
      const source = '''
model User {
  id    Int    @id
  posts Post[]
}

model Post {
  id     Int  @id
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains('if (data.hasComputedOperators || data.hasRelationWrites) {'),
      );
      expect(output, contains('await _performUpdateWithRelationWrites('));
      expect(
        output,
        isNot(
          contains('updateMany does not support nested relation writes yet'),
        ),
      );
      expect(
        output,
        isNot(
          contains(
            'Computed scalar update operators are not supported in updateMany',
          ),
        ),
      );
    });

    test('emits compound direct relation nested write handling', () {
      const source = '''
model Account {
  tenantId Int
  slug     String
  sessions Session[]
  profile  Profile?

  @@id([tenantId, slug])
}

model Session {
  id          Int     @id
  tenantId    Int
  accountSlug String
  account     Account @relation(fields: [tenantId, accountSlug], references: [tenantId, slug])
}

model Profile {
  id          Int      @id
  tenantId    Int?
  accountSlug String?
  account     Account? @relation(fields: [tenantId, accountSlug], references: [tenantId, slug])

  @@unique([tenantId, accountSlug])
}
''';

      final schema = const SchemaParser().parse(source);
      final output = const ClientGenerator().generateClient(schema);

      expect(
        output,
        contains("'tenantId': _requireRecordValue(existing, 'tenantId'"),
      );
      expect(
        output,
        contains("'accountSlug': _requireRecordValue(existing, 'slug'"),
      );
      expect(
        output,
        contains("'tenantId': _requireRecordValue(related, 'tenantId'"),
      );
      expect(
        output,
        contains("'accountSlug': _requireRecordValue(related, 'slug'"),
      );
      expect(
        output,
        isNot(
          contains(
            'Only single-field direct relations are supported for nested connect/disconnect',
          ),
        ),
      );
    });

    test('matches checked-in generated client fixtures', () {
      const fixtures = <MapEntry<String, String>>[
        MapEntry(
          'test/generated/_runtime_fixture_schema.prisma',
          'test/generated/comon_orm_client.dart',
        ),
        MapEntry(
          'test/generated/_runtime_rich_parity_schema.prisma',
          'test/generated/runtime_rich_parity_client.dart',
        ),
        MapEntry(
          'test/generated/_runtime_compound_direct_schema.prisma',
          'test/generated/runtime_compound_direct_client.dart',
        ),
        MapEntry(
          'test/generated/_runtime_required_inverse_schema.prisma',
          'test/generated/runtime_required_inverse_client.dart',
        ),
        MapEntry(
          'example/schema.prisma',
          'example/generated/comon_orm_client.dart',
        ),
        MapEntry(
          '../comon_orm_postgresql/example/schema.prisma',
          '../comon_orm_postgresql/example/generated/comon_orm_client.dart',
        ),
        MapEntry(
          '../comon_orm_sqlite/example/schema.prisma',
          '../comon_orm_sqlite/example/generated/comon_orm_client.dart',
        ),
        MapEntry(
          '../../examples/postgres/schema.prisma',
          '../../examples/postgres/lib/generated/comon_orm_client.dart',
        ),
        MapEntry(
          '../../examples/flutter_sqlite/schema.prisma',
          '../../examples/flutter_sqlite/lib/generated/comon_orm_client.dart',
        ),
      ];

      for (final fixture in fixtures) {
        final generated = _generateClientForFixture(
          schemaPath: fixture.key,
          outputPath: fixture.value,
        );
        final expected = _readPackageFile(fixture.value);

        expect(
          generated,
          equals(expected),
          reason:
              'Generated client fixture drifted for ${fixture.value}. Regenerate it from ${fixture.key}.',
        );
      }
    });
  });
}

String _generateClientForFixture({
  required String schemaPath,
  required String outputPath,
}) {
  final workflow = const SchemaWorkflow();
  final loaded = workflow.loadValidatedSchemaSync(_fixturePath(schemaPath));
  final generator = workflow.resolveGenerator(loaded);
  final outputFile = File(_fixturePath(outputPath));

  return ClientGenerator(
    options: _resolveClientGeneratorOptions(
      generator: generator,
      anchorDirectory: outputFile.parent,
    ),
  ).generateClient(loaded.schema);
}

String _readPackageFile(String relativePath) {
  return File(_fixturePath(relativePath)).readAsStringSync();
}

String _fixturePath(String relativePath) {
  final normalized = relativePath.replaceAll('/', Platform.pathSeparator);
  return '${_comonOrmPackageRoot.path}${Platform.pathSeparator}$normalized';
}

final Directory _workspaceRoot = _resolveWorkspaceRoot();
final Directory _comonOrmPackageRoot = Directory(
  '${_workspaceRoot.path}${Platform.pathSeparator}packages${Platform.pathSeparator}comon_orm',
);

ClientGeneratorOptions _resolveClientGeneratorOptions({
  required ResolvedGeneratorConfig generator,
  required Directory anchorDirectory,
}) {
  final explicitSqliteHelper = generator.sqliteHelper;
  if (explicitSqliteHelper != null) {
    return ClientGeneratorOptions(
      sqliteHelperKind: switch (explicitSqliteHelper) {
        'flutter' => SqliteClientHelperKind.flutter,
        _ => SqliteClientHelperKind.vm,
      },
    );
  }

  final pubspec = _findNearestPubspec(anchorDirectory);
  if (pubspec == null) {
    return const ClientGeneratorOptions();
  }

  final source = pubspec.readAsStringSync();
  final sqliteHelperKind =
      _pubspecReferencesPackage(source, 'comon_orm_sqlite_flutter')
      ? SqliteClientHelperKind.flutter
      : SqliteClientHelperKind.vm;
  return ClientGeneratorOptions(sqliteHelperKind: sqliteHelperKind);
}

File? _findNearestPubspec(Directory start) {
  var current = start.absolute;
  while (true) {
    final candidate = File(
      '${current.path}${Platform.pathSeparator}pubspec.yaml',
    );
    if (candidate.existsSync()) {
      return candidate;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}

bool _pubspecReferencesPackage(String source, String packageName) {
  for (final line in source.split('\n')) {
    final trimmed = line.trim();
    if (trimmed == 'name: $packageName' ||
        trimmed.startsWith('$packageName:')) {
      return true;
    }
  }
  return false;
}

Directory _resolveWorkspaceRoot() {
  var current = Directory.current.absolute;
  while (true) {
    final packagePubspec = File(
      '${current.path}${Platform.pathSeparator}packages${Platform.pathSeparator}comon_orm${Platform.pathSeparator}pubspec.yaml',
    );
    if (packagePubspec.existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError(
        'Could not resolve workspace root for generator fixture tests.',
      );
    }
    current = parent;
  }
}
