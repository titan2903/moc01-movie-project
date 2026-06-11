import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_project/main.dart';

void main() {
  testWidgets('Movie Project UI smoke test and detail navigation with favorites', (WidgetTester tester) async {
    // Set viewport size large enough to fit all list items without scrolling
    await tester.binding.setSurfaceSize(const Size(800, 1000));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the AppBar title 'Movie Catalog' is present.
    expect(find.text('Movie Catalog'), findsOneWidget);

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

    // Initially, there should be no active favorites on screen
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(5));

    // Tap favorite icon on the first item (Inception)
    final favoriteButtons = find.byIcon(Icons.favorite_border);
    await tester.tap(favoriteButtons.first);
    await tester.pumpAndSettle();

    // Verify favorite icon changed to filled
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(4));

    // Tap on the 'Inception' item to navigate to details
    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();

    // Verify we are on the details screen
    expect(find.text('Movie Details'), findsOneWidget);
    expect(find.text('Synopsis'), findsOneWidget);
    expect(
      find.textContaining('A thief who steals corporate secrets through the use of dream-sharing technology'),
      findsOneWidget,
    );

    // Check that the favorite state is carried over (should see 2 filled hearts: one in appbar, one in bottom button)
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));

    // Toggle favorite off on details screen using the bottom button (Remove from Favorites)
    await tester.tap(find.text('Remove from Favorites'));
    await tester.pumpAndSettle();

    // Now, should have 0 filled hearts and 2 empty hearts (one in appbar, one in bottom button)
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));

    // Toggle favorite back on using the appbar favorite button (which is the first action button in AppBar)
    final appBarFavoriteButton = find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.favorite_border),
    );
    await tester.tap(appBarFavoriteButton);
    await tester.pumpAndSettle();

    // Verify it is favorited again
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));

    // Go back to list page
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // Verify we are back on the list page and Inception is still favorited
    expect(find.text('Movie Catalog'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(4));
  });
}
