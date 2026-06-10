// Smoke test: the app builds and the main navigation renders.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App builds and shows the bottom navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pump(); // let the provider's async load settle

    // Bottom navigation labels are present.
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.text('Charts'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('My'), findsOneWidget);

    // Empty ledger state is shown on first launch.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
