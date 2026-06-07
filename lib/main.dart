import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'ui/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  state.init();
  runApp(OrigamiMentorApp(state: state));
}

class OrigamiMentorApp extends StatelessWidget {
  const OrigamiMentorApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Origami Mentor',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4F8A8B),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF6F4EF),
              cardTheme: const CardThemeData(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            home: state.isLoading ? const LoadingScreen() : const AppShell(),
          );
        },
      ),
    );
  }
}
