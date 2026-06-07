import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'models/bank.dart';
import 'models/transaction.dart';
import 'models/note.dart';
import 'models/goal.dart';
import 'models/todo_item.dart';
import 'logic/transaction_manager.dart';

part 'theme.dart';
part 'utils.dart';
part 'screens/home.dart';
part 'screens/transfer.dart';
part 'screens/plan/plan_page.dart';
part 'screens/plan/notes_tab.dart';
part 'screens/plan/goals_tab.dart';
part 'screens/plan/todos_tab.dart';
part 'screens/plan/plan_common.dart';
part 'screens/settings.dart';
part 'screens/profile.dart';
part 'screens/onboarding.dart';
part 'widgets/transaction_input_sheet.dart';
part 'widgets/budget_planner_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge: app draws behind system bars, but back/home/recents
  // remain visible and tappable. Status + nav bars get transparent
  // backgrounds so the app's color flows under them seamlessly.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Use bundled font files; never reach out to the network at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Curl',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(_manager.themeMode),
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
      PlanPage(manager: widget.manager),
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
              icon: Icon(Icons.checklist_outlined),
              activeIcon: Icon(Icons.checklist_rounded),
              label: 'Plan',
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
