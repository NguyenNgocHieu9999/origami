import 'package:flutter_test/flutter_test.dart';
import 'package:origami/data/origami_database.dart';
import 'package:origami/models/origami_models.dart';
import 'package:origami/state/app_state.dart';
import 'package:sqflite/sqflite.dart';

class FakeOrigamiDatabase implements OrigamiDatabase {
  List<CompletedStep> completedStepsList = [];

  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<List<OrigamiModel>> getModels() async => [];

  @override
  Future<List<OrigamiStep>> getSteps(int modelId) async => [];

  @override
  Future<List<CompletedStep>> getCompletedSteps() async {
    return completedStepsList;
  }

  @override
  Future<void> setStepCompleted({
    required int modelId,
    required int stepId,
    required bool completed,
  }) async {}

  @override
  Future<void> setFavorite(int modelId, bool favorite) async {}

  @override
  Future<List<AchievementEntry>> getAchievements() async => [];

  @override
  Future<int> insertAchievement(AchievementEntry entry) async => 0;

  @override
  Future<void> updateAchievement(AchievementEntry entry) async {}

  @override
  Future<void> deleteAchievement(int id) async {}

  @override
  Future<AppUser?> getUser() async => null;

  @override
  Future<void> saveUser(AppUser user) async {}

  @override
  Future<void> clearUser() async {}

  @override
  Future<void> resetDatabase() async {}
}

