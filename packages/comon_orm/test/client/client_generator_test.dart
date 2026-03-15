import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('ClientGenerator', () {
    test('emits typed client, delegates, inputs and nested create helpers', () {
      const source = '''
model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String @unique
  posts Post[]
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
          'late final UserDelegate user = UserDelegate(_client.model(\'User\'));',
        ),
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
      expect(output, contains('Future<User?> findUnique({'));
      expect(output, contains('required UserWhereUniqueInput where,'));
      expect(output, contains('Future<User?> findFirst({'));
      expect(output, contains('List<UserOrderByInput>? orderBy,'));
      expect(output, contains('Future<int> count({'));
      expect(output, contains('Future<User> create({'));
      expect(output, contains('Future<User> update({'));
      expect(output, contains('Future<int> updateMany({'));
      expect(output, contains('Future<User> delete({'));
      expect(output, contains('Future<int> deleteMany({'));
      expect(output, contains('List<UserScalarField>? distinct,'));
      expect(output, contains('Future<UserAggregateResult> aggregate({'));
      expect(output, contains('Future<List<UserGroupByRow>> groupBy({'));
      expect(output, contains('enum UserScalarField {'));
      expect(output, contains('class UserCountAggregateInput {'));
      expect(output, contains('class UserAggregateResult {'));
      expect(output, contains('class UserGroupByOrderByInput {'));
      expect(output, contains('class UserGroupByRow {'));
      expect(
        output,
        contains('distinct: distinct?.map((field) => field.name).toSet()'),
      );
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
        contains(
          'Exactly one unique selector must be provided for UserWhereUniqueInput.',
        ),
      );
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
        contains('class UserCreateNestedManyWithoutManagerInput {'),
      );
      expect(
        output,
        contains('class UserCreateNestedOneWithoutMenteesInput {'),
      );
      expect(
        output,
        contains('class UserCreateNestedManyWithoutMentorInput {'),
      );
      expect(output, contains('class UserCreateWithoutReportsInput {'));
      expect(output, contains('class UserCreateWithoutManagerInput {'));
      expect(output, contains('class UserCreateWithoutMenteesInput {'));
      expect(output, contains('class UserCreateWithoutMentorInput {'));
      expect(
        output,
        contains(
          "QueryRelation(field: 'manager', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'managerId', targetKeyField: 'id')",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'reports', targetModel: 'User', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'managerId')",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'mentor', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'mentorId', targetKeyField: 'id')",
        ),
      );
      expect(
        output,
        contains(
          "QueryRelation(field: 'mentees', targetModel: 'User', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'mentorId')",
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
  });
}
