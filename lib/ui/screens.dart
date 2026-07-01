
import 'dart:async';
import 'package:flutter/material.dart';

import '../models/origami_models.dart';
import '../state/app_state.dart';
import 'origami_painter.dart';

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

class FloatingOrigami extends StatefulWidget {
  const FloatingOrigami({super.key});

  @override
  State<FloatingOrigami> createState() => _FloatingOrigamiState();
}

class _FloatingOrigamiState extends State<FloatingOrigami> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _controller.repeat(reverse: true);
    }
    _animation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Transform.rotate(
            angle: _animation.value * 0.002,
            child: child,
          ),
        );
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3A20).withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.appState;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Mesh
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE2EFE7),
                  Color(0xFFD3EBE0),
                  Color(0xFFF7EBD3), // Warm touch of honey yellow
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Subtle decorative shapes in the background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5A93B).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F3A20).withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Animated Floating Visual
                  const FloatingOrigami(),
                  const SizedBox(height: 40),
                  // App Title & Tagline
                  Text(
                    'ORIGAMI MENTOR',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF0F3A20),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5A93B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Khơi nguồn sáng tạo từ những nếp gấp đơn giản',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2E6F40),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  // Feature highlights cards / onboarding preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          context,
                          icon: Icons.map_outlined,
                          title: 'Sơ đồ gấp vectơ động',
                          subtitle: 'Hình vẽ các bước sắc nét, xoay hướng trực quan.',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.black12, height: 1),
                        ),
                        _buildFeatureRow(
                          context,
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Trò chuyện AI Coach',
                          subtitle: 'Hỏi đáp kỹ thuật gấp và mẹo thực hành tức thì.',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.black12, height: 1),
                        ),
                        _buildFeatureRow(
                          context,
                          icon: Icons.camera_alt_outlined,
                          title: 'Nhật ký Polaroid',
                          subtitle: 'Lưu giữ hành trình xếp giấy cùng đánh giá 5 sao.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: () {
                        state.dismissWelcome();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3A20),
                        elevation: 4,
                        shadowColor: const Color(0xFF0F3A20).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bắt đầu ngay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F3A20).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F3A20),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F3A20),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

class AnimateIn extends StatefulWidget {
  const AnimateIn({super.key, required this.child, required this.delay});
  final Widget child;
  final Duration delay;

  @override
  State<AnimateIn> createState() => _AnimateInState();
}

