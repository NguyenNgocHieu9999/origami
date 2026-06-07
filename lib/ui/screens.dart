import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/origami_models.dart';
import '../state/app_state.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

extension AppContext on BuildContext {
  AppState get appState => AppScope.of(this);
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _titles = ['Tổng quan', 'Mẫu gấp', 'Thành quả', 'AI Coach'];

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final screens = [
      HomeScreen(onOpenCatalog: () => setState(() => _index = 1)),
      const CatalogScreen(),
      const JournalScreen(),
      const AiCoachScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      drawer: AppDrawer(
        onSelectTab: (index) {
          Navigator.of(context).pop();
          setState(() => _index = index);
        },
      ),
      body: SafeArea(child: screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined),
            selectedIcon: Icon(Icons.view_list),
            label: 'Mẫu',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Kết quả',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
        ],
      ),
      floatingActionButton: state.errorMessage == null
          ? null
          : FloatingActionButton.small(
              tooltip: 'Thông báo lỗi',
              onPressed: () => _showSnack(context, state.errorMessage!),
              child: const Icon(Icons.info_outline),
            ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final user = state.currentUser;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4F8A8B)),
            accountName: Text(user?.name ?? 'Chưa đăng nhập'),
            accountEmail: Text(user?.email ?? 'Đăng nhập Gmail để lưu hồ sơ'),
            currentAccountPicture: Avatar(user: user, radius: 30),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Tổng quan'),
            onTap: () => onSelectTab(0),
          ),
          ListTile(
            leading: const Icon(Icons.view_list_outlined),
            title: const Text('Danh sách kiểu gấp'),
            onTap: () => onSelectTab(1),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Thành quả bản thân'),
            onTap: () => onSelectTab(2),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('AI hướng dẫn'),
            onTap: () => onSelectTab(3),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule_outlined),
            title: const Text('Business Rule'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RulesScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenCatalog});

  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final user = state.currentUser;
    final completedModels = state.achievements
        .map((entry) => entry.modelId)
        .toSet()
        .length;
    final badges = state.badgeAwards();
    final unlockedBadges = badges.where((badge) => badge.unlocked).length;
    final recommendation = state.recommendedModel();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HeaderPanel(user: user),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Mẫu gấp',
                value: '${state.models.length}',
                icon: Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Đã hoàn thành',
                value: '$completedModels',
                icon: Icons.task_alt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Huy hiệu',
                value: '$unlockedBadges/${badges.length}',
                icon: Icons.military_tech_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recommendation != null)
          RecommendationPanel(
            model: recommendation,
            onTap: () {
              state.selectModel(recommendation);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrigamiDetailScreen(model: recommendation),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Huy hiệu tiến độ',
          actionLabel: 'Xem mẫu',
          onAction: onOpenCatalog,
        ),
        const SizedBox(height: 8),
        for (final badge in badges) BadgeTile(badge: badge),
      ],
    );
  }
}

