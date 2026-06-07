// Transfer screen: move funds between banks.
part of '../main.dart';

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

