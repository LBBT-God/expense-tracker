import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
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

  // Let the realtime snapshot listener deliver pending changes.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

  late FakeFirebaseFirestore fake;
  late TransactionProvider p;

  setUp(() async {
    fake = FakeFirebaseFirestore();
    p = TransactionProvider(firestore: fake);
    await settle();
  });

  group('TransactionProvider CRUD (Firestore)', () {
    test('starts empty', () async {
      expect(p.allTransactions, isEmpty);
      expect(p.balance, 0);
    });

    test('add() inserts a record and updates totals', () async {
      await p.add(tx(id: '1', amount: 100, type: TransactionType.income));
      await p.add(tx(id: '2', amount: 30, type: TransactionType.expense));
      await settle();

      expect(p.allTransactions.length, 2);
      expect(p.totalIncome, 100);
      expect(p.totalExpense, 30);
      expect(p.balance, 70);
    });

    test('add() persists to the underlying Firestore collection', () async {
      await p.add(tx(id: '1', amount: 42));
      await settle();

      final snap = await fake.collection('transactions').get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['amount'], 42);
    });

    test('update() replaces the matching record', () async {
      await p.add(tx(id: '1', amount: 30));
      await settle();
      await p.update(tx(id: '1', amount: 45));
      await settle();

      expect(p.allTransactions.length, 1);
      expect(p.getById('1')!.amount, 45);
    });

    test('delete() removes the matching record', () async {
      await p.add(tx(id: '1'));
      await p.add(tx(id: '2'));
      await settle();
      await p.delete('1');
      await settle();

      expect(p.allTransactions.length, 1);
      expect(p.getById('1'), isNull);
      expect(p.getById('2'), isNotNull);
    });

    test('clearAll() empties the ledger', () async {
      await p.add(tx(id: '1'));
      await p.add(tx(id: '2'));
      await settle();
      await p.clearAll();
      await settle();

      expect(p.allTransactions, isEmpty);
    });

    test('setBudget() stores the monthly budget', () async {
      await p.setBudget(1500);
      expect(p.monthlyBudget, 1500);

      final doc = await fake.collection('settings').doc('app').get();
      expect((doc.data()!['monthlyBudget'] as num).toDouble(), 1500);
    });
  });
}
