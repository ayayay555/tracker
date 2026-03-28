import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'models/bank.dart';
import 'models/transaction.dart';
import 'logic/transaction_manager.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const FinTrackApp(),
    ),
  );
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primaryColor: const Color(0xFF2D3436),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2D3436),
          secondary: Color(0xFF636E72),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3436),
            letterSpacing: -1.0,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF636E72),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_manager.userBankIds.isEmpty) {
      return OnboardingScreen(onComplete: (selectedIds) {
        setState(() {
          _manager.setUserBanks(selectedIds);
        });
      });
    }

    return Scaffold(
      body: _currentIndex == 0 ? _buildHome(context) : _buildAnalysis(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2D3436),
        unselectedItemColor: Colors.black12,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'Analysis'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 1 ? null : Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FloatingActionButton(
          onPressed: _showAddTransactionSheet,
          backgroundColor: const Color(0xFF2D3436),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    // For local UI purposes, assume initial balance is 0 for banks not in transactions
    final totalBalance = _manager.getTotalBalance({});
    
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '₱${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ),

          // Monthly Budget Status (New Section)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Budget', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3436),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Spent this month', style: TextStyle(color: Colors.white60, fontSize: 13)),
                            Text(
                              '₱${_manager.getTotalMonthlyExpenses().toStringAsFixed(0)} / ₱${_manager.monthlyBudget.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (_manager.getTotalMonthlyExpenses() / _manager.monthlyBudget).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // User's Banks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Accounts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
                  const SizedBox(height: 12),
                  ..._manager.userBankIds.map((id) {
                    final bank = Bank.phBanks.firstWhere((b) => b.id == id, orElse: () => Bank(id: id, name: id.toUpperCase(), type: BankType.traditional));
                    final bankBalance = _manager.getBankBalance(id);
                    
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BankDetailsScreen(bank: bank, manager: _manager),
                        ),
                      ).then((_) => setState(() {})),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  bank.type == BankType.digital ? 'Digital Wallet' : 'Traditional Bank',
                                  style: const TextStyle(fontSize: 12, color: Colors.black26, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Text(
                              '₱${bankBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text('History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
            ),
          ),

          _manager.transactions.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: Text('No activity yet.', style: TextStyle(color: Colors.black26))),
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
                          color: Colors.redAccent.withOpacity(0.05),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _manager.deleteTransaction(tx.id);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F2F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  tx.type == TransactionType.income ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                  color: tx.type == TransactionType.income ? Colors.black : Colors.black45,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                    Text(tx.bankId.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.black38)),
                                  ],
                                ),
                              ),
                              Text(
                                '${tx.type == TransactionType.income ? '+' : '-'}₱${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: tx.type == TransactionType.income ? Colors.black : Colors.black54,
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
            const Text('Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Spending', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500)),
                      Text('₱${monthlyExpenses.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: budgetPercent,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F2F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D3436)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(budgetPercent * 100).toInt()}% of monthly limit',
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            const Text('Top Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38)),
            const SizedBox(height: 16),
            
            if (topCategories.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No data recorded.', style: TextStyle(color: Colors.black12))))
            else
              ...topCategories.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Text('₱${entry.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => AddTransactionSheet(manager: _manager),
    ).then((result) {
      if (result != null && result is Transaction) {
        setState(() {
          _manager.addTransaction(result);
        });
      }
    });
  }
}

class OnboardingScreen extends StatefulWidget {
  final Function(List<String>) onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> _selectedIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('Welcome to FinTrack', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
              const SizedBox(height: 12),
              const Text('Which banks or wallets do you use?', style: TextStyle(fontSize: 16, color: Colors.black45)),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: Bank.phBanks.length,
                  itemBuilder: (context, index) {
                    final bank = Bank.phBanks[index];
                    final isSelected = _selectedIds.contains(bank.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) _selectedIds.remove(bank.id);
                          else _selectedIds.add(bank.id);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF1F2F6) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? const Color(0xFF2D3436) : Colors.black.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: const Color(0xFF2D3436)),
                            const SizedBox(width: 16),
                            Text(bank.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIds.isEmpty ? null : () => widget.onComplete(_selectedIds),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3436),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: Colors.black12,
                  ),
                  child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTransactionSheet extends StatefulWidget {
  final TransactionManager manager;
  const AddTransactionSheet({super.key, required this.manager});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionType _type = TransactionType.expense;
  late String _selectedBankId;
  String _selectedCategory = 'Food';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customBankController = TextEditingController();

  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Shopping', 'Salary', 'Others'];

  @override
  void initState() {
    super.initState();
    _selectedBankId = widget.manager.userBankIds.first;
  }

  @override
  Widget build(BuildContext context) {
    final userBanks = widget.manager.userBankIds.map((id) => Bank.phBanks.firstWhere(
      (b) => b.id == id, orElse: () => Bank(id: id, name: id.toUpperCase(), type: BankType.traditional))).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Log Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.keyboard_arrow_down)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _typeButton('Expense', TransactionType.expense),
              const SizedBox(width: 8),
              _typeButton('Deposit', TransactionType.income),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
            decoration: const InputDecoration(
              prefixText: '₱',
              hintText: '0.00',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.black12),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          const Text('Select Bank', style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...userBanks.map((bank) {
                final isSelected = _selectedBankId == bank.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBankId = bank.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3436) : const Color(0xFFF1F2F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(bank.name, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }),
              GestureDetector(
                onTap: _showCustomBankPrompt,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Text('+ Add Other', style: TextStyle(color: Colors.black54)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    color: isSelected ? const Color(0xFF2D3436) : const Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
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
                backgroundColor: const Color(0xFF2D3436),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Save Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showCustomBankPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Other Bank'),
        content: TextField(
          controller: _customBankController,
          decoration: const InputDecoration(hintText: 'Enter bank name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = _customBankController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  widget.manager.addCustomBank(name.toLowerCase());
                  _selectedBankId = name.toLowerCase();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
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
            color: isSelected ? const Color(0xFFF1F2F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF2D3436) : Colors.black.withOpacity(0.05)),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF2D3436) : Colors.black26, fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal)),
        ),
      ),
    );
  }
}

class BankDetailsScreen extends StatelessWidget {
  final Bank bank;
  final TransactionManager manager;

  const BankDetailsScreen({super.key, required this.bank, required this.manager});

  @override
  Widget build(BuildContext context) {
    final transactions = manager.getTransactionsByBank(bank.id);
    final balance = manager.getBankBalance(bank.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(bank.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const Text('Current Balance', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                  '₱${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No transactions for this bank.', style: TextStyle(color: Colors.black26)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F2F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                tx.type == TransactionType.income ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                color: tx.type == TransactionType.income ? Colors.black : Colors.black45,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text(
                                    '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${tx.type == TransactionType.income ? '+' : '-'}₱${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: tx.type == TransactionType.income ? Colors.black : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
