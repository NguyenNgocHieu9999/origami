import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/origami_models.dart';

class OrigamiDatabase {
  static final OrigamiDatabase instance = OrigamiDatabase._();

  OrigamiDatabase._();

  Database? _database;

  // Web in-memory database fallback
  final List<OrigamiModel> _webModels = [];
  final List<OrigamiStep> _webSteps = [];
  final List<CompletedStep> _webCompletedSteps = [];
  final List<AchievementEntry> _webAchievements = [];
  AppUser? _webUser;
  int _webAchievementIdSeq = 1;

  void _seedWebData() {
    _webModels.clear();
    _webSteps.clear();
    final models = <OrigamiModel>[
      const OrigamiModel(
        id: 1,
        title: 'Hạc giấy Senbazuru',
        category: 'Truyền thống',
        difficulty: 2,
        minutes: 12,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu hạc cổ điển để luyện nếp gấp núi, thung lũng và đảo cánh.',
        colorHex: '4F8A8B',
        imageKey: 'crane',
        isFavorite: true,
      ),
      const OrigamiModel(
        id: 2,
        title: 'Thuyền giấy nổi',
        category: 'Cơ bản',
        difficulty: 1,
        minutes: 6,
        paperSize: 'A4',
        description:
            'Bài nhập môn với các nếp gấp đối xứng, dễ kiểm tra thành quả.',
        colorHex: 'F2A65A',
        imageKey: 'boat',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 3,
        title: 'Hoa tulip',
        category: 'Trang trí',
        difficulty: 2,
        minutes: 10,
        paperSize: '12 x 12 cm',
        description: 'Tạo bông hoa và thân lá, phù hợp để ghi nhật ký màu sắc.',
        colorHex: 'D1495B',
        imageKey: 'tulip',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 4,
        title: 'Ếch bật',
        category: 'Tương tác',
        difficulty: 3,
        minutes: 14,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu có cơ chế bật, yêu cầu ép nếp đều và cân lực ở chân sau.',
        colorHex: '6A994E',
        imageKey: 'frog',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 5,
        title: 'Hộp masu',
        category: 'Ứng dụng',
        difficulty: 3,
        minutes: 16,
        paperSize: '20 x 20 cm',
        description:
            'Hộp vuông dùng được, cần tuân thủ rule khóa mép trước khi hoàn thành.',
        colorHex: '577590',
        imageKey: 'box',
        isFavorite: true,
      ),
      const OrigamiModel(
        id: 6,
        title: 'Rồng mini',
        category: 'Nâng cao',
        difficulty: 4,
        minutes: 28,
        paperSize: '20 x 20 cm',
        description:
            'Mẫu thử thách với nhiều lớp giấy, thích hợp dùng AI Coach khi kẹt bước.',
        colorHex: '845EC2',
        imageKey: 'dragon',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 7,
        title: 'Phi tiêu Ninja (Shuriken)',
        category: 'Tương tác',
        difficulty: 3,
        minutes: 15,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu phi tiêu 4 góc cổ điển. Cần lắp ghép khéo léo 2 mảnh giấy rời để tạo khóa liên kết.',
        colorHex: '9A7B56',
        imageKey: 'shuriken',
        isFavorite: false,
      ),
    ];

    _webModels.addAll(models);

    var stepId = 1;
    for (final model in models) {
      final steps = _stepsFor(model, stepId);
      stepId += steps.length;
      _webSteps.addAll(steps);
    }
  }

