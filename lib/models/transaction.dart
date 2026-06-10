import 'dart:convert';

enum TransactionType { income, expense }

enum Category {
  food,
  transport,
  shopping,
  entertainment,
  health,
  salary,
  education,
  other,
}

extension CategoryExtension on Category {
  String get label {
    const labels = {
      Category.food: 'Food',
      Category.transport: 'Transport',
      Category.shopping: 'Shopping',
      Category.entertainment: 'Entertainment',
      Category.health: 'Health',
      Category.salary: 'Salary',
      Category.education: 'Education',
      Category.other: 'Other',
    };
    return labels[this]!;
  }

  String get icon {
    const icons = {
      Category.food: '🍔',
      Category.transport: '🚗',
      Category.shopping: '🛍️',
      Category.entertainment: '🎮',
      Category.health: '💊',
      Category.salary: '💼',
      Category.education: '📚',
      Category.other: '📦',
    };
    return icons[this]!;
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;
  final TransactionType type;
  final String note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.note = '',
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    Category? category,
    DateTime? date,
    TransactionType? type,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.index,
      'date': date.millisecondsSinceEpoch,
      'type': type.index,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: Category.values[map['category']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: TransactionType.values[map['type']],
      note: map['note'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(jsonDecode(source));
}
