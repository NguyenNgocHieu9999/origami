// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:origami/main.dart';
import 'package:origami/state/app_state.dart';

void main() {
  testWidgets('Origami app shows dashboard after loading', (
    WidgetTester tester,
  ) async {
    final state = AppState();
    state.isLoading = false;

    // Build our app and trigger a frame.
    await tester.pumpWidget(OrigamiMentorApp(state: state));
    await tester.pumpAndSettle();

    expect(find.text('Origami Mentor'), findsOneWidget);
    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
  });
}
