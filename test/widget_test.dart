import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_project/main.dart';

void main() {
  testWidgets('Movie Project UI smoke test', (WidgetTester tester) async {
    // Set viewport size large enough to fit all list items without scrolling
    await tester.binding.setSurfaceSize(const Size(800, 1000));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'Movie Project' is present.
    expect(find.text('Movie Project'), findsOneWidget);

    // Verify that the movie titles are present.
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('Tenet'), findsOneWidget);
    expect(find.text('The Dark Knight Rises'), findsOneWidget);
    expect(find.text('Avatar: The Way of Water'), findsOneWidget);

    // Verify ratings are displayed.
    expect(find.text('8.4'), findsOneWidget);
    expect(find.text('8.6'), findsOneWidget);
    expect(find.text('7.4'), findsOneWidget);
  });
}
