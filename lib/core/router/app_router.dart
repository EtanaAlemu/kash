import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/add_expense/add_expense_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/vault/manage_categories_screen.dart';
import '../../features/vault/vault_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _analyticsKey = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _vaultKey = GlobalKey<NavigatorState>(debugLabel: 'vault');

GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _analyticsKey,
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _vaultKey,
            routes: [
              GoRoute(
                path: '/vault',
                builder: (context, state) => const VaultScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/add',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/edit/:id',
        builder: (context, state) => AddExpenseScreen(
          transactionId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/vault/categories',
        builder: (context, state) => const ManageCategoriesScreen(),
      ),
    ],
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
