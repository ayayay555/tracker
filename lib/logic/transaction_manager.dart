import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionManager {
  List<Transaction> _transactions = [];
  double monthlyBudget = 20000.0;
  static const String _storageKey = 'fintrack_transactions';

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _transactions = decoded.map((item) => Transaction.fromJson(item)).toList();
    }
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_transactions.map((tx) => tx.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addTransaction(Transaction tx) async {
    _transactions.insert(0, tx);
    await saveTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await saveTransactions();
  }

  // Analysis Features
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categories = {};
    for (final tx in _transactions.where((t) => t.type == TransactionType.expense)) {
      categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
    }
    return categories;
  }

  Map<String, double> getSpendingByBank() {
    final Map<String, double> banks = {};
    for (final tx in _transactions.where((t) => t.type == TransactionType.expense)) {
      banks[tx.bankId] = (banks[tx.bankId] ?? 0) + tx.amount;
    }
    return banks;
  }

  List<MapEntry<String, double>> getTopSpendCategories({int limit = 5}) {
    final categories = getExpensesByCategory().entries.toList();
    categories.sort((a, b) => b.value.compareTo(a.value));
    return categories.take(limit).toList();
  }

  double getTotalBalance(Map<String, double> initialBalances) {
    double total = initialBalances.values.fold(0, (sum, b) => sum + b);
    for (final tx in _transactions) {
      if (tx.type == TransactionType.income) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  double getTotalMonthlyExpenses() {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            tx.date.month == now.month &&
            tx.date.year == now.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
}
