// Deposit / Withdraw bottom sheet.
part of '../main.dart';

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
  final TextEditingController _descController = TextEditingController();
  String? _selectedBankId;

  @override
  void initState() {
    super.initState();
    if (widget.manager.userBankIds.isNotEmpty) {
      _selectedBankId = widget.manager.userBankIds.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
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
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'What was this expense for?',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
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
            : (_descController.text.trim().isEmpty
                  ? 'Expense'
                  : _descController.text.trim()),
        type: widget.type,
        date: DateTime.now(),
        note: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
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
