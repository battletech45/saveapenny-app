import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: l10n.navTransactions,
            ),
            NavigationDestination(
              icon: const Icon(Icons.flag_outlined),
              selectedIcon: const Icon(Icons.flag_rounded),
              label: l10n.navPlan,
            ),
            NavigationDestination(
              icon: const Icon(Icons.trending_up_outlined),
              selectedIcon: const Icon(Icons.trending_up_rounded),
              label: l10n.navPortfolio,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz_outlined),
              selectedIcon: const Icon(Icons.more_horiz_rounded),
              label: l10n.navMore,
            ),
          ],
        ),
      ),
    );
  }
}
