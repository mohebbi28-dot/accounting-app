import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/ledger_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String accounts = '/accounts';
  static const String journal = '/journal';
  static const String ledger = '/ledger';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case accounts:
        return MaterialPageRoute(builder: (_) => const AccountsScreen());
      case journal:
        return MaterialPageRoute(builder: (_) => const JournalScreen());
      case ledger:
        return MaterialPageRoute(builder: (_) => const LedgerScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('صفحه‌ای برای ${settings.name} یافت نشد'),
            ),
          ),
        );
    }
  }
}
