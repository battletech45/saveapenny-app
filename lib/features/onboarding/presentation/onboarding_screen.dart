import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/onboarding/application/onboarding_controller.dart';
import 'package:saveapenny/features/onboarding/presentation/onboarding_page.dart';
import 'package:saveapenny/features/onboarding/presentation/onboarding_page_data.dart';
import 'package:saveapenny/features/onboarding/presentation/widgets/onboarding_footer.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = onboardingPages(l10n);
    final isLast = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: <Widget>[
                  for (final page in pages)
                    OnboardingPage(
                      icon: page.icon,
                      headline: page.headline,
                      body: page.body,
                    ),
                ],
              ),
            ),
            OnboardingFooter(
              pageCount: pages.length,
              currentPage: _page,
              isLast: isLast,
              onSkip: () => _complete(context),
              onContinue: () => isLast
                  ? _complete(context)
                  : _controller.nextPage(
                      duration: AppDuration.base,
                      curve: Curves.easeInOutCubic,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context) async {
    await ref.read(onboardingControllerProvider.notifier).markOnboarded();
    if (context.mounted) {
      GoRouter.of(context).go('/home');
    }
  }
}
