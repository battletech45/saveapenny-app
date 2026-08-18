import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

class NavigationHubItem {
  const NavigationHubItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class NavigationHubScreen extends StatelessWidget {
  const NavigationHubScreen({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<NavigationHubItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView.separated(
          key: ValueKey(Theme.of(context).brightness),
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final item = items[index];

            return Card(
              child: ListTile(
                onTap: item.onTap,
                leading: Icon(
                  item.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(item.label, style: context.textTheme.body),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          },
        ),
      ),
    );
  }
}
