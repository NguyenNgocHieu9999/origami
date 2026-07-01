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
      const OrigamiModel(
        id: 8,
        title: 'Thiên nga kiêu sa',
        category: 'Truyền thống',
        difficulty: 2,
        minutes: 9,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu thiên nga cổ điển với nếp gấp cổ cong dài thanh lịch, dễ thực hiện.',
        colorHex: '3A86C8',
        imageKey: 'swan',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 9,
        title: 'Bướm mùa xuân',
        category: 'Trang trí',
        difficulty: 2,
        minutes: 8,
        paperSize: '12 x 12 cm',
        description:
            'Mẫu bướm xinh xắn để trang trí, cần các nếp gấp xếp ly xếp chồng khéo léo.',
        colorHex: 'FF7B93',
        imageKey: 'butterfly',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 10,
        title: 'Khủng long T-Rex',
        category: 'Nâng cao',
        difficulty: 4,
        minutes: 25,
        paperSize: '20 x 20 cm',
        description:
            'Mẫu thử thách đầy thú vị dành cho các bạn thích tạo hình các loài sinh vật cổ đại.',
        colorHex: 'C86A3A',
        imageKey: 'dinosaur',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 11,
        title: 'Rùa biển',
        category: 'Sinh vật biển',
        difficulty: 4,
        minutes: 20,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu rùa biển nghệ thuật với mai lục giác rộng và 4 chi bơi cân đối. Cần 17 bước gấp chi tiết.',
        colorHex: '4CAF50',
        imageKey: 'turtle',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 12,
        title: 'Cây xương rồng',
        category: 'Thực vật',
        difficulty: 3,
        minutes: 15,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu cây xương rồng trong chậu xinh xắn. Cần 13 bước gấp chi tiết để tạo hình chậu và các nhánh xương rồng.',
        colorHex: '8BC34A',
        imageKey: 'cactus',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 13,
        title: 'Sư tử bờm rộng',
        category: 'Động vật',
        difficulty: 3,
        minutes: 16,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu sư tử dũng mãnh với bờm rộng và thân đứng kiêu hãnh. Cần 14 bước gấp chi tiết.',
        colorHex: 'FF9800',
        imageKey: 'lion',
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
      version: 4,
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
    if (oldVersion < 3) {
      // 1. Delete old steps for crane (modelId = 1)
      await db.delete('origami_steps', where: 'modelId = ?', whereArgs: [1]);
      
      // 2. Clear completed steps progress for crane so they fold the 28 new steps
      await db.delete('completed_steps', where: 'modelId = ?', whereArgs: [1]);

      // 3. Seed 28 new crane steps with safe IDs starting at 1000
      final craneModel = const OrigamiModel(
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
      );

      final steps = _stepsFor(craneModel, 1000);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }
    if (oldVersion < 4) {
      // 1. Delete old steps for frog (modelId = 4)
      await db.delete('origami_steps', where: 'modelId = ?', whereArgs: [4]);
      
      // 2. Clear completed steps progress for frog so they fold the 22 new steps
      await db.delete('completed_steps', where: 'modelId = ?', whereArgs: [4]);

      // 3. Seed 22 new frog steps with safe IDs starting at 2000
      final frogModel = const OrigamiModel(
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
      );

      final steps = _stepsFor(frogModel, 2000);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
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
      const OrigamiModel(
        id: 8,
        title: 'Thiên nga kiêu sa',
        category: 'Truyền thống',
        difficulty: 2,
        minutes: 9,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu thiên nga cổ điển với nếp gấp cổ cong dài thanh lịch, dễ thực hiện.',
        colorHex: '3A86C8',
        imageKey: 'swan',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 9,
        title: 'Bướm mùa xuân',
        category: 'Trang trí',
        difficulty: 2,
        minutes: 8,
        paperSize: '12 x 12 cm',
        description:
            'Mẫu bướm xinh xắn để trang trí, cần các nếp gấp xếp ly xếp chồng khéo léo.',
        colorHex: 'FF7B93',
        imageKey: 'butterfly',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 10,
        title: 'Khủng long T-Rex',
        category: 'Nâng cao',
        difficulty: 4,
        minutes: 25,
        paperSize: '20 x 20 cm',
        description:
            'Mẫu thử thách đầy thú vị dành cho các bạn thích tạo hình các loài sinh vật cổ đại.',
        colorHex: 'C86A3A',
        imageKey: 'dinosaur',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 11,
        title: 'Rùa biển',
        category: 'Sinh vật biển',
        difficulty: 4,
        minutes: 20,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu rùa biển nghệ thuật với mai lục giác rộng và 4 chi bơi cân đối. Cần 17 bước gấp chi tiết.',
        colorHex: '4CAF50',
        imageKey: 'turtle',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 12,
        title: 'Cây xương rồng',
        category: 'Thực vật',
        difficulty: 3,
        minutes: 15,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu cây xương rồng trong chậu xinh xắn. Cần 13 bước gấp chi tiết để tạo hình chậu và các nhánh xương rồng.',
        colorHex: '8BC34A',
        imageKey: 'cactus',
        isFavorite: false,
      ),
      const OrigamiModel(
        id: 13,
        title: 'Sư tử bờm rộng',
        category: 'Động vật',
        difficulty: 3,
        minutes: 16,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu sư tử dũng mãnh với bờm rộng và thân đứng kiêu hãnh. Cần 14 bước gấp chi tiết.',
        colorHex: 'FF9800',
        imageKey: 'lion',
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
      final steps = _stepsFor(model, 39);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }

    final List<Map<String, dynamic>> maps8 = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [8],
    );
    if (maps8.isEmpty) {
      final model = const OrigamiModel(
        id: 8,
        title: 'Thiên nga kiêu sa',
        category: 'Truyền thống',
        difficulty: 2,
        minutes: 9,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu thiên nga cổ điển với nếp gấp cổ cong dài thanh lịch, dễ thực hiện.',
        colorHex: '3A86C8',
        imageKey: 'swan',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 45);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }

    final List<Map<String, dynamic>> maps9 = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [9],
    );
    if (maps9.isEmpty) {
      final model = const OrigamiModel(
        id: 9,
        title: 'Bướm mùa xuân',
        category: 'Trang trí',
        difficulty: 2,
        minutes: 8,
        paperSize: '12 x 12 cm',
        description:
            'Mẫu bướm xinh xắn để trang trí, cần các nếp gấp xếp ly xếp chồng khéo léo.',
        colorHex: 'FF7B93',
        imageKey: 'butterfly',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 51);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }

    final List<Map<String, dynamic>> maps10 = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [10],
    );
    if (maps10.isEmpty) {
      final model = const OrigamiModel(
        id: 10,
        title: 'Khủng long T-Rex',
        category: 'Nâng cao',
        difficulty: 4,
        minutes: 25,
        paperSize: '20 x 20 cm',
        description:
            'Mẫu thử thách đầy thú vị dành cho các bạn thích tạo hình các loài sinh vật cổ đại.',
        colorHex: 'C86A3A',
        imageKey: 'dinosaur',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 57);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }

    final List<Map<String, dynamic>> maps11 = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [11],
    );
    if (maps11.isEmpty) {
      final model = const OrigamiModel(
        id: 11,
        title: 'Rùa biển',
        category: 'Sinh vật biển',
        difficulty: 4,
        minutes: 20,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu rùa biển nghệ thuật với mai lục giác rộng và 4 chi bơi cân đối. Cần 17 bước gấp chi tiết.',
        colorHex: '4CAF50',
        imageKey: 'turtle',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 65);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }

    final List<Map<String, dynamic>> maps12 = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [12],
    );
    if (maps12.isEmpty) {
      final model = const OrigamiModel(
        id: 12,
        title: 'Cây xương rồng',
        category: 'Thực vật',
        difficulty: 3,
        minutes: 15,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu cây xương rồng trong chậu xinh xắn. Cần 13 bước gấp chi tiết để tạo hình chậu và các nhánh xương rồng.',
        colorHex: '8BC34A',
        imageKey: 'cactus',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 82);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }

    final List<Map<String, dynamic>> maps13 = await db.query(
      'origami_models',
      where: 'id = ?',
      whereArgs: [13],
    );
    if (maps13.isEmpty) {
      final model = const OrigamiModel(
        id: 13,
        title: 'Sư tử bờm rộng',
        category: 'Động vật',
        difficulty: 3,
        minutes: 16,
        paperSize: '15 x 15 cm',
        description:
            'Mẫu sư tử dũng mãnh với bờm rộng và thân đứng kiêu hãnh. Cần 14 bước gấp chi tiết.',
        colorHex: 'FF9800',
        imageKey: 'lion',
        isFavorite: false,
      );
      await db.insert('origami_models', model.toMap());
      final steps = _stepsFor(model, 95);
      for (final step in steps) {
        await db.insert('origami_steps', step.toMap());
      }
    }
  }

  List<OrigamiStep> _stepsFor(OrigamiModel model, int firstId) {
    final List<({String title, String instruction, String tip, int seconds})> base;
    List<String> craneImages = const [];
    List<String> frogImages = const [];
    
    switch (model.imageKey) {
      case 'crane':
        craneImages = [
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-1.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-step-2.gif',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-3.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-4.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-5.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-6.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-7.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-8.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-step-9.gif',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-10.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-11.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-12.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-step-13.gif',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-14.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-15.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-step-16.gif',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-17.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-18.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-step-19.gif',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-20.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-21.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-step-22.gif',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-23.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-24.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-25.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-26.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-diagram-step-27.png',
          'https://origami.me/wp-content/uploads/2026/01/origami-crane-paper-fold-completed.jpg',
        ];
        base = [
          (
            title: 'Tạo nếp chéo định hình',
            instruction: 'Bắt đầu với mặt có màu hướng lên trên, đặt tờ giấy theo hình kim cương (hình thoi). Gấp đôi và mở ra theo cả hai đường chéo (ngang và dọc).',
            tip: 'Nếp gấp đầu tiên thường là quan trọng nhất. Hãy dành thời gian căn chỉnh thật cẩn thận.',
            seconds: 40,
          ),
          (
            title: 'Lật giấy mặt sau',
            instruction: 'Lật ngược tờ giấy lại để mặt trắng hướng lên trên.',
            tip: 'Giữ cho giấy phẳng phiu khi lật.',
            seconds: 20,
          ),
          (
            title: 'Tạo nếp gấp ngang dọc',
            instruction: 'Gấp đôi tờ giấy từ mép này sang mép kia, theo cả chiều dọc và chiều ngang, rồi mở ra.',
            tip: 'Hãy miết thật chặt nếp gấp để tạo các nếp hướng dẫn sắc nét.',
            seconds: 40,
          ),
          (
            title: 'Tạo hình vuông cơ bản (Square Base)',
            instruction: 'Thu gọn giấy theo các nếp gấp sẵn có bằng cách đưa góc bên trái và bên phải xuống để gặp góc dưới cùng, tạo thành một hình vuông nhỏ.',
            tip: 'Vuốt phẳng các góc để tạo hình vuông cân đối.',
            seconds: 60,
          ),
          (
            title: 'Gấp mép bên hình vuông',
            instruction: 'Gấp các mép bên trái và bên phải của lớp giấy phía trên vào sát trục đường giữa.',
            tip: 'Chỉ gấp lớp giấy trên cùng, không gấp lớp giấy phía sau.',
            seconds: 45,
          ),
          (
            title: 'Gập đỉnh tam giác',
            instruction: 'Gấp đỉnh tam giác phía trên xuống, căn chỉnh nếp gấp trùng với mép trên của các vạt giấy vừa tạo ở Bước 5.',
            tip: 'Bước này giúp tạo nếp định hình nằm ngang.',
            seconds: 30,
          ),
          (
            title: 'Mở nếp gấp mép bên',
            instruction: 'Mở các vạt giấy vừa gấp ở Bước 5 ra (giữ nguyên nếp gấp đỉnh tam giác ở Bước 6).',
            tip: 'Việc này giúp chuẩn bị nếp gấp cho bước tạo cánh tiếp theo.',
            seconds: 25,
          ),
          (
            title: 'Gấp cánh hoa (Petal Fold) mặt trước',
            instruction: 'Nhấc lớp giấy trên cùng lên từ góc dưới và đưa nó lên trên theo nếp gấp ngang. Ép các mép bên ngoài vào sát đường giữa để tạo thành hình kim cương dài.',
            tip: 'Hãy làm thật chậm rãi để giấy không bị rách ở phần tâm.',
            seconds: 60,
          ),
          (
            title: 'Lật mặt sau',
            instruction: 'Lật ngược mô hình lại.',
            tip: 'Giữ nếp gấp mặt trước không bị xê dịch.',
            seconds: 20,
          ),
          (
            title: 'Tạo nếp gấp phụ mặt sau',
            instruction: 'Gấp mép trái và mép phải của lớp giấy phía trên vào đường giữa rồi mở ra để tạo nếp. Gấp đỉnh tam giác phía trên xuống rồi mở ra.',
            tip: 'Nếp gấp định hình giúp việc tạo cánh hoa ở mặt sau dễ dàng hơn.',
            seconds: 45,
          ),
          (
            title: 'Gấp cánh hoa mặt sau',
            instruction: 'Tương tự như Bước 8, nhấc lớp giấy phía trên lên từ góc dưới, gấp ngược lên và ép hai mép bên vào đường giữa để hoàn tất hình chim cơ bản (Bird Base) 🐦.',
            tip: 'Đảm bảo cả hai mặt đều đối xứng và cân đối.',
            seconds: 60,
          ),
          (
            title: 'Thu hẹp vạt giấy mặt trước',
            instruction: 'Gấp mép trái và phải của vạt giấy phía trước vào sát đường giữa.',
            tip: 'Đừng gấp sát rạt đường giữa, hãy chừa một khe nhỏ khoảng 1mm để các bước bẻ cổ và đuôi sau này dễ dàng hơn.',
            seconds: 50,
          ),
          (
            title: 'Lật mô hình',
            instruction: 'Lật ngược mô hình lại.',
            tip: 'Vuốt nhẹ mô hình cho phẳng.',
            seconds: 20,
          ),
          (
            title: 'Thu hẹp vạt giấy mặt sau',
            instruction: 'Tiếp tục gấp mép trái và phải của vạt giấy phía trước vào sát đường giữa, chừa lại một khe nhỏ.',
            tip: 'Khoảng trống nhỏ này sẽ giúp cổ và đuôi hạc chuyển động linh hoạt mà không bị kẹt giấy.',
            seconds: 50,
          ),
          (
            title: 'Lật vạt giấy mặt trước',
            instruction: 'Gấp vạt giấy bên phải phía trên cùng sang bên trái (như lật một trang sách).',
            tip: 'Miết nếp gấp lật thật thẳng.',
            seconds: 30,
          ),
          (
            title: 'Lật mô hình',
            instruction: 'Lật ngược mô hình lại.',
            tip: 'Giữ phẳng các lớp giấy.',
            seconds: 20,
          ),
          (
            title: 'Lật vạt giấy mặt sau',
            instruction: 'Tương tự như Bước 15, gấp vạt giấy bên phải phía trên cùng sang bên trái.',
            tip: 'Điều này giúp đổi trục của mô hình để chuẩn bị gấp cổ và đuôi hạc.',
            seconds: 30,
          ),
          (
            title: 'Gập ngược vạt giấy mặt trước lên',
            instruction: 'Gấp góc nhọn bên dưới của vạt giấy phía trước hướng thẳng lên trên dọc theo nếp gấp ngang có sẵn.',
            tip: 'Đưa vạt giấy lên cao hết mức có thể mà không làm nhăn giấy.',
            seconds: 40,
          ),
          (
            title: 'Lật mô hình',
            instruction: 'Lật ngược mô hình lại.',
            tip: 'Cố gắng giữ cho các mép thẳng hàng.',
            seconds: 20,
          ),
          (
            title: 'Gập ngược vạt giấy mặt sau lên',
            instruction: 'Lặp lại thao tác gấp góc nhọn phía dưới lên trên ở mặt này, tương tự như Bước 18.',
            tip: 'Vuốt nếp gấp đáy thật chặt.',
            seconds: 40,
          ),
          (
            title: 'Lật vạt giấy mặt trước lần nữa',
            instruction: 'Gấp vạt giấy bên phải phía trên cùng sang bên trái.',
            tip: 'Lúc này những khoảng trống nhỏ bạn để lại ở Bước 12 và 14 sẽ phát huy tác dụng, giúp các lớp giấy xếp lên nhau êm ái hơn.',
            seconds: 30,
          ),
          (
            title: 'Lật mô hình',
            instruction: 'Lật ngược mô hình lại.',
            tip: 'Đặt mô hình ngay ngắn.',
            seconds: 20,
          ),
          (
            title: 'Lật vạt giấy mặt sau lần nữa',
            instruction: 'Gấp vạt giấy bên phải phía trên cùng sang bên trái một lần nữa.',
            tip: 'Sau bước này, hai phần cổ và đuôi nhọn sẽ nằm ẩn bên trong các lớp cánh.',
            seconds: 30,
          ),
          (
            title: 'Tạo đuôi hạc (Swivel Fold)',
            instruction: 'Giữ phần đuôi nhọn của hạc (nằm giữa hai cánh), kéo xoay nó ra phía ngoài bên trái. Căn chỉnh sao cho nó tạo một góc chéo đẹp mắt rồi miết phẳng đáy để cố định.',
            tip: 'Kéo nhẹ nhàng để không làm rách phần khớp nối giữa cánh và đuôi.',
            seconds: 50,
          ),
          (
            title: 'Tạo cổ hạc',
            instruction: 'Làm tương tự với phần nhọn bên phải để tạo cổ hạc. Kéo xoay nó ra phía ngoài bên phải và miết phẳng đáy.',
            tip: 'Cố gắng điều chỉnh cho góc nghiêng của cổ và đuôi đối xứng nhau.',
            seconds: 50,
          ),
          (
            title: 'Tạo nếp gấp đầu hạc (Mountain Fold)',
            instruction: 'Gấp ngược đầu nhọn ở phía cổ hạc xuống dưới sang bên phải để tạo nếp gấp đầu. Không có điểm tham chiếu chính xác, hãy tự căn chỉnh tỷ lệ đầu hạc vừa vặn, miết kỹ rồi mở nếp gấp ra.',
            tip: 'Nếp gấp này giúp định hình để thực hiện bước gấp lộn đầu hạc tiếp theo.',
            seconds: 40,
          ),
          (
            title: 'Hoàn thiện đầu hạc (Inside Reverse Fold)',
            instruction: 'Ấn đỉnh đầu hạc xuống và luồn nó vào giữa hai lớp giấy của cổ hạc (gấp lộn ngược vào trong) dọc theo các nếp gấp vừa tạo ở Bước 26. Ép chặt lại để cố định đầu hạc.',
            tip: 'Chú ý miết chặt phần mỏ hạc để đầu hạc trông sắc nét.',
            seconds: 40,
          ),
          (
            title: 'Xòe cánh hạc hoàn thành! 🕊️',
            instruction: 'Nhẹ nhàng cầm hai cánh kéo sang hai bên để mở rộng thân hạc.',
            tip: 'Bạn có thể làm phồng phần lưng hạc bằng cách thổi nhẹ vào lỗ nhỏ ở đáy hạc hoặc kéo nhẹ hai cánh theo hướng ngược nhau.',
            seconds: 40,
          ),
        ];
        break;
      case 'boat':
        base = [
          (
            title: 'Chuẩn bị giấy chữ nhật',
            instruction: 'Đặt tờ giấy chữ nhật nằm dọc trên bàn, mặt màu úp xuống dưới.',
            tip: 'Sử dụng giấy A4 hoặc giấy tập học sinh phẳng.',
            seconds: 35,
          ),
          (
            title: 'Gấp đôi giấy',
            instruction: 'Gấp đôi tờ giấy từ trên xuống dưới, căn chỉnh hai góc trùng khớp.',
            tip: 'Miết chặt nếp gấp ngang ở phía trên.',
            seconds: 40,
          ),
          (
            title: 'Gấp góc tam giác',
            instruction: 'Gấp hai góc trên cùng hướng vào trục giữa tạo thành một hình tam giác nhọn.',
            tip: 'Đảm bảo hai cạnh chéo của tam giác khít nhau ở đường giữa.',
            seconds: 60,
          ),
          (
            title: 'Gấp mép giấy dưới',
            instruction: 'Gấp dải giấy thừa ở mép dưới lên trên ở cả hai phía đối diện.',
            tip: 'Bẻ gập các góc thừa ở hai đầu vào trong để khóa chặt.',
            seconds: 75,
          ),
          (
            title: 'Mở rộng tạo hình thoi',
            instruction: 'Luồn hai ngón tay cái vào khe trống phía dưới tam giác, kéo rộng ra rồi ép dẹt thành hình thoi.',
            tip: 'Hãy làm nhẹ tay để không làm rách phần tâm hình thoi.',
            seconds: 80,
          ),
          (
            title: 'Hoàn thiện thuyền nổi',
            instruction: 'Gấp hai góc dưới của hình thoi lên đỉnh, sau đó tiếp tục mở rộng đáy và kéo nhẹ hai cánh bên ra.',
            tip: 'Mở rộng lòng thuyền bên dưới để thuyền có thể tự đứng vững trên nước.',
            seconds: 90,
          ),
        ];
        break;
      case 'tulip':
        base = [
          (
            title: 'Chuẩn bị giấy hoa',
            instruction: 'Dùng giấy vuông nhỏ màu đỏ hoặc vàng, mặt màu úp xuống dưới.',
            tip: 'Nên chọn giấy có màu sắc rực rỡ để bông hoa trông sinh động.',
            seconds: 30,
          ),
          (
            title: 'Tạo tam giác cân',
            instruction: 'Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác cân hướng đỉnh lên trên.',
            tip: 'Miết nhẹ cạnh đáy tam giác.',
            seconds: 40,
          ),
          (
            title: 'Gấp cánh hoa trái',
            instruction: 'Gấp góc bên trái hướng lên trên và hơi lệch ra phía ngoài trục giữa.',
            tip: 'Góc nghiêng của cánh hoa quyết định độ nở của bông hoa.',
            seconds: 50,
          ),
          (
            title: 'Gấp cánh hoa phải',
            instruction: 'Gấp góc bên phải đối xứng lên trên tương tự như góc bên trái.',
            tip: 'Cố gắng giữ cho hai cánh hoa đối xứng cân đối với nhau.',
            seconds: 50,
          ),
          (
            title: 'Gấp đáy hoa',
            instruction: 'Gấp một phần nhỏ góc nhọn phía dưới bông hoa ra phía sau để tạo đáy hoa phẳng.',
            tip: 'Bước này giúp bông hoa dễ dàng gắn vào cành lá hơn.',
            seconds: 40,
          ),
          (
            title: 'Ghép cành lá',
            instruction: 'Dùng tờ giấy màu xanh khác gấp cuộn tạo thành thân và lá, sau đó cắm bông hoa vào đầu cành.',
            tip: 'Có thể dùng một chút keo dán để bông hoa bám chắc vào cành.',
            seconds: 70,
          ),
        ];
        break;
      case 'frog':
        frogImages = [
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-1.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-2.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-3.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-4.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-5.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-paper-fold-step-6.gif',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-7.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-paper-fold-step-8.gif',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-9.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-10.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-paper-fold-step-11.gif',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-12.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-13.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-14.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-15.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-paper-fold-step-16.gif',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-17.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-paper-fold-step-18.gif',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-19.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-20.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-diagram-step-21.png',
          'https://origami.me/wp-content/uploads/2026/02/origami-frog-paper-fold-completed.jpg',
        ];
        base = [
          (
            title: 'Tạo nếp gấp ngang định hình',
            instruction: 'Bắt đầu với mặt trắng của tờ giấy hướng lên trên. Gấp đôi tờ giấy theo chiều ngang, sau đó mở ra.',
            tip: 'Bạn cũng có thể bắt đầu với một tờ giấy hình chữ nhật (bằng nửa hình vuông) và làm từ Bước 3. Việc này giúp ếch dễ gấp hơn vì ít lớp giấy hơn, nhưng nó sẽ không bật cao bằng, đặc biệt nếu giấy mỏng.',
            seconds: 40,
          ),
          (
            title: 'Gấp đôi giấy theo chiều dọc',
            instruction: 'Gấp đôi tờ giấy theo chiều dọc, từ trái sang phải.',
            tip: 'Miết nếp gấp dọc thật sắc nét.',
            seconds: 20,
          ),
          (
            title: 'Gấp đôi theo chiều ngang',
            instruction: 'Gấp đôi tờ giấy theo chiều ngang một lần nữa, sau đó mở ra.',
            tip: 'Trước khi gấp, đặt ngón tay lên mép bên phải để giữ cố định các lớp giấy không bị lệch.',
            seconds: 40,
          ),
          (
            title: 'Gấp chéo góc phải dưới',
            instruction: 'Gấp mép dưới bên phải vào sát đường trục giữa nằm ngang. Miết kỹ nếp gấp rồi mở ra.',
            tip: 'Nếp gấp chéo này sẽ định hình cho phần đầu ếch.',
            seconds: 40,
          ),
          (
            title: 'Gấp chéo góc trái dưới',
            instruction: 'Gấp mép dưới bên trái vào sát đường trục giữa nằm ngang. Miết kỹ nếp gấp rồi mở ra.',
            tip: 'Làm tương tự Bước 4 để tạo nếp chéo đối xứng.',
            seconds: 40,
          ),
          (
            title: 'Lật giấy',
            instruction: 'Lật ngược tờ giấy lại.',
            tip: 'Đảm bảo các nếp gấp chéo trước đó không bị nhàu.',
            seconds: 20,
          ),
          (
            title: 'Gấp mép dưới vào giữa',
            instruction: 'Gấp mép dưới của tờ giấy lên sát đường trục giữa nằm ngang. Miết kỹ nếp gấp rồi mở ra.',
            tip: 'Nếp gấp ngang này giúp định vị việc xếp góc ở bước tiếp theo.',
            seconds: 40,
          ),
          (
            title: 'Lật giấy lại',
            instruction: 'Lật ngược tờ giấy lại một lần nữa.',
            tip: 'Vuốt phẳng mô hình giấy.',
            seconds: 20,
          ),
          (
            title: 'Tạo tam giác đỉnh (Waterbomb Base)',
            instruction: 'Ấn nhẹ hai góc bên trái và bên phải ở mép dưới vào trong, đồng thời đẩy mép dưới lên trên để thu gọn lại thành một hình tam giác (phần nền bom nước - Waterbomb Base).',
            tip: 'Dùng các ngón tay ép phẳng các nếp gấp chéo đã tạo ở Bước 4 và 5.',
            seconds: 60,
          ),
          (
            title: 'Tạo hai chân trước của ếch',
            instruction: 'Gấp các vạt giấy phía trên hướng chếch xuống dưới hai bên. Không có điểm tham chiếu chính xác, hãy gấp đối xứng để tạo thành hai chân trước của ếch.',
            tip: 'Góc chân xòe rộng giúp ếch thăng bằng tốt hơn khi nhảy.',
            seconds: 50,
          ),
          (
            title: 'Xoay mô hình 180 độ',
            instruction: 'Xoay mô hình ngược lại 180 độ (đưa phần chân trước vừa gấp lên phía trên).',
            tip: 'Xoay mô hình giúp việc thao tác phần thân sau dễ dàng hơn.',
            seconds: 20,
          ),
          (
            title: 'Gập đôi mép dưới lên',
            instruction: 'Gấp mép giấy dưới cùng hướng lên trên sát đường nằm ngang gần nhất.',
            tip: 'Miết nếp gấp ngang thật chặt.',
            seconds: 40,
          ),
          (
            title: 'Thu gọn thân sau',
            instruction: 'Gấp mép bên trái và bên phải hướng vào đường trục giữa dọc.',
            tip: 'Hãy nhấc nhẹ hai vạt chân trước lên trước khi gấp để chúng không bị vướng vào lớp giấy gấp bên dưới.',
            seconds: 50,
          ),
          (
            title: 'Gập ngược phần thân sau lên',
            instruction: 'Gấp mép dưới hướng thẳng lên trên cho đến khi chạm tới điểm nối giữa hai chân trước.',
            tip: 'Đây là bước xếp chồng nhiều lớp giấy, hãy dùng lực miết mạnh để nếp gấp thẳng.',
            seconds: 50,
          ),
          (
            title: 'Tạo nếp gấp chéo phụ thân sau',
            instruction: 'Gấp mép trái và mép phải của lớp giấy phía trên chếch xuống dưới chạm mép đáy, sau đó mở ra để tạo nếp.',
            tip: 'Nếp gấp chéo này sẽ giúp tạo khớp chân sau ở Bước 17.',
            seconds: 40,
          ),
          (
            title: 'Mở vạt giấy thân sau',
            instruction: 'Mở vạt giấy vừa gấp ngược lên ở Bước 14 ra (giữ nguyên các nếp gấp chéo chéo tạo ở Bước 15).',
            tip: 'Mở ra để chuẩn bị gấp lật tạo đùi sau.',
            seconds: 30,
          ),
          (
            title: 'Gập lật tạo đùi sau',
            instruction: 'Nhấc hai vạt giấy phía dưới lên và đẩy mép dưới hướng lên trên chạm điểm nối chân trước. Hai góc giấy bên dưới sẽ tự động mở xòe ra hai bên.',
            tip: 'Vuốt đều tay để vạt giấy mở ra thành hình thuyền nằm ngang.',
            seconds: 60,
          ),
          (
            title: 'Ép phẳng hai bên chân sau',
            instruction: 'Gấp ép hai vạt giấy bên trái và bên phải hướng xuống dưới dọc theo các nếp gấp sẵn có.',
            tip: 'Hai vạt giấy nhọn lúc này sẽ chĩa thẳng xuống dưới.',
            seconds: 40,
          ),
          (
            title: 'Tạo hình hai chân sau',
            instruction: 'Gấp mép trong của hai vạt giấy dưới hướng chếch ra ngoài sát các đường nếp gấp gần nhất để tạo hình chân sau của ếch.',
            tip: 'Đảm bảo hai chân sau đối xứng nhau và mở rộng sang hai bên.',
            seconds: 50,
          ),
          (
            title: 'Gập đôi tạo khớp nhảy thứ nhất',
            instruction: 'Gấp gập toàn bộ phần thân dưới lên trên dọc theo đường ranh giới nơi chân trước và chân sau gặp nhau.',
            tip: 'Đây là bước gấp lò xo để tạo lực nhảy, miết nếp gấp thật chặt.',
            seconds: 50,
          ),
          (
            title: 'Gập ngược tạo khớp nhảy thứ hai (Lò xo)',
            instruction: 'Gấp ngược lớp giấy vừa gấp hướng xuống dưới sao cho mép gấp nằm chính giữa phần thân sau. Miết thật mạnh để tạo nếp lò xo đàn hồi.',
            tip: 'Đây là khớp nén quyết định độ nảy của chú ếch bật.',
            seconds: 50,
          ),
          (
            title: 'Lật mô hình và hoàn thành chú ếch bật! 🐸',
            instruction: 'Lật ngược mô hình chú ếch lại, dùng tay kéo nhẹ hai chân sau ra sau một chút. Nhấn nhẹ vào phần lò xo ở đuôi và thả tay ra để chú ếch bật nhảy!',
            tip: 'Bạn có thể dùng bút vẽ thêm mắt hoặc tô màu trang trí cho chú ếch thêm phần ngộ nghĩnh.',
            seconds: 50,
          ),
        ];
        break;
      case 'box':
        base = [
          (
            title: 'Tạo nếp trục giữa',
            instruction: 'Gấp đôi tờ giấy theo cả chiều ngang và chiều dọc để lấy đường tâm chữ thập.',
            tip: 'Sử dụng giấy cứng hoặc giấy có hai mặt màu khác nhau.',
            seconds: 45,
          ),
          (
            title: 'Gấp góc Blintz',
            instruction: 'Gấp cả bốn góc nhọn của tờ giấy hướng vào đúng điểm tâm trung tâm.',
            tip: 'Cố gắng không để các góc đè lên nhau.',
            seconds: 70,
          ),
          (
            title: 'Tạo nếp thành hộp',
            instruction: 'Gấp hai cạnh đối xứng vào đường giữa, miết kỹ rồi mở ra. Làm tương tự với hai cạnh còn lại.',
            tip: 'Các nếp gấp này sẽ định hình chiều cao của thành hộp.',
            seconds: 90,
          ),
          (
            title: 'Mở hai góc đối diện',
            instruction: 'Mở rộng hai góc đối diện ra ngoài, giữ nguyên hai góc còn lại ở tâm.',
            tip: 'Mẫu lúc này trông giống như một hình thoi dài.',
            seconds: 50,
          ),
          (
            title: 'Dựng thành hộp',
            instruction: 'Dựng đứng hai thành dọc đối diện lên vuông góc với đáy hộp theo các nếp gấp sẵn.',
            tip: 'Giữ cố định hai thành đứng bằng một tay.',
            seconds: 80,
          ),
          (
            title: 'Khóa mép hộp',
            instruction: 'Gấp hai đầu nhọn còn lại vào trong đáy hộp, ôm sát qua thành để khóa chặt cố định hộp.',
            tip: 'Miết chặt các nếp gấp ở góc đáy để hộp vuông vức và đứng vững.',
            seconds: 95,
          ),
        ];
        break;
      case 'dragon':
        base = [
          (
            title: 'Tạo nếp chéo chuẩn bị',
            instruction: 'Gấp chéo tờ giấy vuông để tạo nếp gấp chữ X lớn cắt chéo trung tâm.',
            tip: 'Hãy miết nếp thật nét để tạo điểm tựa cho các bước gấp sau.',
            seconds: 60,
          ),
          (
            title: 'Tạo nếp gấp vuông',
            instruction: 'Xếp gọn các góc giấy chồng lên nhau để hình thành nếp gấp vuông cơ bản (Square Base).',
            tip: 'Giữ cho các góc giấy mở luôn hướng xuống phía dưới.',
            seconds: 80,
          ),
          (
            title: 'Tạo nếp gấp cánh chim',
            instruction: 'Gấp các mép bên vào tâm rồi lật mở để tạo hình cánh chim thon dài (Bird Base) tương tự như hạc.',
            tip: 'Các lớp giấy chồng lên nhau cần được vuốt thật mỏng và đều.',
            seconds: 120,
          ),
          (
            title: 'Gập đôi lật thân rồng',
            instruction: 'Gập đôi dọc theo sống giữa và lật hướng đôi cánh dài hướng xuống dưới để làm thân rồng.',
            tip: 'Đảm bảo trục giữa hoàn toàn thẳng hàng.',
            seconds: 90,
          ),
          (
            title: 'Tạo đầu và mõm rồng',
            instruction: 'Dùng nếp gấp lật ngược (inside reverse fold) ở một đầu nhọn hướng lên trên để tạo hình sừng và mõm.',
            tip: 'Làm chậm bước này để không làm rách góc nhọn nhỏ.',
            seconds: 130,
          ),
          (
            title: 'Gấp đuôi zíc-zắc',
            instruction: 'Gấp xếp ly zíc-zắc (pleat fold) dọc theo phần đuôi để tạo gai lưng và đuôi rồng uốn lượn.',
            tip: 'Dùng móng tay miết mạnh nếp gấp zíc-zắc để tạo nếp giữ.',
            seconds: 110,
          ),
          (
            title: 'Dựng hình đôi cánh',
            instruction: 'Gập đôi cánh rồng hướng ra ngoài và gấp các đường song song xếp nếp tạo độ phồng cho cánh.',
            tip: 'Tạo độ cong nhẹ để cánh rồng trông như đang bay.',
            seconds: 120,
          ),
          (
            title: 'Hoàn thiện chân đứng',
            instruction: 'Bẻ nhẹ hai góc nhọn ở bụng dưới ra phía trước tạo thành chân rồng nhỏ hỗ trợ thăng bằng.',
            tip: 'Chỉnh lại form cổ rồng hướng cao lên kiêu hãnh và kiểm tra độ đứng vững.',
            seconds: 100,
          ),
        ];
        break;
      case 'shuriken':
        base = [
          (
            title: 'Chuẩn bị hai mảnh giấy',
            instruction: 'Sử dụng hai dải giấy hình chữ nhật dài có màu sắc tương phản nhau.',
            tip: 'Tỷ lệ chiều rộng bằng một phần tư chiều dài là tốt nhất.',
            seconds: 40,
          ),
          (
            title: 'Gấp đôi chiều dọc',
            instruction: 'Gấp đôi cả hai mảnh giấy theo chiều dọc để tạo thành hai dải hẹp cứng cáp.',
            tip: 'Miết thật phẳng để dải giấy không bị phồng.',
            seconds: 50,
          ),
          (
            title: 'Gấp góc đối xứng',
            instruction: 'Gấp hai góc ở hai đầu của mỗi mảnh giấy theo hướng ngược nhau tạo hình bình hành.',
            tip: 'Quan trọng: Hai mảnh giấy phải được gấp đối xứng ngược chiều nhau hoàn toàn.',
            seconds: 80,
          ),
          (
            title: 'Tạo hình tam giác nhỏ',
            instruction: 'Tiếp tục gập các góc nhọn vào phía trong tạo thành hai tam giác gối đầu nhau trên mỗi dải.',
            tip: 'Mỗi mảnh lúc này sẽ trông như hai hình tam giác dính nhau.',
            seconds: 70,
          ),
          (
            title: 'Lắp ráp mảnh ghép chéo',
            instruction: 'Đặt mảnh thứ nhất nằm ngang, mảnh thứ hai nằm dọc chéo lên trên tạo hình chữ X.',
            tip: 'Giữ chặt điểm giao nhau ở trung tâm.',
            seconds: 70,
          ),
          (
            title: 'Khóa các góc phi tiêu',
            instruction: 'Lần lượt gài các góc nhọn của mảnh này vào các khe gấp có sẵn của mảnh kia để khóa chặt liên kết.',
            tip: 'Dùng đầu tăm hoặc tay miết chặt để bốn cạnh phi tiêu phẳng và khít đều.',
            seconds: 110,
          ),
        ];
        break;
      case 'swan':
        base = [
          (
            title: 'Chuẩn bị giấy thoi',
            instruction: 'Dùng giấy vuông, mặt màu úp xuống dưới, gấp chéo tạo nếp giữa rồi mở ra.',
            tip: 'Nên chọn giấy màu một mặt trắng một mặt màu để phân biệt rõ.',
            seconds: 40,
          ),
          (
            title: 'Gấp hình diều',
            instruction: 'Gấp hai cạnh bên sát mép vào trục nếp giữa tạo thành hình chiếc diều thon dài.',
            tip: 'Miết nhẹ từ đỉnh nhọn ra ngoài.',
            seconds: 60,
          ),
          (
            title: 'Gấp thon cổ',
            instruction: 'Lật mặt sau của giấy, tiếp tục gấp hai cạnh bên hướng vào trục giữa một lần nữa.',
            tip: 'Phần đầu nhọn lúc này sẽ rất dài và mảnh để làm cổ thiên nga.',
            seconds: 80,
          ),
          (
            title: 'Gập đôi tạo cổ',
            instruction: 'Gấp ngược góc nhọn dài phía dưới lên sát góc nhọn ngắn phía trên để tạo dáng cổ đứng.',
            tip: 'Đảm bảo cổ thiên nga thẳng hàng với trục thân.',
            seconds: 70,
          ),
          (
            title: 'Tạo đầu và mỏ',
            instruction: 'Bẻ gập một đoạn nhỏ đầu nhọn của cổ thiên nga hướng ra phía trước để làm đầu và mỏ.',
            tip: 'Có thể gấp nếp xếp ly nhỏ để mỏ thiên nga hướng xuống.',
            seconds: 60,
          ),
          (
            title: 'Gập đôi dọc hoàn thiện',
            instruction: 'Gập đôi toàn bộ mẫu theo chiều dọc hướng ra sau, kéo nhẹ cổ thiên nga hướng lên và miết chặt nếp giữ.',
            tip: 'Uốn cong nhẹ phần đuôi phía sau để thiên nga trông duyên dáng hơn.',
            seconds: 90,
          ),
        ];
        break;
      case 'butterfly':
        base = [
          (
            title: 'Gấp nếp cơ bản',
            instruction: 'Gấp đôi tờ giấy vuông theo cả đường chéo và đường vuông góc, sau đó mở phẳng ra.',
            tip: 'Miết kỹ để các nếp giao nhau tại đúng tâm hình vuông.',
            seconds: 50,
          ),
          (
            title: 'Tạo tam giác kép',
            instruction: 'Thu gọn giấy theo các nếp gấp chéo để tạo thành hình tam giác kép (Waterbomb Base).',
            tip: 'Mỗi bên sẽ có hai lá tam giác chồng lên nhau.',
            seconds: 70,
          ),
          (
            title: 'Gấp cánh trên',
            instruction: 'Gấp hai góc nhọn của lớp tam giác phía trên xuống sát góc nhọn ở đáy.',
            tip: 'Chỉ gấp lớp giấy phía trên, giữ nguyên lớp dưới.',
            seconds: 60,
          ),
          (
            title: 'Gấp lật đuôi sau',
            instruction: 'Lật mặt sau của tam giác, kéo góc nhọn ở đáy lên phía trên vượt qua mép ngang một khoảng nhỏ.',
            tip: 'Góc nhọn này sẽ kéo cong nhẹ hai cánh bướm phía dưới lên.',
            seconds: 80,
          ),
          (
            title: 'Gài khóa cánh bướm',
            instruction: 'Bẻ góc nhọn thừa vượt quá mép đè ra phía trước để gài chặt giữ cố định hình dáng.',
            tip: 'Miết chặt góc gài khóa để giấy không tự bung ra.',
            seconds: 60,
          ),
          (
            title: 'Tạo độ cong đôi cánh',
            instruction: 'Gấp nhẹ đôi cánh dọc theo trục giữa hướng vào trong rồi buông nhẹ để cánh bướm xòe tự nhiên.',
            tip: 'Không miết nếp gấp giữa quá mạnh để giữ độ cong 3D cho cánh bướm.',
            seconds: 80,
          ),
        ];
        break;
      case 'dinosaur':
        base = [
          (
            title: 'Tạo nếp gấp hình diều',
            instruction: 'Gấp chéo giấy tạo nếp gấp dọc trung tâm, sau đó gấp hai cạnh bên trên hướng vào đường giữa.',
            tip: 'Sử dụng giấy vuông kích thước lớn (khoảng 20cm) để dễ thực hiện.',
            seconds: 60,
          ),
          (
            title: 'Tạo hình diều kép',
            instruction: 'Lật mặt sau của giấy, tiếp tục gấp hai cạnh bên phía dưới hướng vào đường trung tâm.',
            tip: 'Giữ các cạnh giấy thẳng khít và không chồng lên nhau.',
            seconds: 80,
          ),
          (
            title: 'Gấp thon cổ và đuôi',
            instruction: 'Gấp hai góc bên tiếp tục hướng sát vào trục giữa một lần nữa để làm thon gọn phần đuôi và cổ.',
            tip: 'Mẫu lúc này rất thon và dài ở cả hai đầu.',
            seconds: 90,
          ),
          (
            title: 'Gập đôi dọc tạo thân',
            instruction: 'Gập đôi toàn bộ mẫu theo chiều dọc để chuẩn bị định hình các chi tiết đầu và đuôi.',
            tip: 'Tất cả các nếp gấp chéo cần phẳng phiu.',
            seconds: 80,
          ),
          (
            title: 'Lật ngược cổ và đuôi',
            instruction: 'Dùng nếp gấp lật ngược (inside reverse fold) bẻ đầu nhọn trước lên làm cổ, đầu sau gập chúc xuống làm đuôi.',
            tip: 'Kéo nhẹ góc giấy để định lượng độ dài và độ cao của cổ.',
            seconds: 110,
          ),
          (
            title: 'Tạo đầu khủng long',
            instruction: 'Gập ngược đầu nhọn trên đỉnh cổ hướng xuống dưới một lần nữa để rút ngắn mõm và tạo hình đầu T-Rex.',
            tip: 'Dùng đầu ngón tay miết chặt các lớp giấy dày ở cổ.',
            seconds: 100,
          ),
          (
            title: 'Tạo bàn chân thăng bằng',
            instruction: 'Tạo hai nếp gấp nhỏ lật ngược ở chân dưới hướng ra phía trước để làm bàn chân đứng.',
            tip: 'Cân chỉnh góc mở hai chân để khủng long có thể đứng thăng bằng trên mặt bàn.',
            seconds: 120,
          ),
          (
            title: 'Hoàn thiện hai tay trước',
            instruction: 'Gập hai dải nhọn nhỏ phía trước ngực hướng xuống dưới làm hai cánh tay ngắn đặc trưng của T-Rex.',
            tip: 'Vuốt lại phần gai lưng và đuôi để hoàn thiện tư thế đứng kiêu hãnh.',
            seconds: 90,
          ),
        ];
        break;
      case 'turtle':
        base = [
          (
            title: 'Gấp đôi tạo nếp chéo',
            instruction: 'Gấp đôi tờ giấy theo đường chéo tạo nếp gấp núi, sau đó mở ra để lấy trục chéo.',
            tip: 'Đường chéo sẽ đóng vai trò trục xương sống của rùa biển.',
            seconds: 40,
          ),
          (
            title: 'Gập đôi lấy trục ngang',
            instruction: 'Gấp đôi từ mép dưới lên mép trên để lấy đường nếp ngang vuông góc.',
            tip: 'Hãy miết chặt để đường nếp hiện rõ.',
            seconds: 40,
          ),
          (
            title: 'Mở rộng góc tam giác',
            instruction: 'Gài mở lớp giấy ở góc phía trên bên trái ra rồi vuốt phẳng tạo thành hình tam giác.',
            tip: 'Đặt tay vào giữa kẽ giấy để đẩy đều ra hai bên.',
            seconds: 60,
          ),
          (
            title: 'Gập dẹt khóa góc trái',
            instruction: 'Gấp ép dẹt lớp tam giác vừa mở xuống để khóa chặt nếp bên trái.',
            tip: 'Đây là thao tác chuẩn bị tạo vây bơi trước.',
            seconds: 50,
          ),
          (
            title: 'Lật mặt sau',
            instruction: 'Lật ngược mặt sau của tờ giấy ra phía trước một cách cẩn thận.',
            tip: 'Giữ các nếp gấp trước đó không bị xô lệch.',
            seconds: 35,
          ),
          (
            title: 'Tạo tam giác kép',
            instruction: 'Thực hiện tương tự thao tác mở và gập dẹt cho bên phải để hoàn chỉnh tam giác kép.',
            tip: 'Tam giác kép này là khung xương chính cho toàn bộ mẫu.',
            seconds: 70,
          ),
          (
            title: 'Lấy nếp mép dưới',
            instruction: 'Gập các góc nhọn ở đáy dưới hướng vào đường tâm giữa rồi mở ra lấy nếp.',
            tip: 'Nếp này sẽ hỗ trợ tạo hình chân sau của rùa.',
            seconds: 55,
          ),
          (
            title: 'Gấp mở mai rùa',
            instruction: 'Nâng lớp giấy dưới cùng hướng lên trên để làm phồng và khóa nếp gấp mai rùa.',
            tip: 'Kéo nhẹ để giấy phồng đều không bị rách góc.',
            seconds: 80,
          ),
          (
            title: 'Thu gọn thân giữa',
            instruction: 'Xếp các mép giấy ở thân giữa khít vào nhau theo trục dọc để cố định lưng.',
            tip: 'Miết kỹ hai bên thành để rùa không bị phồng.',
            seconds: 65,
          ),
          (
            title: 'Cắt tạo chi trước',
            instruction: 'Sử dụng kéo cắt dọc sống giữa của lớp trên cùng một đoạn nhỏ theo hình vẽ.',
            tip: 'Đường cắt này chia đôi dải giấy để gấp hai chân trước.',
            seconds: 70,
          ),
          (
            title: 'Gấp vây bơi trước',
            instruction: 'Gập chéo hai cánh vừa cắt sang hai bên để làm vây bơi trước.',
            tip: 'Góc nghiêng của vây trước tạo tư thế rùa như đang bơi.',
            seconds: 60,
          ),
          (
            title: 'Tạo khớp vai vây',
            instruction: 'Gấp nếp gấp lật ngược bên trong ở hai đầu vây trước để tạo độ cong cho chi.',
            tip: 'Miết chặt khớp vai để cố định hướng vây.',
            seconds: 80,
          ),
          (
            title: 'Gập thon thân dưới',
            instruction: 'Gập nhẹ hai mép giấy bên ở thân dưới vào trong để thu nhỏ phần đuôi rùa.',
            tip: 'Bước này giúp phần mai rùa trông to và rõ nét hơn.',
            seconds: 50,
          ),
          (
            title: 'Gấp chân sau',
            instruction: 'Bẻ cụp hai góc nhọn ở đáy dưới chéo ra ngoài làm chân bơi sau.',
            tip: 'Chân sau ngắn hơn và xiên góc rộng hơn chân trước.',
            seconds: 60,
          ),
          (
            title: 'Khóa khớp chân sau',
            instruction: 'Gập nếp xếp ly nhỏ ở hai chân sau để tạo hình mái chèo chèo nước.',
            tip: 'Ấn nhẹ đầu ngón tay tạo nếp gợn sóng.',
            seconds: 50,
          ),
          (
            title: 'Lật lại mặt trước',
            instruction: 'Lật ngược toàn bộ mẫu giấy lại để mặt lưng (mai rùa) hướng lên trên.',
            tip: 'Mẫu lúc này đã hiện rõ hình dáng chú rùa biển.',
            seconds: 40,
          ),
          (
            title: 'Hoàn thiện mai lục giác',
            instruction: 'Căn chỉnh phần mai phẳng phiu, vuốt cong nhẹ 4 góc để tạo thành hình lục giác đứng dáng.',
            tip: 'Đặt rùa lên mặt phẳng và căn chỉnh các chi bơi cân đối.',
            seconds: 90,
          ),
        ];
        break;
      case 'cactus':
        base = [
          (
            title: 'Chuẩn bị nếp dọc',
            instruction: 'Gấp đôi tờ giấy hình vuông theo trục dọc rồi mở ra để lấy nếp tâm.',
            tip: 'Dùng giấy hai mặt màu khác nhau (xanh và cam) là tốt nhất.',
            seconds: 35,
          ),
          (
            title: 'Gấp hình diều',
            instruction: 'Gấp hai cạnh bên phía dưới hướng vào đường nếp giữa tạo thành hình diều.',
            tip: 'Đảm bảo hai mép giấy khít nhau và không đè lên nhau.',
            seconds: 50,
          ),
          (
            title: 'Gập thon đáy chậu',
            instruction: 'Gấp hai góc nhọn phía đáy dưới hướng ngược lên trên để làm thon gọn đáy chậu.',
            tip: 'Gấp khoảng một phần ba chiều cao tam giác đáy.',
            seconds: 60,
          ),
          (
            title: 'Lật ngược khóa đáy',
            instruction: 'Lật ngược nếp gấp đáy vừa gấp vào mặt bên trong để cố định hình chậu.',
            tip: 'Miết chặt để nếp khóa không tự bung ra.',
            seconds: 60,
          ),
          (
            title: 'Tạo nhánh trái',
            instruction: 'Dùng nếp gấp lật ngược một phần lớp giấy bên trái hướng lên để tạo thành nhánh xương rồng.',
            tip: 'Nhánh trái hướng nghiêng khoảng 45 độ.',
            seconds: 70,
          ),
          (
            title: 'Gấp góc nhánh phải',
            instruction: 'Gấp lật góc đuôi giấy bên phải hướng chéo lên trên làm nhánh xương rồng đối diện.',
            tip: 'Nhánh phải nằm thấp hơn nhánh trái một chút cho tự nhiên.',
            seconds: 70,
          ),
          (
            title: 'Gấp ngược tạo thế nhánh',
            instruction: 'Gấp ngược lớp giấy của hai nhánh ra ngoài để tạo độ dày 3D cho các nhánh cây.',
            tip: 'Vuốt nhẹ các mép gấp ở nhánh cây.',
            seconds: 65,
          ),
          (
            title: 'Gấp zíc-zắc thân chậu',
            instruction: 'Gấp xếp ly zíc-zắc (pleat fold) ở đoạn nối giữa thân cây và chậu hoa để phân tầng.',
            tip: 'Nếp gấp này tạo viền nổi cho miệng chậu hoa.',
            seconds: 80,
          ),
          (
            title: 'Chỉnh nhánh trái đứng',
            instruction: 'Gập nếp chéo nhỏ ở khớp nhánh bên trái để hướng nhánh cây mọc thẳng đứng lên.',
            tip: 'Đầu nhánh trái sẽ song song với thân chính.',
            seconds: 55,
          ),
          (
            title: 'Chỉnh nhánh phải đứng',
            instruction: 'Thực hiện tương tự nếp gập chéo cho nhánh bên phải để tạo sự cân đối.',
            tip: 'Hai nhánh lúc này chĩa lên hai bên như hình xương rồng sa mạc.',
            seconds: 55,
          ),
          (
            title: 'Vát chéo thành chậu',
            instruction: 'Gấp gập nhẹ hai mép bên của phần chậu hoa phía dưới ra sau để tạo dáng chậu vát chéo.',
            tip: 'Miệng chậu to hơn đáy chậu.',
            seconds: 60,
          ),
          (
            title: 'Lật ngược mặt trước',
            instruction: 'Lật ngược toàn bộ mẫu giấy lại để mặt trước hiện rõ thân cây màu xanh và chậu màu cam.',
            tip: 'Mẫu đã hoàn thành phần tạo hình cơ bản.',
            seconds: 40,
          ),
          (
            title: 'Hoàn thiện chậu cây',
            instruction: 'Căn chỉnh chậu đứng vững, nắn nhẹ các nhánh xương rồng để tạo độ phồng 3D sinh động.',
            tip: 'Có thể đặt chậu cây lên bàn để trang trí.',
            seconds: 80,
          ),
        ];
        break;
      case 'lion':
        base = [
          (
            title: 'Tạo nếp chéo',
            instruction: 'Gấp chéo tờ giấy hình vuông để lấy nếp gấp giữa rồi mở phẳng ra.',
            tip: 'Nên chọn giấy màu vàng hoặc cam để làm nổi bật chú sư tử.',
            seconds: 35,
          ),
          (
            title: 'Gấp mép vào tâm',
            instruction: 'Gấp hai mép giấy ở góc đối diện hướng vào sát đường tâm chéo.',
            tip: 'Đường gấp đứt nét nằm song song với trục chéo.',
            seconds: 55,
          ),
          (
            title: 'Gấp ngược ra sau',
            instruction: 'Gấp hai mép bên vừa gấp ngược ra phía sau theo nếp gấp núi dọc.',
            tip: 'Mặt màu của bờm sư tử sẽ hiện rõ ở phía sau.',
            seconds: 60,
          ),
          (
            title: 'Thu gọn đầu mõm',
            instruction: 'Gập tiếp hai mép nhọn nhỏ ở đầu bên trái ra sau để thu gọn mõm sư tử.',
            tip: 'Nếp gấp này tạo hình cho khuôn mặt thon gọn.',
            seconds: 50,
          ),
          (
            title: 'Gập đôi dọc',
            instruction: 'Gập đôi toàn bộ mẫu theo chiều dọc dọc theo trục giữa.',
            tip: 'Dáng sư tử bắt đầu được hình thành.',
            seconds: 45,
          ),
          (
            title: 'Lật ngược dựng cổ',
            instruction: 'Dùng nếp gấp lật ngược bên ngoài (outside reverse fold) bẻ đầu nhọn trái hướng thẳng đứng lên.',
            tip: 'Cổ sư tử vuông góc với đường lưng.',
            seconds: 70,
          ),
          (
            title: 'Gấp rộng bờm sư tử',
            instruction: 'Gập đè lớp cổ hướng xuống hai bên để xòe rộng phần bờm sư tử ra.',
            tip: 'Bờm rộng bao quanh cổ là đặc trưng dũng mãnh.',
            seconds: 80,
          ),
          (
            title: 'Tạo mõm và hàm',
            instruction: 'Lật gập lớp mõm nhọn phía trước hướng chúc xuống dưới để tạo hình hàm dưới.',
            tip: 'Gấp nhẹ tay để đầu mõm không bị rách.',
            seconds: 60,
          ),
          (
            title: 'Bo tròn bờm',
            instruction: 'Gấp ngược các góc nhọn ngoài của bờm ra sau để tạo bờm mặt tròn trịa.',
            tip: 'Miết nhẹ các nếp bo góc ở bờm.',
            seconds: 65,
          ),
          (
            title: 'Thu gọn thân sau',
            instruction: 'Bẻ gập mép giấy ở thân sau hướng vào trong để thu nhỏ phần mông sư tử.',
            tip: 'Nếp gấp giúp cơ thể sư tử trông thon gọn và cân đối.',
            seconds: 50,
          ),
          (
            title: 'Gập đuôi chéo',
            instruction: 'Gấp chéo phần đuôi nhọn dài phía sau hướng chúc xuống đất để làm chân sau.',
            tip: 'Chân sau giúp sư tử đứng vững chãi.',
            seconds: 60,
          ),
          (
            title: 'Tạo khớp gối sau',
            instruction: 'Gập ngược đầu nhọn đuôi hướng lên trên để làm khớp chân và thế đứng.',
            tip: 'Căn góc gối cho cân đối với chân trước.',
            seconds: 55,
          ),
          (
            title: 'Bẻ nhỏ đuôi',
            instruction: 'Gập lật ngược đuôi sư tử một lần nữa chĩa ra sau để tạo đuôi nhỏ.',
            tip: 'Đuôi nhỏ chúc lên tạo sự sinh động.',
            seconds: 50,
          ),
          (
            title: 'Vẽ mặt hoàn thiện',
            instruction: 'Dùng bút vẽ thêm mắt, mũi và râu lên mặt để hoàn thành chú sư tử oai vệ.',
            tip: 'Sư tử có thể tự đứng vững trên 4 chi.',
            seconds: 90,
          ),
        ];
        break;
      default:
        base = [
          (
            title: 'Chuẩn bị giấy',
            instruction: 'Đặt mặt màu úp xuống, xoay giấy thành hình thoi và miết nhẹ để giấy phẳng.',
            tip: 'Giữ hai góc đối diện cùng nằm trên một đường thẳng.',
            seconds: 45,
          ),
          (
            title: 'Tạo nếp trung tâm',
            instruction: 'Gấp đôi theo đường chéo, mở ra, sau đó gấp đường chéo còn lại để có tâm chính xác.',
            tip: 'Nếp đầu tiên quyết định độ cân của toàn bộ mẫu.',
            seconds: 70,
          ),
          (
            title: 'Khóa hình cơ bản',
            instruction: 'Đưa bốn góc về tâm theo đúng thứ tự trong hình mô phỏng và ép phẳng từng cạnh.',
            tip: 'Không kéo căng giấy, chỉ dẫn nếp bằng đầu ngón tay.',
            seconds: 95,
          ),
          (
            title: 'Tạo chi tiết chính',
            instruction: 'Gấp các mép theo trục giữa để hình thành phần đặc trưng của mẫu.',
            tip: 'Nếu hai mép không gặp nhau, mở ra và chỉnh lại từ nếp trung tâm.',
            seconds: 110,
          ),
          (
            title: 'Đảo nếp và dựng hình',
            instruction: 'Mở nhẹ lớp giấy, đảo nếp theo dấu có sẵn rồi dựng khối 3D.',
            tip: 'Đây là bước dễ rách giấy nhất, hãy làm chậm.',
            seconds: 120,
          ),
          (
            title: 'Hoàn thiện',
            instruction: 'Căn chỉnh các góc, miết lại nếp khóa và kiểm tra mẫu đứng vững.',
            tip: 'Chụp lại thành quả để lưu vào nhật ký cá nhân.',
            seconds: 80,
          ),
        ];
        break;
    }

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
          imageKey: model.imageKey == 'crane'
              ? craneImages[i]
              : model.imageKey == 'frog'
                  ? frogImages[i]
                  : '${model.imageKey}_${i + 1}',
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
      case 'swan':
        return 'độ cong mềm mại của cổ thiên nga';
      case 'butterfly':
        return 'nếp gấp ly đối xứng tạo cánh bướm';
      case 'dinosaur':
        return 'nếp gấp lật ngược để tạo đầu và đuôi khủng long';
      case 'turtle':
        return 'hình dạng phẳng cân đối của bốn chi bơi và độ nổi của mai';
      case 'cactus':
        return 'độ xiên tự nhiên của các nhánh xương rồng và viền chậu';
      case 'lion':
        return 'độ to rộng bo tròn của bờm và dáng đứng vững của 4 chân';
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
