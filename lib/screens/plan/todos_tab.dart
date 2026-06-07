// Plan > To-Dos tab + todo editor.
part of '../../main.dart';

class _TodosTab extends StatelessWidget {
  final TransactionManager manager;
  final VoidCallback onChange;
  const _TodosTab({required this.manager, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todos = manager.todos;

    if (todos.isEmpty) {
      return _emptyState(
        theme,
        Icons.task_alt_rounded,
        'No to-dos yet',
        'Tap + to add a spending plan',
      );
    }

    final pending = todos.where((t) => !t.completed).toList();
    final done = todos.where((t) => t.completed).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        ...pending.map((t) => _todoTile(context, t, theme)),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              'Completed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...done.map((t) => _todoTile(context, t, theme)),
        ],
      ],
    );
  }

  Widget _todoTile(BuildContext context, TodoItem todo, ThemeData theme) {
    final bank = Bank.phBanks.firstWhere(
      (b) => b.id == todo.bankId,
      orElse: () => Bank(id: todo.bankId, name: todo.bankId.toUpperCase(), type: BankType.traditional),
    );
    final balance = manager.getBankBalance(todo.bankId);
    final canAfford = balance >= todo.cost;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await manager.deleteTodo(todo.id);
        onChange();
      },
      child: GestureDetector(
        onTap: () {
          if (todo.completed) return;
          _showTodoEditor(context, manager, todo, onChange);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (todo.completed) {
                    await manager.uncompleteTodo(todo.id);
                    onChange();
                  } else {
                    final ok = await manager.completeTodo(todo.id);
                    if (!ok) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Not enough balance in ${bank.name}'),
                            behavior: SnackBarBehavior.floating,
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } else {
                      onChange();
                    }
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.completed
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: todo.completed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: todo.completed
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        decoration: todo.completed ? TextDecoration.lineThrough : null,
                        decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          bank.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        if (!todo.completed && !canAfford) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'short',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₱${todo.cost.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: todo.completed
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTodoEditor(BuildContext context, TransactionManager manager, TodoItem? existing, VoidCallback onChange) {
  if (manager.userBankIds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add a bank first in onboarding/settings'),
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
      ),
    );
    return;
  }

  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final costCtrl = TextEditingController(text: existing?.cost.toStringAsFixed(0) ?? '');
  String bankId = existing?.bankId ?? manager.userBankIds.first;
  if (!manager.userBankIds.contains(bankId)) bankId = manager.userBankIds.first;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  existing == null ? 'New To-Do' : 'Edit To-Do',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                _planFieldLabel(theme, 'What for?'),
                _planTextField(theme, titleCtrl, 'e.g. Pay GCash bill'),
                const SizedBox(height: 16),
                _planFieldLabel(theme, 'Cost (₱)'),
                _planTextField(theme, costCtrl, '500', isNumber: true),
                const SizedBox(height: 16),
                _planFieldLabel(theme, 'Source bank'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: bankId,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurface),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      dropdownColor: theme.cardColor,
                      items: manager.userBankIds.map((id) {
                        final bank = Bank.phBanks.firstWhere(
                          (b) => b.id == id,
                          orElse: () => Bank(id: id, name: id.toUpperCase(), type: BankType.traditional),
                        );
                        final balance = manager.getBankBalance(id);
                        return DropdownMenuItem(
                          value: id,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text(bank.name, overflow: TextOverflow.ellipsis)),
                                Text(
                                  '₱${balance.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setSheetState(() => bankId = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final cost = double.tryParse(costCtrl.text);
                      if (title.isEmpty || cost == null || cost <= 0) return;
                      if (existing == null) {
                        await manager.addTodo(TodoItem(
                          title: title,
                          cost: cost,
                          bankId: bankId,
                        ));
                      } else {
                        await manager.updateTodo(existing.id, title: title, cost: cost, bankId: bankId);
                      }
                      onChange();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      existing == null ? 'Save To-Do' : 'Update To-Do',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// --- PLAN HELPERS ---

