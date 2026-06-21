// Smoke test: the main navigation renders. Uses a fake Firestore so the test
// runs without a real Firebase connection.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/screens/main_screen.dart';

void main() {
  testWidgets('Main navigation renders', (tester) async {
    final fake = FakeFirebaseFirestore();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TransactionProvider(firestore: fake),
        child: const MaterialApp(home: MainScreen()),
      ),
    );
    await tester.pump();

    // Bottom navigation labels are present.
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.text('Charts'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('My'), findsOneWidget);
  });
}
