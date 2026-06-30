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
                seedColor: const Color(0xFF1B4332),
                primary: const Color(0xFF1B4332),
                secondary: const Color(0xFFD4A373),
                tertiary: const Color(0xFF40916C),
                surface: const Color(0xFFFFFFFF),
                error: const Color(0xFFBA1A1A),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFFAF9F6),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFAF9F6),
                elevation: 0,
                centerTitle: true,
                scrolledUnderElevation: 0,
                titleTextStyle: TextStyle(
                  color: Color(0xFF1B4332),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF1B4332), width: 1.5),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: const Color(0xFFFFFFFF),
                elevation: 8,
                indicatorColor: const Color(0xFFD8F3DC),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                height: 72,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: Color(0xFF1B4332), size: 24);
                  }
                  return const IconThemeData(color: Colors.black54, size: 24);
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      color: Color(0xFF1B4332),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    );
                  }
                  return const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  );
                }),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B4332),
                  side: const BorderSide(color: Color(0xFF1B4332), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