class _AnimateInState extends State<AnimateIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTesting) {
      _controller.value = 1.0;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
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
        AnimateIn(
          delay: const Duration(milliseconds: 50),
          child: HeaderPanel(user: user),
        ),
        const SizedBox(height: 16),
        AnimateIn(
          delay: const Duration(milliseconds: 150),
          child: Row(
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
        ),
        const SizedBox(height: 16),
        if (recommendation != null) ...[
          AnimateIn(
            delay: const Duration(milliseconds: 250),
            child: RecommendationPanel(
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
          ),
          const SizedBox(height: 16),
        ],
        AnimateIn(
          delay: const Duration(milliseconds: 350),
          child: SectionHeader(
            title: 'Huy hiệu tiến độ',
            actionLabel: 'Xem mẫu',
            onAction: onOpenCatalog,
          ),
        ),
        const SizedBox(height: 8),
        ...badges.asMap().entries.map((entry) {
          final index = entry.key;
          final badge = entry.value;
          return AnimateIn(
            delay: Duration(milliseconds: 400 + index * 60),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BadgeTile(badge: badge),
            ),
          );
        }),
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
          colors: [Color(0xFF0F3A20), Color(0xFF2A5C43)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3A20).withValues(alpha: 0.12),
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
        borderRadius: BorderRadius.circular(20),
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

  Widget _difficultyBadge(BuildContext context, int difficulty) {
    Color color;
    String text;
    switch (difficulty) {
      case 1:
        color = const Color(0xFF2E6F40);
        text = 'Cơ bản';
        break;
      case 2:
        color = const Color(0xFF3B82F6);
        text = 'Trung bình';
        break;
      case 3:
        color = const Color(0xFFE5A93B);
        text = 'Khó';
        break;
      case 4:
      default:
        color = const Color(0xFFBA1A1A);
        text = 'Thử thách';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

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
            borderRadius: BorderRadius.circular(20),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  model.paperSize,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _difficultyBadge(context, model.difficulty),
                              ],
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

class StepTile extends StatefulWidget {
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
  State<StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<StepTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.completed ? theme.colorScheme.primary.withValues(alpha: 0.02) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.completed ? theme.colorScheme.primary.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
          width: widget.completed ? 1.6 : 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      widget.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: widget.completed ? theme.colorScheme.primary : Colors.black26,
                      size: 24,
                    ),
                    onPressed: () => widget.onChanged(!widget.completed),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Bước ${widget.step.stepOrder}: ${widget.step.title}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: widget.completed ? theme.colorScheme.primary : Colors.black87,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black45,
                    size: 20,
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Text(
                      widget.step.instruction,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                           child: widget.step.imageKey.startsWith('http')
                              ? Image.network(
                                  widget.step.imageKey,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image_outlined,
                                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                              size: 32,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Không tải được hình ảnh',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : (widget.step.imageKey.startsWith('crane_')
                                  ? Image.asset(
                                      'assets/images/${widget.step.imageKey}.png',
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
                                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Sơ đồ bước ${widget.step.stepOrder}',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : OrigamiStepDiagram(
                                      modelKey: widget.step.imageKey.split('_').first,
                                      stepOrder: widget.step.stepOrder,
                                      themeColor: theme.colorScheme.primary,
                                    )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mẹo: ${widget.step.tip}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    StepTimerWidget(durationSeconds: widget.step.seconds),
                  ],
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
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

  Widget _starRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i <= rating ? const Color(0xFFE5A93B) : Colors.black12,
            size: 18,
          ),
      ],
    );
  }

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
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _starRating(entry.rating),
                _badge(context, Icons.access_time, '${entry.minutesSpent} phút', theme.colorScheme.primary),
                _badge(context, Icons.calendar_today, _dateText(entry.completedAt), Colors.black45),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.02),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 4,
                  ),
                  top: BorderSide(color: Colors.black.withValues(alpha: 0.03)),
                  bottom: BorderSide(color: Colors.black.withValues(alpha: 0.03)),
                  right: BorderSide(color: Colors.black.withValues(alpha: 0.03)),
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
        color: tintColor.withValues(alpha: 0.06),
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

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Xin chào! Tôi là AI Coach hướng dẫn gấp giấy Origami. Hãy chọn mẫu gấp cần hướng dẫn ở trên, sau đó nhập câu hỏi hoặc chọn các mẹo nhanh phía dưới để tôi hỗ trợ nhé!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text, AppState state) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: cleanText, isUser: true));
      _controller.clear();
    });
    _scrollToBottom();

    await state.askAi(cleanText);

    if (state.aiAnswer != null) {
      setState(() {
        _messages.add(ChatMessage(text: state.aiAnswer!, isUser: false));
      });
      _scrollToBottom();
    }
  }

  List<String> _getQuickQueries(OrigamiModel? selected) {
    if (selected == null) {
      return [
        'Làm sao để miết nếp gấp phẳng?',
        'Nếu giấy bị rách thì sửa thế nào?',
        'Nên dùng loại giấy nào cho người mới?',
      ];
    }
    return [
      'Gấp mẫu ${selected.title} cần chú ý gì?',
      'Cách sửa khi nếp gấp bị lệch?',
      'Tôi bị rách giấy ở nếp gấp đảo?',
      'Quy tắc ghi nhận hoàn thành là gì?',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final selected = state.selectedModel;
    final theme = Theme.of(context);
    final quickQueries = _getQuickQueries(selected);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Selector Panel at the top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<OrigamiModel>(
                      initialValue: selected,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.primary.withValues(alpha: 0.03),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        labelText: 'AI Hướng dẫn cho mẫu',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        for (final model in state.models)
                          DropdownMenuItem(
                            value: model,
                            child: Text(
                              model.title,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                      onChanged: (model) {
                        if (model != null) {
                          state.selectModel(model);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Cài đặt API Key',
                  icon: const Icon(Icons.vpn_key_outlined),
                  color: theme.colorScheme.primary,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
              ],
            ),
          ),

          // Active Provider Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(
                  Icons.bolt,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Đang chạy: ${state.aiProvider == 'pollinations' ? 'Pollinations AI (Không cần Key)' : state.aiProvider == 'gemini' ? 'Google Gemini' : state.aiProvider == 'groq' ? 'Groq AI' : 'OpenRouter'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length + (state.isAiLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Typing indicator bubble
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                            child: Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.05),
                                width: 1,
                              ),
                            ),
                            child: SizedBox(
                              width: 32,
                              height: 18,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _dot(theme),
                                  _dot(theme),
                                  _dot(theme),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isUser) ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                            child: Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: message.isUser ? theme.colorScheme.primary : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                                bottomRight: Radius.circular(message.isUser ? 4 : 16),
                              ),
                              border: message.isUser 
                                  ? null 
                                  : Border.all(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser ? Colors.white : Colors.black87,
                                fontSize: 14.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick prompt chips
          Container(
            height: 48,
            color: Colors.transparent,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: quickQueries.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final query = quickQueries[index];
                return ActionChip(
                  label: Text(query),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  onPressed: state.isAiLoading
                      ? null
                      : () => _sendMessage(query, state),
                );
              },
            ),
          ),

          // Input text bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) => _sendMessage(value, state),
                      decoration: InputDecoration(
                        hintText: 'Nhập câu hỏi tại đây...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: state.isAiLoading
                          ? null
                          : () => _sendMessage(_controller.text, state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(ThemeData theme) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.6),
        shape: BoxShape.circle,
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
  late String _selectedProvider;
  late final TextEditingController _geminiKeyController;
  late final TextEditingController _groqKeyController;
  late final TextEditingController _openrouterKeyController;

  @override
  void initState() {
    super.initState();
    _selectedProvider = 'pollinations';
    _geminiKeyController = TextEditingController();
    _groqKeyController = TextEditingController();
    _openrouterKeyController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.appState;
    _selectedProvider = state.aiProvider;
    _geminiKeyController.text = state.geminiApiKey ?? '';
    _groqKeyController.text = state.groqApiKey ?? '';
    _openrouterKeyController.text = state.openrouterApiKey ?? '';
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _groqKeyController.dispose();
    _openrouterKeyController.dispose();
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Trợ lý học tập AI Coach',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Chọn cấu hình dịch vụ AI để nhận hướng dẫn gấp giấy trực tuyến thông minh.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedProvider,
                  decoration: InputDecoration(
                    labelText: 'Chọn nhà cung cấp AI',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.hub_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'pollinations',
                      child: Text('Pollinations AI (Không cần API Key)'),
                    ),
                    DropdownMenuItem(
                      value: 'gemini',
                      child: Text('Google AI Studio (Gemini Flash)'),
                    ),
                    DropdownMenuItem(
                      value: 'groq',
                      child: Text('Groq Console (Llama 3.1)'),
                    ),
                    DropdownMenuItem(
                      value: 'openrouter',
                      child: Text('OpenRouter (Gemma 2 Free)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedProvider = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedProvider == 'pollinations') ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pollinations AI hoạt động miễn phí trực tiếp không cần API key. Đã thiết lập sẵn sàng!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _selectedProvider == 'gemini'
                        ? _geminiKeyController
                        : _selectedProvider == 'groq'
                            ? _groqKeyController
                            : _openrouterKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _selectedProvider == 'gemini'
                          ? 'Gemini API Key'
                          : _selectedProvider == 'groq'
                              ? 'Groq API Key'
                              : 'OpenRouter API Key',
                      prefixIcon: const Icon(Icons.key),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SelectableText(
                      _selectedProvider == 'gemini'
                          ? 'Đăng ký nhận key miễn phí tại: https://aistudio.google.com/'
                          : _selectedProvider == 'groq'
                              ? 'Đăng ký nhận key miễn phí tại: https://console.groq.com/'
                              : 'Đăng ký nhận key miễn phí tại: https://openrouter.ai/',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu cấu hình AI'),
                    onPressed: () async {
                      await state.saveAiConfig(
                        provider: _selectedProvider,
                        geminiKey: _geminiKeyController.text,
                        groqKey: _groqKeyController.text,
                        openrouterKey: _openrouterKeyController.text,
                      );
                      if (context.mounted) {
                        _showSnack(context, 'Đã lưu cấu hình AI thành công!');
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  void _showBadgeDetail(BuildContext context, BadgeAward badge) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: badge.unlocked
                        ? const LinearGradient(
                            colors: [Color(0xFFE5A93B), Color(0xFFF2D091)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade300, Colors.grey.shade400],
                          ),
                    boxShadow: badge.unlocked
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE5A93B).withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    badge.unlocked ? Icons.emoji_events : Icons.lock_outline,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badge.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: badge.unlocked
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge.unlocked ? 'Huy hiệu đã mở khóa' : 'Huy hiệu đang khóa',
                    style: TextStyle(
                      color: badge.unlocked ? theme.colorScheme.primary : Colors.black45,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showBadgeDetail(context, badge),
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
                          colors: [Color(0xFFE5A93B), Color(0xFFF2D091)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                  boxShadow: badge.unlocked
                      ? [
                          BoxShadow(
                            color: const Color(0xFFE5A93B).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  badge.unlocked ? Icons.emoji_events : Icons.lock_outline,
                  color: Colors.white,
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

class StepTimerWidget extends StatefulWidget {
  const StepTimerWidget({super.key, required this.durationSeconds});

  final int durationSeconds;

  @override
  State<StepTimerWidget> createState() => _StepTimerWidgetState();
}

class _StepTimerWidgetState extends State<StepTimerWidget> {
  Timer? _timer;
  late int _timeLeft;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.durationSeconds;
  }

  @override
  void didUpdateWidget(covariant StepTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationSeconds != widget.durationSeconds) {
      _stopTimer();
      setState(() {
        _timeLeft = widget.durationSeconds;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        _stopTimer();
        setState(() {
          _timeLeft = 0;
        });
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _timeLeft = widget.durationSeconds;
    });
  }

  String _formatTime(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = widget.durationSeconds > 0 ? _timeLeft / widget.durationSeconds : 0.0;
    final isFinished = _timeLeft == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isFinished 
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.15) 
            : theme.colorScheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFinished 
              ? theme.colorScheme.error.withValues(alpha: 0.2) 
              : theme.colorScheme.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFinished ? Icons.alarm_on : Icons.timer_outlined,
            size: 20,
            color: isFinished ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFinished ? 'Đã hết giờ gấp!' : 'Thời gian gấp: ${_formatTime(_timeLeft)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isFinished ? theme.colorScheme.error : theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 4,
                    backgroundColor: Colors.black.withValues(alpha: 0.04),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFinished ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (_isRunning)
            IconButton(
              icon: const Icon(Icons.pause_circle_outline, size: 24),
              color: theme.colorScheme.primary,
              onPressed: _pauseTimer,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            )
          else
            IconButton(
              icon: Icon(
                isFinished ? Icons.replay_circle_filled_outlined : Icons.play_circle_outline, 
                size: 24
              ),
              color: isFinished ? theme.colorScheme.error : theme.colorScheme.primary,
              onPressed: isFinished ? _resetTimer : _startTimer,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          if (!isFinished && _timeLeft < widget.durationSeconds) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.replay_outlined, size: 20),
              color: Colors.black54,
              onPressed: _resetTimer,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
