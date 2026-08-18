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

/// The landing screen for the Money/Plan/Portfolio/More bottom-nav tabs — a
/// card grid of destinations, each with its own tinted icon tile.
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
        child: GridView.builder(
          key: ValueKey(Theme.of(context).brightness),
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.15,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final color = ChartPalette.forIndex(
              Theme.of(context).brightness == Brightness.dark
                  ? ChartPalette.dark
                  : ChartPalette.light,
              index,
            );

            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Icon(item.icon, color: color),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        item.label,
                        style: context.textTheme.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
