import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/onboarding/application/onboarding_controller.dart';
import 'package:saveapenny/features/onboarding/presentation/onboarding_page.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.headlineKey,
    required this.bodyKey,
  });

  final IconData icon;
  final String headlineKey;
  final String bodyKey;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.account_balance_wallet_outlined,
      headlineKey: 'onboardingPage1Headline',
      bodyKey: 'onboardingPage1Body',
    ),
    _OnboardingPageData(
      icon: Icons.flag_outlined,
      headlineKey: 'onboardingPage2Headline',
      bodyKey: 'onboardingPage2Body',
    ),
    _OnboardingPageData(
      icon: Icons.insights_outlined,
      headlineKey: 'onboardingPage3Headline',
      bodyKey: 'onboardingPage3Body',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _page == _pages.length - 1;

    String headlineFor(_OnboardingPageData data) {
      switch (data.headlineKey) {
        case 'onboardingPage1Headline':
          return l10n.onboardingPage1Headline;
        case 'onboardingPage2Headline':
          return l10n.onboardingPage2Headline;
        case 'onboardingPage3Headline':
          return l10n.onboardingPage3Headline;
        default:
          return '';
      }
    }

    String bodyFor(_OnboardingPageData data) {
      switch (data.headlineKey) {
        case 'onboardingPage1Headline':
          return l10n.onboardingPage1Body;
        case 'onboardingPage2Headline':
          return l10n.onboardingPage2Body;
        case 'onboardingPage3Headline':
          return l10n.onboardingPage3Body;
        default:
          return '';
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: <Widget>[
                  for (final page in _pages)
                    OnboardingPage(
                      icon: page.icon,
                      headline: headlineFor(page),
                      body: bodyFor(page),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (var i = 0; i < _pages.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          width: i == _page ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? context.colors.textPrimary
                                : context.colors.border,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: <Widget>[
                      if (!isLast)
                        TextButton(
                          onPressed: () => _complete(context),
                          child: Text(l10n.onboardingSkip),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => isLast
                            ? _complete(context)
                            : _controller.nextPage(
                                duration: AppDuration.base,
                                curve: Curves.easeInOutCubic,
                              ),
                        child: Text(
                          isLast
                              ? l10n.onboardingGetStarted
                              : l10n.commonContinue,
                        ),
                      ),
                    ],
                  ),
                ],
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
