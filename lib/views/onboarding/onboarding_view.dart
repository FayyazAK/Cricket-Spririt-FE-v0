import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../app/app_state.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Welcome to Cricket Spirit',
      description: 'Track your passion for the game with a clean, modern look.',
      icon: Icons.sports_cricket_outlined,
    ),
    _OnboardingSlide(
      title: 'Sharpen Your Skills',
      description: 'Log drills, monitor progress, and celebrate improvements.',
      icon: Icons.show_chart_outlined,
    ),
    _OnboardingSlide(
      title: 'Stay Connected',
      description: 'Share milestones with teammates and keep the spirit alive.',
      icon: Icons.groups_outlined,
    ),
    _OnboardingSlide(
      title: 'Ready to Play?',
      description: 'Jump in and explore the app tailored for cricket lovers.',
      icon: Icons.emoji_events_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    appState.completeOnboarding();
  }

  void _next() {
    if (_currentPage == _slides.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: CricketSpiritColors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: CricketSpiritColors.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: CricketSpiritColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 8,
                      width: isActive ? 24 : 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? CricketSpiritColors.primary
                            : CricketSpiritColors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child:
                      Text(_currentPage == _slides.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

