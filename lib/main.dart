import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'models/bank.dart';
import 'models/transaction.dart';
import 'logic/transaction_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    DevicePreview(
      enabled:
          kIsWeb &&
          ![
            TargetPlatform.android,
            TargetPlatform.iOS,
          ].contains(defaultTargetPlatform),
      builder: (context) => const CurlApp(),
    ),
  );
}

class CurlApp extends StatefulWidget {
  const CurlApp({super.key});

  @override
  State<CurlApp> createState() => _CurlAppState();
}

class _CurlAppState extends State<CurlApp> {
  final TransactionManager _manager = TransactionManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _manager.loadData();
    setState(() {
      _isLoading = false;
    });
  }

  ThemeData _getTheme(AppThemeMode mode, BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );

    switch (mode) {
      case AppThemeMode.banana:
        return baseTheme.copyWith(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
          primaryColor: const Color(0xFFFFD93D),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFFD93D),
            secondary: Color(0xFF2C2C2E),
            surface: Colors.white,
            onSurface: Color(0xFF2C2C2E),
          ),
          cardColor: Colors.white,
        );
      case AppThemeMode.dark:
        return baseTheme.copyWith(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFFFFD93D),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD93D),
            secondary: Color(0xFF2C2C2E),
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
            onSecondary: Colors.white,
          ),
          cardColor: const Color(0xFF1E1E1E),
        );
      case AppThemeMode.system:
        return baseTheme.copyWith(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF2F2F7),
          primaryColor: const Color(0xFF007AFF),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF007AFF),
            secondary: Color(0xFF1C1C1E),
            surface: Colors.white,
          ),
          cardColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Curl',
      debugShowCheckedModeBanner: false,
      theme: _getTheme(_manager.themeMode, context),
      home: _manager.username.isEmpty
          ? OnboardingScreen(
              manager: _manager,
              onComplete: () => setState(() {}),
            )
          : MainNavigation(
              manager: _manager,
              onThemeChange: () => setState(() {}),
            ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final TransactionManager manager;
  final VoidCallback onThemeChange;
  const MainNavigation({
    super.key,
    required this.manager,
    required this.onThemeChange,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(manager: widget.manager),
      TransferPage(manager: widget.manager),
      SettingsPage(
        manager: widget.manager,
        onThemeChange: widget.onThemeChange,
      ),
      ProfilePage(manager: widget.manager),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: colorScheme.secondary,
          unselectedItemColor: Colors.grey.withValues(alpha: 0.5),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined),
              activeIcon: Icon(Icons.swap_horiz_rounded),
              label: 'Transfer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREENS ---

class HomeScreen extends StatefulWidget {
  final TransactionManager manager;
  const HomeScreen({super.key, required this.manager});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTransactionsExpanded = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showBankBreakdown(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Bank Breakdown',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            ...widget.manager.userBankIds.map((id) {
              final balance = widget.manager.getBankBalance(id);
              final bank = Bank.phBanks.firstWhere(
                (b) => b.id == id,
                orElse: () => Bank(
                  id: id,
                  name: id.toUpperCase(),
                  type: BankType.traditional,
                ),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bank.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '₱${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBalance = widget.manager.getTotalBalance();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.manager.username,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          backgroundImage:
                              widget.manager.profilePicturePath != null
                                  ? FileImage(
                                      File(widget.manager.profilePicturePath!),
                                    )
                                  : null,
                          child: widget.manager.profilePicturePath == null
                              ? Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Premium Balance Island
                    GestureDetector(
                      onTap: () => _showBankBreakdown(context, theme),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.secondary,
                              theme.colorScheme.secondary.withValues(
                                alpha: 0.8,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₱${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                _actionButton(
                                  context,
                                  'Deposit',
                                  Icons.arrow_downward_rounded,
                                  () => _showTransactionSheet(
                                    TransactionType.income,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _actionButton(
                                  context,
                                  'Withdraw',
                                  Icons.arrow_upward_rounded,
                                  () => _showTransactionSheet(
                                    TransactionType.expense,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Budget Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: _showBudgetModal,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monthly Budget',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${widget.manager.budgetItems.length} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${widget.manager.getTotalMonthlyExpenses().toStringAsFixed(0)} spent',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '₱${widget.manager.monthlyBudget.toStringAsFixed(0)} total',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                (widget.manager.getTotalMonthlyExpenses() /
                                        widget.manager.monthlyBudget)
                                    .clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Expandable Transactions Island
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isTransactionsExpanded =
                                  !_isTransactionsExpanded,
                            ),
                            child: AnimatedRotation(
                              turns: _isTransactionsExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (widget.manager.transactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No transactions yet',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _isTransactionsExpanded
                              ? widget.manager.transactions.length
                              : (widget.manager.transactions.length > 1
                                  ? 1
                                  : widget.manager.transactions.length),
                          itemBuilder: (context, index) => _transactionTile(
                            widget.manager.transactions[index],
                            theme,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionTile(Transaction tx, ThemeData theme) {
    final isExpense = tx.type == TransactionType.expense;
    final isTransfer = tx.type == TransactionType.transfer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTransfer
                  ? Colors.blue.withValues(alpha: 0.1)
                  : (isExpense
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isTransfer
                  ? Icons.swap_horiz_rounded
                  : (isExpense
                      ? Icons.shopping_bag_rounded
                      : Icons.account_balance_wallet_rounded),
              size: 20,
              color: isTransfer
                  ? Colors.blue
                  : (isExpense ? Colors.red : Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  tx.bankId.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? "-" : isTransfer ? "" : "+"}₱${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionSheet(TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TransactionInputSheet(manager: widget.manager, type: type),
    ).then((_) => setState(() {}));
  }

  void _showBudgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetPlannerSheet(manager: widget.manager),
    ).then((_) => setState(() {}));
  }
}

class BudgetPlannerSheet extends StatefulWidget {
  final TransactionManager manager;
  const BudgetPlannerSheet({super.key, required this.manager});

  @override
  State<BudgetPlannerSheet> createState() => _BudgetPlannerSheetState();
}

class _BudgetPlannerSheetState extends State<BudgetPlannerSheet> {
  late List<Map<String, dynamic>> _items;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.manager.budgetItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Budget Planner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: Key(item['name'] + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => setState(() => _items.removeAt(index)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '₱${item['amount'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add New Item
          Container(
            padding: EdgeInsets.only(bottom: bottomInset + 24, top: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Item (e.g. Rent)',
                      filled: true,
                      fillColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      filled: true,
                      fillColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final amount = double.tryParse(_amountController.text);
                    if (_nameController.text.isNotEmpty && amount != null) {
                      setState(() {
                        _items.add({
                          'name': _nameController.text,
                          'amount': amount,
                        });
                        _nameController.clear();
                        _amountController.clear();
                      });
                    }
                  },
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                widget.manager.updateBudgetItems(_items);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Save Plan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class TransferPage extends StatefulWidget {
  final TransactionManager manager;
  const TransferPage({super.key, required this.manager});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin {
  String? fromBankId;
  String? toBankId;
  final TextEditingController _amountController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.manager.userBankIds.isNotEmpty) {
      fromBankId = widget.manager.userBankIds.first;
      if (widget.manager.userBankIds.length > 1) {
        toBankId = widget.manager.userBankIds[1];
      }
    }
  }

  void _swapBanks() {
    _animController.forward(from: 0);
    setState(() {
      final temp = fromBankId;
      fromBankId = toBankId;
      toBankId = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Transfer',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 40),

              // Sleek Card Container for Transfer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _bankSelectorCard(
                      theme,
                      'Send from',
                      fromBankId,
                      (val) => setState(() => fromBankId = val),
                    ),

                    // Floating Animated Swap
                    Transform.translate(
                      offset: const Offset(0, 0),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(
                          CurvedAnimation(
                            parent: _animController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: _swapBanks,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.swap_vert_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    _bankSelectorCard(
                      theme,
                      'Receive in',
                      toBankId,
                      (val) => setState(() => toBankId = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    prefixStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                    border: InputBorder.none,
                    hintText: '0.00',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _performTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 10,
                    shadowColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: const Text(
                    'Confirm Transfer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankSelectorCard(
    ThemeData theme,
    String label,
    String? selectedId,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface,
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
              ),
              items: widget.manager.userBankIds.map((id) {
                final bank = Bank.phBanks.firstWhere(
                  (b) => b.id == id,
                  orElse: () => Bank(
                    id: id,
                    name: id.toUpperCase(),
                    type: BankType.traditional,
                  ),
                );
                return DropdownMenuItem(value: id, child: Text(bank.name));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _performTransfer() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (fromBankId != null &&
        amount > widget.manager.getBankBalance(fromBankId!)) {
      _showWarning(
        'Insufficient Funds',
        'You are transferring more than your current balance in this bank.',
      );
      return;
    }
    if (amount > 0 &&
        fromBankId != null &&
        toBankId != null &&
        fromBankId != toBankId) {
      final tx = Transaction(
        bankId: fromBankId!,
        targetBankId: toBankId!,
        amount: amount,
        category: 'Transfer',
        type: TransactionType.transfer,
        date: DateTime.now(),
      );
      widget.manager.addTransaction(tx);
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer Successful!'),
          behavior: SnackBarBehavior.floating,
          shape: StadiumBorder(),
        ),
      );
    }
  }

  void _showWarning(String title, String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'OK',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final TransactionManager manager;
  final VoidCallback onThemeChange;
  const SettingsPage({
    super.key,
    required this.manager,
    required this.onThemeChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),

            Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _themeOption(
                    context,
                    'Banana Yellow',
                    AppThemeMode.banana,
                    const Color(0xFFFFD93D),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  _themeOption(
                    context,
                    'System Default',
                    AppThemeMode.system,
                    Colors.blue,
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  _themeOption(
                    context,
                    'Dark Mode',
                    AppThemeMode.dark,
                    const Color(0xFF2C2C2E),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    String title,
    AppThemeMode mode,
    Color color,
  ) {
    final isSelected = manager.themeMode == mode;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(backgroundColor: color, radius: 16),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onTap: () {
        manager.setTheme(mode);
        onThemeChange();
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  final TransactionManager manager;
  const ProfilePage({super.key, required this.manager});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.manager.username);
    _emailController = TextEditingController(text: widget.manager.email);
    _phoneController = TextEditingController(text: widget.manager.phoneNumber);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await widget.manager.setUserProfile(
        name: widget.manager.username,
        pic: image.path,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isEditing) {
                        widget.manager.setUserProfile(
                          name: _nameController.text,
                          mail: _emailController.text,
                          phone: _phoneController.text,
                        );
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isEditing
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isEditing
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.05,
                          ),
                          image: widget.manager.profilePicturePath != null
                              ? DecorationImage(
                                  image: FileImage(
                                    File(widget.manager.profilePicturePath!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: widget.manager.profilePicturePath == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondary,
                            radius: 22,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _infoField(theme, 'Full Name', _nameController),
                    Divider(
                      height: 32,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                    _infoField(theme, 'Email Address', _emailController),
                    Divider(
                      height: 32,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                    _infoField(theme, 'Phone Number', _phoneController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoField(
    ThemeData theme,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.only(top: 8),
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// --- ONBOARDING ---

class OnboardingScreen extends StatefulWidget {
  final TransactionManager manager;
  final VoidCallback onComplete;
  const OnboardingScreen({
    super.key,
    required this.manager,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedBanks = [];
  AppThemeMode _selectedTheme = AppThemeMode.banana;

  void _next() {
    if (_step < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
      setState(() => _step++);
    } else {
      widget.manager.setUserProfile(name: _nameController.text);
      widget.manager.setUserBanks(_selectedBanks);
      widget.manager.setTheme(_selectedTheme);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _welcomeStep(theme),
                  _bankStep(theme),
                  _themeStep(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _canGoNext() ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 10,
                    shadowColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: Text(
                    _step == 2 ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canGoNext() {
    if (_step == 0) return _nameController.text.isNotEmpty;
    if (_step == 1) return _selectedBanks.isNotEmpty;
    return true;
  }

  Widget _welcomeStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Image.asset('img/newmascot.png', height: 160),
          ),
          const SizedBox(height: 48),
          Text(
            'Welcome to Curl',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your premium financial companion.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'What should we call you?',
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Banks',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the accounts you use regularly.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: Bank.phBanks.length,
              itemBuilder: (context, index) {
                final bank = Bank.phBanks[index];
                final isSelected = _selectedBanks.contains(bank.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected)
                        _selectedBanks.remove(bank.id);
                      else
                        _selectedBanks.add(bank.id);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          bank.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Theme',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a vibe that suits you best.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          _themeCard(
            theme,
            'Banana',
            'Vibrant & Yellow',
            AppThemeMode.banana,
            const Color(0xFFFFD93D),
          ),
          _themeCard(
            theme,
            'System',
            'Clean & Minimal',
            AppThemeMode.system,
            Colors.blue,
          ),
          _themeCard(
            theme,
            'Dark Mode',
            'Easy on the eyes',
            AppThemeMode.dark,
            const Color(0xFF2C2C2E),
          ),
        ],
      ),
    );
  }

  Widget _themeCard(
    ThemeData theme,
    String title,
    String desc,
    AppThemeMode mode,
    Color color,
  ) {
    final isSelected = _selectedTheme == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: CircleAvatar(backgroundColor: color, radius: 12),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}

class TransactionInputSheet extends StatefulWidget {
  final TransactionManager manager;
  final TransactionType type;
  const TransactionInputSheet({
    super.key,
    required this.manager,
    required this.type,
  });

  @override
  State<TransactionInputSheet> createState() => _TransactionInputSheetState();
}

class _TransactionInputSheetState extends State<TransactionInputSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedBankId;
  String _selectedCategory = 'Food';
  final List<String> _categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Others',
    'Salary',
    'Gift',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.manager.userBankIds.isNotEmpty) {
      _selectedBankId = widget.manager.userBankIds.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 32,
        right: 32,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.type == TransactionType.income ? 'Deposit' : 'Withdraw',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixText: '₱ ',
              border: InputBorder.none,
              hintText: '0.00',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              prefixStyle: TextStyle(
                fontSize: 32,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Select Bank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.manager.userBankIds.map((id) {
              final isSelected = _selectedBankId == id;
              return GestureDetector(
                onTap: () => setState(() => _selectedBankId = id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    id.toUpperCase(),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          if (widget.type == TransactionType.expense) ...[
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 10,
                shadowColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.3,
                ),
              ),
              child: const Text(
                'Save Log',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (widget.type == TransactionType.expense && _selectedBankId != null) {
      if (amount > widget.manager.getBankBalance(_selectedBankId!)) {
        _showWarning('Insufficient Funds', 'You are spending more than your current balance in this bank.');
        return;
      }
    }
    if (amount > 0 && _selectedBankId != null) {
      final tx = Transaction(
        bankId: _selectedBankId!,
        amount: amount,
        category: widget.type == TransactionType.income
            ? 'Deposit'
            : _selectedCategory,
        type: widget.type,
        date: DateTime.now(),
      );
      widget.manager.addTransaction(tx);
      Navigator.pop(context);
    }
  }

  void _showWarning(String title, String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'OK',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
