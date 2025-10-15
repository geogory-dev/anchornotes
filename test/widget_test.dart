// SyncPad Widget Tests
// Phase 1: Basic smoke test to verify app builds

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anchornotes/main.dart';

void main() {
  testWidgets('SyncPad app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SyncPadApp());

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
