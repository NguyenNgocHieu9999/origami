
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Avatar(user: user, radius: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null ? 'Origami Mentor' : 'Xin chào, ${user!.name} 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ??
                      'Theo dõi từng nếp gấp, lưu thành quả và hỏi AI khi bị kẹt.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.3,
                  ),
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
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
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
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OrigamiArt(model: model, size: 84),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'GỢI Ý TIẾP THEO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${model.category} • ${model.minutes} phút • Độ khó ${model.difficulty}/4',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
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
    final theme = Theme.of(context);
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            labelText: 'Tìm kiểu gấp giấy...',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _category == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => setState(() => _category = category),
                selectedColor: theme.colorScheme.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        for (final model in filtered) ...[
          ModelCard(model: model),
          const SizedBox(height: 14),
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
    final theme = Theme.of(context);
    return FutureBuilder<List<OrigamiStep>>(
      future: state.stepsFor(model.id),
      builder: (context, snapshot) {
        final steps = snapshot.data ?? const <OrigamiStep>[];
        final completed = state.completedStepIdsFor(model.id).length;
        final progress = steps.isEmpty ? 0.0 : completed / steps.length;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  OrigamiArt(model: model, size: 80),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: model.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                              icon: Icon(
                                model.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: model.isFavorite ? Colors.redAccent : Colors.black38,
                                size: 20,
                              ),
                              onPressed: () => state.toggleFavorite(model),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$completed/${steps.length} bước',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${model.paperSize} • Độ khó ${model.difficulty}/4',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(model.title),
        actions: [
          IconButton(
            tooltip: 'Hỏi AI Coach',
            icon: const Icon(Icons.auto_awesome),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrigamiArt(model: model, size: 96),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _metaBadge(context, Icons.access_time, '${model.minutes} phút'),
                                _metaBadge(context, Icons.straighten, model.paperSize),
                                _metaBadge(context, Icons.bar_chart, 'Độ khó ${model.difficulty}/4'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ gấp giấy',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${completed.length}/${steps.length} bước',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 20),
              for (final step in steps)
                StepTile(
                  step: step,
                  completed: completed.contains(step.id),
                  onChanged: (value) =>
                      state.toggleStep(model, step, value ?? false),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Ghi nhận thành quả'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AchievementFormScreen(model: model),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _metaBadge(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: completed ? theme.colorScheme.primary.withValues(alpha: 0.02) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: completed ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
          width: completed ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(!completed),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed ? theme.colorScheme.primary : Colors.black26,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bước ${step.stepOrder}: ${step.title}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: completed ? theme.colorScheme.primary : Colors.black87,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.instruction,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: step.imageKey.isNotEmpty
                              ? Image.asset(
                                  'assets/images/${step.imageKey}.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/step_${step.stepOrder}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.04),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.photo_outlined,
                                                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Sơ đồ bước ${step.stepOrder}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/step_${step.stepOrder}.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.photo_outlined,
                                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                              size: 32,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Sơ đồ bước ${step.stepOrder}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Mẹo: ${step.tip}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
    final theme = Theme.of(context);
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
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return AchievementCard(entry: entries[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Thêm nhật ký', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.modelTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Sửa',
                  icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary.withValues(alpha: 0.7), size: 20),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AchievementFormScreen(entry: entry),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Xóa',
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _badge(context, Icons.star, '${entry.rating} sao', const Color(0xFFE8C547)),
                _badge(context, Icons.access_time, '${entry.minutesSpent} phút', theme.colorScheme.primary),
                _badge(context, Icons.calendar_today, _dateText(entry.completedAt), Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 3.5,
                  ),
                ),
              ),
              child: Text(
                entry.note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            if (entry.photoPath != null && entry.photoPath!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.image_outlined, size: 14, color: Colors.black45),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ảnh local: ${entry.photoPath}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, IconData icon, String label, Color tintColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tintColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: tintColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
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
                  : (value) {
                      setState(() {
                        _model = value;
                        if (value != null) {
                          _minutesController.text = '${value.minutes}';
                        }
                      });
                    },
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
    return Material(
      color: Colors.transparent,
      child: ListView(
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
      ),
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Avatar(user: user, radius: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Người dùng Khách',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'Đăng nhập Gmail để đồng bộ hồ sơ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user == null) ...[
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập bằng Gmail'),
              onPressed: state.signInWithGoogle,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.school_outlined),
              label: const Text('Dùng tài khoản demo Gmail'),
              onPressed: state.signInDemo,
            ),
          ] else
            FilledButton.tonalIcon(
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất tài khoản'),
              onPressed: state.signOut,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.08),
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),
          Text(
            'Trợ lý học tập AI Coach',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cấu hình Gemini API key của bạn để sử dụng AI hướng dẫn trực tuyến. Khóa được lưu hoàn toàn bảo mật trên máy cục bộ.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.3),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Gemini API key',
              prefixIcon: Icon(Icons.key, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Lưu API key cục bộ'),
            onPressed: () async {
              await state.saveApiKey(_apiKeyController.text);
              if (context.mounted) {
                _showSnack(context, 'Đã lưu cấu hình AI trong máy.');
              }
            },
          ),
          const SizedBox(height: 20),
          const RuleHint(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Reset Database (Cài lại dữ liệu gốc)'),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cài lại Cơ sở dữ liệu?'),
                  content: const Text(
                    'Thao tác này sẽ xóa sạch toàn bộ tiến độ, thành quả đã lưu và nạp lại 7 mẫu gấp giấy ban đầu.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await state.resetDatabase();
                if (context.mounted) {
                  _showSnack(context, 'Đã cài lại dữ liệu gốc thành công!');
                }
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: badge.unlocked
                    ? const LinearGradient(
                        colors: [Color(0xFFD4A373), Color(0xFFE3D5CA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                boxShadow: badge.unlocked
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD4A373).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                badge.unlocked ? Icons.emoji_events : Icons.lock_outline,
                color: badge.unlocked ? Colors.white : Colors.black38,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: badge.unlocked ? theme.colorScheme.primary : Colors.black54,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: badge.unlocked
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.black12,
                ),
              ),
              child: Text(
                badge.unlocked ? 'Đã nhận' : 'Khóa',
                style: TextStyle(
                  color: badge.unlocked ? theme.colorScheme.primary : Colors.black38,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
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
    return Semantics(
      label: 'Hình minh họa ${model.title}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/${model.imageKey}.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      ),
    );
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
