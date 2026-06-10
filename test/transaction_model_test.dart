import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction.dart';

void main() {
  Transaction sample() => Transaction(
        id: 'abc-123',
        title: 'Lunch',
        amount: 12.50,
        category: Category.food,
        date: DateTime(2025, 5, 26, 13, 30),
        type: TransactionType.expense,
        note: 'Nasi lemak',
      );

  group('Transaction model', () {
    test('toMap / fromMap round trip preserves all fields', () {
      final t = sample();
      final restored = Transaction.fromMap(t.toMap());

      expect(restored.id, t.id);
      expect(restored.title, t.title);
      expect(restored.amount, t.amount);
      expect(restored.category, t.category);
      expect(restored.date, t.date);
      expect(restored.type, t.type);
      expect(restored.note, t.note);
    });

    test('toJson / fromJson round trip preserves all fields', () {
      final t = sample();
      final restored = Transaction.fromJson(t.toJson());

      expect(restored.id, t.id);
      expect(restored.amount, t.amount);
      expect(restored.category, t.category);
      expect(restored.type, t.type);
    });

    test('copyWith only overrides the given fields', () {
      final t = sample();
      final edited = t.copyWith(amount: 99.0, note: 'updated');

      expect(edited.amount, 99.0);
      expect(edited.note, 'updated');
      // Untouched fields stay the same.
      expect(edited.id, t.id);
      expect(edited.category, t.category);
      expect(edited.type, t.type);
    });

    test('category exposes a label and an icon', () {
      expect(Category.food.label, 'Food');
      expect(Category.salary.label, 'Salary');
      expect(Category.food.icon, isNotEmpty);
    });
  });
}