class HeaderPanel extends StatelessWidget {
  const HeaderPanel({super.key, required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3A3D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Avatar(user: user, radius: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null ? 'Origami Mentor' : 'Xin chào, ${user!.name}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ??
                      'Theo dõi từng nếp gấp, lưu thành quả và hỏi AI khi bị kẹt.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF4F8A8B)),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class RecommendationPanel extends StatelessWidget {
  const RecommendationPanel({
    super.key,
    required this.model,
    required this.onTap,
  });

  final OrigamiModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              OrigamiArt(model: model, size: 88),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý tiếp theo',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${model.category} • ${model.minutes} phút • Độ khó ${model.difficulty}/4',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _query = '';
  String _category = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final categories = [
      'Tất cả',
      ...state.models.map((item) => item.category).toSet(),
    ];
    final filtered = state.models.where((model) {
      final matchCategory =
          _category == 'Tất cả' || model.category == _category;
      final matchQuery =
          model.title.toLowerCase().contains(_query.toLowerCase()) ||
          model.description.toLowerCase().contains(_query.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Tìm kiểu gấp giấy',
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ChoiceChip(
                label: Text(category),
                selected: _category == category,
                onSelected: (_) => setState(() => _category = category),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        for (final model in filtered) ...[
          ModelCard(model: model),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class ModelCard extends StatelessWidget {
  const ModelCard({super.key, required this.model});

  final OrigamiModel model;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return FutureBuilder<List<OrigamiStep>>(
      future: state.stepsFor(model.id),
      builder: (context, snapshot) {
        final steps = snapshot.data ?? const <OrigamiStep>[];
        final completed = state.completedStepIdsFor(model.id).length;
        final progress = steps.isEmpty ? 0.0 : completed / steps.length;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              await state.selectModel(model);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrigamiDetailScreen(model: model),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  OrigamiArt(model: model, size: 76),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              tooltip: model.isFavorite
                                  ? 'Bỏ yêu thích'
                                  : 'Yêu thích',
                              icon: Icon(
                                model.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () => state.toggleFavorite(model),
                            ),
                          ],
                        ),
                        Text(
                          model.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 6),
                        Text(
                          '$completed/${steps.length} bước • ${model.paperSize} • Độ khó ${model.difficulty}/4',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrigamiDetailScreen extends StatelessWidget {
  const OrigamiDetailScreen({super.key, required this.model});

  final OrigamiModel model;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return Scaffold(
      appBar: AppBar(
        title: Text(model.title),
        actions: [
          IconButton(
            tooltip: 'Hỏi AI',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () {
              state.selectModel(model);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AiCoachScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<OrigamiStep>>(
        future: state.stepsFor(model.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final steps = snapshot.data!;
          final completed = state.completedStepIdsFor(model.id);
          final progress = steps.isEmpty
              ? 0.0
              : completed.length / steps.length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrigamiArt(model: model, size: 110),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('${model.minutes} phút')),
                            Chip(label: Text(model.paperSize)),
                            Chip(label: Text('Độ khó ${model.difficulty}/4')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progress, minHeight: 8),
              const SizedBox(height: 8),
              Text('${completed.length}/${steps.length} bước đã hoàn thành'),
              const SizedBox(height: 16),
              for (final step in steps)
                StepTile(
                  step: step,
                  completed: completed.contains(step.id),
                  onChanged: (value) =>
                      state.toggleStep(model, step, value ?? false),
                ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: const Icon(Icons.add_task),
                label: const Text('Ghi nhận thành quả'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AchievementFormScreen(model: model),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  const StepTile({
    super.key,
    required this.step,
    required this.completed,
    required this.onChanged,
  });

  final OrigamiStep step;
  final bool completed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: completed,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('Bước ${step.stepOrder}: ${step.title}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.instruction),
              const SizedBox(height: 6),
              Text(
                'Mẹo: ${step.tip}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final entries = state.achievements;
    return Scaffold(
      body: entries.isEmpty
          ? EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Chưa có thành quả',
              message:
                  'Hoàn tất đủ các bước của một mẫu rồi lưu nhật ký để mở huy hiệu.',
              actionLabel: 'Tạo nhật ký',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AchievementFormScreen(),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in entries) AchievementCard(entry: entry),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nhật ký'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AchievementFormScreen()),
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key, required this.entry});

  final AchievementEntry entry;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.modelTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Sửa',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AchievementFormScreen(entry: entry),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa thành quả?'),
                        content: const Text(
                          'Nhật ký này sẽ bị xóa khỏi SQLite local.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Hủy'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await state.deleteAchievement(entry.id!);
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('${entry.rating} sao')),
                Chip(label: Text('${entry.minutesSpent} phút')),
                Chip(label: Text(_dateText(entry.completedAt))),
              ],
            ),
            const SizedBox(height: 8),
            Text(entry.note),
            if (entry.photoPath != null) ...[
              const SizedBox(height: 8),
              Text(
                'Ảnh local: ${entry.photoPath}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AchievementFormScreen extends StatefulWidget {
  const AchievementFormScreen({super.key, this.model, this.entry});

  final OrigamiModel? model;
  final AchievementEntry? entry;

  @override
  State<AchievementFormScreen> createState() => _AchievementFormScreenState();
}

class _AchievementFormScreenState extends State<AchievementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  late final TextEditingController _minutesController;
  late final TextEditingController _photoController;
  OrigamiModel? _model;
  int _rating = 4;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _noteController = TextEditingController(text: entry?.note ?? '');
    _minutesController = TextEditingController(
      text: '${entry?.minutesSpent ?? widget.model?.minutes ?? 10}',
    );
    _photoController = TextEditingController(text: entry?.photoPath ?? '');
    _rating = entry?.rating ?? 4;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.appState;
    _model ??=
        widget.model ??
        state.models
            .where((model) => model.id == widget.entry?.modelId)
            .firstOrNull ??
        state.selectedModel ??
        state.models.firstOrNull;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _minutesController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa thành quả' : 'Ghi nhận thành quả'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<OrigamiModel>(
              initialValue: _model,
              decoration: const InputDecoration(labelText: 'Mẫu gấp'),
              items: [
                for (final model in state.models)
                  DropdownMenuItem(value: model, child: Text(model.title)),
              ],
              onChanged: _isEditing
                  ? null
                  : (value) => setState(() => _model = value),
              validator: (value) => value == null ? 'Chọn mẫu gấp' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Ghi chú thành quả'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minutesController,
              decoration: const InputDecoration(labelText: 'Số phút thực hiện'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final number = int.tryParse(value ?? '');
                if (number == null || number <= 0) {
                  return 'Nhập số phút hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn ảnh local (tùy chọn)',
                prefixIcon: Icon(Icons.image_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rating: $_rating sao',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_rating',
              onChanged: (value) => setState(() => _rating = value.round()),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: Icon(_isEditing ? Icons.save_outlined : Icons.add_task),
              label: Text(_isEditing ? 'Lưu thay đổi' : 'Lưu thành quả'),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                final selectedModel = _model!;
                final minutes = int.parse(_minutesController.text);
                if (_isEditing) {
                  await state.updateAchievement(
                    widget.entry!.copyWith(
                      note: _noteController.text.trim(),
                      rating: _rating,
                      minutesSpent: minutes,
                      photoPath: _photoController.text.trim().isEmpty
                          ? null
                          : _photoController.text.trim(),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  return;
                }

                final result = await state.addAchievement(
                  model: selectedModel,
                  note: _noteController.text,
                  rating: _rating,
                  minutesSpent: minutes,
                  photoPath: _photoController.text,
                );
                if (!context.mounted) {
                  return;
                }
                _showSnack(context, result.message);
                if (result.allowed) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 12),
            const RuleHint(),
          ],
        ),
      ),
    );
  }
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final selected = state.selectedModel;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (selected != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  OrigamiArt(model: selected, size: 72),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đang hỏi cho',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          selected.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'AI dùng bước trong SQLite để trả lời sát bài gấp.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<OrigamiModel>(
          initialValue: selected,
          decoration: const InputDecoration(
            labelText: 'Chọn mẫu để AI hướng dẫn',
          ),
          items: [
            for (final model in state.models)
              DropdownMenuItem(value: model, child: Text(model.title)),
          ],
          onChanged: (model) {
            if (model != null) {
              state.selectModel(model);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Câu hỏi cho AI',
            hintText: 'Ví dụ: Em bị lệch ở bước 4, sửa thế nào?',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: state.isAiLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: const Text('Nhận hướng dẫn'),
          onPressed: state.isAiLoading
              ? null
              : () => state.askAi(_controller.text),
        ),
        const SizedBox(height: 12),
        if (state.aiAnswer != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(state.aiAnswer!),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.settings_outlined),
          label: Text(
            state.geminiApiKey == null
                ? 'Cấu hình Gemini API key'
                : 'Đổi Gemini API key',
          ),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apiKeyController.text = context.appState.geminiApiKey ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final user = state.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Avatar(user: user, radius: 34),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Khách',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(user?.email ?? 'Chưa đăng nhập Gmail'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (user == null) ...[
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập bằng Gmail'),
              onPressed: state.signInWithGoogle,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.school_outlined),
              label: const Text('Dùng tài khoản demo Gmail'),
              onPressed: state.signInDemo,
            ),
          ] else
            FilledButton.tonalIcon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              onPressed: state.signOut,
            ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'AI hướng dẫn',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Gemini API key',
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Lưu API key local'),
            onPressed: () async {
              await state.saveApiKey(_apiKeyController.text);
              if (context.mounted) {
                _showSnack(context, 'Đã lưu cấu hình AI trong máy.');
              }
            },
          ),
          const SizedBox(height: 20),
          const RuleHint(),
        ],
      ),
    );
  }
}

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Rule')),
      body: const Padding(padding: EdgeInsets.all(16), child: RuleHint()),
    );
  }
}

class RuleHint extends StatelessWidget {
  const RuleHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Luật nghiệp vụ hoàn thành',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text('• Phải tick đủ mọi bước của mẫu trước khi lưu thành quả.'),
            Text('• Rating tối thiểu 3 sao mới được tính hoàn thành.'),
            Text(
              '• Huy hiệu tự mở theo số mẫu khác nhau, rating trung bình và mẫu độ khó cao.',
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge});

  final BadgeAward badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          badge.unlocked ? Icons.verified : Icons.lock_outline,
          color: badge.unlocked ? const Color(0xFF4F8A8B) : Colors.grey,
        ),
        title: Text(badge.title),
        subtitle: Text(badge.description),
        trailing: Text(badge.unlocked ? 'Mở' : 'Khóa'),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF4F8A8B)),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.user, required this.radius});

  final AppUser? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8C547),
      child: Text(
        (user?.name.isNotEmpty ?? false)
            ? user!.name.characters.first.toUpperCase()
            : 'O',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
          color: const Color(0xFF1F3A3D),
        ),
      ),
    );
  }
}

