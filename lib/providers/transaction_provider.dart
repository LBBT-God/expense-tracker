import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  double _monthlyBudget = 0;

  List<Transaction> get allTransactions => List.unmodifiable(_transactions);

  double get monthlyBudget => _monthlyBudget;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  Transaction? getById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  TransactionProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('transactions') ?? [];
    _transactions = data.map((s) => Transaction.fromJson(s)).toList();
    _monthlyBudget = prefs.getDouble('monthly_budget') ?? 0;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'transactions',
      _transactions.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> add(Transaction t) async {
    _transactions.add(t);
    await _save();
    notifyListeners();
  }

  Future<void> update(Transaction t) async {
    final i = _transactions.indexWhere((x) => x.id == t.id);
    if (i != -1) {
      _transactions[i] = t;
      await _save();
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', amount);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _transactions.clear();
    await _save();
    notifyListeners();
  }
}
