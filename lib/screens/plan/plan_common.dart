// Shared widgets + date formatters for the Plan tabs.
part of '../../main.dart';

Widget _emptyState(ThemeData theme, IconData icon, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          child: Icon(icon, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );
}

Widget _planFieldLabel(ThemeData theme, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 0.3,
      ),
    ),
  );
}

Widget _planTextField(ThemeData theme, TextEditingController controller, String hint, {bool isNumber = false}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    ),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      return diff.inMinutes <= 1 ? 'just now' : '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatDeadline(DateTime date) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final daysLeft = date.difference(DateTime.now()).inDays;
  final formatted = '${months[date.month - 1]} ${date.day}, ${date.year}';
  if (daysLeft < 0) return '$formatted (overdue)';
  if (daysLeft == 0) return '$formatted (today)';
  if (daysLeft <= 30) return '$formatted ($daysLeft days left)';
  return formatted;
}

// --- ONBOARDING ---

