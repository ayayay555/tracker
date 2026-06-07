import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/note.dart';
import '../models/goal.dart';
import '../models/todo_item.dart';

enum AppThemeMode { banana, system, dark }

class TransactionManager {
  List<Transaction> _transactions = [];
  List<String> _userBankIds = [];
  double monthlyBudget = 20000.0;
  List<Map<String, dynamic>> budgetItems = [];

  List<Note> _notes = [];
  List<Goal> _goals = [];
  List<TodoItem> _todos = [];

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
  static const String _budgetItemsKey = 'curl_budget_items';

  static const String _notesKey = 'curl_notes';
  static const String _goalsKey = 'curl_goals';
  static const String _todosKey = 'curl_todos';

  static const String _usernameKey = 'curl_username';
  static const String _emailKey = 'curl_email';
  static const String _phoneKey = 'curl_phone';
  static const String _profilePicKey = 'curl_profile_pic';
  static const String _themeKey = 'curl_theme';

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<String> get userBankIds => List.unmodifiable(_userBankIds);
  List<Note> get notes => List.unmodifiable(_notes);
  List<Goal> get goals => List.unmodifiable(_goals);
  List<TodoItem> get todos => List.unmodifiable(_todos);

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
    
    final String? itemsData = prefs.getString(_budgetItemsKey);
    if (itemsData != null) {
      budgetItems = List<Map<String, dynamic>>.from(jsonDecode(itemsData));
    }

    // Load Notes
    final String? notesData = prefs.getString(_notesKey);
    if (notesData != null) {
      final List<dynamic> decoded = jsonDecode(notesData);
      _notes = decoded.map((item) => Note.fromJson(item)).toList();
    }

    // Load Goals
    final String? goalsData = prefs.getString(_goalsKey);
    if (goalsData != null) {
      final List<dynamic> decoded = jsonDecode(goalsData);
      _goals = decoded.map((item) => Goal.fromJson(item)).toList();
    }

    // Load Todos
    final String? todosData = prefs.getString(_todosKey);
    if (todosData != null) {
      final List<dynamic> decoded = jsonDecode(todosData);
      _todos = decoded.map((item) => TodoItem.fromJson(item)).toList();
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

  Future<void> updateBudgetItems(List<Map<String, dynamic>> items) async {
    budgetItems = items;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetItemsKey, jsonEncode(items));
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

  // ---------- NOTES ----------
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    await _saveNotes();
  }

  Future<void> updateNote(String id, {String? title, String? body}) async {
    final note = _notes.firstWhere((n) => n.id == id);
    if (title != null) note.title = title;
    if (body != null) note.body = body;
    note.updatedAt = DateTime.now();
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _saveNotes();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }

  // ---------- GOALS ----------
  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsKey, jsonEncode(_goals.map((g) => g.toJson()).toList()));
  }

  Future<void> addGoal(Goal goal) async {
    _goals.insert(0, goal);
    await _saveGoals();
  }

  Future<void> updateGoal(String id, {String? title, double? targetAmount, double? savedAmount, DateTime? deadline, bool clearDeadline = false}) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    if (title != null) goal.title = title;
    if (targetAmount != null) goal.targetAmount = targetAmount;
    if (savedAmount != null) goal.savedAmount = savedAmount;
    if (clearDeadline) {
      goal.deadline = null;
    } else if (deadline != null) {
      goal.deadline = deadline;
    }
    await _saveGoals();
  }

  Future<void> contributeToGoal(String id, double amount) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    goal.savedAmount += amount;
    if (goal.savedAmount < 0) goal.savedAmount = 0;
    await _saveGoals();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveGoals();
  }

  // ---------- TODOS ----------
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todosKey, jsonEncode(_todos.map((t) => t.toJson()).toList()));
  }

  Future<void> addTodo(TodoItem todo) async {
    _todos.insert(0, todo);
    await _saveTodos();
  }

  Future<void> updateTodo(String id, {String? title, double? cost, String? bankId}) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (todo.completed) return;
    if (title != null) todo.title = title;
    if (cost != null) todo.cost = cost;
    if (bankId != null) todo.bankId = bankId;
    await _saveTodos();
  }

  /// Mark a todo as done. Creates an expense transaction from the linked bank.
  /// Returns false if the linked bank doesn't have enough balance.
  Future<bool> completeTodo(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (todo.completed) return true;

    final balance = getBankBalance(todo.bankId);
    if (balance < todo.cost) return false;

    final tx = Transaction(
      bankId: todo.bankId,
      amount: todo.cost,
      category: 'To-Do: ${todo.title}',
      type: TransactionType.expense,
      date: DateTime.now(),
      note: todo.title,
    );
    await addTransaction(tx);

    todo.completed = true;
    todo.completedAt = DateTime.now();
    todo.linkedTransactionId = tx.id;
    await _saveTodos();
    return true;
  }

  /// Reverse completion. Removes the linked expense transaction if it still exists.
  Future<void> uncompleteTodo(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (!todo.completed) return;

    if (todo.linkedTransactionId != null) {
      await deleteTransaction(todo.linkedTransactionId!);
    }
    todo.completed = false;
    todo.completedAt = null;
    todo.linkedTransactionId = null;
    await _saveTodos();
  }

  Future<void> deleteTodo(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (todo.linkedTransactionId != null) {
      await deleteTransaction(todo.linkedTransactionId!);
    }
    _todos.removeWhere((t) => t.id == id);
    await _saveTodos();
  }
}
