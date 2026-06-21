import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/foundation.dart' hide Category;
import '../models/transaction.dart';

/// Holds the app's data and performs all CRUD against Cloud Firestore.
///
/// Transactions live in the `transactions` collection (one document per record,
/// keyed by its id). The monthly budget is stored in `settings/app`. A realtime
/// snapshot listener keeps the in-memory list in sync, so any add/update/delete
/// is reflected in the UI automatically.
class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _db;
  List<Transaction> _transactions = [];
  double _monthlyBudget = 0;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// [firestore] can be injected in tests (e.g. FakeFirebaseFirestore).
  TransactionProvider({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance {
    _listenTransactions();
    _loadBudget();
  }

  CollectionReference<Map<String, dynamic>> get _txCol =>
      _db.collection('transactions');
  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _db.collection('settings').doc('app');

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

  // ── Read (realtime) ──
  void _listenTransactions() {
    _sub = _txCol.snapshots().listen((snapshot) {
      _transactions = snapshot.docs
          .map((d) => Transaction.fromMap(d.data()))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });
  }

  Future<void> _loadBudget() async {
    final snap = await _settingsDoc.get();
    _monthlyBudget = (snap.data()?['monthlyBudget'] as num?)?.toDouble() ?? 0;
    notifyListeners();
  }

  // ── Create ──
  Future<void> add(Transaction t) async {
    await _txCol.doc(t.id).set(t.toMap());
  }

  // ── Update ──
  Future<void> update(Transaction t) async {
    await _txCol.doc(t.id).set(t.toMap());
  }

  // ── Delete ──
  Future<void> delete(String id) async {
    await _txCol.doc(id).delete();
  }

  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    await _settingsDoc.set({'monthlyBudget': amount}, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> clearAll() async {
    final snap = await _txCol.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
