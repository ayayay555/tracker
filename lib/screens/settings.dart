// Settings screen: theme switching.
part of '../main.dart';

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

