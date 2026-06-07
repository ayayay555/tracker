// Plan > Goals tab + goal editor.
part of '../../main.dart';

class _GoalsTab extends StatelessWidget {
  final TransactionManager manager;
  final VoidCallback onChange;
  const _GoalsTab({required this.manager, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goals = manager.goals;

    if (goals.isEmpty) {
      return _emptyState(
        theme,
        Icons.flag_outlined,
        'No goals yet',
        'Tap + to set your first savings goal',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Dismissible(
          key: Key(goal.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) async {
            await manager.deleteGoal(goal.id);
            onChange();
          },
          child: GestureDetector(
            onTap: () => _showGoalEditor(context, manager, goal, onChange),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (goal.isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Reached',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱${goal.savedAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'of ₱${goal.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  ),
                  if (goal.deadline != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDeadline(goal.deadline!),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showGoalEditor(BuildContext context, TransactionManager manager, Goal? existing, VoidCallback onChange) {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final targetCtrl = TextEditingController(text: existing?.targetAmount.toStringAsFixed(0) ?? '');
  final savedCtrl = TextEditingController(text: existing?.savedAmount.toStringAsFixed(0) ?? '0');
  final addCtrl = TextEditingController();
  DateTime? deadline = existing?.deadline;

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
                  existing == null ? 'New Goal' : 'Edit Goal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                _planFieldLabel(theme, 'Title'),
                _planTextField(theme, titleCtrl, 'e.g. New laptop'),
                const SizedBox(height: 16),
                _planFieldLabel(theme, 'Target Amount (₱)'),
                _planTextField(theme, targetCtrl, '50000', isNumber: true),
                const SizedBox(height: 16),
                if (existing != null) ...[
                  _planFieldLabel(theme, 'Add to savings (₱)'),
                  Row(
                    children: [
                      Expanded(child: _planTextField(theme, addCtrl, '0', isNumber: true)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final amt = double.tryParse(addCtrl.text);
                          if (amt != null && amt > 0) {
                            await manager.contributeToGoal(existing.id, amt);
                            addCtrl.clear();
                            savedCtrl.text = manager.goals.firstWhere((g) => g.id == existing.id).savedAmount.toStringAsFixed(0);
                            setSheetState(() {});
                            onChange();
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
                  const SizedBox(height: 16),
                  _planFieldLabel(theme, 'Saved (₱) — adjust manually'),
                  _planTextField(theme, savedCtrl, '0', isNumber: true),
                  const SizedBox(height: 16),
                ],
                _planFieldLabel(theme, 'Deadline (optional)'),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: deadline ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                          );
                          if (picked != null) {
                            setSheetState(() => deadline = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              const SizedBox(width: 8),
                              Text(
                                deadline == null ? 'No deadline' : _formatDeadline(deadline!),
                                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (deadline != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setSheetState(() => deadline = null),
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final target = double.tryParse(targetCtrl.text);
                      final saved = double.tryParse(savedCtrl.text) ?? 0;
                      if (title.isEmpty || target == null || target <= 0) return;
                      if (existing == null) {
                        await manager.addGoal(Goal(
                          title: title,
                          targetAmount: target,
                          savedAmount: saved,
                          deadline: deadline,
                        ));
                      } else {
                        await manager.updateGoal(
                          existing.id,
                          title: title,
                          targetAmount: target,
                          savedAmount: saved,
                          deadline: deadline,
                          clearDeadline: deadline == null,
                        );
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
                      existing == null ? 'Save Goal' : 'Update Goal',
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

// --- TODOS TAB ---