class OrigamiArt extends StatelessWidget {
  const OrigamiArt({super.key, required this.model, required this.size});

  final OrigamiModel model;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${model.colorHex}', radix: 16));
    return Semantics(
      label: 'Hình minh họa ${model.title}',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: OrigamiPainter(color: color, imageKey: model.imageKey),
        ),
      ),
    );
  }
}

class OrigamiPainter extends CustomPainter {
  OrigamiPainter({required this.color, required this.imageKey});

  final Color color;
  final String imageKey;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.width * 0.025);
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.08);
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = color.withValues(alpha: 0.12),
    );

    switch (imageKey) {
      case 'boat':
        _boat(canvas, size, paint, line, shadow);
        break;
      case 'tulip':
        _tulip(canvas, size, paint, line, shadow);
        break;
      case 'frog':
        _frog(canvas, size, paint, line, shadow);
        break;
      case 'box':
        _box(canvas, size, paint, line, shadow);
        break;
      case 'dragon':
        _dragon(canvas, size, paint, line, shadow);
        break;
      default:
        _crane(canvas, size, paint, line, shadow);
    }
  }

  void _crane(Canvas canvas, Size s, Paint paint, Paint line, Paint shadow) {
    final path = Path()
      ..moveTo(s.width * .12, s.height * .55)
      ..lineTo(s.width * .44, s.height * .28)
      ..lineTo(s.width * .56, s.height * .55)
      ..lineTo(s.width * .88, s.height * .35)
      ..lineTo(s.width * .62, s.height * .72)
      ..lineTo(s.width * .48, s.height * .60)
      ..lineTo(s.width * .30, s.height * .78)
      ..close();
    canvas.drawPath(path.shift(Offset(0, s.height * .03)), shadow);
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(s.width * .44, s.height * .28),
      Offset(s.width * .48, s.height * .60),
      line,
    );
    canvas.drawLine(
      Offset(s.width * .56, s.height * .55),
      Offset(s.width * .88, s.height * .35),
      line,
    );
  }

  void _boat(Canvas canvas, Size s, Paint paint, Paint line, Paint shadow) {
    final hull = Path()
      ..moveTo(s.width * .12, s.height * .58)
      ..lineTo(s.width * .88, s.height * .58)
      ..lineTo(s.width * .68, s.height * .78)
      ..lineTo(s.width * .30, s.height * .78)
      ..close();
    final sail = Path()
      ..moveTo(s.width * .48, s.height * .18)
      ..lineTo(s.width * .48, s.height * .58)
      ..lineTo(s.width * .23, s.height * .58)
      ..close();
    canvas.drawPath(hull.shift(Offset(0, s.height * .03)), shadow);
    canvas.drawPath(hull, paint);
    canvas.drawPath(sail, paint..color = color.withValues(alpha: .82));
    canvas.drawLine(
      Offset(s.width * .48, s.height * .18),
      Offset(s.width * .48, s.height * .78),
      line,
    );
  }

  void _tulip(Canvas canvas, Size s, Paint paint, Paint line, Paint shadow) {
    final flower = Path()
      ..moveTo(s.width * .50, s.height * .18)
      ..lineTo(s.width * .72, s.height * .42)
      ..quadraticBezierTo(
        s.width * .62,
        s.height * .66,
        s.width * .50,
        s.height * .62,
      )
      ..quadraticBezierTo(
        s.width * .38,
        s.height * .66,
        s.width * .28,
        s.height * .42,
      )
      ..close();
    canvas.drawPath(flower.shift(Offset(0, s.height * .03)), shadow);
    canvas.drawPath(flower, paint);
    canvas.drawLine(
      Offset(s.width * .50, s.height * .62),
      Offset(s.width * .50, s.height * .86),
      Paint()
        ..color = const Color(0xFF4E7D42)
        ..strokeWidth = s.width * .06,
    );
    canvas.drawLine(
      Offset(s.width * .50, s.height * .20),
      Offset(s.width * .50, s.height * .62),
      line,
    );
  }

  void _frog(Canvas canvas, Size s, Paint paint, Paint line, Paint shadow) {
    final body = Path()
      ..moveTo(s.width * .20, s.height * .46)
      ..lineTo(s.width * .42, s.height * .24)
      ..lineTo(s.width * .80, s.height * .46)
      ..lineTo(s.width * .66, s.height * .76)
      ..lineTo(s.width * .34, s.height * .76)
      ..close();
    canvas.drawPath(body.shift(Offset(0, s.height * .03)), shadow);
    canvas.drawPath(body, paint);
    canvas.drawCircle(
      Offset(s.width * .38, s.height * .42),
      s.width * .035,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(s.width * .62, s.height * .42),
      s.width * .035,
      Paint()..color = Colors.white,
    );
    canvas.drawLine(
      Offset(s.width * .34, s.height * .76),
      Offset(s.width * .20, s.height * .86),
      line,
    );
    canvas.drawLine(
      Offset(s.width * .66, s.height * .76),
      Offset(s.width * .82, s.height * .86),
      line,
    );
  }

  void _box(Canvas canvas, Size s, Paint paint, Paint line, Paint shadow) {
    final top = Path()
      ..moveTo(s.width * .26, s.height * .34)
      ..lineTo(s.width * .50, s.height * .20)
      ..lineTo(s.width * .74, s.height * .34)
      ..lineTo(s.width * .50, s.height * .48)
      ..close();
    final left = Path()
      ..moveTo(s.width * .26, s.height * .34)
      ..lineTo(s.width * .50, s.height * .48)
      ..lineTo(s.width * .50, s.height * .78)
      ..lineTo(s.width * .26, s.height * .62)
      ..close();
    final right = Path()
      ..moveTo(s.width * .74, s.height * .34)
      ..lineTo(s.width * .50, s.height * .48)
      ..lineTo(s.width * .50, s.height * .78)
      ..lineTo(s.width * .74, s.height * .62)
      ..close();
    canvas.drawPath(left.shift(Offset(0, s.height * .03)), shadow);
    canvas.drawPath(top, paint..color = color.withValues(alpha: .92));
    canvas.drawPath(left, paint..color = color.withValues(alpha: .80));
    canvas.drawPath(right, paint..color = color);
    canvas.drawLine(
      Offset(s.width * .50, s.height * .48),
      Offset(s.width * .50, s.height * .78),
      line,
    );
  }

  void _dragon(Canvas canvas, Size s, Paint paint, Paint line, Paint shadow) {
    final path = Path()
      ..moveTo(s.width * .12, s.height * .68)
      ..lineTo(s.width * .34, s.height * .34)
      ..lineTo(s.width * .48, s.height * .56)
      ..lineTo(s.width * .60, s.height * .22)
      ..lineTo(s.width * .88, s.height * .44)
      ..lineTo(s.width * .66, s.height * .50)
      ..lineTo(s.width * .76, s.height * .82)
      ..lineTo(s.width * .48, s.height * .62)
      ..lineTo(s.width * .30, s.height * .82)
      ..close();
    canvas.drawPath(path.shift(Offset(0, s.height * .03)), shadow);
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(s.width * .34, s.height * .34),
      Offset(s.width * .48, s.height * .62),
      line,
    );
    canvas.drawLine(
      Offset(s.width * .60, s.height * .22),
      Offset(s.width * .66, s.height * .50),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant OrigamiPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.imageKey != imageKey;
  }
}

String _dateText(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
