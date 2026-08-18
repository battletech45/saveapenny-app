import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps a screen so its floating action button hides while the body's
/// primary scrollable is actually moving its offset downward, and reappears
/// once it moves back up. A page that reports scroll notifications without
/// its offset actually changing — content that fits the viewport, or
/// overscroll/bounce at an edge — leaves the FAB alone.
///
/// Usage:
/// ```dart
/// return ScrollAwareFabVisibility(
///   builder: (context, fabVisible) => Scaffold(
///     floatingActionButton: ScrollAwareFab(
///       visible: fabVisible,
///       child: FloatingActionButton(...),
///     ),
///     body: ...,
///   ),
/// );
/// ```
class ScrollAwareFabVisibility extends StatefulWidget {
  const ScrollAwareFabVisibility({super.key, required this.builder});

  final Widget Function(BuildContext context, ValueListenable<bool> visible)
  builder;

  @override
  State<ScrollAwareFabVisibility> createState() =>
      _ScrollAwareFabVisibilityState();
}

class _ScrollAwareFabVisibilityState extends State<ScrollAwareFabVisibility> {
  static const double _offsetThreshold = 4;

  final ValueNotifier<bool> _visible = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    final metrics = notification.metrics;
    if (!metrics.hasContentDimensions || metrics.maxScrollExtent <= 0) {
      // Nothing to actually scroll (content fits the viewport) — never hide.
      _visible.value = true;
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta.abs() < _offsetThreshold) {
        return false;
      }
      _visible.value = delta < 0;
    } else if (notification is OverscrollNotification) {
      // Bounce past an edge isn't a real offset change; ignore it.
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.builder(context, _visible),
    );
  }
}

/// Animates [child] (a floating action button) away on scroll-down and back
/// on scroll-up, driven by the [visible] notifier from an ancestor
/// [ScrollAwareFabVisibility].
class ScrollAwareFab extends StatelessWidget {
  const ScrollAwareFab({super.key, required this.visible, required this.child});

  final ValueListenable<bool> visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (context, isVisible, child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          offset: isVisible ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isVisible ? 1 : 0,
            child: IgnorePointer(ignoring: !isVisible, child: child),
          ),
        );
      },
      child: child,
    );
  }
}
