import 'package:comon_orm/src/client/query_models.dart';
import 'package:comon_orm/src/engine/query_planner.dart';
import 'package:test/test.dart';

void main() {
  const planner = QueryPlanner();

  group('QueryPlanner', () {
    test(
      'planFindMany returns findMany action with batch strategy when include is present',
      () {
        final plan = planner.planFindMany(
          const FindManyQuery(
            model: 'User',
            include: QueryInclude({
              'posts': QueryIncludeEntry(
                relation: QueryRelation(
                  field: 'posts',
                  targetModel: 'Post',
                  cardinality: QueryRelationCardinality.many,
                  localKeyField: 'id',
                  targetKeyField: 'userId',
                ),
              ),
            }),
          ),
        );
        expect(plan.model, 'User');
        expect(plan.action, PlannedAction.findMany);
        expect(plan.includeRelations, ['posts']);
        expect(plan.includeStrategy, IncludeStrategy.batch);
      },
    );

    test('planFindMany returns perRow strategy when no include', () {
      final plan = planner.planFindMany(const FindManyQuery(model: 'User'));
      expect(plan.includeStrategy, IncludeStrategy.perRow);
    });

    test('planFindUnique returns findUnique action', () {
      final plan = planner.planFindUnique(
        const FindUniqueQuery(model: 'User', where: <QueryPredicate>[]),
      );
      expect(plan.model, 'User');
      expect(plan.action, PlannedAction.findUnique);
    });

    test(
      'planFindFirst returns findFirst action with batch strategy when include present',
      () {
        final plan = planner.planFindFirst(
          const FindFirstQuery(
            model: 'Post',
            include: QueryInclude({
              'user': QueryIncludeEntry(
                relation: QueryRelation(
                  field: 'user',
                  targetModel: 'User',
                  cardinality: QueryRelationCardinality.one,
                  localKeyField: 'userId',
                  targetKeyField: 'id',
                ),
              ),
            }),
          ),
        );
        expect(plan.action, PlannedAction.findFirst);
        expect(plan.includeStrategy, IncludeStrategy.batch);
      },
    );

    test('planCreate returns create action with nestedWriteRelations', () {
      const relation = QueryRelation(
        field: 'posts',
        targetModel: 'Post',
        cardinality: QueryRelationCardinality.many,
        localKeyField: 'id',
        targetKeyField: 'userId',
      );
      final plan = planner.planCreate(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{},
          nestedCreates: <CreateRelationWrite>[
            CreateRelationWrite(
              relation: relation,
              records: <Map<String, Object?>>[],
            ),
          ],
        ),
      );
      expect(plan.action, PlannedAction.create);
      expect(plan.nestedWriteRelations, hasLength(1));
      expect(plan.nestedWriteRelations.first.field, 'posts');
    });

    test('planCreateMany returns createMany action', () {
      final plan = planner.planCreateMany(
        const CreateManyQuery(model: 'User', data: <Map<String, Object?>>[]),
      );
      expect(plan.action, PlannedAction.createMany);
    });

    test('planUpdate returns update action', () {
      final plan = planner.planUpdate(
        const UpdateQuery(
          model: 'User',
          where: <QueryPredicate>[],
          data: <String, Object?>{},
        ),
      );
      expect(plan.action, PlannedAction.update);
    });

    test('planUpdateMany returns updateMany action', () {
      final plan = planner.planUpdateMany(
        const UpdateManyQuery(
          model: 'User',
          where: <QueryPredicate>[],
          data: <String, Object?>{},
        ),
      );
      expect(plan.action, PlannedAction.updateMany);
    });

    test('planUpsert returns upsert action', () {
      final plan = planner.planUpsert(
        const UpsertQuery(
          model: 'User',
          where: <QueryPredicate>[],
          create: <String, Object?>{},
          update: <String, Object?>{},
        ),
      );
      expect(plan.action, PlannedAction.upsert);
    });

    test('planDelete returns delete action', () {
      final plan = planner.planDelete(
        const DeleteQuery(model: 'User', where: <QueryPredicate>[]),
      );
      expect(plan.action, PlannedAction.delete);
    });

    test('planDeleteMany returns deleteMany action', () {
      final plan = planner.planDeleteMany(
        const DeleteManyQuery(model: 'User', where: <QueryPredicate>[]),
      );
      expect(plan.action, PlannedAction.deleteMany);
    });
  });
}
