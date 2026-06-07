// Dead code removed from lib/logic/transaction_manager.dart.
//
// These members had ZERO callers anywhere in the app. They are preserved here
// for reference only — this file is intentionally NOT compiled (del/ is excluded
// from analysis). To restore, paste the relevant member back into the
// TransactionManager class.
//
// ---------------------------------------------------------------------------

// Field + persistence key for a "per-category budget" feature that was never
// wired into any screen. Only loadData() read it and updateCategoryBudget()
// wrote it — neither was reachable from the UI.
//
//   Map<String, double> categoryBudgets = {};
//   static const String _catBudgetKey = 'curl_cat_budgets';
//
// loadData() block:
//   final String? catData = prefs.getString(_catBudgetKey);
//   if (catData != null) {
//     categoryBudgets = Map<String, double>.from(jsonDecode(catData));
//   }

Future<void> updateCategoryBudget(String category, double amount) async {
  categoryBudgets[category] = amount;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_catBudgetKey, jsonEncode(categoryBudgets));
}

// Added custom bank ids — never invoked (onboarding uses setUserBanks instead).
void addCustomBank(String id) {
  if (!_userBankIds.contains(id)) {
    _userBankIds.add(id);
    saveUserBanks();
  }
}

// Transactions filtered by bank — no caller.
List<Transaction> getTransactionsByBank(String bankId) {
  return _transactions
      .where((tx) => tx.bankId == bankId || tx.targetBankId == bankId)
      .toList();
}

// Category spend analytics — dead since expenses became free-text descriptions.
// No screen calls these.
Map<String, double> getExpensesByCategory() {
  final Map<String, double> categories = {};
  for (final tx in _transactions.where((t) => t.type == TransactionType.expense)) {
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }
  return categories;
}

List<MapEntry<String, double>> getTopSpendCategories({int limit = 5}) {
  final categories = getExpensesByCategory().entries.toList();
  categories.sort((a, b) => b.value.compareTo(a.value));
  return categories.take(limit).toList();
}
