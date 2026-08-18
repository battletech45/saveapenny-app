import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

/// A shimmering placeholder block, for use where the eventual content's
/// shape is known (a list row, a card) so loading reads as "content is
/// arriving" rather than a blocking spinner. Falls back to [LoadingView] for
/// full-page loads of unknown shape.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.surfaceSubtle;
    final highlight = context.colors.border;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1 - 2 * t, 0),
              end: Alignment(1 - 2 * t + 2, 0),
              colors: <Color>[base, highlight, base],
              stops: const <double>[0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              borderRadius:
                  widget.borderRadius ?? BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton shaped like a standard list row (leading circle + two lines +
/// trailing value) — matches the app's common transaction/account/budget row
/// layout.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          SkeletonBox(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(width: 120),
                SizedBox(height: AppSpacing.xs),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          SkeletonBox(width: 56, height: 16),
        ],
      ),
    );
  }
}

/// A skeleton shaped like a standard card (title + a couple of value rows) —
/// matches budget/goal/account card layouts.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SkeletonBox(width: 140, height: 18),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 8),
            SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                SkeletonBox(width: 72, height: 32),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 72, height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of [count] skeleton rows, for a screen whose eventual
/// content is a `ListView` of [SkeletonListTile] or [SkeletonCard].
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6, this.asCards = false});

  final int count;
  final bool asCards;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: count,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) =>
          asCards ? const SkeletonCard() : const SkeletonListTile(),
    );
  }
}