void main() {
  group('AppState canComplete tests', () {
    late FakeOrigamiDatabase fakeDb;
    late AppState state;

    setUp(() {
      fakeDb = FakeOrigamiDatabase();
      state = AppState(database: fakeDb);
    });

    test('canComplete returns allowed for normal model (difficulty < 3) when all steps ticked and rating >= 3', () async {
      const model = OrigamiModel(
        id: 1,
        title: 'Easy Model',
        category: 'Basic',
        difficulty: 2,
        minutes: 5,
        paperSize: '15x15',
        description: 'Test easy model',
        colorHex: 'FFFFFF',
        imageKey: 'crane',
        isFavorite: false,
      );

      final steps = [
        const OrigamiStep(
          id: 101,
          modelId: 1,
          stepOrder: 1,
          title: 'Step 1',
          instruction: 'Fold 1',
          tip: 'Tip 1',
          seconds: 30,
          imageKey: 'easy_1',
        ),
        const OrigamiStep(
          id: 102,
          modelId: 1,
          stepOrder: 2,
          title: 'Step 2',
          instruction: 'Fold 2',
          tip: 'Tip 2',
          seconds: 30,
          imageKey: 'easy_2',
        ),
      ];

      // Simulate steps completed (order doesn't matter for easy model)
      fakeDb.completedStepsList = [
        CompletedStep(modelId: 1, stepId: 102, completedAt: DateTime(2026, 1, 1, 10, 0)),
        CompletedStep(modelId: 1, stepId: 101, completedAt: DateTime(2026, 1, 1, 10, 5)),
      ];
      state.completedSteps = fakeDb.completedStepsList;

      final result = state.canComplete(model, steps, 4);
      expect(result.allowed, isTrue);
      expect(result.message, 'Đủ điều kiện lưu thành quả và xét huy hiệu.');
    });

    test('canComplete returns disallowed when rating is less than 3', () async {
      const model = OrigamiModel(
        id: 1,
        title: 'Easy Model',
        category: 'Basic',
        difficulty: 2,
        minutes: 5,
        paperSize: '15x15',
        description: 'Test easy model',
        colorHex: 'FFFFFF',
        imageKey: 'crane',
        isFavorite: false,
      );

      final steps = [
        const OrigamiStep(
          id: 101,
          modelId: 1,
          stepOrder: 1,
          title: 'Step 1',
          instruction: 'Fold 1',
          tip: 'Tip 1',
          seconds: 30,
          imageKey: 'easy_1',
        ),
      ];

      fakeDb.completedStepsList = [
        CompletedStep(modelId: 1, stepId: 101, completedAt: DateTime(2026, 1, 1, 10, 0)),
      ];
      state.completedSteps = fakeDb.completedStepsList;

      final result = state.canComplete(model, steps, 2);
      expect(result.allowed, isFalse);
      expect(result.message, 'Rating tối thiểu là 3 sao để được tính hoàn thành.');
    });

    test('canComplete returns disallowed when some steps are missing', () async {
      const model = OrigamiModel(
        id: 1,
        title: 'Easy Model',
        category: 'Basic',
        difficulty: 2,
        minutes: 5,
        paperSize: '15x15',
        description: 'Test easy model',
        colorHex: 'FFFFFF',
        imageKey: 'crane',
        isFavorite: false,
      );

      final steps = [
        const OrigamiStep(id: 101, modelId: 1, stepOrder: 1, title: 'Step 1', instruction: 'F1', tip: 'T1', seconds: 10, imageKey: 'easy_1'),
        const OrigamiStep(id: 102, modelId: 1, stepOrder: 2, title: 'Step 2', instruction: 'F2', tip: 'T2', seconds: 10, imageKey: 'easy_2'),
      ];

      fakeDb.completedStepsList = [
        CompletedStep(modelId: 1, stepId: 101, completedAt: DateTime(2026, 1, 1, 10, 0)),
      ];
      state.completedSteps = fakeDb.completedStepsList;

      final result = state.canComplete(model, steps, 4);
      expect(result.allowed, isFalse);
      expect(result.message, 'Cần tick đủ 1 bước còn thiếu trước khi ghi thành quả.');
    });

    test('canComplete returns allowed for hard model (difficulty >= 3) when steps completed in chronological order', () async {
      const model = OrigamiModel(
        id: 2,
        title: 'Hard Model',
        category: 'Advanced',
        difficulty: 3,
        minutes: 15,
        paperSize: '15x15',
        description: 'Test hard model',
        colorHex: 'FFFFFF',
        imageKey: 'dragon',
        isFavorite: false,
      );

      final steps = [
        const OrigamiStep(id: 201, modelId: 2, stepOrder: 1, title: 'Step 1', instruction: 'F1', tip: 'T1', seconds: 10, imageKey: 'hard_1'),
        const OrigamiStep(id: 202, modelId: 2, stepOrder: 2, title: 'Step 2', instruction: 'F2', tip: 'T2', seconds: 10, imageKey: 'hard_2'),
        const OrigamiStep(id: 203, modelId: 2, stepOrder: 3, title: 'Step 3', instruction: 'F3', tip: 'T3', seconds: 10, imageKey: 'hard_3'),
      ];

      fakeDb.completedStepsList = [
        CompletedStep(modelId: 2, stepId: 201, completedAt: DateTime(2026, 1, 1, 10, 0)),
        CompletedStep(modelId: 2, stepId: 202, completedAt: DateTime(2026, 1, 1, 10, 1)),
        CompletedStep(modelId: 2, stepId: 203, completedAt: DateTime(2026, 1, 1, 10, 2)),
      ];
      state.completedSteps = fakeDb.completedStepsList;

      final result = state.canComplete(model, steps, 5);
      expect(result.allowed, isTrue);
      expect(result.message, 'Đủ điều kiện lưu thành quả và xét huy hiệu.');
    });

    test('canComplete returns disallowed for hard model (difficulty >= 3) when steps completed out of chronological order', () async {
      const model = OrigamiModel(
        id: 2,
        title: 'Hard Model',
        category: 'Advanced',
        difficulty: 3,
        minutes: 15,
        paperSize: '15x15',
        description: 'Test hard model',
        colorHex: 'FFFFFF',
        imageKey: 'dragon',
        isFavorite: false,
      );

      final steps = [
        const OrigamiStep(id: 201, modelId: 2, stepOrder: 1, title: 'Step 1', instruction: 'F1', tip: 'T1', seconds: 10, imageKey: 'hard_1'),
        const OrigamiStep(id: 202, modelId: 2, stepOrder: 2, title: 'Step 2', instruction: 'F2', tip: 'T2', seconds: 10, imageKey: 'hard_2'),
        const OrigamiStep(id: 203, modelId: 2, stepOrder: 3, title: 'Step 3', instruction: 'F3', tip: 'T3', seconds: 10, imageKey: 'hard_3'),
      ];

      // Step 2 was completed BEFORE step 1, which violates chronological order!
      fakeDb.completedStepsList = [
        CompletedStep(modelId: 2, stepId: 202, completedAt: DateTime(2026, 1, 1, 10, 0)),
        CompletedStep(modelId: 2, stepId: 201, completedAt: DateTime(2026, 1, 1, 10, 1)),
        CompletedStep(modelId: 2, stepId: 203, completedAt: DateTime(2026, 1, 1, 10, 2)),
      ];
      state.completedSteps = fakeDb.completedStepsList;

      final result = state.canComplete(model, steps, 5);
      expect(result.allowed, isFalse);
      expect(result.message, 'Mẫu khó cần hoàn tất toàn bộ checkpoint theo đúng thứ tự.');
    });
  });
}
