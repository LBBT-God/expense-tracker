import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Transaction tx({
    String id = 'id',
    double amount = 10,
    TransactionType type = TransactionType.expense,
    Category category = Category.food,
  }) {
    return Transaction(
      id: id,
      title: category.label,
      amount: amount,
      category: category,
      date: DateTime(2025, 5, 26),
      type: type,
    );
  }

  // Build a provider and wait for its async _load() to complete.
  Future<TransactionProvider> freshProvider() async {
    SharedPreferences.setMockInitialValues({});
    final p = TransactionProvider();
    await Future<void>.delayed(Duration.zero);
    return p;
  }

  group('TransactionProvider CRUD', () {
    test('starts empty', () async {
      final p = await freshProvider();
      expect(p.allTransactions, isEmpty);
      expect(p.balance, 0);
    });

    test('add() inserts a record and updates totals', () async {
      final p = await freshProvider();
      await p.add(tx(id: '1', amount: 100, type: TransactionType.income));
      await p.add(tx(id: '2', amount: 30, type: TransactionType.expense));

      expect(p.allTransactions.length, 2);
      expect(p.totalIncome, 100);
      expect(p.totalExpense, 30);
      expect(p.balance, 70);
    });

    test('update() replaces the matching record', () async {
      final p = await freshProvider();
      await p.add(tx(id: '1', amount: 30));
      await p.update(tx(id: '1', amount: 45));

      expect(p.allTransactions.length, 1);
      expect(p.getById('1')!.amount, 45);
    });

    test('delete() removes the matching record', () async {
      final p = await freshProvider();
      await p.add(tx(id: '1'));
      await p.add(tx(id: '2'));
      await p.delete('1');

      expect(p.allTransactions.length, 1);
      expect(p.getById('1'), isNull);
      expect(p.getById('2'), isNotNull);
    });

    test('clearAll() empties the ledger', () async {
      final p = await freshProvider();
      await p.add(tx(id: '1'));
      await p.add(tx(id: '2'));
      await p.clearAll();

      expect(p.allTransactions, isEmpty);
    });

    test('setBudget() stores the monthly budget', () async {
      final p = await freshProvider();
      await p.setBudget(1500);
      expect(p.monthlyBudget, 1500);
    });
  });
}
