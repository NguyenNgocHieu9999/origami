import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/origami_database.dart';
import '../models/origami_models.dart';
import '../services/ai_coach_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    OrigamiDatabase? database,
    AiCoachService? aiCoachService,
    GoogleSignIn? googleSignIn,
  }) : _database = database ?? OrigamiDatabase.instance,
       _aiCoachService = aiCoachService ?? const AiCoachService(),
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: const ['email', 'profile'],
             clientId: kIsWeb
                 ? '1098757259381-5dklrb1gi164aiq39etflrkkh216te5g.apps.googleusercontent.com'
                 : null,
           ) {
    try {
      showWelcome = !WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } catch (_) {
      showWelcome = false;
    }
  }

  final OrigamiDatabase _database;
  final AiCoachService _aiCoachService;
  final GoogleSignIn _googleSignIn;

  bool isLoading = true;
  bool isAiLoading = false;
  bool showWelcome = true;
  String? errorMessage;
  String? aiAnswer;
  String aiProvider = 'pollinations';
  String? geminiApiKey;
  String? groqApiKey;
  String? openrouterApiKey;
  AppUser? currentUser;
  OrigamiModel? selectedModel;
  List<OrigamiModel> models = [];
  List<AchievementEntry> achievements = [];
  List<CompletedStep> completedSteps = [];
  final Map<int, List<OrigamiStep>> _stepsByModel = {};

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      aiProvider = prefs.getString('ai_provider') ?? 'pollinations';
      geminiApiKey = prefs.getString('gemini_api_key');
      groqApiKey = prefs.getString('groq_api_key');
      openrouterApiKey = prefs.getString('openrouter_api_key');
      currentUser = await _database.getUser();
      models = await _database.getModels();
      completedSteps = await _database.getCompletedSteps();
      achievements = await _database.getAchievements();
      selectedModel = models.firstOrNull;
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Không khởi tạo được dữ liệu: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void dismissWelcome() {
    showWelcome = false;
    notifyListeners();
  }

  Future<List<OrigamiStep>> stepsFor(int modelId) async {
    final cached = _stepsByModel[modelId];
    if (cached != null) {
      return cached;
    }
    final steps = await _database.getSteps(modelId);
    _stepsByModel[modelId] = steps;
    return steps;
  }

  Set<int> completedStepIdsFor(int modelId) {
    return completedSteps
        .where((item) => item.modelId == modelId)
        .map((item) => item.stepId)
        .toSet();
  }

  double progressFor(int modelId) {
    final steps = _stepsByModel[modelId];
    if (steps == null || steps.isEmpty) {
      return 0;
    }
    return completedStepIdsFor(modelId).length / steps.length;
  }

  Future<void> selectModel(OrigamiModel model) async {
    selectedModel = model;
    await stepsFor(model.id);
    notifyListeners();
  }

  Future<void> toggleFavorite(OrigamiModel model) async {
    await _database.setFavorite(model.id, !model.isFavorite);
    models = await _database.getModels();
    selectedModel =
        models.where((item) => item.id == model.id).firstOrNull ??
        selectedModel;
    notifyListeners();
  }

  Future<void> toggleStep(
    OrigamiModel model,
    OrigamiStep step,
    bool completed,
  ) async {
    await _database.setStepCompleted(
      modelId: model.id,
      stepId: step.id,
      completed: completed,
    );
    completedSteps = await _database.getCompletedSteps();
    notifyListeners();
  }

  CompletionRuleResult canComplete(
    OrigamiModel model,
    List<OrigamiStep> steps,
    int rating,
  ) {
    final completed = completedStepIdsFor(model.id);
    final missing = steps.where((step) => !completed.contains(step.id)).length;
    if (missing > 0) {
      return CompletionRuleResult(
        allowed: false,
        message: 'Cần tick đủ $missing bước còn thiếu trước khi ghi thành quả.',
      );
    }
    if (rating < 3) {
      return const CompletionRuleResult(
        allowed: false,
        message: 'Rating tối thiểu là 3 sao để được tính hoàn thành.',
      );
    }
    if (model.difficulty >= 3) {
      final completionTimes = {
        for (final cs in completedSteps)
          if (cs.modelId == model.id) cs.stepId: cs.completedAt,
      };
      for (int i = 0; i < steps.length - 1; i++) {
        final currentStepTime = completionTimes[steps[i].id];
        final nextStepTime = completionTimes[steps[i + 1].id];
        if (currentStepTime != null &&
            nextStepTime != null &&
            currentStepTime.isAfter(nextStepTime)) {
          return const CompletionRuleResult(
            allowed: false,
            message:
                'Mẫu khó cần hoàn tất toàn bộ checkpoint theo đúng thứ tự.',
          );
        }
      }
    }
    return const CompletionRuleResult(
      allowed: true,
      message: 'Đủ điều kiện lưu thành quả và xét huy hiệu.',
    );
  }

  Future<CompletionRuleResult> addAchievement({
    required OrigamiModel model,
    required String note,
    required int rating,
    required int minutesSpent,
    String? photoPath,
  }) async {
    final steps = await stepsFor(model.id);
    final rule = canComplete(model, steps, rating);
    if (!rule.allowed) {
      return rule;
    }

    await _database.insertAchievement(
      AchievementEntry(
        modelId: model.id,
        modelTitle: model.title,
        note: note.trim().isEmpty
            ? 'Đã hoàn thành ${model.title}'
            : note.trim(),
        rating: rating,
        completedAt: DateTime.now(),
        minutesSpent: minutesSpent,
        photoPath: photoPath?.trim().isEmpty ?? true ? null : photoPath?.trim(),
      ),
    );
    achievements = await _database.getAchievements();
    notifyListeners();
    return const CompletionRuleResult(
      allowed: true,
      message: 'Đã lưu thành quả.',
    );
  }

  Future<void> updateAchievement(AchievementEntry entry) async {
    await _database.updateAchievement(entry);
    achievements = await _database.getAchievements();
    notifyListeners();
  }

  Future<void> deleteAchievement(int id) async {
    await _database.deleteAchievement(id);
    achievements = await _database.getAchievements();
    notifyListeners();
  }

  List<BadgeAward> badgeAwards() {
    final completedModelIds = achievements.map((item) => item.modelId).toSet();
    final averageRating = achievements.isEmpty
        ? 0.0
        : achievements.map((item) => item.rating).reduce((a, b) => a + b) /
              achievements.length;
    final hasHardModel = achievements.any((entry) {
      final model = models
          .where((item) => item.id == entry.modelId)
          .firstOrNull;
      return model != null && model.difficulty >= 3;
    });

    return [
      BadgeAward(
        code: 'first_fold',
        title: 'Nếp gấp đầu tiên',
        description: 'Hoàn thành mẫu origami đầu tiên.',
        unlocked: achievements.isNotEmpty,
      ),
      BadgeAward(
        code: 'collector',
        title: 'Bộ sưu tập nhỏ',
        description: 'Hoàn thành 3 mẫu khác nhau.',
        unlocked: completedModelIds.length >= 3,
      ),
      BadgeAward(
        code: 'precision',
        title: 'Tay gấp chuẩn',
        description: 'Rating trung bình từ 4 sao.',
        unlocked: achievements.length >= 2 && averageRating >= 4,
      ),
      BadgeAward(
        code: 'challenge',
        title: 'Vượt mẫu khó',
        description: 'Hoàn thành ít nhất 1 mẫu độ khó 3+.',
        unlocked: hasHardModel,
      ),
    ];
  }

  OrigamiModel? recommendedModel() {
    if (models.isEmpty) {
      return null;
    }
    final completedModelIds = achievements.map((item) => item.modelId).toSet();
    final unfinished = models
        .where((model) => !completedModelIds.contains(model.id))
        .toList();
    if (unfinished.isEmpty) {
      return models.reduce((a, b) => a.difficulty >= b.difficulty ? a : b);
    }
    unfinished.sort((a, b) {
      final favoriteCompare = (b.isFavorite ? 1 : 0).compareTo(
        a.isFavorite ? 1 : 0,
      );
      if (favoriteCompare != 0) {
        return favoriteCompare;
      }
      return a.difficulty.compareTo(b.difficulty);
    });
    return unfinished.first;
  }

  Future<void> askAi(String question) async {
    isAiLoading = true;
    aiAnswer = null;
    notifyListeners();
    try {
      final model = selectedModel;
      final steps = model == null ? <OrigamiStep>[] : await stepsFor(model.id);

      String? activeKey;
      if (aiProvider == 'gemini') {
        activeKey = geminiApiKey;
      } else if (aiProvider == 'groq') {
        activeKey = groqApiKey;
      } else if (aiProvider == 'openrouter') {
        activeKey = openrouterApiKey;
      }

      aiAnswer = await _aiCoachService.ask(
        question: question,
        model: model,
        steps: steps,
        apiKey: activeKey,
        provider: aiProvider,
      );
    } catch (error) {
      aiAnswer = 'Không tạo được hướng dẫn AI: $error';
    } finally {
      isAiLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAiConfig({
    required String provider,
    String? geminiKey,
    String? groqKey,
    String? openrouterKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    aiProvider = provider;
    await prefs.setString('ai_provider', provider);

    geminiApiKey = geminiKey?.trim().isEmpty ?? true ? null : geminiKey!.trim();
    if (geminiApiKey == null) {
      await prefs.remove('gemini_api_key');
    } else {
      await prefs.setString('gemini_api_key', geminiApiKey!);
    }

    groqApiKey = groqKey?.trim().isEmpty ?? true ? null : groqKey!.trim();
    if (groqApiKey == null) {
      await prefs.remove('groq_api_key');
    } else {
      await prefs.setString('groq_api_key', groqApiKey!);
    }

    openrouterApiKey = openrouterKey?.trim().isEmpty ?? true ? null : openrouterKey!.trim();
    if (openrouterApiKey == null) {
      await prefs.remove('openrouter_api_key');
    } else {
      await prefs.setString('openrouter_api_key', openrouterApiKey!);
    }

    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }
      final user = AppUser(
        id: account.id,
        name: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: account.photoUrl,
      );
      await _database.saveUser(user);
      currentUser = user;
      errorMessage = null;
    } catch (error) {
      errorMessage =
          'Đăng nhập Google thất bại. Hãy kiểm tra cấu hình OAuth/SHA-1: $error';
    }
    notifyListeners();
  }

  Future<void> signInDemo() async {
    final user = const AppUser(
      id: 'demo-gmail-user',
      name: 'Sinh viên Origami',
      email: 'sinhvien.origami@gmail.com',
    );
    await _database.saveUser(user);
    currentUser = user;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // GoogleSignIn can throw when no platform account is attached.
    }
    await _database.clearUser();
    currentUser = null;
    notifyListeners();
  }

  Future<void> resetDatabase() async {
    isLoading = true;
    notifyListeners();
    try {
      await _database.resetDatabase();
      models = await _database.getModels();
      completedSteps = await _database.getCompletedSteps();
      achievements = await _database.getAchievements();
      selectedModel = models.firstOrNull;
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Không reset được dữ liệu: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