  Future<Database> get database async {
    final current = _database;
    if (current != null) {
      return current;
    }
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dbPath, 'origami_mentor.db'),
      version: 2,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    await _migrateOrSeedIfNeeded(db);
    _database = db;
    return db;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_user(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        photoUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE origami_models(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        minutes INTEGER NOT NULL,
        paperSize TEXT NOT NULL,
        description TEXT NOT NULL,
        colorHex TEXT NOT NULL,
        imageKey TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE origami_steps(
        id INTEGER PRIMARY KEY,
        modelId INTEGER NOT NULL,
        stepOrder INTEGER NOT NULL,
        title TEXT NOT NULL,
        instruction TEXT NOT NULL,
        tip TEXT NOT NULL,
        seconds INTEGER NOT NULL,
        imageKey TEXT NOT NULL,
        FOREIGN KEY(modelId) REFERENCES origami_models(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE completed_steps(
        modelId INTEGER NOT NULL,
        stepId INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        PRIMARY KEY(modelId, stepId)
      )
    ''');

    await db.execute('''
      CREATE TABLE achievement_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        modelId INTEGER NOT NULL,
        modelTitle TEXT NOT NULL,
        note TEXT NOT NULL,
        rating INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        minutesSpent INTEGER NOT NULL,
        photoPath TEXT
      )
    ''');

    await _seedModels(db);
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE origami_steps ADD COLUMN imageKey TEXT NOT NULL DEFAULT ""');
      
      final List<Map<String, dynamic>> stepRows = await db.query('origami_steps');
      for (final row in stepRows) {
        final id = row['id'] as int;
        final modelId = row['modelId'] as int;
        final stepOrder = row['stepOrder'] as int;
        
        final List<Map<String, dynamic>> modelRows = await db.query(
          'origami_models',
          where: 'id = ?',
          whereArgs: [modelId],
        );
        if (modelRows.isNotEmpty) {
          final modelImageKey = modelRows.first['imageKey'] as String;
          final computedImageKey = '${modelImageKey}_$stepOrder';
          await db.update(
            'origami_steps',
            {'imageKey': computedImageKey},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    }
  }

  Future<void> _seedModels(Database db) async {
    final models = <OrigamiModel>[
      const OrigamiModel(
        id: 1,
        title: 'Hạc giấy Senbazuru',
        category: 'Truyền thống',
        difficulty: 2,
        minutes: 12,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu hạc cổ điển để luyện nếp gấp núi, thung lũng và đảo cánh.',
        colorHex: '4F8A8B',
        imageKey: 'crane',
        isFavorite: true,
      ),
      const OrigamiModel(
        id: 2,
        title: 'Thuyền giấy nổi',
        category: 'Cơ bản',
        difficulty: 1,
        minutes: 6,
        paperSize: 'A4',
        description:
            'Bài nhập môn với các nếp gấp đối xứng, dễ kiểm tra thành quả.',
        colorHex: 'F2A65A',
        imageKey: 'boat',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 3,
        title: 'Hoa tulip',
        category: 'Trang trí',
        difficulty: 2,
        minutes: 10,
        paperSize: '12 x 12 cm',
        description: 'Tạo bông hoa và thân lá, phù hợp để ghi nhật ký màu sắc.',
        colorHex: 'D1495B',
        imageKey: 'tulip',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 4,
        title: 'Ếch bật',
        category: 'Tương tác',
        difficulty: 3,
        minutes: 14,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu có cơ chế bật, yêu cầu ép nếp đều và cân lực ở chân sau.',
        colorHex: '6A994E',
        imageKey: 'frog',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 5,
        title: 'Hộp masu',
        category: 'Ứng dụng',
        difficulty: 3,
        minutes: 16,
        paperSize: '20 x 20 cm',
        description:
            'Hộp vuông dùng được, cần tuân thủ rule khóa mép trước khi hoàn thành.',
        colorHex: '577590',
        imageKey: 'box',
        isFavorite: true,
      ),
      const OrigamiModel(
        id: 6,
        title: 'Rồng mini',
        category: 'Nâng cao',
        difficulty: 4,
        minutes: 28,
        paperSize: '20 x 20 cm',
        description:
            'Mẫu thử thách với nhiều lớp giấy, thích hợp dùng AI Coach khi kẹt bước.',
        colorHex: '845EC2',
        imageKey: 'dragon',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 7,
        title: 'Phi tiêu Ninja (Shuriken)',
        category: 'Tương tác',
        difficulty: 3,
        minutes: 15,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu phi tiêu 4 góc cổ điển. Cần lắp ghép khéo léo 2 mảnh giấy rời để tạo khóa liên kết.',
        colorHex: '9A7B56',
        imageKey: 'shuriken',
        isFavorite: false,
      ),
    ];

    for (final model in models) {
      await db.insert('origami_models', model.toMap());
    }

    var stepId = 1;
    for (final model in models) {
      final steps = _stepsFor(model, stepId);
      stepId += steps.length;
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }
  }

  Future<void> _migrateOrSeedIfNeeded(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='origami_models'",
    );
    if (tables.isEmpty) {
      await _create(db, 1);
      return;
    }

    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM origami_models'),
    );
    if (countResult == null || countResult == 0) {
      await _seedModels(db);
      return;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [7],
    );
    if (maps.isEmpty) {
      final model = const OrigamiModel(
        id: 7,
        title: 'Phi tiêu Ninja (Shuriken)',
        category: 'Tương tác',
        difficulty: 3,
        minutes: 15,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu phi tiêu 4 góc cổ điển. Cần lắp ghép khéo léo 2 mảnh giấy rời để tạo khóa liên kết.',
        colorHex: '9A7B56',
        imageKey: 'shuriken',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 37);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }
  }

  List<OrigamiStep> _stepsFor(OrigamiModel model, int firstId) {
    final base = <({String title, String instruction, String tip, int seconds})>[
      (
        title: 'Chuẩn bị giấy',
        instruction:
            'Đặt mặt màu úp xuống, xoay giấy thành hình thoi và miết nhẹ để giấy phẳng.',
        tip: 'Giữ hai góc đối diện cùng nằm trên một đường thẳng.',
        seconds: 45,
      ),
      (
        title: 'Tạo nếp trung tâm',
        instruction:
            'Gấp đôi theo đường chéo, mở ra, sau đó gấp đường chéo còn lại để có tâm chính xác.',
        tip: 'Nếp đầu tiên quyết định độ cân của toàn bộ mẫu.',
        seconds: 70,
      ),
      (
        title: 'Khóa hình cơ bản',
        instruction:
            'Đưa bốn góc về tâm theo đúng thứ tự trong hình mô phỏng và ép phẳng từng cạnh.',
        tip: 'Không kéo căng giấy, chỉ dẫn nếp bằng đầu ngón tay.',
        seconds: 95,
      ),
      (
        title: 'Tạo chi tiết chính',
        instruction:
            'Gấp các mép theo trục giữa để hình thành phần đặc trưng của mẫu.',
        tip: 'Nếu hai mép không gặp nhau, mở ra và chỉnh lại từ nếp trung tâm.',
        seconds: 110,
      ),
      (
        title: 'Đảo nếp và dựng hình',
        instruction:
            'Mở nhẹ lớp giấy, đảo nếp theo dấu có sẵn rồi dựng khối 3D.',
        tip: 'Đây là bước dễ rách giấy nhất, hãy làm chậm.',
        seconds: 120,
      ),
      (
        title: 'Hoàn thiện',
        instruction:
            'Căn chỉnh các góc, miết lại nếp khóa và kiểm tra mẫu đứng vững.',
        tip: 'Chụp lại thành quả để lưu vào nhật ký cá nhân.',
        seconds: 80,
      ),
    ];

    return [
      for (var i = 0; i < base.length; i++)
        OrigamiStep(
          id: firstId + i,
          modelId: model.id,
          stepOrder: i + 1,
          title: base[i].title,
          instruction:
              '${base[i].instruction} Với mẫu ${model.title}, hãy ưu tiên ${_focusFor(model.imageKey)}.',
          tip: base[i].tip,
          seconds: base[i].seconds + (model.difficulty * 8),
          imageKey: '${model.imageKey}_${i + 1}',
        ),
    ];
  }

  String _focusFor(String imageKey) {
    switch (imageKey) {
      case 'boat':
        return 'đường sống giữa thật thẳng';
      case 'tulip':
        return 'độ cong tự nhiên của cánh';
      case 'frog':
        return 'lực đàn hồi ở hai chân sau';
      case 'box':
        return 'mép khóa không bị hở';
      case 'dragon':
        return 'các lớp giấy mỏng và đều';
      case 'shuriken':
        return 'độ phẳng của các khớp khóa liên kết';
      default:
        return 'hai cánh cân nhau';
    }
  }

  Future<List<OrigamiModel>> getModels() async {
    if (kIsWeb) {
      if (_webModels.isEmpty) {
        _seedWebData();
      }
      return _webModels;
    }
    final db = await database;
    final rows = await db.query(
      'origami_models',
      orderBy: 'difficulty ASC, title ASC',
    );
    return rows.map(OrigamiModel.fromMap).toList();
  }

  Future<List<OrigamiStep>> getSteps(int modelId) async {
    if (kIsWeb) {
      if (_webModels.isEmpty) {
        _seedWebData();
      }
      return _webSteps.where((step) => step.modelId == modelId).toList();
    }
    final db = await database;
    final rows = await db.query(
      'origami_steps',
      where: 'modelId = ?',
      whereArgs: [modelId],
      orderBy: 'stepOrder ASC',
    );
    return rows.map(OrigamiStep.fromMap).toList();
  }

  Future<List<CompletedStep>> getCompletedSteps() async {
    if (kIsWeb) {
      return _webCompletedSteps;
    }
    final db = await database;
    final rows = await db.query('completed_steps');
    return rows.map(CompletedStep.fromMap).toList();
  }

  Future<void> setStepCompleted({
    required int modelId,
    required int stepId,
    required bool completed,
  }) async {
    if (kIsWeb) {
      _webCompletedSteps.removeWhere((item) => item.modelId == modelId && item.stepId == stepId);
      if (completed) {
        _webCompletedSteps.add(CompletedStep(
          modelId: modelId,
          stepId: stepId,
          completedAt: DateTime.now(),
        ));
      }
      return;
    }
    final db = await database;
    if (completed) {
      await db.insert(
        'completed_steps',
        CompletedStep(
          modelId: modelId,
          stepId: stepId,
          completedAt: DateTime.now(),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        'completed_steps',
        where: 'modelId = ? AND stepId = ?',
        whereArgs: [modelId, stepId],
      );
    }
  }

  Future<void> setFavorite(int modelId, bool favorite) async {
    if (kIsWeb) {
      final index = _webModels.indexWhere((m) => m.id == modelId);
      if (index != -1) {
        _webModels[index] = _webModels[index].copyWith(isFavorite: favorite);
      }
      return;
    }
    final db = await database;
    await db.update(
      'origami_models',
      {'isFavorite': favorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [modelId],
    );
  }

  Future<List<AchievementEntry>> getAchievements() async {
    if (kIsWeb) {
      final list = List<AchievementEntry>.from(_webAchievements);
      list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return list;
    }
    final db = await database;
    final rows = await db.query(
      'achievement_entries',
      orderBy: 'completedAt DESC',
    );
    return rows.map(AchievementEntry.fromMap).toList();
  }

  Future<int> insertAchievement(AchievementEntry entry) async {
    if (kIsWeb) {
      final newEntry = entry.copyWith(id: _webAchievementIdSeq++);
      _webAchievements.add(newEntry);
      return newEntry.id!;
    }
    final db = await database;
    return db.insert('achievement_entries', entry.toMap()..remove('id'));
  }

  Future<void> updateAchievement(AchievementEntry entry) async {
    if (kIsWeb) {
      final index = _webAchievements.indexWhere((item) => item.id == entry.id);
      if (index != -1) {
        _webAchievements[index] = entry;
      }
      return;
    }
    final db = await database;
    await db.update(
      'achievement_entries',
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteAchievement(int id) async {
    if (kIsWeb) {
      _webAchievements.removeWhere((item) => item.id == id);
      return;
    }
    final db = await database;
    await db.delete('achievement_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<AppUser?> getUser() async {
    if (kIsWeb) {
      return _webUser;
    }
    final db = await database;
    final rows = await db.query('app_user', limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return AppUser.fromMap(rows.first);
  }

  Future<void> saveUser(AppUser user) async {
    if (kIsWeb) {
      _webUser = user;
      return;
    }
    final db = await database;
    await db.delete('app_user');
    await db.insert(
      'app_user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearUser() async {
    if (kIsWeb) {
      _webUser = null;
      return;
    }
    final db = await database;
    await db.delete('app_user');
  }

  Future<void> resetDatabase() async {
    if (kIsWeb) {
      _webCompletedSteps.clear();
      _webAchievements.clear();
      _webUser = null;
      _webAchievementIdSeq = 1;
      _seedWebData();
      return;
    }
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS app_user');
    await db.execute('DROP TABLE IF EXISTS origami_models');
    await db.execute('DROP TABLE IF EXISTS origami_steps');
    await db.execute('DROP TABLE IF EXISTS completed_steps');
    await db.execute('DROP TABLE IF EXISTS achievement_entries');
    await _create(db, 1);
  }
}
