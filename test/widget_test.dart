import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_posts_manager/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OfflinePostsManager());

    // Verify that the app title is shown
    expect(find.text('Offline Posts Manager'), findsOneWidget);
    
    // Verify that the floating action button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
