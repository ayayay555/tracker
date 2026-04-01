import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

enum AppThemeMode { banana, system, dark }

class TransactionManager {
  List<Transaction> _transactions = [];
  List<String> _userBankIds = [];
  double monthlyBudget = 20000.0;
  String budgetNote = '';
  Map<String, double> categoryBudgets = {};
  
  // User Profile
  String username = '';
  String email = '';
  String phoneNumber = '';
  String? profilePicturePath;
  
  // Theme
  AppThemeMode themeMode = AppThemeMode.banana;

  static const String _storageKey = 'curl_transactions';
  static const String _banksKey = 'curl_user_banks';
  static const String _budgetKey = 'curl_budget';
  static const String _budgetNoteKey = 'curl_budget_note';
  static const String _catBudgetKey = 'curl_cat_budgets';
  
  static const String _usernameKey = 'curl_username';
  static const String _emailKey = 'curl_email';
  static const String _phoneKey = 'curl_phone';
  static const String _profilePicKey = 'curl_profile_pic';
  static const String _themeKey = 'curl_theme';

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<String> get userBankIds => List.unmodifiable(_userBankIds);

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Transactions
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _transactions = decoded.map((item) => Transaction.fromJson(item)).toList();
    }

    // Load User Banks
    _userBankIds = prefs.getStringList(_banksKey) ?? [];

    // Load Budgets
    monthlyBudget = prefs.getDouble(_budgetKey) ?? 20000.0;
    budgetNote = prefs.getString(_budgetNoteKey) ?? '';
    final String? catData = prefs.getString(_catBudgetKey);
    if (catData != null) {
      categoryBudgets = Map<String, double>.from(jsonDecode(catData));
    }
    
    // Load Profile
    username = prefs.getString(_usernameKey) ?? '';
    email = prefs.getString(_emailKey) ?? '';
    phoneNumber = prefs.getString(_phoneKey) ?? '';
    profilePicturePath = prefs.getString(_profilePicKey);
    
    // Load Theme
    final int themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.banana.index;
    themeMode = AppThemeMode.values[themeIndex];
  }

  Future<void> updateBudget(double amount) async {
    monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }

  Future<void> updateBudgetNote(String note) async {
    budgetNote = note;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetNoteKey, note);
  }

  Future<void> updateCategoryBudget(String category, double amount) async {
    categoryBudgets[category] = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_catBudgetKey, jsonEncode(categoryBudgets));
  }

  Future<void> setUserProfile({required String name, String? mail, String? phone, String? pic}) async {
    username = name;
    if (mail != null) email = mail;
    if (phone != null) phoneNumber = phone;
    if (pic != null) profilePicturePath = pic;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, phoneNumber);
    if (profilePicturePath != null) await prefs.setString(_profilePicKey, profilePicturePath!);
  }

  Future<void> setTheme(AppThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> saveUserBanks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_banksKey, _userBankIds);
  }

  void setUserBanks(List<String> ids) {
    _userBankIds = ids;
    saveUserBanks();
  }

  void addCustomBank(String id) {
    if (!_userBankIds.contains(id)) {
      _userBankIds.add(id);
      saveUserBanks();
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

  // Filtered History
  List<Transaction> getTransactionsByBank(String bankId) {
    return _transactions.where((tx) => tx.bankId == bankId || tx.targetBankId == bankId).toList();
  }

  double getBankBalance(String bankId) {
    double balance = 0;
    for (final tx in _transactions) {
      if (tx.type == TransactionType.income) {
        if (tx.bankId == bankId) balance += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        if (tx.bankId == bankId) balance -= tx.amount;
      } else if (tx.type == TransactionType.transfer) {
        if (tx.bankId == bankId) balance -= tx.amount;
        if (tx.targetBankId == bankId) balance += tx.amount;
      }
    }
    return balance;
  }

  // Analysis Features
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categories = {};
    for (final tx in _transactions.where((t) => t.type == TransactionType.expense)) {
      categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
    }
    return categories;
  }

  double getTotalBalance() {
    double total = 0;
    for (final bankId in _userBankIds) {
      total += getBankBalance(bankId);
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

  List<MapEntry<String, double>> getTopSpendCategories({int limit = 5}) {
    final categories = getExpensesByCategory().entries.toList();
    categories.sort((a, b) => b.value.compareTo(a.value));
    return categories.take(limit).toList();
  }
}
