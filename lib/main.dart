import 'package:flutter/material.dart';
import 'models/bank.dart';
import 'models/transaction.dart';
import 'logic/transaction_manager.dart';

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00FFAB),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFAB),
          secondary: Color(0xFF00FFAB),
          surface: Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.5,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionManager _manager = TransactionManager();
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _manager.loadTransactions();
    setState(() {
      _isLoading = false;
    });
  }
  
  // Dummy data for initial balances
  final Map<String, double> _balances = {
    'gcash': 5420.50,
    'maya': 12300.75,
    'bdo': 45000.00,
    'gotyme': 890.00,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _buildHome(context) : _buildAnalysis(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFF00FFAB),
        unselectedItemColor: Colors.white24,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analysis'),
        ],
      ),
      // Floating Action Button: Add Transaction
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 1 ? null : Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FloatingActionButton.extended(
          onPressed: _showAddTransactionSheet,
          backgroundColor: const Color(0xFF00FFAB),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          label: const Text(
            'Add Transaction',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          icon: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    final totalBalance = _manager.getTotalBalance(_balances);
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Sticky Header: Total Wealth
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Wealth', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '₱${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Bank Scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _balances.length,
                itemBuilder: (context, index) {
                  final bankKey = _balances.keys.elementAt(index);
                  final balance = _balances[bankKey]!;
                  final bank = Bank.phBanks.firstWhere((b) => b.id == bankKey, orElse: () => Bank(id: bankKey, name: bankKey.toUpperCase(), type: BankType.traditional));

                  return Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(bank.name, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold)),
                        Text('₱${balance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Transaction History Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Minimalist Transaction List
          _manager.transactions.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(
                      child: Text('No transactions yet.', style: TextStyle(color: Colors.white30)),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = _manager.transactions[index];
                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: Colors.red.withOpacity(0.1),
                          child: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _manager.deleteTransaction(tx.id);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: tx.type == TransactionType.income ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  tx.type == TransactionType.income ? Icons.south_west : Icons.north_east,
                                  color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(tx.bankId.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                  ],
                                ),
                              ),
                              Text(
                                '${tx.type == TransactionType.income ? '+' : '-'}₱${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tx.type == TransactionType.income ? const Color(0xFF00FFAB) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                      childCount: _manager.transactions.length,
                      ),
                      ),
          // Padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAnalysis(BuildContext context) {
    final monthlyExpenses = _manager.getTotalMonthlyExpenses();
    final budgetPercent = (monthlyExpenses / _manager.monthlyBudget).clamp(0.0, 1.0);
    final topCategories = _manager.getTopSpendCategories();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            // Budget Progress Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Budget', style: TextStyle(color: Colors.white54)),
                      Text(
                        '₱${monthlyExpenses.toStringAsFixed(0)} / ₱${_manager.monthlyBudget.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: budgetPercent,
                      minHeight: 12,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budgetPercent > 0.8 ? Colors.red : const Color(0xFF00FFAB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    budgetPercent > 0.8 ? 'Careful! You are almost at your limit.' : 'You are doing great!',
                    style: TextStyle(fontSize: 12, color: budgetPercent > 0.8 ? Colors.red : Colors.white54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            const Text('Top Spending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            if (topCategories.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No expense data yet.', style: TextStyle(color: Colors.white24))))
            else
              ...topCategories.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16)),
                    Text('₱${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const AddTransactionSheet(),
    ).then((result) {
      if (result != null && result is Transaction) {
        setState(() {
          _manager.addTransaction(result);
        });
      }
    });
  }
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionType _type = TransactionType.expense;
  String _selectedBankId = 'gcash';
  String _selectedCategory = 'Food';
  final TextEditingController _amountController = TextEditingController();

  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Shopping', 'Salary', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Type Toggle
          Row(
            children: [
              _typeButton('Expense', TransactionType.expense),
              const SizedBox(width: 12),
              _typeButton('Income', TransactionType.income),
            ],
          ),
          const SizedBox(height: 32),

          // Amount Input
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF00FFAB)),
            decoration: const InputDecoration(
              prefixText: '₱',
              hintText: '0.00',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white10),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),

          // Bank Selection
          const Text('From/To Bank', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Bank.phBanks.length,
              itemBuilder: (context, index) {
                final bank = Bank.phBanks[index];
                final isSelected = _selectedBankId == bank.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBankId = bank.id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00FFAB) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bank.name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Category Selection
          const Text('Category', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  final tx = Transaction(
                    bankId: _selectedBankId,
                    amount: amount,
                    category: _selectedCategory,
                    type: _type,
                    date: DateTime.now(),
                  );
                  Navigator.pop(context, tx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFAB),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _typeButton(String label, TransactionType type) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.white24 : Colors.white10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white30,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
